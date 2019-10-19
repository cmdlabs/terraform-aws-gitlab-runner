variable "registration_token" {}

variable "enable_ssh_access" {
  default = false
}

variable "vpc_id" {}
variable "subnet_ids" {
  type = list(string)
}

module "runner" {
  source = "../../"

  key_name = "default"

  aws_region = "ap-southeast-2"

  vpc_id       = var.vpc_id
  subnet_ids   = var.subnet_ids

  gitlab_runner_registration_config = {
    registration_token = var.registration_token
    description        = "runner default - auto"
    locked_to_project  = "true"
    run_untagged       = "false"
    maximum_timeout    = "3600"
    access_level       = "not_protected"
  }

  enable_ssh_access = var.enable_ssh_access
}
