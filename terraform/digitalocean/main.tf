variable "image_type" {
  # https://slugs.do-api.dev
  default = "docker-20-04"
}
variable "region" {
  # https://slugs.do-api.dev
  default = "fra1"
}
variable "size" {
  # https://slugs.do-api.dev
  default = "s-1vcpu-1gb"
}
//variable "vpc_uuid" {
//  # UUID of the DigitalOcean project. Leave empty to add the resource to the default project.
//  # Use the API to obtain the list of VPCs: https://developers.digitalocean.com/documentation/v2/#list-all-vpcs
//  default = ""
//}
//variable "gh_username" {
//  # GitHub username used for accessing the private repository.
//  # Provided in the CLI.
//}
//variable "gh_pat" {
//  # GitHub Personal Access Token for accessing the private repository.
//  # Provided in the CLI.
//}

# Create new project
resource "digitalocean_project" "valheim_project" {
  name        = "Valheim"
  description = "A project to group Valheim-related resources."
  purpose     = "Service or API"
  environment = "Production"
}

# Create a Virtual Private Cloud (VPC) – a private network
resource "digitalocean_vpc" "valheim_vpc" {
  name     = "valheim-network"
  region   = var.region
  ip_range = "10.10.10.0/24"
}

# Create a new Droplet
resource "digitalocean_droplet" "valheim_droplet" {
  image = var.image_type
  name = "Valheim-Server"
  region = var.region
  size = var.size
  vpc_uuid = digitalocean_vpc.valheim_vpc.id
  private_networking = true
  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]

  connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    private_key = file(var.private_ssh_key)
    timeout = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      "docker pull 'mbround18/valheim:1.2.0'"
    ]
  }
}

# Assign the Droplet to the new project
resource "digitalocean_project_resources" "valheim_resource" {
  project = digitalocean_project.valheim_project.id
  resources = [
    digitalocean_droplet.valheim_droplet.urn
  ]
}
