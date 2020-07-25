#!/bin/bash
# DynDNS Script for Hetzner API by FarrowStrange
# v1.0

record_ttl='60'
record_type='A'

display_help() {
  cat <<EOF
exec: ./dyndns.sh -a <Auth-API-Token> -z <Zone ID> -r <Record ID> -n <Record Name>

parameters:
  -a  - Auth-API-Token
  -z  - Zone ID
  -r  - Record ID
  -n  - Record name

optional parameters:
  -t  - TTL
  -T  - Type

help:
  -h  - Show Help 

example:
  .exec: ./dyndns.sh -a 234hj23S7d9asd213 -z 98jFjsd8dh1GH7 -r AHD82h347fGAF1 -n dyn
EOF
  exit 1
}

while getopts ":a:z:r:n:tT" opt; do
  case "$opt" in
    a )
      auth_api_token="${OPTARG}"
      ;;
    z )
      zone_id="${OPTARG}"
      ;;
    r )
     record_id="${OPTARG}"
      ;;
    n )
      record_name="${OPTARG}"
      ;;
    t )
      record_ttl="${OPTARG}"
      ;;
    T )
      record_type="${OPTARG}"
      ;;
    h )
      display_help
      ;;
  esac
done



pub_addr=`curl -s ifconfig.me`
api_dyn_addr=`curl -s "https://dns.hetzner.com/api/v1/records/${record_id}" -H 'Auth-API-Token: '${auth_api_token} | cut -d ',' -f 4 | cut -d '"' -f 4`

if [[ $pub_addr == $api_dyn_addr ]]; then
  echo "DNS record is up to date - nothing to to."
else
  echo "DNS record is no longer valid - updating record" 

  curl -s -X "PUT" "https://dns.hetzner.com/api/v1/records/${record_id}" \
    -H 'Content-Type: application/json' \
    -H 'Auth-API-Token: '${auth_api_token} \
    -d $'{
      "value": "'${pub_addr}'",
      "ttl": '${record_ttl}',
      "type": "'${record_type}'",
      "name": "'${record_name}'",
      "zone_id": "'${zone_id}'"
    }'

  if [[ $? != 0 ]]; then
    echo "Unable to update record"
  else
    echo "DNS record updated successfully"
  fi
fi