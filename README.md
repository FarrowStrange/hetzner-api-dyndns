# Hetzner API DynDNS

A small script to dynamically update DNS records using the Hetzner DNS-API. Feel free to propose changes.

**Hetzner DNS API Doc**

https://dns.hetzner.com/api-docs/

# Preparations
## Generate Access Token
First, a new access token must be created in the DNS Console. This should be copied immediately, because for security reasons it will not be possible to display the token later. 

## Get all Zones
Get all zones and copy zone ID 
```
curl "https://dns.hetzner.com/api/v1/zones" -H \
'Auth-API-Token: ${apitoken}'
```

## Add Record
Use the previously obtained zone id to create a dns record. 
In the output you get the record ID. This is needed in the script and should therefore be noted.
```
curl -X "POST" "https://dns.hetzner.com/api/v1/records" \
     -H 'Content-Type: application/json' \
     -H 'Auth-API-Token: ${apitoken}' \
     -d $'{
  "value": "${yourpublicip}",
  "ttl": 60,
  "type": "A",
  "name": "dyn",
  "zone_id": "${zoneID}"
}'
```

# Usage
Insert the Access token and the Zone and Record ID in the script. 

To keep your DynDNS Records up to date, you create a cronjob that calls the script periodically. 
It is advisable to keep the TTL as low as possible, so that changed records are used as soon as possible.
```
api_auth_token=${apitoken}
api_zone=${zoneID}
api_record=${recordID}
```