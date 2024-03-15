gateway_token=$(make get-token)
echo "GATEWAY TOKEN:"
echo "$gateway_token"

acl_token=$(make get-consul-acl-token | tail -1)
echo "ACL TOKEN:"
echo "$acl_token"

curl -H "Authorizaction: Bearer ${gateway_token}" http://localhost:4000/core-metadata/api/v3/ping


curl 'http://localhost:4000/api/v3/registrycenter/ping' \
  -H 'Accept: application/json, text/plain, */*' \
  -H 'Accept-Language: en-US,en;q=0.9' \
  -H "Authorization: Bearer ${acl_token}" \
  -H 'Cache-Control: no-cache' \
  -H 'Connection: keep-alive' \
  -H 'Pragma: no-cache' \
  -H 'Referer: http://localhost:4000/en-US/' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-GPC: 1' \
  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36' \
  -H 'X-Consul-Token: asdf' \
  -H 'X-Requested-With: XMLHttpRequest' \
  -H 'sec-ch-ua: "Not A(Brand";v="99", "Brave";v="121", "Chromium";v="121"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Windows"' \
  --compressed