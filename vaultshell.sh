token=$(docker run --rm -ti -v edgex_vault-config:/vault/config alpine cat /vault/config/assets/resp-init.json | jq -r '.root_token')
#docker exec -ti -e "VAULT_TOKEN=${token}" edgex-vault sh -l
docker exec -e "VAULT_TOKEN=${token}" edgex-vault sh -c /token.redo.sh
