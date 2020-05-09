#!/usr/bin/env bash
set -eu
export PATH=$PATH:$PWD/bin
export VCAP_APPLICATION='{
  "organization_name": "test-org",
  "space_name": "test-space",
  "application_name": "test-app"
}'

for test in tests/*; do
  ./$test
  rm -rf /tmp/credhub-environment-variables
done