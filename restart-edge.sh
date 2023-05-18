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
ziti edge enroll ./ekuiper.identity.jwt

echo "--------------------------------"
echo "fetching ekuiper creds"
token=$(docker run --rm -ti -v edgex_vault-config:/vault/config alpine cat /vault/config/assets/resp-init.json | jq -r '.root_token')
docker exec -ti -e "VAULT_TOKEN=${token}" edgex-vault vault kv get secret/edgex/app-rules-engine/redisdb | tee ekuiper.creds.txt

echo "--------------------------------"
#docker compose -f docker-compose.cwd.yml logs -f

