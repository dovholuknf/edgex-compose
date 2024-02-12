docker compose -f docker-compose.yml stop core-command
docker compose -f docker-compose.yml stop core-metadata
docker compose -f docker-compose.yml stop core-data
docker compose -f docker-compose.yml stop device-virtual
docker compose -f docker-compose.yml stop device-rest
docker compose -f docker-compose.yml stop app-rules-engine