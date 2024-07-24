#!/bin/bash

# Default value for secretstore_host
secretstore_host="edgex-vault"
secretstore_port="8200"
username="edgexuser"

# Parse the command line argument
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --vault-host) secretstore_host="$2"; shift ;;
        --vault-port) secretstore_port="$2"; shift ;;
        --username) username="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

echo "Vault host is set to: $secretstore_host. It can be overridden by supplying --vault-host some.other.host"
echo "Vault port is set to: $secretstore_port. It can be overridden by supplying --vault-port 8500"
echo "Vault username is set to: $username. It can be overridden by supplying --username otheruser"
start_time=$(date +%s)
while true; do
    status_code=$(curl -s --max-time 1 -o /dev/null -w "%{http_code}" "http://${secretstore_host}:${secretstore_port}/ui/")
    
    if [ "$status_code" -eq 200 ]; then
        echo "http://${secretstore_host}:${secretstore_port} is up and returned a 200 status code. Continuing..."
        break
    else
        echo "Waiting for http://${secretstore_host}:${secretstore_port} to return a 200 status code. Current status: $status_code"
        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        if [ "$elapsed_time" -gt 5 ]; then
            echo "Timeout: http://${secretstore_host}:${secretstore_port} did not return a 200 status code within 5 seconds."
            exit 1
        fi
        sleep 1  # Delay for 1 second before retrying
    fi
done

docker run --rm -it --entrypoint "" \
  -e SECRETSTORE_HOST="${secretstore_host}" \
  -e username="${username}" \
  -v edgex_vault-config:/vault/config \
  --network edgex_edgex-network \
  nexus3.edgexfoundry.org:10004/security-proxy-setup:latest \
  /edgex/secrets-config proxy deluser --user "${username}" --useRootToken

password=$(docker run --rm -it --entrypoint "" \
  -e SECRETSTORE_HOST="${secretstore_host}" \
  -e username="${username}" \
  -v edgex_vault-config:/vault/config \
  --network edgex_edgex-network \
  nexus3.edgexfoundry.org:10004/security-proxy-setup:latest \
  /edgex/secrets-config proxy adduser --user "${username}" --useRootToken  | jq -r '.password')

secretstore_token=$(curl -ks "http://${secretstore_host}:${secretstore_port}/v1/auth/userpass/login/${username}" -d "{\"password\":\"${password}\"}" | jq -r '.auth.client_token')
echo $secretstore_token
id_token=$(curl -ks -H "Authorization: Bearer ${secretstore_token}" "http://${secretstore_host}:${secretstore_port}/v1/identity/oidc/token/${username}" | jq -r '.data.token')

# Check that we got sane output from the previous commands before coughing up the token
introspect_result=$(curl -ks -H "Authorization: Bearer ${secretstore_token}" "http://${secretstore_host}:${secretstore_port}/v1/identity/oidc/introspect" -d "{\"token\":\"${id_token}\"}" | jq -r '.active')
if [ "${introspect_result}" = "true" ]; then
  echo "$id_token"
	exit 0
else
	echo "ERROR" >&2
	exit 1
fi


