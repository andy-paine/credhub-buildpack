# credhub-buildpack

Allows for fetching of secrets at runtime from CredHub into environment variables for apps.

## Background

When deploying applications to Cloud Foundry, sometimes it is not possible to modify those applications to read secrets such as credentials from CredHub directly. This buildpack utilizes the `profile.d` directory to supply a script that will export environment variables based CredHub variable lookups. Any scripts present in the `profile.d` directory will be `source`d when the application starts up.

## Usage

To use this buildpack, include [https://github.com/andy-paine/credhub-buildpack](https://github.com/andy-paine/credhub-buildpack) anywhere but the last element in the `buildpacks` field in your Cloud Foundry manifest, for example:
```yaml
buildpacks:
  - https://github.com/andy-paine/credhub-buildpack
  - python_buildpack
```

Authentication to a CredHub server is done by the `credhub` CLI using following environment variables:
```
CREDHUB_SERVER - URL of CredHub server
CREDHUB_CA_CERT - CA certificate of CredHub server
CREDHUB_CLIENT - UAA client ID
CREDHUB_SECRET - UAA client secret
```

The buildpack will then provide a script that at runtime will export any environment variables starting with `CREDHUB_ENV_` with the value of the secret from CredHub.

For example, including an environment variable `CREDHUB_ENV_FOO=/foo/bar/baz` will set the value of the `FOO` environment variable with the contents of the credential `/foo/bar/baz` from CredHub. Secrets are looked up based on name (`credhub find -n <name>`). When multiple secrets are found, the first returned result is used and a warning output to the logs.

### Compound credentials
The JSON and certificate credential types in CredHub often need components extracting out of them. You can select these components by adding a `.` followed by the relevant `jq` selector when specifying the credential path. For example, given the following CredHub credential:
```
$ credhub get -n /some/json
id: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
name: /some/json
type: json
value:
  foo: bar
version_created_at: "2020-05-06T20:43:07Z"
```
Setting an environment variable of `CREDHUB_ENV_FOO=/some/json.foo` will set the value of the `FOO` environment variable to be `bar`.

## Testing

There are some simple tests in the `tests/` directory for making sure this release works as expected and for allowing for some TDD when making changes. These expect a CredHub server to be stood up and the correct `CREDHUB_` credentials for authenticating against the server to be present. A simple way to get this working is to use [BUCC](https://github.com/starkandwayne/bucc)
