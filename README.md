# env-map-buildpack

Allows for fetching of secrets at runtime from CredHub into environment variables for apps. Requires bundling with `credhub` CLI.

## Background

When deploying applications to Cloud Foundry, sometimes it is not possible to modify those applications to read secrets such as credentials from CredHub directly. This buildpack utilizes the `profile.d` directory to supply a script that will export environment variables based CredHub variable lookups. Any scripts present in the `profile.d` directory will be `source`d when the application starts up.

## Usage

> Note: This is currently non-functional until the `credhub` CLI is bundled with it.
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

For example, including an environment variable called `CREDHUB_ENV_FOO: /foo/bar/baz` will provide the application with the `FOO` environment variable with the contents of the secret at `/foo/bar/baz` in CredHub. Secrets are looked up based on name (`credhub find -n <name>`). When multiple secrets are found, the first returned result is used and a warning output to the logs.

