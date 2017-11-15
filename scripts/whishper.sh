#!/usr/bin/env bash

# whishper sends the provided message to the provided slack channel
# using the incoming-webhook url expected to be defined in the job environment
whishper() { 
  channel="${1}"
  message="${2}"

  for necessary_var in SLACK_INCOMING_WEBHOOK_URL channel message; do
    if [[ "${!necessary_var}" == "" ]]; then
      echo "Missing ${necessary_var} in env"
      usage
      return 1
    fi
  done

  data='
    {"channel":"'"${channel}"'",
    "text":"'"${message}"'"}
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
