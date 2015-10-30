#Dockerfile to build Pentaho's Business Analytics frontend 
# v 1.0
# Created using pentaho 'archive' instructions from https://help.pentaho.com/Documentation/5.4/0F0/0P0/020/0B0
# and info from https://github.com/rxacevedo/docker-pentaho-di/blob/master/Dockerfile
#
# Docker Build Instructions:
#  docker build -t pentaho-di .
# Docker Run Instructions:
#
#  #For testing the build process on a pc.
#   docker run -d --name pentaho-di -p 9080:9080 -e TIER=TEST -e PGUSER=postgresadm -e PGPWD=8s88jjjChangeMe99aks88 -e PGHOST=pentaho-db -e PGPORT=5432 -e PGDATABASE=postgres --link pentaho-db:pentaho-db -v /docker/mounts/pentaho-di/opt/pentaho:/opt/pentaho pentaho-di:latest &
#
#  #On first ever run, you must include the PGPWD (postgres adimn) password to initialize the database.
#    docker run -i --name pentaho-di -p 10802:9080 -e PGUSER=postgresadm -e PGPWD=8s88jjjChangeMe99aks88 -e PGHOST=pentaho-db -e PGPORT=5432 -e PGDATABASE=postgres --link pentaho-db:pentaho-db  -v /docker/mounts/pentaho-di/opt/pentaho:/opt/pentaho pentaho-di:latest &
#
#  #On subsequent boots, (after db is initialized), run non-interactive.
#    #Test
#     docker run -d --name pentaho-di-test -p 10802:9080 -e TIER=TEST -e PGUSER=postgresadm -e PGPWD=8s88jjjChangeMe99aks88 -e PGHOST=pentaho-db-test -e PGPORT=5432 -e PGDATABASE=postgres --link pentaho-db-test:pentaho-db-test -v /docker/mounts/pentaho-di-test/opt/pentaho:/opt/pentaho --memory 6656M --memory-swap -1 --oom-kill-disable -c=512 pentaho-di:latest &
#    #Prod
#     docker run -d --name pentaho-di-prod -p 10806:9080 -e TIER=PROD -e PGUSER=postgresadm -e PGPWD=8s88jjjChangeMe99aks88 -e PGHOST=pentaho-db-prod -e PGPORT=5432 -e PGDATABASE=postgres --link pentaho-db-prod:pentaho-db-prod -v /docker/mounts/p_t1/pentaho-di-prod/opt/pentaho:/opt/pentaho --memory 6656M --memory-swap -1 --oom-kill-disable -c=1024 pentaho-di:0.99 &
#
FROM phusion/baseimage:0.9.17
MAINTAINER Dave Barnum <dave@thebarnums.com>

#Update Ubuntu and add repo for postgres 9.4
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list; \
	curl -s http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -; \
	apt-get update; \
	apt-get upgrade -y


##################################
#  Install Major Dependences     #
##################################
RUN apt-get install -y ca-certificates curl wget zip unzip vim postgresql-client-9.4 expect rsync; \
	#pentaho requires xvfb when X server is unavailable.; \
	apt-get install -y xvfb; \
	#Tomcat's APM library helps with tomcat speed. Need version 1.1.30+ (not available from normal repo.); \ -Doesn't seem to be working so I commented it out
	sudo add-apt-repository ppa:pharmgkb/trusty -y; \
	sudo apt-get update; \
	sudo apt-get install libtcnative-1 -y
ENV LD_LIBRARY_PATH "/usr/lib/x86_64-linux-gnu/"

#Scripts used for startup & initialization.
COPY scripts /scripts
RUN chmod 777 /scripts; \
	chmod 755 /scripts/*.sh; \
	chmod 755 /scripts/*.exp;

#** Install Java ***
#*******************

RUN echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections; \
	echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections; \
	add-apt-repository ppa:webupd8team/java -y; \
	apt-get update; \
	apt-get install oracle-java8-installer -y;

ENV JAVA_HOME=/usr/lib/jvm/java-8-oracle
#** Done Installing Java **

##################################
# Setup Pentaho Environment      #
##################################
#Set the target version.  This will be used by the run script to determine if we need to upgrade the version on disk.
ENV PENTAHO_DI_TARGET_VER="6.0.0.0-353"

ENV PENTAHO_JAVA_HOME=$JAVA_HOME
ENV PENTAHO_HOME=/opt/pentaho
ENV CATALINA_HOME=$PENTAHO_HOME/server/data-integration-server/tomcat
ENV KETTLE_HOME=$PENTAHO_HOME/.kettle/
ENV PENTAHO_INSTALLED_LICENSE_PATH=$PENTAHO_HOME/.pentaho/.installedLicenses.xml
ENV CATALINA_OPTS="-Djava.awt.headless=true -Xms4g -Xmx6g -Dsun.rmi.dgc.client.gcInterval=3600000 -XX:MaxMetaspaceSize=256m -Dsun.rmi.dgc.server.gcInterval=3600000 -Dpentaho.installed.licenses.file=$PENTAHO_INSTALLED_LICENSE_PATH"

#Set Passwords for pentaho database users - default is 'password'
ENV jcr_user_pwd="ppaiChangeMem887"
ENV hibuser_pwd="s5gChangeMe877"
ENV pentaho_user_pwd="0apChangeMe5S66"

#Create Pentaho user & Create main folder structure
RUN useradd -s /bin/bash -d ${PENTAHO_HOME} pentaho; \
	mkdir -p ${PENTAHO_HOME}; \
	mkdir -p ${PENTAHO_HOME}/automation; \
	mkdir -p /tmp/pentaho/build; \
	chown -R pentaho:pentaho /opt/pentaho;

#Default build folder.  Contains xml file for unpacking the pentaho downloads. Also contains JDBC drivers.
COPY build /tmp/pentaho/build
RUN chown -R pentaho:pentaho /tmp/pentaho

#We don't actually install Pentaho in this dockerfile.  This is because Pentaho is not like other programs you install and update via apt-get.
#It is installed via placing packages in the right folder.  Since those packages might already exist in a running environment we only need to install
#dependencies here.  The rest, including installation of a new environment and upgrades can be handled by the service_start_pentaho.sh script.
#Additionally, new installation has been disabled in our environment because we don't need that anymore. (to prevent building a new environment when something unexpected happens like if NFS is not present.)
ENV ALLOW_NEW_INSTALL="YES"

#Setup auto start process
RUN mkdir -p /etc/service/pentaho; \
	ln -s /scripts/service_start_pentaho.sh /etc/service/pentaho/run;

#Cleanup
RUN apt-get clean; \
	rm -rf /var/lib/apt/lists/* /var/tmp/*
	
#We use baseimage-docker's my_init process.
CMD ["/sbin/my_init"]
