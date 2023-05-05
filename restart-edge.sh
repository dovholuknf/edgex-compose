docker compose -f docker-compose.cwd.yml down -v
docker compose -f docker-compose.cwd.yml pull
docker compose -f docker-compose.cwd.yml up -d

sudo chmod 777 -R /tmp/edgex/secrets/

echo "setting up ziti..."
source /dev/stdin <<< $(docker compose -f docker-compose.cwd.yml exec -it ziti-controller grep "export ZITI_PWD" ziti.env)

docker compose cp setup-ziti.sh ziti-controller:/persistent
docker compose exec -it ziti-controller bash -c /persistent/setup-ziti.sh

docker compose cp ziti-controller:/persistent/curlz.jwt /mnt/v/temp/
ziti edge enroll /mnt/v/temp/curlz.jwt

echo "--------------------------------"
docker compose -f docker-compose.cwd.yml logs -f
