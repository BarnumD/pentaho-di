This docker container allows you to run both Pentaho Data Integration EE as well as Carte as a service.

To start the container with only PDI:
Docker run example: (Starting pdi)
  > run the docker-db container first.
  > docker run -d --name pentaho-di-
  >> -p 9080:9080 #Map a host port to http port 9080.
  >> -e PGUSER=postgresadm #Set the postgres username
  >> -e PGPWD=POSTGRESSADMPASSWORD #Set the postgres password
  >> -e PGHOST=pentaho-db #Set the postgres hostname
  >> -e PGPORT=5432 #Set the postgres port
  >> -e PGDATABASE=postgres #Set the database type
  >> --link pentaho-db:pentaho-db #link to the postgres container
  >> -v /docker/mounts/pentaho-di/opt/pentaho:/opt/pentaho Map the /opt/pentaho folder to a volume on the container.
  >> pentaho-di:latest &
  
To start the container with carte:
Carte can be run inside the same container as PDI, or separately.  To run separately you would pass -e SERVICE_ENABLE_PDI=N and -e SERVICE_ENABLE_CARTE=Y
Since this is packaged together with PDI enterprise edition, PDI is designed to be the carte 'master server'.  Therefore, if you're running carte at all, it would probably be as separate slaves to PDI.
The following environment variables can be passed to docker run using the -e option:
  CARTE_NAME: The name of this Carte node (default: carte-server)
  CARTE_NETWORK_INTERFACE: The network interface to bind to (default: eth0)
  CARTE_PORT: The port to listen to (default: 9001)
  CARTE_USER: The username for this node (default: cluster)
  CARTE_PASSWORD: The password for this node (default: cluster)
  CARTE_IS_MASTER: Whether this is a master node (default: Y)
  CARTE_INCLUDE_MASTERS: Whether to include a masters section in the Carte configuration (default: N)
If CARTE_INCLUDE_MASTERS is 'Y', then these additional environment variables apply:

  CARTE_REPORT_TO_MASTERS: Whether to notify the defined master node that this node exists (default: Y)
  CARTE_MASTER_NAME: The name of the master node (default: carte-master)
  CARTE_MASTER_HOSTNAME: The hostname of the master node (default: localhost)
  CARTE_MASTER_PORT: The port of the master ndoe (default: 9001)
  CARTE_MASTER_USER: The username of the master node (default: cluster)
  CARTE_MASTER_PASSWORD: The password of the master node (default: cluster)
  CARTE_MASTER_IS_MASTER: Whether this master node is a master node (default: Y)

Docker run example: (Starting carte container to attach to pdi master)
  > run the docker-db container first.
  > docker run -d --name pentaho-di-
  >> -p 9080:9080 #Map a host port to pdi http port 9080.
  >> -e PGUSER=postgresadm #Set the postgres username
  >> -e PGPWD=POSTGRESSADMPASSWORD #Set the postgres password
  >> -e PGHOST=pentaho-db #Set the postgres hostname
  >> -e PGPORT=5432 #Set the postgres port
  >> -e PGDATABASE=postgres #Set the database type
  >> -e SERVICE_ENABLE_PDI=N #Start the carte service.
  >> -e SERVICE_ENABLE_CARTE=Y #Start the carte service.
  >> -e CARTE_NAME=CarteClient01
  >> -e CARTE_USER=cluster
  >> -e CARTE_PASSWORD=pasword
  >> -e CARTE_IS_MASTER=N
  >> -e CARTE_INCLUDE_MASTERS=Y
  >> -e CARTE_REPORT_TO_MASTERS=Y
  >> -e CARTE_MASTER_NAME=pdi.domain.org(for prod)
  >> -e CARTE_MASTER_USER=admin
  >> -e CARTE_MASTER_PASSWORD=password
  >> --link pentaho-db:pentaho-db #link to the postgres container
  >> -v /docker/mounts/pentaho-di/opt/pentaho:/opt/pentaho Map the /opt/pentaho folder to a volume on the container.
  >> pentaho-di:latest &