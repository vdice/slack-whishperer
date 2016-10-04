#!/usr/bin/env bats

setup() {
  . "${BATS_TEST_DIRNAME}/../scripts/whishper.sh"
  load stub
  stub curl
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
