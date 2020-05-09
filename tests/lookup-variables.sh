#!/usr/bin/env bash
set -eu

function delete_creds {
    credhub delete -n /test-org/foo
    credhub delete -n /test-org/test-space/foo
    credhub delete -n /test-org/test-space/test-app/foo
    credhub delete -n /my-base-path/foo/baz
}
trap delete_creds EXIT

function get_org_scoped_value {
    credhub set -n /test-org/foo -t value -v testvalue
    export CREDHUB_ENV_CH_ORG_TEST_VALUE='/$CF_ORG/foo'
    source fetch-credhub-credentials.sh

    if [ "$CH_ORG_TEST_VALUE" != "testvalue" ]; then
      echo "CH_ORG_TEST_VALUE: $CH_ORG_TEST_VALUE does not equal 'testvalue'"
      exit 1
    fi
    unset CREDHUB_ENV_CH_ORG_TEST_VALUE
}

function get_space_scoped_value {
    credhub set -n /test-org/test-space/foo -t value -v testvalue
    export CREDHUB_ENV_CH_SPACE_TEST_VALUE='/$CF_ORG/$CF_SPACE/foo'
    source fetch-credhub-credentials.sh

    if [ "$CH_SPACE_TEST_VALUE" != "testvalue" ]; then
      echo "CH_SPACE_TEST_VALUE: $CH_SPACE_TEST_VALUE does not equal 'testvalue'"
      exit 1
    fi
    unset CREDHUB_ENV_CH_SPACE_TEST_VALUE
}

function get_app_scoped_value {
    credhub set -n /test-org/test-space/test-app/foo -t value -v testvalue
    export CREDHUB_ENV_CH_APP_TEST_VALUE='/$CF_ORG/$CF_SPACE/$CF_APP/foo'
    source fetch-credhub-credentials.sh

    if [ "$CH_APP_TEST_VALUE" != "testvalue" ]; then
      echo "CH_APP_TEST_VALUE: $CH_APP_TEST_VALUE does not equal 'testvalue'"
      exit 1
    fi
    unset CREDHUB_ENV_CH_APP_TEST_VALUE
}

function get_custom_base_path_value {
    credhub set -n /my-base-path/foo/baz -t value -v testvalue
    export CREDHUB_BASE_PATH=/my-base-path
    export CREDHUB_ENV_CH_BASE_PATH_TEST_VALUE='/foo/baz'
    source fetch-credhub-credentials.sh

    if [ "$CH_BASE_PATH_TEST_VALUE" != "testvalue" ]; then
      echo "CH_BASE_PATH_TEST_VALUE: $CH_BASE_PATH_TEST_VALUE does not equal 'testvalue'"
      exit 1
    fi
    unset CREDHUB_ENV_CH_BASE_PATH_TEST_VALUE
    unset CREDHUB_BASE_PATH
}

get_org_scoped_value
get_space_scoped_value
get_app_scoped_value
get_custom_base_path_value