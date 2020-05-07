#!/usr/bin/env bash
set -eu

env_dir="/tmp/credhub-environment-variables"
file_dir="${CREDHUB_FILES_DIR:-/tmp/credhub-files}"
mkdir -p $env_dir $file_dir
fetch-credhub-credentials.rb $env_dir $file_dir
for env_var in $(ls $env_dir); do
  export $env_var="$(cat $env_dir/$env_var)"
done