#!/usr/bin/env bats

setup() {
  . "${BATS_TEST_DIRNAME}/../scripts/whishper.sh"
  load stub
  stub curl
  SLACK_INCOMING_WEBHOOK_URL=mysecretslackwebhookurl
  USAGE='Usage: SLACK_INCOMING_WEBHOOK_URL=topsecret whishper.sh <channel> <message>'
}

teardown() {
  rm_stubs
}

strip-ws() {
  echo -e "${1}" | tr -d '[[:space:]]'
}

@test "whishper" {
  channel="test-channel"
  message="test-message"

  run whishper "${channel}" "${message}"

  expected_data='
    {"channel":"'"${channel}"'",
    "text":"'"${message}"'"}
  '

  expected_output='
    Notifying Slack with the following data:
    '${expected_data}'
  '

  [ "${status}" -eq 0 ]
  [ "$(strip-ws "${output}")" == "$(strip-ws "${expected_output}")" ]
}

@test "whishper: necessary vars: no SLACK_INCOMING_WEBHOOK_URL" {
  unset SLACK_INCOMING_WEBHOOK_URL

  run whishper

  expected_output='
    Missing SLACK_INCOMING_WEBHOOK_URL in env
    '${USAGE}'
  '

  [ "${status}" -eq 1 ]
  [ "$(strip-ws "${output}")" == "$(strip-ws "${expected_output}")" ]
}

@test "whishper: necessary vars: no channel" {
  run whishper

  expected_output='
    Missing channel in env
    '${USAGE}'
  '

  [ "${status}" -eq 1 ]
  [ "$(strip-ws "${output}")" == "$(strip-ws "${expected_output}")" ]
}

@test "whishper: necessary vars: no message" {
  channel="test-channel"

  run whishper "${channel}"

  expected_output='
    Missing message in env
    '${USAGE}'
  '

  [ "${status}" -eq 1 ]
  [ "$(strip-ws "${output}")" == "$(strip-ws "${expected_output}")" ]
}
