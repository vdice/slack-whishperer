#!/usr/bin/env bash
set -eo pipefail

# whishper sends the message contained in the provided path to the slack
# channel associated with the incoming-webhook url expected to be defined
# in the job environment
whishper() { 
  message_file="${1}"

  if [[ "${SLACK_INCOMING_WEBHOOK_URL}" == "" ]]; then
    echo "Missing SLACK_INCOMING_WEBHOOK_URL in env"
    usage
    return 1
  fi

  if [[ -z "${message_file}" ]]; then
    echo "A path to the message file needs to be provided"
    usage
    return 1
  fi

  message_text="$(cat "${message_file}")" || return 1

  tmpfile="$(mktemp)"
  jq \
    --null-input \
    --arg text "${message_text}" \
    '{"text": $text}' > "${tmpfile}"
  sed -i -e 's/\n/\\n/g' "${tmpfile}"

  { echo "Notifying Slack with the following data:"; \
    jq < "${tmpfile}"; } >&2

  cmd="
    curl -sSf \
      -o /dev/null \
      -w '%{http_code}\n' \
      -X POST \
      -H 'Content-type: application/json' \
      --data '@${tmpfile}' \
      ${SLACK_INCOMING_WEBHOOK_URL}
  "

  if ! status="$(eval "${cmd}")"; then
    echo "Message failed to be whishpered :(" >&2
    return 1
  fi

  if ! [[ "${status}" == '200' ]]; then
    echo "Unexpected HTTP Code (${status}); please check webhook url and try again" >&2
    return 1
  fi

  echo "Message successfully whishpered!" >&2
}

usage() {
  echo "Usage: SLACK_INCOMING_WEBHOOK_URL=topsecret whishper.sh path/to/message"
}

whishper "$@"
