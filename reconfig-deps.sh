source .env.8441

ziti edge login "${OPENZITI_ADVERTISED_ADDRESS}:${OPENZITI_ADVERTISED_PORT}" -u "${ZITI_USER}" -p "${ZITI_PWD}" -y
ziti edge delete edge-router ${OPENZITI_EDGEX_ROUTER_NAME}
# create router:
ziti edge create edge-router ${OPENZITI_EDGEX_ROUTER_NAME} -t -o ${OPENZITI_EDGEX_ROUTER_NAME}.jwt
docker compose cp ${OPENZITI_EDGEX_ROUTER_NAME}.jwt openziti-router:/home/ziggy/${OPENZITI_EDGEX_ROUTER_NAME}.jwt
docker compose exec --user root openziti-router chown ziggy:ziggy /home/ziggy/${OPENZITI_EDGEX_ROUTER_NAME}.jwt
rm ${OPENZITI_EDGEX_ROUTER_NAME}.jwt


