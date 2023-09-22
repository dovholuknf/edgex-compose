vault delete identity/oidc/role/app-rules-engine
vault delete identity/oidc/role/core-command
vault delete identity/oidc/role/core-common-config-bootstrapper
vault delete identity/oidc/role/core-data
vault delete identity/oidc/role/core-metadata
vault delete identity/oidc/role/device-rest
vault delete identity/oidc/role/device-virtual
vault delete identity/oidc/role/security-bootstrapper-messagebus
vault delete identity/oidc/role/security-bootstrapper-redis
vault delete identity/oidc/role/security-proxy-auth
vault delete identity/oidc/role/security-proxy-setup
vault delete identity/oidc/role/security-spiffe-token-provider
vault delete identity/oidc/role/support-notifications
vault delete identity/oidc/role/support-scheduler

vault write identity/oidc/role/app-rules-engine key=edgex-identity client_id=edgex template='{"name": "app-rules-engine"}'
vault write identity/oidc/role/core-command key=edgex-identity client_id=edgex template='{"name": "core-command"}'
vault write identity/oidc/role/core-common-config-bootstrapper key=edgex-identity client_id=edgex template='{"name": "core-common-config-bootstrapper"}'
vault write identity/oidc/role/core-data key=edgex-identity client_id=edgex template='{"name": "core-data"}'
vault write identity/oidc/role/core-metadata key=edgex-identity client_id=edgex template='{"name": "core-metadata"}'
vault write identity/oidc/role/device-rest key=edgex-identity client_id=edgex template='{"name": "device-rest"}'
vault write identity/oidc/role/device-virtual key=edgex-identity client_id=edgex template='{"name": "device-virtual"}'
vault write identity/oidc/role/security-bootstrapper-messagebus key=edgex-identity client_id=edgex template='{"name": "security-bootstrapper-messagebus"}'
vault write identity/oidc/role/security-bootstrapper-redis key=edgex-identity client_id=edgex template='{"name": "security-bootstrapper-redis"}'
vault write identity/oidc/role/security-proxy-auth key=edgex-identity client_id=edgex template='{"name": "security-proxy-auth"}'
vault write identity/oidc/role/security-proxy-setup key=edgex-identity client_id=edgex template='{"name": "security-proxy-setup"}'
vault write identity/oidc/role/security-spiffe-token-provider key=edgex-identity client_id=edgex template='{"name": "security-spiffe-token-provider"}'
vault write identity/oidc/role/support-notifications key=edgex-identity client_id=edgex template='{"name": "support-notifications"}'
vault write identity/oidc/role/support-scheduler key=edgex-identity client_id=edgex template='{"name": "support-scheduler"}'
