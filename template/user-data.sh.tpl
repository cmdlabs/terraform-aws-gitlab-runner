#!/usr/bin/env bash

update_hosts_file() {
  echo "\
127.0.0.1   localhost localhost.localdomain $(hostname)" \
  >> /etc/hosts
}

update_system() {
  yum -y update
}

install_deps() {
  yum -y install aws-cli jq
}

edit_config_toml() {
  :
}

install_gitlab_runner() {
  curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh | bash
  yum -y install gitlab-runner
}

register_runner() {
  registration_token="${gitlab_runner_registration_token}"
  # TODO.
}

start_gitlab_runner() {
  service gitlab-runner restart
  chkconfig gitlab-runner on
}

main() {
  update_hosts_file
  update_system
  install_deps
  edit_config_toml
  install_gitlab_runner
  register_runner
  #start_gitlab_runner
}

if [ "$0" == "$BASH_SOURCE" ] ; then
  main
fi

# vim: set ft=sh:
