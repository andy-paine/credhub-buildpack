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

### Environment variables
Include an environment variable of the format `CREDHUB_ENV_FOO=/foo/bar/baz` to set the value of the `FOO` environment variable at runtime with the contents of the `/foo/bar/baz` credential from CredHub.

### Files
Include an environment variable of the format `CREDHUB_FILE_password=/foo/bar/password` to create a file called `password` with the contents of the `/foo/bar/baz` credential from CredHub. Files are written to `/tmp/credhub-files/`. This can be overridden by setting the `CREDHUB_FILES_DIR` environment variable.

### Lookups
Secret paths are absolute by default. A custom base path for lookups can be specified by setting the `CREDHUB_BASE_PATH` environment variable. The following placeholders can be used in credentials paths and will be populated with the information of the application at runtime:
* CF_ORG
* CF_SPACE
* CF_APP

This allows users to structure their CredHub secrets in a way that matches Cloud Foundry. For example, to keep the same application configuration in multiple different environments, the environment variable `CREDHUB_ENV_PASSWORD=/$CF_SPACE/password` could be used which would be populated by the credential at `/dev/password` or `/staging/password` etc. depending on the space in which the application was deployed.

### Selectors
The JSON and certificate credential types in CredHub often need components extracting out of them. These components can be selected by adding a `.` followed by the relevant `jq` selector when specifying the credential path.

### Examples
A full list of tested example formats can be found in the [tests/ directory](tests/).
| Credential | Value | Type | Environemnt variable | Result |
| ---------- | ----- | ---- | -------------------- | ------ |
| /foo/bar   | baz   | value | CREDHUB_ENV_BAR=/foo/bar | FOO=baz |
| /foo/baz   | faz   | password | CREDHUB_ENV_PASSWORD=/foo/baz | PASSWORD=faz |
| /foo/jazz  | {"key": "value"} | json | CREDHUB_ENV_JSON=/foo/jazz | JSON={"key": "value"} |
| /foo/cert  | **credhub certificate** | certificate | CREDHUB_ENV_CERT_CA=/foo/cert.ca | CERT_CA=-----BEGIN CERTIFICATE-----  etc. |
| /foo/cert  | **credhub certificate** | certificate | CREDHUB_FILE_my_ca_cert | /tmp/credhub-files/my_ca_cert -> CA from /foo/cert |

## Testing

There are some simple tests in the `tests/` directory for making sure this release works as expected and for allowing for some TDD when making changes. These expect a CredHub server to be stood up and the correct `CREDHUB_` credentials for authenticating against the server to be present. A simple way to get this working is to use [BUCC](https://github.com/starkandwayne/bucc).
