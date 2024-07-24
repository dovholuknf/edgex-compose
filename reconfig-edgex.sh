source .env.8441

ziti edge login "${OPENZITI_ADVERTISED_ADDRESS}:${OPENZITI_ADVERTISED_PORT}" -u "${ZITI_USER}" -p "${ZITI_PWD}" -y

while true; do
  if [ $(ziti edge list terminators | grep 'edgex.vault' | wc -l) -gt 0 ]; then
    echo "yes"
    break
  else
    echo "waiting for edgex.vault terminator..."
  fi
  sleep 1 # Add a sleep to avoid overwhelming the system
done

echo 'terminator exists... just waiting 5 more seconds....'
sleep 5

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
  -c 'chown -Rc 2002:2001 "${OPENZITI_PERSISTENCE_PATH}"; /openziti-init-entrypoint.sh'










