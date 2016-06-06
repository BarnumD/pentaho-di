#!/bin/bash
#Attributions:
#  Some code in this and other files from https://github.com/aloysius-lim/docker-pentaho-di

#Before we start carte we must check the environment.  This could be a brand new container/volume or it could be a new container mounting a volume with an existing version.  We also need to check if the existing version needs to be updated.
###################################################
## Check Pentaho Data Integration Installation   ##
###################################################
## First we must check if DI is installed & if it is at the appropriate service pack.  Carte relies on the installation from di.
if [ ! -f "$PENTAHO_HOME/automation/pentaho_di_installed_version.txt" ]; then 
  echo "DI Version file does not exist so carte couldn't start."
  #Perhaps this is the first run, and PDI will be installed by it's startup script.  Carte will wait.
  echo "Waiting to start carte."
  sleep 240
fi
#################################
## Done Checking Installation  ##
#################################


## Copy any new JDBC Drivers that have been added
cp -f /tmp/pentaho/build/jdbc/* $PENTAHO_HOME/data-integration/lib/
chown -R pentaho:pentaho $PENTAHO_HOME/data-integration/lib
#################################
## Configure Carte             ##
#################################
## Set carte config variables
if [[ -z "$CARTE_NAME" ]]; then CARTE_NAME=carte-server; fi
if [[ -z "$CARTE_NETWORK_INTERFACE" ]]; then CARTE_NETWORK_INTERFACE=lo; fi
if [[ -z "$CARTE_PORT" ]]; then
  if [[ "$PENTAHO_ENABLE_SSL" == "Y" ]]; then
    CARTE_PORT=9001;
  else
    CARTE_PORT=8080;
  fi
fi
if [[ -z "$CARTE_USER" ]]; then CARTE_USER=cluster; fi
if [[ -z "$CARTE_PASSWORD" ]]; then CARTE_PASSWORD=cluster; fi
if [[ -z "$CARTE_IS_MASTER" ]]; then CARTE_IS_MASTER=Y; fi

if [[ -z "$CARTE_INCLUDE_MASTERS" ]]; then CARTE_INCLUDE_MASTERS=N; fi

if [[ -z "$CARTE_REPORT_TO_MASTERS" ]]; then CARTE_REPORT_TO_MASTERS=Y; fi
if [[ -z "$CARTE_MASTER_NAME" ]]; then CARTE_MASTER_NAME=carte-master; fi
if [[ -z "$CARTE_MASTER_HOSTNAME" ]]; then CARTE_MASTER_HOSTNAME=localhost; fi
if [[ -z "$CARTE_MASTER_PORT" ]]; then CARTE_MASTER_PORT=8080; fi
if [[ -z "$CARTE_MASTER_USER" ]]; then CARTE_MASTER_USER=cluster; fi
if [[ -z "$CARTE_MASTER_PASSWORD" ]]; then CARTE_MASTER_PASSWORD=cluster; fi
if [[ -z "$CARTE_MASTER_IS_MASTER" ]]; then CARTE_MASTER_IS_MASTER=Y; fi

## Create carte config file on the fly.  We create the carte config file on the fly and the config file is not stored on attachable storage so that this container can be reused by multiple containers sharing the same storage.
echo "" > /tmp/carte_config.xml; chown pentaho:pentaho /tmp/carte_config.xml; #Initialize a new carte_config.xml
echo '<slave_config>
  <!--
     Document description...
     - masters: You can list the slave servers to which this slave has to report back to.
                If this is a master, we will contact the other masters to get a list of all the slaves in the cluster.
     - report_to_masters : send a message to the defined masters to let them know we exist (Y/N)
     - slaveserver : specify the slave server details of this carte instance.
                     IMPORTANT : the username and password specified here are used by the master instances to connect to this slave.
  -->' >> /tmp/carte_config.xml
if [ "$CARTE_INCLUDE_MASTERS" = "Y" ]; then
echo "  <masters>
    <slaveserver>
      <name>$CARTE_MASTER_NAME</name>
      <hostname>$CARTE_MASTER_HOSTNAME</hostname>
      <port>$CARTE_MASTER_PORT</port>
      <username>$CARTE_MASTER_USER</username>
      <password>$CARTE_MASTER_PASSWORD</password>
      <master>$CARTE_MASTER_IS_MASTER</master>
    </slaveserver>
  </masters>

  <report_to_masters>$CARTE_REPORT_TO_MASTERS</report_to_masters>
  " >> /tmp/carte_config.xml
fi
echo "  <slaveserver>
    <name>$CARTE_NAME</name>
    <network_interface>$CARTE_NETWORK_INTERFACE</network_interface>
    <port>$CARTE_PORT</port>
    <username>$CARTE_USER</username>
    <password>$CARTE_PASSWORD</password>
    <master>$CARTE_IS_MASTER</master>" >> /tmp/carte_config.xml
if [[ "$PENTAHO_ENABLE_SSL" == "Y" ]]; then
  echo "    <sslConfig>
      <keyStore>$PENTAHO_KEYSTORE_LOC</keyStore>
      <keyStorePassword>$PENTAHO_KEYSTORE_PASSWORD</keyStorePassword>
      <keyPassword>$PENTAHO_KEY_PASSWORD</keyPassword>
    </sslConfig>" >> /tmp/carte_config.xml
fi
echo "  </slaveserver>
</slave_config>" >> /tmp/carte_config.xml

#################################
## Start Pentaho Carte Server  ##
#################################
#Start the carte process
if [[ "$SERVICE_ENABLE_CARTE" == "Y" ]]; then
  echo "Starting carte service.."
  exec setuser pentaho $PENTAHO_HOME/data-integration/carte.sh /tmp/carte_config.xml
else
  sleep 10000
fi