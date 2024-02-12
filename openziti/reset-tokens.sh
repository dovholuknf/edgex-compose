docker compose -f docker-compose.yml --project-name edgex stop security-secretstore-setup
docker compose -f docker-compose.yml --project-name edgex rm -f security-secretstore-setup
docker compose -f docker-compose.yml --project-name edgex up -d

docker compose -f openziti/ziti.yml --project-name edgex cp openziti/setup-ziti.sh openziti:.
docker compose -f openziti/ziti.yml --project-name edgex exec -it openziti bash -c ./setup-ziti.sh
sudo chmod 777 -R /tmp/edgex/secrets
make get-token > /tmp/edgex/secrets/ui.token.json
