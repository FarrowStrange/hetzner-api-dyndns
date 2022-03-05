FROM ubuntu:latest

RUN apt-get update && apt-get install -y curl dnsutils jq cron

COPY dyndns.sh /usr/bin/dyndns.sh
RUN chmod +x /usr/bin/dyndns.sh

COPY docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
RUN chmod +x /usr/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["cron", "-f", "-l", "2"]
