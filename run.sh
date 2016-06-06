#!/bin/bash
docker stop pentaho-di
docker rm pentaho-di
docker run -d --name pentaho-di -p 9080:9080 -e Tier=TEST -e PGUSER=postgresadm -e PGPWD=8s88jjjChangeMe99aks88 -e PGHOST=pentaho-db -e PGPORT=5432 -e PGDATABASE=postgres --link pentaho-db:pentaho-db -v /docker/mounts/pentaho-di/opt/pentaho:/opt/pentaho pentaho-di:latest &

