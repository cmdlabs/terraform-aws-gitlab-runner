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

  vpc_id       = var.vpc_id
  subnet_ids   = var.subnet_ids

  gitlab_runner_concurrency = 10

  gitlab_runner_registration_config = {
    url                = "https://gitlab.com"
    name               = "test-runner"
    registration_token = var.registration_token
    docker_image       = "alpine:latest"
  }

  enable_ssh_access = var.enable_ssh_access
}
