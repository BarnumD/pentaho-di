#!/bin/bash
#Cleans out temporary directories used by pentaho.
rm -rf /opt/pentaho/server/data-integration-server/tomcat/work/*
rm -rf /opt/pentaho/server/data-integration-server/tomcat/temp/*
rm -f /opt/pentaho/server/data-integration-server/tomcat/conf/Catalina/localhost/*
rm -rf /opt/pentaho/server/data-integration-server/pentaho-solutions/system/jackrabbit/repository/*

#Remove lock files
FILE="/opt/pentaho/server/data-integration-server/pentaho-solutions/system/jackrabbit/repository/.lock"
if [ -f $FILE ]; then rm $FILE; fi
FILE="/opt/pentaho/server/data-integration-server/pentaho-solutions/system/osgi/cache/cache.lock"
if [ -f $FILE ]; then rm $FILE; fi

#Optionally clear logs
#rm -rf /opt/pentaho/server/data-integration-server/tomcat/logs/*