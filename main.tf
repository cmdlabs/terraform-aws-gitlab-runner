locals {
  gitlab_runner_ami_filter      = ["amzn2-ami-hvm-*-x86_64-ebs"]
  gitlab_runner_instance_type   = "t3.micro"
}

resource "aws_security_group" "runner" {
  name_prefix = "gitlab-runner-security-group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "runner_ssh" {
  count = var.enable_ssh_access ? 1 : 0

  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = var.ssh_cidr_blocks

  security_group_id = aws_security_group.runner.id
}

data "template_file" "user_data" {
  template = file("${path.module}/template/user-data.sh.tpl")

  vars = {
    aws_region                       = var.aws_region
    gitlab_runner_url                = var.gitlab_runner_registration_config["url"]
    gitlab_runner_name               = var.gitlab_runner_registration_config["name"]
    gitlab_runner_registration_token = var.gitlab_runner_registration_config["registration_token"]
    gitlab_runner_docker_image       = var.gitlab_runner_registration_config["docker_image"]
    gitlab_runner_concurrency        = var.gitlab_runner_concurrency
  }
}

data "aws_ami" "runner" {
  most_recent = "true"

  filter {
    name   = "name"
    values = local.gitlab_runner_ami_filter
  }

  owners = ["amazon"]
}

resource "aws_launch_configuration" "gitlab_runner_instance" {
  security_groups      = [aws_security_group.runner.id]
  key_name             = var.key_name
  image_id             = data.aws_ami.runner.id
  user_data            = data.template_file.user_data.rendered
  instance_type        = local.gitlab_runner_instance_type
  iam_instance_profile = aws_iam_instance_profile.instance.name

  root_block_device {
    delete_on_termination = true
    volume_type           = "gp2"
    volume_size           = 8
  }

  associate_public_ip_address = var.enable_ssh_access

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "gitlab_runner_instance" {
  name                      = "gitlab-runner-autoscaling-group"
  vpc_zone_identifier       = var.subnet_ids
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  health_check_grace_period = 0
  launch_configuration      = aws_launch_configuration.gitlab_runner_instance.name
}
