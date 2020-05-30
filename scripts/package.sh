#!/usr/bin/env bash

go get -u github.com/cloudfoundry/libbuildpack/packager/buildpack-packager
buildpack-packager build -stack cflinuxfs3 -cached
