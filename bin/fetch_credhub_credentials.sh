#!/bin/bash
credhub login

for env_var in $(env | grep CREDHUB_ENV_); do
  env_var_name=${env_var%%=*}
  var_name=${env_var_name#CREDHUB_ENV_}
  variable_query=${!env_var_name}
  variable_name=${variable_query%%.*}
  variable_selector=""
  # If it contains '.' then it has a selector
  if [[ $variable_query == *.* ]]; then
    variable_selector=".${variable_query#*.}"
  fi

  credentials="$(credhub find -n $variable_name -j 2>/dev/null)"
  if [ $? -ne 0 ]; then
    echo "$var_name: Not set - unable to find any credentials matching \"$variable_name\""
    continue
  fi

  credential_name="$(echo $credentials | jq -r '.credentials[0].name')"
  matches="$(echo $credentials | jq -r '.credentials | length')"
  echo -n "$var_name: Set to value of $variable_query"
  if [ $matches -gt 1 ]; then
    echo " [WARNING: Found $matches credentials matching \"${!env_var_name}\", using first in list]"
  else
    echo ""
  fi
  export $var_name="$(credhub get -n $credential_name -j | jq -r ".value${variable_selector}")"
done
