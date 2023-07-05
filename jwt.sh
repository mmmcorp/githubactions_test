#!/bin/bash

# 情報そーす
# https://zenn.dev/gorohash/articles/e2c5f6ce50f4e6

# Check if a path was provided as an argument
if [ -z "$1" ]; then
  echo "Please provide the path to your .pem file as an argument."
  exit 1
fi

path_to_pem=$1
# header 作成
header=$(echo -n '{"alg":"RS256","typ":"JWT"}' | base64)

# payload 作成
now=$(date "+%s")
iat=$((${now} - 60))
exp=$((${now} + (10 * 60)))
echo "Please enter the your GitHub App ID:"
read github_app_id
payload=$(echo -n "{\"iat\":${iat},\"exp\":${exp},\"iss\":${github_app_id}}" | base64)

# ヘッダーとペイロードを "." で連結し、openssl コマンドで GitHub App の秘密鍵を使って署名
unsigned_token="${header}.${payload}"
signed_token=$(echo -n "${unsigned_token}" | openssl dgst -binary -sha256 -sign $path_to_pem| base64)
jwt="${unsigned_token}.${signed_token}"
echo $jwt

echo "Please enter the the installation ID of your GitHub App:"
read installationID

accesstoken=`curl -s -X POST \
    -H "Authorization: Bearer ${jwt}" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/app/installations/${installationID}/access_tokens" | jq -r ".token"`

echo $accesstoken
