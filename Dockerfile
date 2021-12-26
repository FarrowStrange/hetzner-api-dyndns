FROM alpine

RUN apk add --no-cache bash curl bind-tools jq

COPY dyndns.sh /app/dyndns.sh

ENTRYPOINT [ "/app/dyndns.sh" ]
