Slack-Whishperer
=====

*slack-whishperer* sends a provided `message` to the slack channel
associated with the incoming-webhook url expected to be defined in the job environment as `SLACK_INCOMING_WEBHOOK_URL`

Usage
______

```shell
export SLACK_INCOMING_WEBHOOK_URL=avocadosslackchannelwebhookurl

scripts/whishper.sh whishper 'Who brought the avocados?'
```

Or, via Docker:

```shell
docker run \
  -e SLACK_INCOMING_WEBHOOK_URL="${SLACK_INCOMING_WEBHOOK_URL}" \
  ghcr.io/vdice/slack-whishperer:latest \
  'Who brought the avocados?'
```

Dev
_____

Pre-reqs:

  * Docker

Get started:

```shell
make
```

