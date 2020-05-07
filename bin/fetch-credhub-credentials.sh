#!/usr/bin/env bash

env_dir="/tmp/credhub-environment-variables"
mkdir -p $env_dir && cd $env_dir
fetch-credhub-credentials.rb $env_dir
for env_var in *; do
  export $env_var="$(cat $env_var)"
done