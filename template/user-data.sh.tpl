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
  yum -y install docker jq
}

install_runner() {
  curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh | bash
  yum -y install gitlab-runner
}

edit_config_toml() {
  sed -i '
    s/^concurrent =/concurrent = '"${gitlab_runner_concurrency}"'/
  ' /etc/gitlab-runner/config.toml
}

start_runner() {
  service docker start
  service gitlab-runner start
  chkconfig gitlab-runner on
}

register_runner() {
  gitlab-runner register --non-interactive --executor 'docker' \
    --url "${gitlab_runner_url}" --name "${gitlab_runner_name}" \
    --registration-token "${gitlab_runner_registration_token}" \
    --docker-image "${gitlab_runner_docker_image}"
}

main() {
  update_hosts_file
  update_system
  install_deps
  install_runner
  edit_config_toml
  start_runner
  register_runner
}

if [ "$0" == "$BASH_SOURCE" ] ; then
  main
fi

# vim: set ft=sh:
