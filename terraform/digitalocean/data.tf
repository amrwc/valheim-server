# See: https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/ssh_key
data "digitalocean_ssh_key" "do_terraform_ssh_key" {
  name = var.do_terraform_ssh_key_name
}
