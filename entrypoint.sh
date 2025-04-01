#!/bin/sh

# Run the DynDNS script continuously with the specified interval
while true; do
    /usr/local/bin/dyndns.sh
    sleep ${UPDATE_INTERVAL:-300}
done
