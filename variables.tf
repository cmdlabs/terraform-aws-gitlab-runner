variable "aws_region" {
  description = "Name of S3 region for the runner cache and SSM"
  type        = string
}

variable "vpc_id" {
  description = "The target VPC for the docker-machine and runner instances"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnets used for hosting the GitLab runners"
  type        = list(string)
}

variable "key_name" {
  description = "The name of the EC2 key pair to use"
  type        = string
  default     = "default"
}

variable "enable_ssh_access" {
  description = "Enables SSH access to the GitLab Runner instance"
  type        = bool
  default     = false
}

variable "ssh_cidr_blocks" {
  description = "List of CIDR blocks to allow SSH Access to docker machine and the GitLab Runner"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "gitlab_runner_registration_config" {
  description = "Configuration used to register the runner"
  type        = map(string)

  default = {
    url                = ""
    name               = ""
    registration_token = ""
    docker_image       = ""
  }
}

variable "gitlab_runner_concurrency" {
  description = "Concurrent value for the runners"
  type        = number
  default     = 5
}
