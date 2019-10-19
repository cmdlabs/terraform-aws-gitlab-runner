#!/usr/bin/env bash

testValidateJSON() {
  for f in policies/* ; do
    assertTrue "$f contains invalid JSON" "jq . $f"
  done
}

. shunit2
