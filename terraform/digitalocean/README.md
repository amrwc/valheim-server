# DigitalOcean Terraform

## Prerequisites

All the scripts require a few environment variables:

```console
export DO_PAT='abcd1234'
export TERRAFORM_SSH_KEY="${HOME}/.ssh/id_ed25519_digitalocean_terraform"
```

## Prepare existing server backups

If you have already played and want to move the world into the server, put the
save files into `valheim/saves/worlds` in the root of the repository. Then, in
the `valheim_server_name` variable, specify a name that matches the name of the
world save files.

## Variables

<details>

<summary>Click here to expand</summary>

### `do_token` (required)

DigitalOcean Personal Access Token. Needed for authentication with DigitalOcean
API.

See: <https://www.digitalocean.com/docs/apis-clis/api/create-personal-access-token>

### `do_ssh_key_path` (required)

Path to a private SSH key without a passphrase that's been added to a
DigitalOcean account. Needed to provision the Droplet.

NOTE: This is the SSH key you would use to connect to the Droplet, if
necessary.

See: <https://www.digitalocean.com/docs/droplets/how-to/add-ssh-keys/to-account>

### `do_terraform_ssh_key_name` (optional)

Name of the SSH key added to a DigitalOcean account (as is visible on
DigitalOcean). Normally, it should be the same SSH key that's been specified in
the `do_ssh_key_path` variable.

The `digitalocean_ssh_key` data source fetches its details from DigitalOcean.
Then, the `digitalocean_droplet` uses the ID from the details to add this SSH
key to the new Droplet.

Defaults to `id_ed25519_digitalocean_terraform`.

See: <https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/ssh_key>

### `valheim_server_name` (optional)

The public name of the Valheim server.

Defaults to `Valheim Docker DigitalOcean`.

### `valheim_server_password` (optional)

The password to access the Valheim server.

<details>

<summary>Defaults to <code>hunter2</code>.</summary>

You _should_ change it.

```text
<Cthon98> hey, if you type in your pw, it will show as stars
<Cthon98> ********* see!
<AzureDiamond> hunter2
<AzureDiamond> doesnt look like stars to me
<Cthon98> <AzureDiamond> *******
<Cthon98> thats what I see
<AzureDiamond> oh, really?
<Cthon98> Absolutely
<AzureDiamond> you can go hunter2 my hunter2-ing hunter2
<AzureDiamond> haha, does that look funny to you?
<Cthon98> lol, yes. See, when YOU type hunter2, it shows to us as *******
<AzureDiamond> thats neat, I didnt know IRC did that
<Cthon98> yep, no matter how many times you type hunter2, it will show to us as *******
<AzureDiamond> awesome!
<AzureDiamond> wait, how do you know my pw?
<Cthon98> er, I just copy pasted YOUR ******'s and it appears to YOU as hunter2 cause its your pw
<AzureDiamond> oh, ok.
```

</details>

### `valheim_world_name` (optional)

Name of the Valheim world. It directly correlates to the save file names.

Defaults to `Default`.

### `valheim_local_saves` (optional)

Path to the local saves parent directory (the one that contains `worlds/`). If
the game is installed on the local system, the path should be something like
this (use forward slashes):

```text
C:/Users/<USERNAME>/AppData/LocalLow/IronGate/Valheim
```

Alternatively, put the save files into `valheim/saves` in the root of this
repository.

Defaults to the `valheim/saves` directory present in the root of the
repository.

### `test` (optional)

Whether this execution is a test provision. If set to `true`, the DigitalOcean
resource names will have random values appended to them, and the VPC's IP range
will also be randomised as to not overlap with the existing IP ranges.

Note that it _will_ perform a full provision, but with unique names. This is to
be able to develop these scripts without having to avoid changes to existing
deployments.

Defaults to `false`.

</details>

## Plan

Initialise Terraform and test the release plan:

```console
terraform init

terraform plan \
    -var "do_token=${DO_PAT}" \
    -var "private_ssh_key=${TERRAFORM_SSH_KEY}"
```

## Deploy

If the plan passed and looks right, deploy the resources:

```console
terraform apply \
    -var "do_token=${DO_PAT}" \
    -var "private_ssh_key=${TERRAFORM_SSH_KEY}" \
    -var "valheim_server_name=Valheim" \
    -var "hunter2" \
    -var "valheim_world_name=NewWorld"
```

## Clean up

**WARNING:** This will delete all the resources that Terraform has created.

```console
terraform destroy \
    -var "do_token=${DO_PAT}" \
    -var "private_ssh_key=${TERRAFORM_SSH_KEY}"
```

## Troubleshooting Terraform

### Outdated state

Sometimes, Terrafor will throw errors similar to the following. It's probably
because the resource has been removed from the UI, and the local state is
out-of-date.

> Error: Error reading Project: GET https://api.digitalocean.com/v2/projects/3f7be189-85ff-4030-bc43-8f92f55f450e: 404 project not found

The simplest way to resolve it is to wipe the local state clean, and start
over:

```console
rm -rf .terraform* terraform.*
terraform init
```

## Troubleshooting DigitalOcean

You can use DigitalOcean's API to inspect resources that aren't easily
accessible from the UI. Documentation
[here](https://developers.digitalocean.com/documentation).

Note that each request requires a DigitalOcean Personal Access Token
(`DO_PAT`) in the `Authorization` header.

### VPCs

#### List existing VPCs

```console
curl \
    --request GET \
    --header "Content-Type: application/json" \
    --header "Authorization: Bearer ${DO_PAT}"
    'https://api.digitalocean.com/v2/vpcs' \
    | jq
```

#### Remove a VPC

```console
curl \
    --request DELETE \
    --header "Content-Type: application/json" \
    --header "Authorization: Bearer ${DO_PAT}"
    'https://api.digitalocean.com/v2/vpcs/<vpc_id>' \
    | jq
```
