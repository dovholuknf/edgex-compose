source .env.8441

ziti edge login "${OPENZITI_ADVERTISED_ADDRESS}:${OPENZITI_ADVERTISED_PORT}" -u "${ZITI_USER}" -p "${ZITI_PWD}" -y
ziti edge delete edge-router ${OPENZITI_EDGEX_ROUTER_NAME}
# create router:
ziti edge create edge-router ${OPENZITI_EDGEX_ROUTER_NAME} -t -o ${OPENZITI_EDGEX_ROUTER_NAME}.jwt
docker compose cp ${OPENZITI_EDGEX_ROUTER_NAME}.jwt openziti-router:/home/ziggy/${OPENZITI_EDGEX_ROUTER_NAME}.jwt
docker compose exec --user root openziti-router chown ziggy:ziggy /home/ziggy/${OPENZITI_EDGEX_ROUTER_NAME}.jwt
rm ${OPENZITI_EDGEX_ROUTER_NAME}.jwt



ziti edge delete service-policy edgex.vault.bind
ziti edge delete service-policy edgex.vault.dial
ziti edge delete service edgex.vault
ziti edge delete config edgex.vault.intercept
ziti edge delete config edgex.vault.host

#the name of the router on the controller so the controller can make an underlay request
ziti edge create config "edgex.vault.intercept" intercept.v1 \
 '{"protocols":["tcp"],"addresses":["vault.edgex.ziti"], "portRanges":[{"low":8200, "high":8200}]}'
ziti edge create config "edgex.vault.host" host.v1 \
  '{"protocol":"tcp", "address":"vault","port":8200}'
ziti edge create service edgex.vault --configs edgex.vault.intercept,edgex.vault.host -a 'edgex.vault'
ziti edge create service-policy edgex.vault.dial Dial --identity-roles '#edgex.vault.dialers' --service-roles @edgex.vault --semantic "AnyOf"
ziti edge create service-policy edgex.vault.bind Bind --identity-roles '#edgex.vault.binders' --service-roles @edgex.vault --semantic "AnyOf"

ziti edge update identity "${OPENZITI_CONTROLLER_ROUTER_NAME}" -a 'public,edgex.vault.dialers'
ziti edge update identity "${OPENZITI_EDGEX_ROUTER_NAME}" -a 'edgex.vault.binders'