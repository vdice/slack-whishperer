Slack-Whishperer
=====

*slack-whishperer* sends a provided `message` to a provided slack `channel`
using the incoming-webhook url expected to be defined in the job environment as `SLACK_INCOMING_WEBHOOK_URL`

Usage
______

```shell
source scripts/whishper.sh

export SLACK_INCOMING_WEBHOOK_URL=avocadosslackchannelwebhookurl

whishper '#avocados' 'Who brought the avocados?'
```

Dev
_____

Pre-reqs:

  * Docker

Get started:

```shell
make
```

