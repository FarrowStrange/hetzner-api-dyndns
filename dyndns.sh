#!/bin/bash
# DynDNS Script for Hetzner DNS API by FarrowStrange
# v1.1

# get OS environment variables
auth_api_token=${HETZNER_AUTH_API_TOKEN:-'<your-hetzner-dns-api-token>'}

zone_name=${HETZNER_ZONE_NAME:-''}
zone_id=${HETZNER_ZONE_ID:-''}

record_name=${HETZNER_RECORD_NAME:-''}
record_ttl=${HETZNER_RECORD_TTL:-'60'}
record_type=${HETZNER_RECORD_TYPE:-'A'}

display_help() {
  cat <<EOF

exec: ./dyndns.sh [ -z <Zone ID> | -Z <Zone Name> ] -r <Record ID> -n <Record Name>

parameters:
  -z  - Zone ID
  -Z  - Zone name
  -r  - Record ID
  -n  - Record name

optional parameters:
  -t  - TTL (Default: 60)
  -T  - Record type (Default: A)

help:
  -h  - Show Help 

requirements:
jq is required to run this scriptcd .

example:
  .exec: ./dyndns.sh -z 98jFjsd8dh1GHasdf7a8hJG7 -r AHD82h347fGAF1 -n dyn
  .exec: ./dyndns.sh -Z example.com -n dyn -T AAAA

EOF
  exit 1
}

logger() {
  echo ${1}: Record_Name: ${record_name} : ${2}
}
while getopts ":z:Z:r:n:t:T:h" opt; do
  case "$opt" in
    z  ) zone_id="${OPTARG}";;
    Z  ) zone_name="${OPTARG}";;
    r  ) record_id="${OPTARG}";;
    n  ) record_name="${OPTARG}";;
    t  ) record_ttl="${OPTARG}";;
    T  ) record_type="${OPTARG}";;
    h  ) display_help;;
    \? ) echo "Invalid option: -$OPTARG" >&2; exit 1;;
    :  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
    *  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
  esac
done

# Check if jq is installed
if ! command -v jq &> /dev/null; then
  logger Error "To run the script 'jq' is needed, but it seems not to be installed."
  logger Error "Please check 'https://github.com/FarrowStrange/hetzner-api-dyndns#install-jq' and try again."
  exit 1
fi

# Check if api token is set 
if [[ "${auth_api_token}" = "" ]]; then
  logger Error "No Auth API Token specified. Please reference at the top of the Script."
  exit 1
fi

# get all zones
zone_info=$(curl -s --location \
          "https://dns.hetzner.com/api/v1/zones" \
          --header 'Auth-API-Token: '${auth_api_token})

# check if either zone_id or zone_name is correct
if [[ "$(echo ${zone_info} | jq --raw-output '.zones[] | select(.name=="'${zone_name}'") | .id')" = "" && "$(echo ${zone_info} | jq --raw-output '.zones[] | select(.id=="'${zone_id}'") | .name')" = "" ]]; then
  logger Error "Something went wrong. Could not find Zone ID."
  logger Error "Check your inputs of either -z <Zone ID> or -Z <Zone Name>."
  logger Error "Use -h to display help."
  exit 1
fi

# get zone_id if zone_name is given and in zones
if [[ "${zone_id}" = "" ]]; then
  zone_id=$(echo ${zone_info} | jq --raw-output '.zones[] | select(.name=="'${zone_name}'") | .id')
fi

# get zone_name if zone_id is given and in zones
if [[ "${zone_name}" = "" ]]; then
  zone_name=$(echo ${zone_info} | jq --raw-output '.zones[] | select(.id=="'${zone_id}'") | .name')
fi

logger Info "Zone_ID: ${zone_id}"
logger Info "Zone_Name: ${zone_name}"

if [[ "${record_name}" = "" ]]; then
  logger Error "Mission option for record name: -n <Record Name>"
  logger Error "Use -h to display help."
  exit 1
fi

# get current public ip address
if [[ "${record_type}" = "AAAA" ]]; then
  logger Info "Using IPv6 as AAAA record is to be set."
  cur_pub_addr=$(dig -6 ch TXT +short whoami.cloudflare @2606:4700:4700::1111 | awk -F '"' '{print $2}')
  if [[ "${cur_pub_addr}" = "" ]]; then
    logger Error "It seems you don't have a IPv6 public address."
    exit 1
  else
    logger Info "Current public IP address: ${cur_pub_addr}"
  fi
elif [[ "${record_type}" = "A" ]]; then
  logger Info "Using IPv4 as record type ${record_type} is not explicitly AAAA."
  cur_pub_addr=$(dig -4 ch TXT +short whoami.cloudflare @1.1.1.1 | awk -F '"' '{print $2}')
  if [[ "${cur_pub_addr}" = "" ]]; then
    logger Error "Apparently there is a problem in determining the public ip address."
    exit 1
  else
    logger Info "Current public IP address: ${cur_pub_addr}"
  fi
else 
  logger Error "Only record type \"A\" or \"AAAA\" are support for DynDNS."
  exit 1
fi

# get record id if not given as parameter
if [[ "${record_id}" = "" ]]; then
    record_id=$(curl -s --location \
                   --request GET 'https://dns.hetzner.com/api/v1/records?zone_id='${zone_id} \
                   --header 'Auth-API-Token: '${auth_api_token} | \
                   jq --raw-output '.records[] | select(.type == "'${record_type}'") | select(.name == "'${record_name}'") | .id')
fi 

logger Info "Record_ID: ${record_id}"

# create a new record
if [[ "${record_id}" = "" ]]; then
    echo "DNS record \"${record_name}\" does not exists - will be created."
    curl -s -X "POST" "https://dns.hetzner.com/api/v1/records" \
         -H 'Content-Type: application/json' \
         -H 'Auth-API-Token: '${auth_api_token} \
         -d $'{
            "value": "'${cur_pub_addr}'",
            "ttl": '${record_ttl}',
            "type": "'${record_type}'",
            "name": "'${record_name}'",
            "zone_id": "'${zone_id}'"
          }'
else
# check if update is needed
    cur_dyn_addr=`curl -s "https://dns.hetzner.com/api/v1/records/${record_id}" -H 'Auth-API-Token: '${auth_api_token} | jq --raw-output '.record.value'`

logger Info "Currently set IP address: ${cur_dyn_addr}"

# update existing record
    if [[ $cur_pub_addr == $cur_dyn_addr ]]; then
        logger Info "DNS record \"${record_name}\" is up to date - nothing to to."
        exit 0
    else
        echo "DNS record \"${record_name}\" is no longer valid - updating record" 
        curl -s -X "PUT" "https://dns.hetzner.com/api/v1/records/${record_id}" \
             -H 'Content-Type: application/json' \
             -H 'Auth-API-Token: '${auth_api_token} \
             -d $'{
               "value": "'${cur_pub_addr}'",
               "ttl": '${record_ttl}',
               "type": "'${record_type}'",
               "name": "'${record_name}'",
               "zone_id": "'${zone_id}'"
             }'
        if [[ $? != 0 ]]; then
            logger Error "Unable to update record: \"${record_name}\""
        else
            logger Info "DNS record \"${record_name}\" updated successfully"
        fi
    fi
fi
