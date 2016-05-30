#!/bin/bash

set -o errexit
set -o pipefail

export GO15VENDOREXPERIMENT=1
export GOOS=linux

cd ${GOPATH}/src/github.com/docker/swarm
go get -v github.com/tools/godep
CGO_ENABLED=0 ${GOPATH}/bin/godep go build -v -a -tags netgo -installsuffix netgo -ldflags '-extldflags "-static" -s' .
cp swarm /output/
