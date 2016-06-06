#!/bin/bash
#Check versions and upgrade pentaho.
#This file has some old versions from the 5.4 upgrades.  These can be replaced with new 6.0.x upgrades later.

lc=0
#Double check if Pentaho is installed at all.
if [ -f "$PENTAHO_HOME/server/data-integration-server/start-pentaho.sh" ]; then
  PENTAHO_DI_INSTALLED_VER=$(grep -oP 'pdi-ee-\K[\d\.\-]*' $PENTAHO_HOME/automation/pentaho_di_installed_version.txt)
  if [[ $PENTAHO_DI_INSTALLED_VER != $PENTAHO_DI_TARGET_VER ]]; then
    #This will update pentaho one step at a time, restarts of the service are required to progress.  Otherwise you could change this to a 'while' statement and do all updates at once.
	if [[ "$PENTAHO_DI_INSTALLED_VER" == "6.0.1.0" ]]; then
	  if [[ "$PENTAHO_DI_TARGET_VER" == "6.0.1.1" || "$PENTAHO_DI_TARGET_VER" == "6.0.1.2" ]]; then
	    echo "Upgrade Pentaho to 6.0.1.1"
		/scripts/upgrade_pentaho_di_6_0_1_0_to_6_0_1_1.sh
	  fi
    elif [[ "$PENTAHO_DI_INSTALLED_VER" == "6.0.1.1" ]]; then
	  if [[ "$PENTAHO_DI_TARGET_VER" == "6.0.1.2" ]]; then
	    echo "Upgrade Pentaho to 6.0.1.2"
	    /scripts/upgrade_pentaho_di_6_0_1_1_to_6_0_1_2.sh
		
	  fi
    fi
	lc=$((lc+1))
	if [ "$lc" -gt 5 ]; then break; lc=; fi
    PENTAHO_DI_INSTALLED_VER=$(grep -oP 'pdi-ee-\K[\d\.\-]*' $PENTAHO_HOME/automation/pentaho_di_installed_version.txt)
  fi
fi

#Ensure pentaho is owner of home folder.
chown -R pentaho:pentaho /opt/pentaho