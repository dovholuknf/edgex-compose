source /persistent/ziti.env
#source /dev/stdin <<< $(docker compose -f docker-compose.cwd.yml exec -it ziti-controller grep "export ZITI_PWD" ziti.env)
while [[ "$(curl -w "%{http_code}" -m 1 -s -k -o /dev/null https://ziti-edge-controller:8441/version)" != "200" ]]; do echo "waiting for https://ziti-edge-controller:8441"; sleep 3; done; echo "controller online"
ziti edge login https://ziti-edge-controller:8441 -u $ZITI_USER -p $ZITI_PWD -y

oidc_server="edgex-vault:8200"
ext_signer_name="vault.clients"
auth_policy_name="${ext_signer_name}.auth.policy"

ziti edge delete service-policy where 'name contains "core"'
ziti edge delete service-policy where 'name contains "core"'
ziti edge delete edge-router-policy where 'name contains "core"'
ziti edge delete config where 'name contains "core"'
ziti edge delete service where 'name contains "core"'
ziti edge delete identity where 'name contains "core"'
ziti edge delete auth-policy ${auth_policy_name}
ziti edge delete ext-jwt-signer ${ext_signer_name}

iss="$(curl -s "http://${oidc_server}/v1/identity/oidc/.well-known/openid-configuration" | jq -r .issuer)"
jwks="http://edgex-vault:8200$(curl -s "http://${oidc_server}/v1/identity/oidc/.well-known/openid-configuration" | jq -r .jwks_uri)"
aud="edgex"
claim="name"

ext_jwt_id=$(ziti edge create ext-jwt-signer "${ext_signer_name}" $iss -u $jwks -a $aud -c $claim)

kc_auth_policy=$(ziti edge create auth-policy "${auth_policy_name}" \
  --primary-ext-jwt-allowed \
  --primary-ext-jwt-allowed-signers "${ext_jwt_id}")

ziti edge create identity service 'core-command-client' -o core-command-client.jwt
ziti edge create identity user curlz -o curlz.jwt

function deleteEdgexService {
  local svc="edgex.$1"
  ziti edge delete config "${svc}-intercept"
  ziti edge delete service "${svc}"
  ziti edge delete erp "${svc}.erp"
  ziti edge delete sp "${svc}.bind"
  ziti edge delete sp "${svc}.dial"
}

function makeEdgexService {
  local svc="edgex.$1"
  local int="$1.edgex.ziti"
  ziti edge create identity service "${svc}" --external-id "${1}" -a "edgex,${svc}-servers" -P "${kc_auth_policy}"
  ziti edge create config "${svc}-intercept" intercept.v1 '{"protocols":["tcp"],"addresses":["'"${int}"'"], "portRanges":[{"low":80, "high":80}]}'
  ziti edge create service "${svc}" -a "${svc}" --configs "${svc}-intercept"
  ziti edge create edge-router-policy "${svc}.erp" --identity-roles "#${svc}" --edge-router-roles '#all'
  ziti edge create service-policy "${svc}.bind" Bind --service-roles "#${svc}" --identity-roles "#${svc}-servers"
  ziti edge create service-policy "${svc}.dial" Dial --service-roles "#${svc}" --identity-roles "#${svc}-clients"
}

makeEdgexService 'core-command'
makeEdgexService 'core-data'
makeEdgexService 'core-metadata'
makeEdgexService 'device-virtual'
makeEdgexService 'rules-engine'
makeEdgexService 'support-notifications'
makeEdgexService 'support-scheduler'
makeEdgexService 'sys-mgmt-agent'

ziti edge update identity edgex.device-virtual -a edgex.device-virtual-servers,edgex.core-command-clients,edgex.core-data-clients,edgex.core-metadata-clients,edgex.device-virtual-clients,edgex.rules-engine-clients,edgex.support-notifications-clients,edgex.support-scheduler-clients,edgex.sys-mgmt-agent-clients
ziti edge update identity curlz -a edgex.rules-engine-servers,edgex.core-command-clients,edgex.core-data-clients,edgex.core-metadata-clients,edgex.device-virtual-clients,edgex.rules-engine-clients,edgex.support-notifications-clients,edgex.support-scheduler-clients,edgex.sys-mgmt-agent-clients
ziti edge update identity edgex.rules-engine -x app-rules-engine

echo " "
echo "ext-jwt-id     : ${ext_jwt_id}"
echo "auth policy id : ${kc_auth_policy}"
echo " "

#echo "copied setup to vault"
#docker cp token.redo.sh edgex-vault:.
#token=$(docker run --rm -ti -v edgex_vault-config:/vault/config alpine cat /vault/config/assets/resp-init.json | jq -r '.root_token')
#docker exec -ti -e "VAULT_TOKEN=${token}" edgex-vault sh -l
#docker exec -e "VAULT_TOKEN=${token}" edgex-vault sh -c /token.redo.sh

echo "maybe run:"
echo "sudo cp /mnt/v/temp/curlz.json /mnt/c/Windows/System32/config/systemprofile/AppData/Roaming/NetFoundry/"
