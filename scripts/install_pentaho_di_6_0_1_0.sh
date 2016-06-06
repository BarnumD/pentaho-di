#!/bin/bash

#Double check if Pentaho is installed at all.
if [ ! -d "/opt/pentaho/server/data-integration-server" ]; then
  #Install Pentaho DI Server at version 6.0.1.0-386
  
  # Components to be installed
  COMPONENTS="pdi-ee"
  PLUGINS=""
  PENTAHO_VERSION="6.0.1.0"
  PENTAHO_PATCH="386"
  PENTAHO_HOME="/opt/pentaho"

  ##################################
  # Bring down and install Pentaho #
  ##################################
  ## Get PDI EE - 2 options
  echo "Downloading packages.  This could take some time.";
  #1. Get from FTP (slow & requires credentials)
  #ENV USER=USER PASS=PASS
  #RUN wget -P /tmp --progress=bar:force ftp://${USER}:${PASS}@supportftp.pentaho.com/Enterprise%20Software/Pentaho_BI_Suite/${PENTAHO_VERSION}-GA/DI-Server/Archive%20Build/*
  #2. Get from dropbox.
  ### Download Pentaho DI   --- (Don't have pwd for ftp, above.  Used dropbox instead.)
  cd /tmp/pentaho;
  if [ ! -f "pdi-ee-6.0.1.0-386-dist.zip" ]; then wget --progress=dot -qO pdi-ee-6.0.1.0-386-dist.zip $pkg_pdi_ee; fi
  
 

# Unzip components, removing the archives as we go
  for PKG in $(echo ${COMPONENTS} | tr ':' '\n'); \
  do echo "Unzipping $PKG-${PENTAHO_VERSION}-${PENTAHO_PATCH}-dist.zip...";
    unzip -q /tmp/pentaho/$PKG-${PENTAHO_VERSION}-${PENTAHO_PATCH}-dist.zip -d /tmp/pentaho;
	echo "$PKG-${PENTAHO_VERSION}" > $PENTAHO_HOME/automation/pentaho_di_installed_version.txt
    rm -rf /tmp/pentaho/$PKG-${PENTAHO_VERSION}-${PENTAHO_PATCH}-dist.zip;
  done


  #********************
  #*   Install DI     *
  #********************
  # Run the pdi-ee installer
  # Install pentaho-ee to /opt/pentaho
  echo "Installing pdi-ee";
  sed -- "s:<installpath>[a-zA-Z0-9/\-\.]*:<installpath>/tmp/pentaho:g" /tmp/pentaho/build/auto-install.xml.default  > auto-install.xml;
  java -jar pdi-ee-${PENTAHO_VERSION}-${PENTAHO_PATCH}/installer.jar auto-install.xml 2>/dev/null;
  mkdir -p /opt/pentaho/server;
  cp -R /tmp/pentaho/pdi-ee/* /opt/pentaho/; rm -rf /tmp/pentaho/pdi-ee*;
  cp -R /opt/pentaho/data-integration-server /opt/pentaho/server/; rm -rf /opt/pentaho/data-integration-server;

  
  #**********************************
  #*  Initialize & setup database   *
  #**********************************
  /scripts/initialize_pentaho_database.exp $PGPWD $pentaho_user_pwd $hibuser_pwd $jcr_user_pwd
  
  #*********************************
  #*  Configure Pentaho settings   *
  #*********************************
  #Set log directory.  Default settings result in error.  Setting absolute path.
  sed -r -i -- "s:\.\./logs/pentaho.log:$CATALINA_HOME/logs/pentaho.log:g" $PENTAHO_HOME/server/data-integration-server/tomcat/webapps/pentaho-di/WEB-INF/classes/log4j.xml
  sed -r -i -- "s:\.\./logs/osgi_pentaho.log:$CATALINA_HOME/logs/osgi_pentaho.log:g" $PENTAHO_HOME/server/data-integration-server/pentaho-solutions/system/osgi/log4j.xml
  
  
  #Done installing pentaho DI.
else
  #Alrady installed?
  echo "Pentaho is already installed?"
fi