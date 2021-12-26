# Hetzner API DynDNS

A small script to dynamically update DNS records using the Hetzner DNS-API. Feel free to propose changes.

**Hetzner DNS API Doc:**

https://dns.hetzner.com/api-docs/

# Preparations

## Install tools

- [`curl`](https://curl.se/)
- [`dig`](https://gitlab.isc.org/isc-projects/bind9/-/tree/main/bin/dig) (part of [BIND9](https://gitlab.isc.org/isc-projects/bind9)): usually packaged as `dnsutils` or `bind-tools`
- [`jq`](https://stedolan.github.io/jq/): [install](https://stedolan.github.io/jq/download/)

## Generate Access Token
First, a new access token must be created in the [Hetzner DNS Console](https://dns.hetzner.com/). This should be copied immediately, because for security reasons it will not be possible to display the token later. But you can generate as many tokens as you like.

# Usage
You store your Access Token either in the script or set it as an OS environment variable. To store it in the script replace `<your-hetzner-dns-api-token>` in the following line in the script.

```
...
auth_api_token=${HETZNER_AUTH_API_TOKEN:-'<your-hetzner-dns-api-token>'}
...
```

As soon as the token is deposited, the script can be called with the appropriate parameters. This allows several DynDNS records to be created in different zones. Optionally, the TTL and the record type can be specified. It is advisable to keep the TTL as low as possible, so that changed records are used as soon as possible.
```
./dyndns.sh [ -z <Zone ID> | -Z <zone_name> ] [-r <Record ID>] -n <Record Name> [-t <TTL>] [-T <Record Type>]
```

To keep your DynDNS Records up to date, you have to create a cronjob that calls the script periodically. 

**Examples:**
You have several possibilities to call the script. In these examples it is called periodically every 5 minutes and updates the DNS entry if necessary.

In the first example only the API token is passed as environment variable and the remaining information as parameters. This allows for example to set multiple DynDNS entries in different zones when the script is called multiple times with different parameters.
```
HETZNER_AUTH_API_TOKEN='<your-hetzner-dns-api-token>'

*/5 * * * * /usr/bin/dyndns.sh -Z example.com -n dyn
```

You can also pass all information as an environment variables to create a DynDNS entry.
```
HETZNER_AUTH_API_TOKEN='<your-hetzner-dns-api-token>'
HETZNER_ZONE_NAME='example.com'
HETZNER_RECORD_NAME='dyn'

*/5 * * * * /usr/bin/dyndns.sh
```

# OS Environment Variables

You can use the following enviroment variables.

|NAME                   | Value                            | Description                                                     |
|:----------------------|----------------------------------|:----------------------------------------------------------------|
|HETZNER_AUTH_API_TOKEN | 925bf046408b55c313740eef2bc18b1e | Your Hetzner API access token                                   |
|HETZNER_ZONE_NAME      | example.com                      | The zone name                                                   |
|HETZNER_ZONE_ID        | DaGaoE6YzDTQHKxrtzfkTx           | The zone ID. Use either the zone name or the zone ID. Not both. |
|HETZNER_RECORD_NAME    | dyn                              | The record name. '@' to set the record for the zone itself.     |
|HETZNER_RECORD_TTL     | 120                              | The TTL of the record. Default(60)                              |
|HETZNER_RECORD_TYPE    | AAAA                             | The record type. Either A for IPv4 or AAAA for IPv6. Default(A) |

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
