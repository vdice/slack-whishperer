#!/usr/bin/env bats

setup() {
  . "${BATS_TEST_DIRNAME}/../scripts/whishper.sh"
  load stub
  stub curl "echo '200'" 0

  SLACK_INCOMING_WEBHOOK_URL=mysecretslackwebhookurl
  USAGE='Usage: SLACK_INCOMING_WEBHOOK_URL=topsecret whishper.sh <channel> <message>'
}

teardown() {
  rm_stubs
}

strip-ws() {
  echo -e "${1}" | tr -d '[[:space:]]'
}

@test "whishper: happy path" {
  message="test message"

  run whishper "${message}"

  expected_data='
    {"text":"'"${message}"'"}
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
  message="test message"

  stub curl "echo 'curl: (22) The requested URL returned error: 404'" 22

  run whishper "${message}"

  expected_data='
    {"text":"'"${message}"'"}
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
  message="test message"

  stub curl "echo '302'" 0

  run whishper "${message}"

  expected_data='
    {"text":"'"${message}"'"}
  '

  expected_output='
    Notifying Slack with the following data:
    '${expected_data}'
    Unexpected HTTP Code (302); please check webhook url and try again
  '

  [ "${status}" -eq 1 ]
  [ "$(strip-ws "${output}")" == "$(strip-ws "${expected_output}")" ]
}

@test "whishper: necessary vars: no SLACK_INCOMING_WEBHOOK_URL" {
  unset SLACK_INCOMING_WEBHOOK_URL

  run whishper

  expected_output='
    Missing value for SLACK_INCOMING_WEBHOOK_URL
    '${USAGE}'
  '

  [ "${status}" -eq 1 ]
  [ "$(strip-ws "${output}")" == "$(strip-ws "${expected_output}")" ]
}

@test "whishper: necessary vars: no message" {
  run whishper

  expected_output='
    Missing value for message
    '${USAGE}'
  '

  [ "${status}" -eq 1 ]
  [ "$(strip-ws "${output}")" == "$(strip-ws "${expected_output}")" ]
}
