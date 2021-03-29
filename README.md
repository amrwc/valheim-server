# Valheim Server Terraformed

## Deploy

DigitalOcean example:

```console
cd terraform/digitalocean
terraform init

export DO_PAT='abcd1234'
export TERRAFORM_SSH_KEY="${HOME}/.ssh/id_ed25519_digitalocean"

terraform plan \
    -var "do_token=${DO_PAT}" \
    -var "private_ssh_key=${TERRAFORM_SSH_KEY}"

# If the plan passed and looks right, deploy the resources
terraform apply \
    -var "do_token=${DO_PAT}" \
    -var "private_ssh_key=${TERRAFORM_SSH_KEY}"
```
