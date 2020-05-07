#!/usr/bin/env bash
set -eu
export PATH=$PATH:$PWD/bin

for test in tests/*; do
  ./$test
  rm -rf /tmp/credhub-environment-variables
done