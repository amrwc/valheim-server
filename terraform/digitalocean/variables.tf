######################################################################################################################
# Secrets ############################################################################################################
######################################################################################################################
variable "do_token" {
  description = "DigitalOcean Personal Access Token."
}

variable "do_ssh_key_path" {
  description = "Path to the SSH key which can access DO services."
}

variable "do_terraform_ssh_key_name" {
  description = "Name of the SSH key added to DigitalOcean."
  default     = "id_ed25519_digitalocean_terraform"
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

# It only becomes important when there are multiple VPCs on the account which may overlap.
variable "vpc_ip_range" {
  default = "10.10.10.2/24"
}

######################################################################################################################
# Valheim server-specific variables ##################################################################################
######################################################################################################################
variable "valheim_server_name" {
  description = "Name of the dedicated server (without spaces)."
  default     = "Terraformed"
}

variable "valheim_server_password" {
  description = "Password used to log into the server. Requires 5 chars at a minimum."
  default     = "hunter2"
}

variable "valheim_world_name" {
  description = "Name of the world -- name of the files in `worlds/` dir."
  default     = "Default"
}

# If the game is installed on the local system, the path should be something like this:
# C:/Users/<USERNAME>/AppData/LocalLow/IronGate/Valheim
# NOTE: Backslashes are not supported.
# Defaults to the `valheim/saves` directory present in the repository.
variable "valheim_local_saves" {
  description = "Path to the local saves parent directory (the one above `worlds/`)."
  default     = "../../valheim/saves"
}

######################################################################################################################
# Miscellaneous ######################################################################################################
######################################################################################################################
variable "test" {
  description = "Whether this execution is a test provision."
  default     = false
  type        = bool
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
