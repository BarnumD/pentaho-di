#!/bin/bash

#Double check if Pentaho is installed at all.
if [ -f "/opt/pentaho/server/data-integration-server/start-pentaho.sh" ]; then
  #Upgrade Pentaho DI Server from version 6.0.1.1 to 6.0.1.2
  
  # Components to be installed
  COMPONENTS="PDI"
  PLUGINS=""
  PENTAHO_VERSION="6.0.1.2"
  PENTAHO_PATCH="413"

  ##################################
  # Bring down and upgrade Pentaho #
  ##################################
  ## Get PBA EE - 2 options
  echo "Downloading packages.  This could take some time.";
  #1. Get from FTP (slow & requires credentials)
  #ENV USER=USER PASS=PASS
  #RUN wget -P /tmp --progress=bar:force ftp://${USER}:${PASS}@supportftp.pentaho.com/Enterprise%20Software/Pentaho_BI_Suite/${PENTAHO_VERSION}-GA/...*
  #2. Get from dropbox.
  ### Download Pentaho Business Analytics & plugins   --- (Don't have pwd for ftp, above.  Used dropbox instead.)
  mkdir -p /tmp/pentaho/; cd /tmp/pentaho;
  if [ ! -f "SP201602-6.0.zip" ]; then wget --progress=dot -qO SP201602-6.0.zip $pkg_SP201602_60; fi
  
# Unzip components, removing the archives as we go
  unzip -q /tmp/pentaho/SP201602-6.0.zip -d /tmp/pentaho;
  rm -rf /tmp/pentaho/SP201602-6.0.zip;

  #********************
  #*   Upgrade DI     *
  #********************
  #Create a backup of /opt/pentaho - Clean up this path later.
  echo "Creating backup folder"
  mkdir -p $PENTAHO_HOME/backup-6.0.1.1/
  rsync -avq /opt/pentaho/* $PENTAHO_HOME/backup-6.0.1.1/ --exclude backup-*

  # Upgrade Pentaho DI to 6.0.1.2
  echo "Upgrading Pentaho DI from 6.0.1.1 to 6.0.1.2";
  unzip -oq /tmp/pentaho/SP201602-6.0/PDI/SP201602-6.0-PDI-Server.zip -d $PENTAHO_HOME/server/
  echo "pdi-ee-${PENTAHO_VERSION}" > /opt/pentaho/automation/pentaho_di_installed_version.txt
  PENTAHO_DI_INSTALLED_VER="pdi-ee-${PENTAHO_VERSION}"
  
  #************************
  #*   Upgrade DI Client  *
  #************************
  echo "Upgrading Pentaho DI client from 6.0.1.1 to 6.0.1.2";
  unzip -oq /tmp/pentaho/SP201602-6.0/PDI/SP201602-6.0-PDI-Client.zip -d $PENTAHO_HOME/
  
  #Cleanup
  rm -rf /tmp/pentaho/SP*
fi