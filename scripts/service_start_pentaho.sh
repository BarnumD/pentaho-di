#!/bin/bash
#Before we start pentaho we must check the environment.  This could be a brand new container/volume or it could be a new container mounting a volume with an existing version.  We also need to check if the existing version needs to be updated.

###################################################
## Check Pentaho Data Integration Installation   ##
###################################################
#First we must check if DI is installed & if it is at the appropriate service pack.
if [ ! -f "$PENTAHO_HOME/automation/pentaho_di_installed_version.txt" ]; then 
  echo "DI Version file does not exist."
  if [ -d "$PENTAHO_HOME/server/data-integration-server/start-pentaho.sh" ]; then
    echo "The DI version file does not exist, but the $PENTAHO_HOMEserver folder does.  This was unexpected."
	sleep 5
	exit
  else
    #Only install pentaho if we are allowed to..
	if [[ $ALLOW_NEW_INSTALL == "YES" ]]; then
      echo "Installing Pentaho DI."
	  #Pentaho DI is not installed.  Run the script to install Pentaho DI from a clean slate.
	  #Run as pentaho user.
	  mkdir -p ${PENTAHO_HOME}/automation
	  chown -R pentaho:pentaho /opt/pentaho
	  /sbin/setuser pentaho /scripts/install_pentaho_di_6_0_0_0-353.sh
	  /sbin/setuser pentaho /scripts/upgrade_pentaho_di.sh
	else
	  echo "Not installing DI because ALLOW_NEW_INSTALL is set to $ALLOW_NEW_INSTALL"
	fi
  fi
else
  #Pentaho is installed.  Check which version is installed.
  PENTAHO_DI_INSTALLED_VER=$(grep -oP 'pdi-ee-\K[\d\.\-]*' $PENTAHO_HOME/automation/pentaho_di_installed_version.txt)
  if [[ $PENTAHO_DI_INSTALLED_VER == $PENTAHO_DI_TARGET_VER ]]; then
    #Pentaho is at the target version.  Do nothing here.
	echo "Pentaho is at the target version."
  else
    echo "Pentaho DI version is at $PENTAHO_DI_INSTALLED_VER which is different than the target version of $PENTAHO_DI_TARGET_VER.  Starting upgrade script."
	/sbin/setuser pentaho /scripts/upgrade_pentaho_di.sh
  fi
fi
#################################
## Done Checking Installation  ##
#################################

#Copy any new JDBC Drivers that have been added
cp -f /tmp/pentaho/build/jdbc/* $CATALINA_HOME/webapps/pentaho-di/WEB-INF/lib/
chown -R pentaho:pentaho $CATALINA_HOME/webapps/pentaho-di/WEB-INF/lib/

##Copy any new JNDI connections in the context.xml that have been added
#Uncomment this if you want to use it.
#cp -f /tmp/pentaho/build/tomcat/META-INF/context.xml* $CATALINA_HOME/webapps/pentaho-di/META-INF/
##Reset context.xml link based on tier. - can recreate link dynamically based on tier.
#rm $CATALINA_HOME/webapps/pentaho-di/META-INF/context.xml
#if [[ $TIER == "TEST" ]]; then
#  ln -s $CATALINA_HOME/webapps/pentaho-di/META-INF/context.xml-test $CATALINA_HOME/webapps/pentaho-di/META-INF/context.xml
#elif [[ $TIER == "PROD" ]]; then
#  ln -s $CATALINA_HOME/webapps/pentaho-di/META-INF/context.xml-prod $CATALINA_HOME/webapps/pentaho-di/META-INF/context.xml
#fi
#chown -R pentaho:pentaho $CATALINA_HOME/webapps/pentaho-di/META-INF

#Copy any new web.xml configurations that have been added
#Uncomment this if you want to use it.
#cp -f /tmp/pentaho/build/tomcat/WEB-INF/web.xml* $CATALINA_HOME/webapps/pentaho-di/WEB-INF/
#chown -R pentaho:pentaho $CATALINA_HOME/webapps/pentaho-di/WEB-INF

#Clean up /tmp
rm -rf /tmp/pentaho/*
#############################
## Start Pentaho DI Server ##
#############################
#Clean the runtime environment
/scripts/clean_pentaho_run_env.sh
#Start the pentaho process
exec setuser pentaho $PENTAHO_HOME/server/data-integration-server/tomcat/bin/catalina.sh run