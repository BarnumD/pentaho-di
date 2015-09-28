#!/bin/bash
#Before we start pentaho we must check the environment.  This could be a brand new container/volume or it could be a new container mounting a volume with an existing version.  We also need to check if the existing version needs to be updated.

#######################################
## Check Pentaho Data Integration    ##
#######################################
#First we must check if DI is installed & if it is at the appropriate service pack.
if [ ! -f "$PENTAHO_HOME/pentaho_di_installed_version.txt" ]; then 
  echo "DI Version file does not exist."
  if [ -d "$PENTAHO_HOME/server/data-integration-server/start-pentaho.sh" ]; then
    echo "The DI version file does not exist, but the $PENTAHO_HOMEserver folder does.  This was unexpected."
	sleep 5
	exit
  else
    echo "Installing Pentaho DI."
	#Pentaho DI is not installed.  Run the script to install Pentaho DI from a clean slate.
	#Run as pentaho user.
	chown -R pentaho:pentaho /opt/pentaho
	/sbin/setuser pentaho /scripts/install_pentaho_di_5_4_0_1-130.sh
	#/sbin/setuser pentaho /scripts/upgrade_pentaho_di.sh #-Implement this later.
  fi
else
  #Pentaho is installed.  Check which version is installed.
  PENTAHO_DI_INSTALLED_VER=$(grep -oP 'pdi-ee-\K[\d\.\-]*' $PENTAHO_HOME/pentaho_di_installed_version.txt)
  if [[ $PENTAHO_DI_INSTALLED_VER == $PENTAHO_DI_TARGET_VER ]]; then
    #Pentaho is at the target version.  Do nothing here.
	echo "Pentaho is at the target version."
  else
    echo "Pentaho DI version is at $PENTAHO_DI_INSTALLED_VER which is different than the target version of $PENTAHO_DI_TARGET_VER.  Starting upgrade script."
	#/sbin/setuser pentaho /scripts/upgrade_pentaho_di.sh #-Implement this later.
  fi
fi
#Components are installed.

#Copy any new JDBC Drivers that have been added
cp -f /tmp/pentaho/build/jdbc/* $PENTAHO_HOME/server/data-integration-server/tomcat/lib/

#Set pentaho as owner
chown -R pentaho:pentaho /opt/pentaho

#Clean up /tmp
rm -rf /tmp/pentaho
#############################
## Start Pentaho DI Server ##
#############################
exec setuser pentaho $PENTAHO_HOME/server/data-integration-server/tomcat/bin/catalina.sh run