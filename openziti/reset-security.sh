docker compose -f docker-compose.yml stop security-secretstore-setup
docker compose -f docker-compose.yml rm -f security-secretstore-setup
docker compose -f docker-compose.yml up -d security-secretstore-setup

sudo chmod 777 -R /tmp/edgex/secrets
make get-token > /tmp/edgex/secrets/ui.token.json
cp /tmp/edgex/secrets/ui.token.json /mnt/c/temp


make get-token > /tmp/edgex/secrets/ui.token.json