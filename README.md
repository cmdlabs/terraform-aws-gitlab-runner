<!-- vim: set ft=markdown: -->
![CMD Solutions|medium](https://s3-ap-southeast-2.amazonaws.com/cmd-website-images/CMDlogo.jpg)

# terraform-aws-gitlab-runner

#### Table of contents

1. [Overview](#overview)
2. [AWS GitLab Runner Terraform](#aws-gitlab-runner-terraform)
    * [Inputs](#inputs)
    * [Registration config](#registration-config)
    * [Outputs](#outputs)
3. [Example](#example)
    * [Obtain a Registration Token](#obtain-a-registration-token)
    * [Add a .gitlab-ci.yml to a project](#add-a-gitlab-ciyml-to-a-project)
    * [Declare the module](#declare-the-module)
4. [License](#license)

## Overview

This module creates a simple GitLab CI Runner using a Docker executor on a long-lived AWS EC2 instance in an Auto Scaling Group.

## AWS GitLab Runner Terraform

### Inputs

The below outlines the current parameters and defaults.

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-------:|:--------:|
|vpc_id|The target VPC for hosting the GitLab Runner|string|""|Yes|
|subnet_ids|List of subnets for hosting the GitLab Runner|list(string)|""|Yes|
|key_name|The name of the EC2 key pair to use|string|default|No|
|enable_ssh_access|Enables SSH access to the GitLab Runner|bool|false|No|
|ssh_cidr_blocks|List of CIDR blocks to use if allowing SSH Access to the GitLab Runner|list(string)|[0.0.0.0/0]|No|
|gitlab_runner_registration_config|Configuration used to register the runner|map(string)|(map)|No|
|gitlab_runner_concurrency|Maximum number of jobs to allow the GitLab Runner to run concurrently|number|5|No|

### Registration config

In the gitlab_runner_registration_config variable pass the details needed to register the GitLab Runner. It accepts four keys:

- `url` - the GitLab URL e.g. https://gitlab.com
- `name` - the name of the GitLab Runner. This is informational only and forms the description
- `registration_token` - the Registration Token. See below for instructions on generating this
- `docker_image` - the Docker Image to be used by the Docker Executor e.g. alpine:latest

### Outputs

None.

## Example

### Obtain a Registration Token

See the GitLab docs [here](https://docs.gitlab.com/ee/ci/runners/#registering-a-specific-runner-with-a-project-registration-token).

- Go to the project in GitLab e.g. https://gitlab.com/alexharv074/test
- On the left hand side select Settings > CI/CD
- Under Runners Expand.

The registration token can be found from here.

Put the token in a tfvars file or in an environment variable:

```text
▶ export TF_VAR_registration_token=XXXXXXXXX
```

### Add a .gitlab-ci.yml to a project

Create a simple `.gitlab-ci.yml` file in the root of your project e.g.

```yaml
---
image: busybox:latest

build1:
  stage: build
  script:
    - echo "hello world"
```

### Declare the module

Here is an example usage:

```tf
variable "registration_token" {}

variable "enable_ssh_access" {
  default = false
}

variable "vpc_id" {}
variable "subnet_ids" {
  type = list(string)
}

variable "key_name" {}

module "runner" {
  source = "git@github.com:cmdlabs/terraform-aws-gitlab-runner.git"

  key_name   = var.key_name
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  gitlab_runner_concurrency = 10

  gitlab_runner_registration_config = {
    url                = "https://gitlab.com"
    name               = "test-runner"
    registration_token = var.registration_token
    docker_image       = "alpine:latest"
  }

  enable_ssh_access = var.enable_ssh_access
}
```

Apply that:

```text
▶ terraform apply
```

## License

Apache 2.0.
