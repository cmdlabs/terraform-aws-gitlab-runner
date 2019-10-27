#!/usr/bin/env bash

. shunit2/test_helper.sh

vars=(
  AWS_ACCESS_KEY_ID
  AWS_SECRET_ACCESS_KEY
  TF_VAR_registration_token
  TF_VAR_enable_ssh_access
  TF_VAR_vpc_id
  TF_VAR_subnet_ids
  TF_VAR_key_name
)
validateVars

[ ! -f ~/.ssh/"$TF_VAR_key_name".pem ] && err "EC2 private key not found"

execBySsh() {
  local ip_address="$1"
  local command="$2"
  ssh -o 'StrictHostKeyChecking no' -i ~/.ssh/"$TF_VAR_key_name".pem ec2-user@"$ip_address" "$command"
}

testSimple() {
  cd simple

  if ! terraform apply -auto-approve ; then
    fail "terraform did not apply"
    startSkipping
  fi

  cd ..

  sleep 20

  ip_address=$(aws ec2 describe-instances --query \
'Reservations[].Instances[?Tags[?Key==`aws:autoscaling:groupName`&&Value==`gitlab-runner-autoscaling-group`]].PublicIpAddress' \
    --output text)

  c=0
  while ! execBySsh "$ip_address" "grep Cloud-init.*finished /var/log/cloud-init-output.log" ; do
    sleep 20
    ((++c))

    if [ $c -gt 10 ] ; then
      fail "Cloud-init did not finish after 10 retries"
      startSkipping
    fi
  done
}

testRunnerRegistered() {
  execBySsh "$ip_address" "grep 'Runner registered successfully' /var/log/cloud-init-output.log"
  assertTrue "Runner registered successfully not seen in log" "$?"
}

oneTimeTearDown() {
  if [ "$NO_TEARDOWN" != "true" ] ; then
    cd simple
    terraform destroy -auto-approve
    cd ..
  fi
}

. shunit2
