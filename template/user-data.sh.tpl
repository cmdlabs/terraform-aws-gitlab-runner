#!/usr/bin/env bash

update_hosts_file() {
  local host_name="$(hostname)"
  echo "\
127.0.0.1   localhost localhost.localdomain $host_name" \
  >> /etc/hosts
}

update_system() {
  yum -y update
}

install_deps() {
  yum -y install aws-cli jq
}

edit_config_toml() {
  sed -i '
    s/^concurrent =/concurrent = '"${gitlab_runner_concurrency}"'/
  ' /etc/gitlab-runner/config.toml
}

install_runner() {
  curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh | bash
  yum -y install gitlab-runner
}

register_runner() {
  gitlab-runner register --non-interactive --executor 'docker' \
    --url "${gitlab_runner_url}" --name "${gitlab_runner_name}" \
    --registration-token "${gitlab_runner_registration_token}" \
    --docker-image "${gitlab_runner_docker_image}"
}

start_runner() {
  service gitlab-runner restart
  chkconfig gitlab-runner on
}

main() {
  update_hosts_file
  update_system
  install_deps
  edit_config_toml
  install_runner
  register_runner
  #start_runner
}

if [ "$0" == "$BASH_SOURCE" ] ; then
  main
fi

# vim: set ft=sh:
