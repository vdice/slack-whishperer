#!/usr/bin/env bash
set -eo pipefail

# whishper sends the provided message to the provided slack channel
# using the incoming-webhook url expected to be defined in the job environment
whishper() {
  channel="${1}"
  message="${2}"

  data='
    {"channel":"'"${channel}"'",
    "text":"'"${message}"'"}
  '

  { echo "Notifying Slack with the following data:"; \
    echo "${data}"; } >&2

  curl \
    -X POST -H 'Content-type: application/json' \
    --data "${data}" \
    "${SLACK_INCOMING_WEBHOOK_URL}"
}
