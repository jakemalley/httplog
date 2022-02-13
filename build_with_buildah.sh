#!/usr/bin/env bash
# script for building httplog using buildah

set -eux

# output image
readonly OUTPUT_IMAGE=docker.io/jakemalley/httplog:latest

# base image
readonly BASE_IMAGE=docker.io/golang:1.17-alpine

## build container
go_builder=$(buildah from "${BASE_IMAGE}")
go_builder_mnt=$(buildah mount $go_builder)

buildah run $go_builder -- sh -c "echo 'nobody:x:65534:65534:nobody:/:/sbin/nologin' > /etc/passwd.nobody"
buildah run $go_builder -- mkdir -p /build /go/src/github.com/jakemalley/httplog
buildah config --workingdir="/go/src/github.com/jakemalley/httplog" $go_builder
buildah copy $go_builder go.mod *.go .

buildah run $go_builder -- go mod download
buildah run $go_builder -- sh -c "CGO_ENABLED=0 GOOS=linux go build -a -o /build/httplog *.go"

## run container
go_runner=$(buildah from scratch)

buildah copy $go_runner $go_builder_mnt/etc/passwd.nobody /etc/passwd
buildah copy $go_runner $go_builder_mnt/build/httplog /httplog

buildah config --user="nobody" $go_runner
buildah config --port="8888" $go_runner
buildah config --cmd="/httplog" $go_runner

## commit
buildah commit $go_runner "${OUTPUT_IMAGE}"

## cleanup
buildah unmount $go_builder
buildah rm $go_builder $go_runner

