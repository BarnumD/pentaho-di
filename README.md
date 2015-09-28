# Pentaho-DI
Dockerized implementation of Pentaho DI (Data Integration)

# To Run:
Clone this repository
Edit the install_pentaho_di...sh file and give it a URL to download the software.
Build the docker image for this and pentaho-db
Run pentaho-db: docker run -d --name pentaho-db -d -p 5432:5432 -v /docker/mounts/pentaho-db/var/lib/postgresql/data:/var/lib/postgresql/data pentaho-db
Run pentaho-di: docker run -d --name pentaho-di -p 9080:9080 -e TIER=TEST -e PGUSER=postgresadm -e PGPWD=8s88jjjChangeMe99aks88 -e PGHOST=pentaho-db -e PGPORT=5432 -e PGDATABASE=postgres --link pentaho-db:pentaho-db -v /docker/mounts/pentaho-di/opt/pentaho:/opt/pentaho pentaho-di:latest &
