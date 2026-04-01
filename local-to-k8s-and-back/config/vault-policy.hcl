# Vault policy for OpenClaw agents
# Grants read-only access to the openclaw secrets path

path "secret/data/openclaw" {
  capabilities = ["read"]
}

path "secret/data/openclaw/*" {
  capabilities = ["read"]
}
