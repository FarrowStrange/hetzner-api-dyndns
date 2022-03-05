#!/bin/sh
set -e

echo "adding cron job: $CRON_SCHEDULE dyndns.sh"
echo "
HETZNER_AUTH_API_TOKEN=\"$HETZNER_AUTH_API_TOKEN\"
HETZNER_ZONE_NAME=\"$HETZNER_ZONE_NAME\"
HETZNER_ZONE_ID=\"$HETZNER_ZONE_ID\"
HETZNER_RECORD_NAME=\"$HETZNER_RECORD_NAME\"
HETZNER_RECORD_ID=\"$HETZNER_HETZNER_RECORD_ID\"
HETZNER_RECORD_TTL=\"$HETZNER_RECORD_TTL\"
HETZNER_RECORD_TYPE=\"$HETZNER_RECORD_TYPE\"
$CRON_SCHEDULE dyndns.sh > /proc/1/fd/1 2>&1
" > /etc/cron.d/dyndns-cron
chmod 0744 /etc/cron.d/dyndns-cron

crontab /etc/cron.d/dyndns-cron

echo "done."

exec "$@"
