FROM alpine:3.16.0

RUN apk update && apk add \
	bash \
	ca-certificates \
	curl

COPY scripts/whishper.sh /usr/local/bin/whishper.sh

ENTRYPOINT ["/usr/local/bin/whishper.sh", "whishper"]