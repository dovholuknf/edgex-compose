source .env.8441

ziti edge login "${OPENZITI_ADVERTISED_ADDRESS}:${OPENZITI_ADVERTISED_PORT}" -u "${ZITI_USER}" -p "${ZITI_PWD}" -y
ziti edge delete edge-router where 'name contains "edgex." limit none'
# create router:
ziti edge create edge-router ${OPENZITI_EDGEX_ROUTER_NAME} -t -o ${OPENZITI_EDGEX_ROUTER_NAME}.jwt
docker compose cp ${OPENZITI_EDGEX_ROUTER_NAME}.jwt openziti-router:/home/ziggy/${OPENZITI_EDGEX_ROUTER_NAME}.jwt
docker compose exec --user root openziti-router chown ziggy:ziggy /home/ziggy/${OPENZITI_EDGEX_ROUTER_NAME}.jwt
rm ${OPENZITI_EDGEX_ROUTER_NAME}.jwt



ziti edge delete service-policy edgex.token-provider.bind
ziti edge delete service-policy edgex.token-provider.dial
ziti edge delete service edgex.token-provider
ziti edge delete config edgex.token-provider.intercept
ziti edge delete config edgex.token-provider.host

#the name of the router on the controller so the controller can make an underlay request
ziti edge create config "edgex.token-provider.intercept" intercept.v1 \
 '{"protocols":["tcp"],"addresses":["token-provider.edgex.ziti"], "portRanges":[{"low":8200, "high":8200}]}'
ziti edge create config "edgex.token-provider.host" host.v1 \
  '{"protocol":"tcp", "address":"'"${EDGEX_TOKEN_PROVIDER_HOST}"'","port":8200}'
ziti edge create service edgex.token-provider \
  --configs edgex.token-provider.intercept,edgex.token-provider.host \
  -a 'edgex.token-provider'
ziti edge create service-policy edgex.token-provider.dial Dial \
  --identity-roles '#edgex.token-provider.dialers' \
  --service-roles @edgex.token-provider --semantic "AnyOf"
ziti edge create service-policy edgex.token-provider.bind Bind \
  --identity-roles '#edgex.token-provider.binders' \
  --service-roles @edgex.token-provider --semantic "AnyOf"

ziti edge update identity "${OPENZITI_CONTROLLER_ROUTER_NAME}" -a 'public,edgex.token-provider.dialers'
ziti edge update identity "${OPENZITI_EDGEX_ROUTER_NAME}" -a 'edgex.token-provider.binders'