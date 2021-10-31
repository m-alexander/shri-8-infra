FROM alpine:3

RUN apk add jq curl

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
