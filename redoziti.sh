. .env.8441

ziti edge login "${OPENZITI_ADVERTISED_ADDRESS}:${OPENZITI_ADVERTISED_PORT}" -u "${ZITI_USER}" -p "${ZITI_PWD}" -y
ziti edge delete edge-router ${OPENZITI_EDGEX_ROUTER_NAME}
# create router:
ziti edge create edge-router ${OPENZITI_EDGEX_ROUTER_NAME} -t -o ${OPENZITI_EDGEX_ROUTER_NAME}.jwt
docker compose cp ${OPENZITI_EDGEX_ROUTER_NAME}.jwt openziti-router:/home/ziggy/${OPENZITI_EDGEX_ROUTER_NAME}.jwt
docker compose exec --user root openziti-router chown ziggy:ziggy /home/ziggy/${OPENZITI_EDGEX_ROUTER_NAME}.jwt
rm ${OPENZITI_EDGEX_ROUTER_NAME}.jwt




ziti edge login "${OPENZITI_ADVERTISED_ADDRESS}:${OPENZITI_ADVERTISED_PORT}" -u "${ZITI_USER}" -p "${ZITI_PWD}" -y
ziti edge delete service-policy edgex-vault-bind
ziti edge delete service-policy edgex-vault-dial
ziti edge delete service edgex-vault
ziti edge delete config edgex-vault.intercept.v1
ziti edge delete config edgex-vault.host.v1

#the name of the router on the controller so the controller can make an underlay request
ziti edge create config "edgex-vault.intercept.v1" intercept.v1 \
  '{"protocols":["tcp"],"addresses":["vault.edgex.ziti"], "portRanges":[{"low":8200, "high":8200}]}'
ziti edge create config "edgex-vault.host.v1" host.v1 \
   '{"protocol":"tcp", "address":"vault","port":8200}'
ziti edge create service edgex-vault --configs edgex-vault.intercept.v1,edgex-vault.host.v1
ziti edge create service-policy edgex-vault-dial Dial --identity-roles '#edgex-vault.dialers' --service-roles @edgex-vault
ziti edge create service-policy edgex-vault-bind Bind --identity-roles '#edgex-vault.binders' --service-roles @edgex-vault

ziti edge update identity ${OPENZITI_CONTROLLER_ROUTER_NAME} -a 'public,edgex-vault.dialers'
ziti edge update identity ${OPENZITI_EDGEX_ROUTER_NAME} -a 'edgex-vault.binders'




docker run -it --rm \
  --env-file .env \
  -e ZITI_ADMIN \
  -e ZITI_PWD \
  -e OPENZITI_OIDC_URL="http://vault.edgex.ziti:8200" \
  -e OPENZITI_PERSISTENCE_PATH="/edgex_openziti" \
  -v edgex_edgex_openziti:/edgex_openziti \
  -v ./openziti-init-entrypoint.sh:/openziti-init-entrypoint.sh \
  --entrypoint "/bin/sh" \
  --user root \
  openziti/ziti-cli \
  -c 'chown -Rc 2002:2001 "${OPENZITI_PERSISTENCE_PATH}" && ./openziti-init-entrypoint.sh'