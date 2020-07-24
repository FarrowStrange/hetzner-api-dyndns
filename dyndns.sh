#!/bin/bash
# DynDNS Script for Hetzner API by FarrowStrange
# V0.1

api_auth_token=
api_zone=
api_record=

pub_addr=`curl -s ifconfig.me`
api_dyn_addr=`curl -s "https://dns.hetzner.com/api/v1/records/${api_record}" -H 'Auth-API-Token: '${api_auth_token} | cut -d ',' -f 4 | cut -d '"' -f 4`

if [[ $pub_addr == $api_dyn_addr ]]; then
  echo "DNS record is up to date - nothing to to."

else
  echo "DNS record is no longer valid - updating record" 


  curl -s -X "PUT" "https://dns.hetzner.com/api/v1/records/${api_record}" \
    -H 'Content-Type: application/json' \
    -H 'Auth-API-Token: '${api_auth_token} \
    -d $'{
      "value": "'${pub_addr}'",
      "ttl": 60,
      "type": "A",
      "name": "gw",
      "zone_id": "'${api_zone}'"
    }'

  if [[ $? != 0 ]]; then
    echo "Unable to update record"
  else
    echo "DNS record updated successfully"
  fi
fi