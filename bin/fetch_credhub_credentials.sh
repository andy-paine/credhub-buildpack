#!/bin/bash
credhub login

for env_var in $(env | grep CREDHUB_ENV_); do
  env_var_name=${env_var%%=*}
  var_name=${env_var_name#CREDHUB_ENV_}

  credentials="$(credhub find -n ${!env_var_name} -j 2>/dev/null)"
  if [ $? -ne 0 ]; then
    echo "$var_name: Not set - unable to find any credentials matching \"${!env_var_name}\""
    continue
  fi

  credential_name="$(echo $credentials | jq -r '.credentials[0].name')"
  matches="$(echo $credentials | jq -r '.credentials | length')"
  echo -n "$var_name: Set to value of $credential_name"
  if [ $matches -gt 1 ]; then
    echo " [WARNING: Found $matches credentials matching \"${!env_var_name}\", using first in list]"
  else
    echo ""
  fi
  export $var_name="$(credhub get -n $credential_name -j | jq -r '.value')"
done
