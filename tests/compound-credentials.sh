#!/usr/bin/env bash
set -eu

function delete_creds {
    credhub delete -n /foo/bar/compound_json
}
trap delete_creds EXIT

function get_single_json_field {
    credhub set -n /foo/bar/compound_json -t json -v '{ "foo": "bar" }'
    export CREDHUB_ENV_CH_TEST_COMPOUND_JSON=/foo/bar/compound_json.foo
    source ./bin/fetch_credhub_credentials.sh

    if [ "$CH_TEST_COMPOUND_JSON" != "bar" ]; then
      echo "CH_TEST_COMPOUND_JSON: $CH_TEST_COMPOUND_JSON does not equal 'bar'"
      exit 1
    fi
}

get_single_json_field