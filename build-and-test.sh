#!/bin/bash

# script to execute a test build

# enable shell echo of all commands as they are run using set -x
set -x

# enable quitting the shell script on any error exit using set -e
set -e

# remove the plugin if installed earlier
docker plugin disable docker-log-driver-test || true
docker plugin rm docker-log-driver-test || true

# remove build file system stuff
rm -rf rootfs || true

# build the plugin image
docker  build -f Dockerfile -t docker-log-driver-test .

# export image to filesystem
ID="`docker create  docker-log-driver-test true`"
echo $ID
mkdir rootfs
docker export $ID | tar -x -C rootfs
docker rm -v $ID

# convert filesystem to registered plugin
docker plugin create docker-log-driver-test .
docker plugin enable docker-log-driver-test
docker plugin ls

# remove old instance of test container
docker rm -vf my-test-container || true

# run test container, and capture it's ID in a variable
ID="`docker run --name my-test-container --log-driver docker-log-driver-test -d busybox echo -n 'This is a test!'`"
echo $ID

# show that the log file is closed (fuser otherwise shows the process id of the owner)
fuser /var/lib/docker/containers/$ID/$ID-json.log || true

# show the output in the file
cat /var/lib/docker/containers/$ID/$ID-json.log


