# DynDNS Script for Hetzner DNS API by FarrowStrange
# v1.0

api_token = ""


import argparse
import json
import urllib.request
import requests


api_parser = argparse.ArgumentParser(description='DynDNS Python Script for Hetzner DNS API:')
positional_group = api_parser.add_argument_group('positional arguments')

positional_group.add_argument('-z','--zone', 
                              metavar='',
                              required=True,
                              help='Zone ID')
positional_group.add_argument('-r','--record',
                              metavar='',
                              required=True,
                              help='Record ID')
positional_group.add_argument('-n','--name',
                              metavar='',
                              required=True,
                              help='Record Name')
api_parser.add_argument('-t','--ttl',
                        metavar='',
                        type=int,
                        default=60,
                        help='TTL (Default: 60)')
api_parser.add_argument('-T','--type',
                        metavar='',
                        default='A',
                        help='Record type (Default: A)')
args = api_parser.parse_args()

if not api_token:
    print("No Auth API Token specified. Please reference at the top of the Script.")
    exit(1)

public_ip = json.loads(urllib.request.urlopen('https://ifconfig.me/all.json').read().decode('utf-8'))['ip_addr']
current_record = requests.get(
      url=f"https://dns.hetzner.com/api/v1/records/{args.record}",
      headers={"Auth-API-Token": f"{api_token}"},
    )
current_ip = (json.loads(current_record.content.decode('utf-8'))['record'])['value']

if current_ip != public_ip:
  print(f"DNS record {args.name} is no longer valid - updating record" )
  requests.put(
    url=f"https://dns.hetzner.com/api/v1/records/{args.record}",
    headers={
      "Content-Type": "application/json",
      "Auth-API-Token": f"{api_token}",
    },
    data=json.dumps({
      "value": f"{public_ip}",
      "ttl": args.ttl,
      "type": f"{args.type}",
      "name": f"{args.name}",
      "zone_id": f"{args.zone}"
    })
  )
else:
  print(f"DNS record {args.name} is up to date - nothing to to.")