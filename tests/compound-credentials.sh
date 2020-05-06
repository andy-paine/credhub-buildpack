#!/usr/bin/env bash
set -eu

function delete_creds {
    credhub delete -n /foo/bar/compound_json
    credhub delete -n /foo/bar/nested_json
    credhub delete -n /foo/bar/array_json
    credhub delete -n /foo/bar/certificate
    rm /tmp/ch-test.crt
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
    unset CREDHUB_ENV_CH_TEST_COMPOUND_JSON
}

function get_nested_json_field {
    credhub set -n /foo/bar/nested_json -t json -v '{ "foo": { "bar": "baz" } }'
    export CREDHUB_ENV_CH_TEST_NESTED_JSON=/foo/bar/nested_json.foo.bar
    source ./bin/fetch_credhub_credentials.sh

    if [ "$CH_TEST_NESTED_JSON" != "baz" ]; then
      echo "CH_TEST_NESTED_JSON: $CH_TEST_NESTED_JSON does not equal 'baz'"
      exit 1
    fi
    unset CREDHUB_ENV_CH_TEST_NESTED_JSON
}

function get_array_selected_json_field {
    credhub set -n /foo/bar/array_json -t json -v '{ "foo": ["bar", "baz"] }'
    export CREDHUB_ENV_CH_TEST_ARRAY_JSON=/foo/bar/array_json.foo[0]
    source ./bin/fetch_credhub_credentials.sh

    if [ "$CH_TEST_ARRAY_JSON" != "bar" ]; then
      echo "CH_TEST_ARRAY_JSON: $CH_TEST_ARRAY_JSON does not equal 'bar'"
      exit 1
    fi
    unset CREDHUB_ENV_CH_TEST_ARRAY_JSON
}

function get_certificate_field {
    credhub generate -n /foo/bar/certificate -t certificate -c "foo.com" --self-sign
    export CREDHUB_ENV_CH_TEST_CERT=/foo/bar/certificate.certificate
    source ./bin/fetch_credhub_credentials.sh

    echo "$CH_TEST_CERT" > /tmp/ch-test.crt
    if [ "$(openssl x509 -in /tmp/ch-test.crt -subject -noout)" != "subject= /CN=foo.com" ]; then
      echo "CH_TEST_CERT: $CH_TEST_CERT does not have a subject of 'subject= /CN=foo.com'"
      exit 1
    fi
    unset CREDHUB_ENV_CH_TEST_CERT
}

get_single_json_field
get_nested_json_field
get_array_selected_json_field
get_certificate_field