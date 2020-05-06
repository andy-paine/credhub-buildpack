#!/usr/bin/env bash
set -eu

function delete_creds {
    credhub delete -n /foo/bar/value
    credhub delete -n /foo/bar/password
}
trap delete_creds EXIT

function get_value {
    credhub set -n /foo/bar/value -t value -v testvalue
    export CREDHUB_ENV_CH_TEST_VALUE=/foo/bar/value
    source ./bin/fetch_credhub_credentials.sh

    if [ "$CH_TEST_VALUE" != "testvalue" ]; then
      echo "CH_TEST_VALUE: $CH_TEST_VALUE does not equal 'testvalue'"
      exit 1
    fi
}

function get_password {
    credhub set -n /foo/bar/password -t password -w testpassword
    export CREDHUB_ENV_CH_TEST_PASSWORD=/foo/bar/password
    source ./bin/fetch_credhub_credentials.sh

    if [ "$CH_TEST_PASSWORD" != "testpassword" ]; then
      echo "CH_TEST_PASSWORD: $CH_TEST_PASSWORD does not equal 'testpassword'"
      exit 1
    fi
}

get_value
get_password