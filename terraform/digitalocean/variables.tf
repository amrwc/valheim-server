######################################################################################################################
# Secrets ############################################################################################################
######################################################################################################################
# DigitalOcean Personal Access Token. 
variable "do_token" {
  # Provided in the CLI. 
}

# Path to the SSH key which can access DO services.
variable "do_ssh_key_path" {
  # Provided in the CLI.
}

# Name of the SSH key added to DigitalOcean.
variable "do_terraform_ssh_key_name" {
  default = "id_ed25519_digitalocean_terraform"
}

######################################################################################################################
# DigitalOcean Droplet settings. See: https://slugs.do-api.dev #######################################################
######################################################################################################################
variable "droplet_image_type" {
  default = "docker-20-04"
}

variable "droplet_region" {
  default = "fra1"
}

# If the server is not performing well enough, try upgrading the Droplet.
variable "droplet_size" {
  default = "s-2vcpu-4gb"
}

######################################################################################################################
# Valheim server-specific variables ##################################################################################
######################################################################################################################
# Name of the dedicated server.
variable "valheim_server_name" {
  default = "Valheim Docker DigitalOcean"
}

# Password used to log into the server. Requires 5 chars at a minimum.
variable "valheim_server_password" {
  default = "hunter2"
}

# Name of the world -- use the name of the files in `worlds/` dir.
variable "valheim_world_name" {
  default = "Default"
}

# Path to the local saves parent directory (the one above `worlds/`). If the game is installed on the local system, the
# path should be something like this: C:\Users\%USERPROFILE%\AppData\LocalLow\IronGate\Valheim\worlds
# Defaults to the directory present in the repository.
variable "valheim_local_saves" {
  default = "../../valheim/saves"
}

######################################################################################################################
# Miscellaneous ######################################################################################################
######################################################################################################################
# Whether this execution is a test provision.
variable "test" {
  default = "false"
}

resource "random_pet" "random_pet" {
  length    = 2
  separator = "-"
}

resource "random_integer" "octet3" {
  min = 0
  max = 255
}

resource "random_integer" "octet4" {
  min = 0
  max = 255
}
