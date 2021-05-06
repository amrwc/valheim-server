# Valheim Server Terraformed

Provisioning Valheim servers with ease – infrastructure as code, and all that.

Refer to cloud provider-specific instructions under `terraform/`.

## Table of contents

- [DigitalOcean](./terraform/digitalocean/README.md)

## General tips and troubleshooting

### VM performance and world size

When the server is built and started, it loads the world. It can take a while
if the given world is vast, and may even fail to load at all if the performance
of the VM is insufficient. To debug such an issue, SSH into the server, and
view the logs of the Docker container:

```console
ssh -i <path_to_private_key> root@<ip_address>
docker logs [--follow] valheim_server
```

If you see a log, such as the following, and nothing seems to happen
afterwards while the VM utilises a lot of resources, it means that the world is
still being loaded. If it persists for longer than, say, 15 minutes, increase
the VM size and try again.

```text
04/03/2021 12:47:22: Starting to load scene:start
```

## See also

- [Valheim server on Amazon Lightsail](https://aws.amazon.com/getting-started/hands-on/valheim-on-aws)
