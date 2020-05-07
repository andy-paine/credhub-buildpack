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

get_value_file