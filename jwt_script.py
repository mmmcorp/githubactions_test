#!/usr/bin/env python3
import os
import time
import base64
import json
import jwt as pyjwt
import requests

# header creation
header = {
    "alg": "RS256",
    "typ": "JWT"
}

# payload creation
now = int(time.time())
iat = now - 60
exp = now + (10 * 60)
github_app_id = os.environ.get("GITHUB_APP_ID")
print(github_app_id)
payload = {
    "iat": iat,
    "exp": exp,
    "iss": github_app_id
}

# create JWT
with open('./githubactions_test.pem', 'r') as f:
    private_key = f.read()
# private_key = os.environ.get("PRIVATE_KEY").replace('\\n', '\n')
print(private_key)

token = pyjwt.encode(payload, private_key, algorithm="RS256", headers=header)
print(token)

installation_id = os.environ.get("INSTALLATION_ID")

# get the access token
url = f"https://api.github.com/app/installations/{installation_id}/access_tokens"
headers = {
    "Authorization": f"Bearer {token}",
    "Accept": "application/vnd.github.v3+json"
}
response = requests.post(url, headers=headers)
response.raise_for_status()

access_token = response.json().get('token')
print(access_token)
