#!/usr/bin/env bash
set -eu

export CREDHUB_FILES_DIR=/tmp/ch-tests

function delete_creds {
    credhub delete -n /foo/bar/value
    rm -rf $CREDHUB_FILES_DIR
}
trap delete_creds EXIT

function get_value_file {
    credhub set -n /foo/bar/value -t value -v testvalue
    export CREDHUB_FILE_ch_test_value=/foo/bar/value
    source fetch-credhub-credentials.sh

    if [ "$(cat $CREDHUB_FILES_DIR/ch_test_value)" != "testvalue" ]; then
      echo "ch_test_file contents: $(cat $CREDHUB_FILES_DIR/ch_test_value) do not equal 'testvalue'"
      exit 1
    fi
    unset CREDHUB_FILE_ch_test_value
}

function get_certificate {
    credhub generate -n /foo/bar/certificate -t certificate -c "foo.com" --self-sign
    export CREDHUB_FILE_ch_test_ca=/foo/bar/certificate.ca
    source fetch-credhub-credentials.sh

    if [ "$(openssl x509 -in $CREDHUB_FILES_DIR/ch_test_ca -subject -noout)" != "subject= /CN=foo.com" ]; then
      echo "ch_test-ca contents: $(cat $CREDHUB_FILES_DIR/ch_test_ca) does not have a subject of 'subject= /CN=foo.com'"
      exit 1
    fi
    unset CREDHUB_FILE_ch_test_ca
}

get_value_file
get_certificate