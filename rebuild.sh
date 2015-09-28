#!/bin/bash
#Script to rebuild the docker image from Dockerfile.
cd /docker/files/pentaho-di
docker stop pentaho-di; docker rm pentaho-di; docker rmi pentaho-di
docker build --no-cache -t pentaho-di .
