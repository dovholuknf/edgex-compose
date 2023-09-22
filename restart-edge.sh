docker compose -f docker-compose.cwd.yml down -v
docker compose -f docker-compose.cwd.yml pull
docker compose -f docker-compose.cwd.yml up -d

sudo chmod 777 -R /tmp/edgex/secrets/

echo "setting up ziti..."
source /dev/stdin <<< $(docker compose -f docker-compose.cwd.yml exec -it ziti-controller grep "export ZITI_PWD" ziti.env)

docker compose -f docker-compose.cwd.yml cp setup-ziti.sh ziti-controller:/persistent

docker compose -f docker-compose.cwd.yml exec -it ziti-controller bash -c "cat /persistent/setup-ziti.sh > /persistent/setup-ziti2.sh"
docker compose -f docker-compose.cwd.yml exec -it ziti-controller bash -c "chmod +x /persistent/setup-ziti2.sh"
docker compose -f docker-compose.cwd.yml exec -it ziti-controller bash -c /persistent/setup-ziti2.sh

docker compose -f docker-compose.cwd.yml cp ziti-controller:/persistent/curlz.jwt .
ziti edge enroll ./curlz.jwt

echo "--------------------------------"
docker compose -f docker-compose.cwd.yml logs -f
