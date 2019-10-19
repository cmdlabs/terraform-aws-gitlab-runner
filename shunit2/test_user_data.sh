#!/usr/bin/env bash

testBashMinusN() {
  bash -n template/user-data.sh.tpl
  assertTrue "Syntax error detected" "$?"
}

. shunit2
