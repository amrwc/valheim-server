output "droplet_public_ip" {
  value = digitalocean_droplet.valheim_droplet.ipv4_address
}
