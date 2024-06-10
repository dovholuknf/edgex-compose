#!/usr/bin/env bash
if [ -e "${OPENZITI_PERSISTENCE_PATH}/healthcheck.json" ]; then
    echo "${OPENZITI_PERSISTENCE_PATH}/healthcheck.json exists. already initialized."
    exit 0
fi

# should be user settable through docker-compose/env/env vars
openziti_server_and_port="${OPENZITI_ADVERTISED_ADDRESS}:${OPENZITI_ADVERTISED_PORT}"
oidc_server=${OPENZITI_OIDC_URL:-"http://vault:8200"}
ext_signer_name=${OPENZITI_EXT_SIGNER_NAME:-"edgex-vault.clients"}
auth_policy_name=${OPENZITI_AUTH_POLICY_NAME:-"${ext_signer_name}.auth.policy"}
iss=${OPENZITI_JWT_ISSUER:-"/v1/identity/oidc"}
jwks=${OPENZITI_JWT_JWKS_URL:-"${oidc_server}/v1/identity/oidc/.well-known/keys"}
aud=${OPENZITI_JWT_AUD:-"edgex"}
claim=${OPENZITI_JWT_CLAIM:-"name"}


while [[ "$(curl -w "%{http_code}" -m 1 -s -k -o /dev/null "https://${openziti_server_and_port}/version")" != "200" ]]; do echo "waiting for https://${openziti_server_and_port}"; sleep 3; done; echo "controller online"
ziti edge login "${openziti_server_and_port}" -u "$ZITI_USER" -p "$ZITI_PWD" -y

echo "CLEANUP: removing any previous configuration"
ziti edge delete identity where 'name contains "edgex." limit none'
ziti edge delete service-policy where 'name contains "edgex." limit none'
ziti edge delete service where 'name contains "edgex." limit none'
ziti edge delete config where 'name contains "edgex." limit none'

ziti edge delete identity where 'name contains "edgex-healthcheck" limit none'
ziti edge delete service-policy where 'name contains "edgex-healthcheck" limit none'
ziti edge delete service where 'name contains "edgex-healthcheck" limit none'
ziti edge delete config where 'name contains "edgex-healthcheck" limit none'

ziti edge delete auth-policy where 'name contains "'"${auth_policy_name}"'" limit none'
ziti edge delete ext-jwt-signer where 'name contains "'"${ext_signer_name}"'" limit none'

ext_jwt_id=$(ziti edge create ext-jwt-signer "${ext_signer_name}" "$iss" -u "$jwks" -a "$aud" -c "$claim")

edgex_auth_policy=$(ziti edge create auth-policy "${auth_policy_name}" \
  --primary-ext-jwt-allowed \
  --primary-ext-jwt-allowed-signers "${ext_jwt_id}")

function makeEdgeXService {
  local svc="edgex.$1"
  local idAttr="$2.id"
  local svcAttr="$2.svc"
  local int="$1.edgex.ziti"
  ziti edge create identity "${svc}" --external-id "${1}" -a "${idAttr},${svc}.server" -P "${edgex_auth_policy}"
  ziti edge create config "${svc}.intercept" intercept.v1 '{"protocols":["tcp"],"addresses":["'"${int}"'"], "portRanges":[{"low":80, "high":80}]}'
  ziti edge create service "${svc}" -a "${svcAttr},${svc}.server" --configs "${svc}.intercept"
  ziti edge create service-policy "${svc}.bind" Bind --service-roles "#${svc}.server" --identity-roles "#${svc}.server"
}

function makeCoreService {
  makeEdgeXService "$1" "core"
}
function makeSupportService {
  makeEdgeXService "$1" "support"
}
function makeDeviceService {
  makeEdgeXService "$1" "device"
}
function makeApplicationService {
  makeEdgeXService "$1" "application"
}

sleep 1

makeCoreService 'core-command'
makeCoreService 'core-data'
makeCoreService 'core-metadata'
makeCoreService 'ui'

makeSupportService 'rules-engine'
makeSupportService 'support-notifications'
makeSupportService 'support-scheduler'

makeDeviceService 'device-bacnet-ip'
makeDeviceService 'device-coap'
makeDeviceService 'device-gpio'
makeDeviceService 'device-modbus'
makeDeviceService 'device-mqtt'
makeDeviceService 'device-onvif-camera'
makeDeviceService 'device-rest'
makeDeviceService 'device-rfid-llrp'
makeDeviceService 'device-snmp'
makeDeviceService 'device-uart'
makeDeviceService 'device-usb-camera'
makeDeviceService 'device-virtual'

makeApplicationService 'app-external-mqtt-trigger'
makeApplicationService 'app-http-export'
makeApplicationService 'app-metrics-influxdb'
makeApplicationService 'app-mqtt-export'
makeApplicationService 'app-rfid-llrp-inventory'
makeApplicationService 'app-rules-engine'
makeApplicationService 'app-record-replay'
makeApplicationService 'app-sample'
  
ziti edge create service-policy edgex.app-core-dial Dial --identity-roles "#application.id" --service-roles "#core.svc"
ziti edge create service-policy edgex.app-support-dial Dial --identity-roles "#application.id" --service-roles "#support.svc"
ziti edge create service-policy edgex.ds-core-dial Dial --identity-roles "#device.id" --service-roles "@edgex.core-metadata"
ziti edge create service-policy edgex.core-core-dial Dial --identity-roles "#core.id" --service-roles "#core.svc"
ziti edge create service-policy edgex.corecmd-device-dial Dial --identity-roles "#edgex.core-command.server" --service-roles "#device.svc"
ziti edge create service-policy edgex.support-core-dial Dial --identity-roles "#support.id" --service-roles "#core.svc"

echo " "
echo "ext-jwt-id     : ${ext_jwt_id}"
echo "auth policy id : ${edgex_auth_policy}"
echo " "

echo "creating the edgex-healthcheck proxy identity"
ziti edge create identity \
  edgex-healthcheck -o "${OPENZITI_PERSISTENCE_PATH}/healthcheck.jwt" \
  -a 'edgex-healthchecker'
ziti edge create service-policy edgex-healthcheck-core-dial Dial --identity-roles "#edgex-healthchecker" --service-roles "#core.svc"
ziti edge create service-policy edgex-healthcheck-support-dial Dial --identity-roles "#edgex-healthchecker" --service-roles "#support.svc"
ziti edge create service-policy edgex-healthcheck-device-dial Dial --identity-roles "#edgex-healthchecker" --service-roles "#device.svc"
ziti edge create service-policy edgex-healthcheck-application-dial Dial --identity-roles "#edgex-healthchecker" --service-roles "#application.svc"

ziti edge create service-policy edgex.ui-support-dial Dial --identity-roles "#edgex.ui.server" --service-roles "#support.svc"

ziti edge enroll "${OPENZITI_PERSISTENCE_PATH}/healthcheck.jwt"

