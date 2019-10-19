#!/usr/bin/env bash

if [ "$(uname -s)" == "Darwin" ] ; then
  if [ ! -x /usr/local/bin/gsed ] ; then
    echo "On Mac OS X you need to install gnu-sed:"
    echo "$ brew install gnu-sed"
    exit 1
  fi

  shopt -s expand_aliases
  alias base64='/usr/local/bin/gbase64'
  alias sed='/usr/local/bin/gsed'
fi

script_under_test='template/user-data.sh.tpl'

setUp() {
  . "$script_under_test"
}

testRegisterRunnerTokenNull() {
  aws() {
    case "${FUNCNAME[0]} $*" in

    "aws ssm get-parameters --names $runners_ssm_token_key --with-decryption --region $aws_region")
      echo '{"InvalidParameters":["'"$runners_ssm_token_key"'"],"Parameters":[]}' ;;

    "aws ssm put-parameter --overwrite --type SecureString --name $runners_ssm_token_key --value $token --region $aws_region")
      echo '{"Version":"1"}' ;;

    esac
  }

  curl() { echo '{"token":"ANOTHERSECRETTOKEN"}' ; }

  config_toml='./test_config.toml'

  cat > "$config_toml" <<EOF
foo bar foo bar
this line has ##TOKEN## in it
baz qux baz qux
EOF

  runners_ssm_token_key='/mykey'
  aws_region='ap-southeast-2'
  runners_url='https://gitlab.com'
  gitlab_runner_registration_token='XXXXXXXX'
  gitlab_runner_description='my runner'
  gitlab_runner_locked_to_project='true'
  gitlab_runner_maximum_timeout='10'
  gitlab_runner_access_level='debug'
  gitlab_runner_log_group_name='gitlab-runner-log-group'

  register_runner

  assertTrue "$config_toml does not have secret token in it" "grep -q ANOTHERSECRETTOKEN $config_toml"

  rm -f "$config_toml"
}

testRegisterRunnerWithError() {
  aws() {
    case "${FUNCNAME[0]} $*" in

    "aws ssm get-parameters --names $runners_ssm_token_key --with-decryption --region $aws_region")
      echo '{"InvalidParameters":["'"$runners_ssm_token_key"'"],"Parameters":[]}' ;;

    esac
  }

  curl() { echo '{"message":{"tags_list":["can not be empty when runner is not allowed to pick untagged jobs"]}}' ; }

  config_toml='./test_config.toml'

  cat > "$config_toml" <<EOF
foo bar foo bar
this line has ##TOKEN## in it
baz qux baz qux
EOF

  runners_ssm_token_key='/mykey'
  aws_region='ap-southeast-2'
  runners_url='https://gitlab.com'
  gitlab_runner_registration_token='XXXXXXXX'
  gitlab_runner_description='my runner'
  gitlab_runner_locked_to_project='true'
  gitlab_runner_maximum_timeout='10'
  gitlab_runner_access_level='debug'
  gitlab_runner_log_group_name='gitlab-runner-log-group'

  register_runner

  assertTrue "$config_toml has been unexpectedly edited" "grep -q '##TOKEN##' $config_toml"

  rm -f "$config_toml"
}

. shunit2
