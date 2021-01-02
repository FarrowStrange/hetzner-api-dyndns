# Hetzner API DynDNS

A small script to dynamically update DNS records using the Hetzner DNS-API. Feel free to propose changes.

**Hetzner DNS API Doc:**

https://dns.hetzner.com/api-docs/

# Preparations

## Install jq
To query the API the small program [jq](https://stedolan.github.io/jq/) is used. Install it first following this [manual page](https://stedolan.github.io/jq/download/).

## Generate Access Token
First, a new access token must be created in the [Hetzner DNS Console](https://dns.hetzner.com/). This should be copied immediately, because for security reasons it will not be possible to display the token later. But you can generate as many tokens as you like.

# Usage
For security reasons, the access token is stored directly in the script. Enter your previously created token here.
```
...
auth_api_token=''
...
```

As soon as the token is deposited, the script can be called with the appropriate parameters. This allows several DynDNS records to be created in different zones. Optionally, the TTL and the record type can be specified. It is advisable to keep the TTL as low as possible, so that changed records are used as soon as possible.
```
./dyndns.sh [ -z <Zone ID> | -Z <zone_name> ] [-r <Record ID>] -n <Record Name> [-t <TTL>] [-T <Record Type>]
```

To keep your DynDNS Records up to date, you have to create a cronjob that calls the script periodically. 

**Example:** Check every 5 Minutes and update if necessary.
```
*/5 * * * * /usr/bin/dyndns.sh -Z example.com -n dyn
```

# Help
Type `-h` to display help page.
```
./dyndns.sh -h
```
```
exec: ./dyndns.sh -Z <Zone Name> -n <Record Name>

parameters:
  -z  - Zone ID
  -Z  - Zone Name
  -r  - Record ID
  -n  - Record name

optional parameters:
  -t  - TTL (Default: 60)
  -T  - Record type (Default: A)

help:
  -h  - Show Help 

example:
  .exec: ./dyndns.sh -Z example.com -n dyn -T AAAA
  .exec: ./dyndns.sh -z 98jFjsd8dh1GHasdf7a8hJG7 -r AHD82h347fGAF1 -n dyn

``` 
# Additional stuff
## Get all Zones
If you want to get all zones in your account and check the desired zone ID.
```
curl "https://dns.hetzner.com/api/v1/zones" -H \
'Auth-API-Token: ${apitoken}' | jq
```
## Get a record ID
If you want to get a record ID manually you may use the following curl command.
```
curl -s --location \
    --request GET 'https://dns.hetzner.com/api/v1/records?zone_id='${zone_id} \
    --header 'Auth-API-Token: '${apitoken} | \
    jq --raw-output '.records[] | select(.type == "'${record_type}'") | select(.name == "'{record_name}'") | .id'
```
## Add Record manually
Use the previously obtained zone ID to create a dns record. 
In the output you get the record ID. This is needed for the script and should therefore be noted.
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
