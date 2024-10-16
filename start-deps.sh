clear
docker compose -f docker-compose-zero-trust-just-deps.yml up -d --remove-orphans
docker compose -f docker-compose-zero-trust-just-deps.yml logs -f 
