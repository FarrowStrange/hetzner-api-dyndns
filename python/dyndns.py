# DynDNS Script for Hetzner DNS API by FarrowStrange
# v1.0

api_token = ""


import argparse
import json
import urllib.request
import requests


def get_record():
  try:
    response = requests.get(
      url=f"https://dns.hetzner.com/api/v1/records/{args.record}",
      headers={"Auth-API-Token": f"{api_token}"},
    )
    print('{content}'.format(
      content=response.content))
  except requests.exceptions.RequestException:
    print('HTTP Request failed')

def update_record():
  try:
    payload_dict = {
      "value": pub_addr,
      "ttl": args.ttl,
      "type": args.type,
      "name": args.name,
      "zone_id": args.zone,
    }
    requests.put(
      url=f"https://dns.hetzner.com/api/v1/records/{args.record}",
      headers={
        "Content-Type": "application/json",
        "Auth-API-Token": f"{api_token}",
      },
      data=json.dumps(payload_dict)
    )
  except requests.exceptions.RequestException:
      print('HTTP Request failed')


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

pub_addr_info = json.loads(urllib.request.urlopen('https://ifconfig.me/all.json').read().decode('utf-8'))
pub_addr = pub_addr_info['ip_addr']
