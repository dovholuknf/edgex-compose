# Exit immediately if any command exits with a non-zero status
set -e

docker compose -f docker-compose.yml --project-name edgex down -v
rm -rf /tmp/edgex/secrets
docker compose -f docker-compose.yml --project-name edgex up -d

#docker compose -f docker-compose.yml --project-name edgex stop core-command
#docker compose -f docker-compose.yml --project-name edgex stop core-metadata
#docker compose -f docker-compose.yml --project-name edgex stop core-data
#docker compose -f docker-compose.yml --project-name edgex stop device-virtual
#docker compose -f docker-compose.yml --project-name edgex stop device-rest
#docker compose -f docker-compose.yml --project-name edgex stop support-notifications
#docker compose -f docker-compose.yml --project-name edgex stop support-scheduler
#docker compose -f docker-compose.yml --project-name edgex stop ui

#docker compose -f docker-compose.yml --project-name edgex stop app-rules-engine

# wait for edgex to start...

echo "waiting 10s"
sleep 10

docker compose -f openziti/ziti.yml --project-name edgex cp openziti/setup-ziti.sh openziti:.
docker compose -f openziti/ziti.yml --project-name edgex exec -it openziti bash -c ./setup-ziti.sh
sudo chmod 777 -R /tmp/edgex/secrets

#mkdir -p /tmp/edgex/secrets/ui/
#
#tokenFile="/tmp/edgex/secrets/ui/secrets-token.json"
#while [ ! -s "$tokenFile" ]; do
#    echo "File is empty. Waiting for contents..."
#    sleep 1  # You can adjust the sleep duration based on your needs
#    echo NO MAKE TOKEN #make get-token > $tokenFile
#done


docker compose -f docker-compose.yml --project-name edgex logs -f






