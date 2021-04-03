locals {
  random_pet    = random_pet.random_pet.id
  random_octet3 = random_integer.octet3.result
  random_octet4 = random_integer.octet4.result

  valheim = var.test ? {
    project_name  = "Valheim-${local.random_pet}"
    network_name  = "valheim-network-${local.random_pet}"
    droplet_name  = "Valheim-Server-${local.random_pet}"
    firewall_name = "valheim-firewall-${local.random_pet}"
    vpc_ip_range  = "10.10.${local.random_octet3}.${local.random_octet4}/24"
    } : {
    project_name  = "Valheim-${var.valheim_server_name}"
    network_name  = "valheim-network-${var.valheim_server_name}"
    droplet_name  = "Valheim-Server-${var.valheim_server_name}"
    firewall_name = "valheim-firewall-${var.valheim_server_name}"
    vpc_ip_range  = var.vpc_ip_range
  }
}

# Create a new project
resource "digitalocean_project" "valheim_project" {
  name        = local.valheim["project_name"]
  description = "A project to group Valheim server-related resources."
  purpose     = "Service or API"
  environment = "Production"
}

# Create a Virtual Private Cloud (VPC) – a private network
# See: https://www.digitalocean.com/community/tutorials/understanding-ip-addresses-subnets-and-cidr-notation-for-networking
resource "digitalocean_vpc" "valheim_vpc" {
  name     = local.valheim["network_name"]
  region   = var.droplet_region
  ip_range = local.valheim["vpc_ip_range"]
}

# Create a new Droplet
resource "digitalocean_droplet" "valheim_droplet" {
  image              = var.droplet_image_type
  name               = local.valheim["droplet_name"]
  region             = var.droplet_region
  size               = var.droplet_size
  vpc_uuid           = digitalocean_vpc.valheim_vpc.id
  private_networking = true
  # Add the given SSH keys to the instance to allow remote provisioning.
  ssh_keys = [
    data.digitalocean_ssh_key.do_terraform_ssh_key.id,
  ]

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(pathexpand(var.do_ssh_key_path))
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      # Required by the file provisioner.
      "mkdir -p /root/valheim/saves"
    ]
  }

  # Copy over the save files -- they'll be mounted into the Docker container.
  provisioner "file" {
    # NOTE: The trailing slash is required for the provisioner to only copy the contents from the given directory into
    # the specified path -- it won't generate the specified destination path.
    # `pathexpand()` transforms `~` into an absolute path, and removes the trailing slash to prevent doubling it.
    # See: https://www.terraform.io/docs/language/resources/provisioners/file.html#directory-uploads
    # See: https://www.terraform.io/docs/language/functions/pathexpand.html
    source      = "${pathexpand(var.valheim_local_saves)}/"
    destination = "/root/valheim/saves"
  }

  # Rewrite using `docker` resource when `provider` will support `depends_on` option.
  # See: https://github.com/hashicorp/terraform/issues/2430
  # See: https://registry.terraform.io/providers/kreuzwerker/docker
  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",

      "docker run --detach --name valheim_server \\",
      # All envars can available among the layers of the valheim tag: https://hub.docker.com/r/ich777/steamcmd/tags
      "    --env SRV_NAME=${var.valheim_server_name} \\",
      # Minimum 5 characters.
      "    --env SRV_PWD=${var.valheim_server_password} \\",
      # World name must match the title of the saves in `valheim/saves/worlds`.
      "    --env WORLD_NAME=${var.valheim_world_name} \\",
      # Allows debug output of `valheim_server.x86_64` into the Docker logs. See `/opt/scripts/start-server.sh` on the
      # Docker image for more details.
      "    --env DEBUG_OUTPUT=true \\",
      "    --publish 2456-2458:2456-2458/udp \\",
      "    --volume /root/valheim/saves:/serverdata/serverfiles/.config/unity3d/IronGate/Valheim \\",
      "    --volume /root/valheim/backups:/serverdata/serverfiles/Backups \\",
      "    ich777/steamcmd:valheim",
    ]
  }
}

# Assign the Droplet to the new project
resource "digitalocean_project_resources" "valheim_resource" {
  project = digitalocean_project.valheim_project.id
  resources = [
    digitalocean_droplet.valheim_droplet.urn,
  ]
}

# Add firewall rules
# NOTE: There was no real reason to push this resource to the bottom of the script, but these rules _may_ cause issues
# with pulling the Docker image if it's before the `docker_image` resource.
resource "digitalocean_firewall" "valheim_droplet_firewall" {
  name = local.valheim["firewall_name"]

  droplet_ids = [
    digitalocean_droplet.valheim_droplet.id,
  ]

  # Allow SSH inbound traffic.
  # NOTE: If possible, specify your exact public IP address here as to stop others from accessing this port.
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0"]
  }

  # Valheim server.
  inbound_rule {
    protocol         = "udp"
    port_range       = "2456-2458"
    source_addresses = ["0.0.0.0/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "2456-2458"
    destination_addresses = ["0.0.0.0/0"]
  }

  # Rules for Steam login and content download.
  # See: https://support.steampowered.com/kb_article.php?ref=8571-GLVN-8711
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "27015-27030"
    source_addresses = ["0.0.0.0/0"]
  }
  inbound_rule {
    protocol         = "udp"
    port_range       = "27015-27030"
    source_addresses = ["0.0.0.0/0"]
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "80"
    destination_addresses = ["0.0.0.0/0"]
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "443"
    destination_addresses = ["0.0.0.0/0"]
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "27015-27030"
    destination_addresses = ["0.0.0.0/0"]
  }
  # This rule is too forgiving -- though the ports specified on the support page linked above aren't enough. SteamCMD
  # fails to download all the required content and the script fails. Would be nice to revisit it, and only open the
  # ports that are actually used. Though remember that `netcat`, and other network analysis tools are not installed on
  # the Docker image by default -- the upstream Dockerfile needs tweaking.
  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0"]
  }
}
