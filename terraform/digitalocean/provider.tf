terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.6.0"
    }
  }
}

variable "do_token" {
  # DigitalOcean Personal Access Token. 
  # Provided in the CLI. 
}
variable "private_ssh_key" {
  # Path to the SSH key which can access DO services.
  # Provided in the CLI.
}

provider "digitalocean" {
  token = var.do_token
}

# Automatically add the SSH key to any new Droplets created.
# NOTE: Replace `id_ed25519_digitalocean_terraform` with the SSH key name added to DigitalOcean.
data "digitalocean_ssh_key" "terraform" {
  name = "id_ed25519_digitalocean_terraform"
}
