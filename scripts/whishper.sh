#!/usr/bin/env bash
set -eo pipefail

# whishper sends the provided message to the slack channel associated with
# the incoming-webhook url expected to be defined in the job environment
whishper() { 
  message="${1}"

  for necessary_var in SLACK_INCOMING_WEBHOOK_URL message; do
    if [[ "${!necessary_var}" == "" ]]; then
      echo "Missing value for ${necessary_var}"
      usage
      return 1
    fi
  done

  data='
    {"text":"'"${message}"'"}
  '

  { echo "Notifying Slack with the following data:"; \
    echo "${data}"; } >&2

  cmd="
    curl -sSf \
      -o /dev/null \
      -w '%{http_code}\n' \
      -X POST -H 'Content-type: application/json' \
      --data '${data}' \
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
  echo "Usage: SLACK_INCOMING_WEBHOOK_URL=topsecret whishper.sh <channel> <message>"
}

"$@"
