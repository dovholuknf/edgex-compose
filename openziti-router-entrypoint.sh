#!/usr/bin/env bash
set -e -u -o pipefail

export ZITI_HOME="${HOME}/router"
mkdir -p $ZITI_HOME

if [ ! -f "${ZITI_HOME}/${OPENZITI_EDGE_ROUTER_NAME}.key" ]; then
  while [ ! -f "${HOME}/${OPENZITI_EDGE_ROUTER_NAME}.jwt" ]; do
    sleep 5
    echo "waiting for router enrollment... please mount or copy the router's jwt to: ${HOME}/${OPENZITI_EDGE_ROUTER_NAME}.jwt"
  done

  while [ ! -r "${HOME}/${OPENZITI_EDGE_ROUTER_NAME}.jwt" ]; do
    sleep 5
    echo "file exists but is not readable: ${HOME}/${OPENZITI_EDGE_ROUTER_NAME}.jwt"
  done

  echo 'router enrollment token detected. enrolling the router'
  # create router config:
  ZITI_CTRL_ADVERTISED_ADDRESS="${OPENZITI_ADVERTISED_ADDRESS}" \
  ZITI_CTRL_ADVERTISED_PORT="${OPENZITI_CONTROL_PORT}" \
  ZITI_ROUTER_ADVERTISED_ADDRESS="${OPENZITI_EDGE_ROUTER_NAME}" \
  ZITI_ROUTER_PORT=3022 \
  ziti create config router edge \
    --tunnelerMode host \
    --routerName "${OPENZITI_EDGE_ROUTER_NAME}" \
    -o "${HOME}/${OPENZITI_EDGE_ROUTER_NAME}.yml"
    
  # enroll router:
  ziti router enroll \
    --jwt "${HOME}/${OPENZITI_EDGE_ROUTER_NAME}.jwt" \
    "${HOME}/${OPENZITI_EDGE_ROUTER_NAME}.yml"
    
    echo 'enrollment complete'
else
  echo 'router enrollment exists'
fi

exec ziti router run "${HOME}/${OPENZITI_EDGE_ROUTER_NAME}.yml"
