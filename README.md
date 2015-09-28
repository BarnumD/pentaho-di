# Pentaho-DI
Dockerized implementation of Pentaho DI (Data Integration) Enterprise Edition.  This configuration uses the 'archive' mode of installation.

# To Run:
<ul>Clone this repository</ul>
<ul>Edit the install_pentaho_di...sh file and give it a URL to download the software.</ul>
<ul>Build the docker image for this and pentaho-db</ul>
<ul>Run pentaho-db: docker run -d --name pentaho-db -d -p 5432:5432 -v /docker/mounts/pentaho-db/var/lib/postgresql/data:/var/lib/postgresql/data pentaho-db</ul>
<ul>Run pentaho-di: docker run -d --name pentaho-di -p 9080:9080 -e TIER=TEST -e PGUSER=postgresadm -e PGPWD=8s88jjjChangeMe99aks88 -e PGHOST=pentaho-db -e PGPORT=5432 -e PGDATABASE=postgres --link pentaho-db:pentaho-db -v /docker/mounts/pentaho-di/opt/pentaho:/opt/pentaho pentaho-di:latest &</ul>
<br><br>
For more information on running in test & production see the dockerfile.