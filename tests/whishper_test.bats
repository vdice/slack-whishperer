#!/usr/bin/env bats

setup() {
  load stub
  stub curl "echo '200'" 0
  stub jq "echo '{\"text\":\"test\nmessage\"}'" 0

  export SLACK_INCOMING_WEBHOOK_URL=mysecretslackwebhookurl
  USAGE='Usage: SLACK_INCOMING_WEBHOOK_URL=topsecret whishper.sh path/to/message'
}

teardown() {
  rm_stubs
}

strip-ws() {
  echo -e "${1}" | tr -d '[[:space:]]'
}

@test "whishper: happy path" {
  message_file="$(mktemp)"

  run ./scripts/whishper.sh "${message_file}"

  expected_data='
    {"text":"test\nmessage"}
  '

  expected_output='
    Notifying Slack with the following data:
    '${expected_data}'
    Message successfully whishpered!
  '

  [ "${status}" -eq 0 ]
  [ "$(strip-ws "${output}")" == "$(strip-ws "${expected_output}")" ]
}

@test "whishper: sad path: curl fails" {
  message_file="$(mktemp)"

  stub curl "echo 'curl: (22) The requested URL returned error: 404'" 22

  run ./scripts/whishper.sh "${message_file}"

  expected_data='
    {"text":"test\nmessage"}
  '

  expected_output='
    Notifying Slack with the following data:
    '${expected_data}'
    Message failed to be whishpered :(
  '

  [ "${status}" -eq 1 ]
  [ "$(strip-ws "${output}")" == "$(strip-ws "${expected_output}")" ]
}

@test "whishper: sad path: unexpected http code" {
  message_file="$(mktemp)"

  stub curl "echo '302'" 0

  run ./scripts/whishper.sh "${message_file}"

  expected_data='
    {"text":"test\nmessage"}
  '

  expected_output='
    Notifying Slack with the following data:
    '${expected_data}'
    Unexpected HTTP Code (302); please check webhook url and try again
  '

  [ "${status}" -eq 1 ]
  [ "$(strip-ws "${output}")" == "$(strip-ws "${expected_output}")" ]
}

@test "whishper: sad path: can't read message" {
  run ./scripts/whishper.sh no-exist

  expected_output="cat: can't open 'no-exist': No such file or directory"

  [ "${status}" -eq 1 ]
  [ "$(strip-ws "${output}")" == "$(strip-ws "${expected_output}")" ]
}

@test "whishper: necessary vars: no SLACK_INCOMING_WEBHOOK_URL" {
  unset SLACK_INCOMING_WEBHOOK_URL

  run ./scripts/whishper.sh

  expected_output='
    Missing SLACK_INCOMING_WEBHOOK_URL in env
    '${USAGE}'
  '

  [ "${status}" -eq 1 ]
  [ "$(strip-ws "${output}")" == "$(strip-ws "${expected_output}")" ]
}

@test "whishper: necessary vars: no message" {
  run ./scripts/whishper.sh

  expected_output='
    A path to the message file needs to be provided
    '${USAGE}'
  '

  [ "${status}" -eq 1 ]
  [ "$(strip-ws "${output}")" == "$(strip-ws "${expected_output}")" ]
}
