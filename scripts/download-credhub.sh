#!/usr/bin/env bash

version="$(cat CREDHUB_VERSION)"
curl -sLo credhub.tgz "https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/$version/credhub-linux-$version.tgz"
tar -xvf credhub.tgz -C bin
