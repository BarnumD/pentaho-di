#!/bin/bash

if [ "$PGHOST" ]; then
  echo "Checking if database is up..."

  # The port should be 5432 - this is assumed in some cases
  nc -zv $PGHOST $PGPORT

  if [ "$?" -ne "0" ]; then
    echo "PostgreSQL connection failed."
    exit 0
  fi

  CHK_DI_QUARTZ=`echo "$(psql -U $PGUSER  -h $PGHOST -d $PGDATABASE -l | egrep '^\sdi_quartz' | wc -l)"`
  CHK_DI_HIBERNATE=`echo "$(psql -U $PGUSER  -h $PGHOST -d $PGDATABASE -l | egrep '^\sdi_hibernate' | wc -l)"`
  CHK_DI_JCR=`echo "$(psql -U $PGUSER  -h $PGHOST -d $PGDATABASE -l | egrep '^\sdi_jackrabbit' | wc -l)"`

  echo "di_quartz: $CHK_DI_QUARTZ"
  echo "hibernate: $CHK_DI_HIBERNATE"
  echo "jcr: $CHK_DI_JCR"

  #Create the databases
  if [ "$CHK_DI_JCR" -eq "0" ]; then
    echo ""; echo "Initializing a new database."
	#Update password
    sed -i -- "s:password:$jcr_user_pwd:g" $PENTAHO_HOME/server/data-integration-server/data/postgresql/create_jcr_postgresql.sql
    #Create jackrabbit db.
	psql -U $PGUSER -h $PGHOST -d $PGDATABASE -f $PENTAHO_HOME/server/data-integration-server/data/postgresql/create_jcr_postgresql.sql
  fi
  if [ "$CHK_DI_HIBERNATE" -eq "0" ]; then
    #Update password
    sed -i -- "s:password:$hibuser_pwd:g" $PENTAHO_HOME/server/data-integration-server/data/postgresql/create_repository_postgresql.sql
    #Create hibernate db.
    psql -U $PGUSER -h $PGHOST -d $PGDATABASE -f $PENTAHO_HOME/server/data-integration-server/data/postgresql/create_repository_postgresql.sql
  fi
  if [ "$CHK_DI_QUARTZ" -eq "0" ]; then
  	#Update password
    sed -i -- "s:password:$pentaho_user_pwd:g" $PENTAHO_HOME/server/data-integration-server/data/postgresql/create_quartz_postgresql.sql
    #Create Quartz db.
    psql -U $PGUSER -h $PGHOST -d $PGDATABASE -f $PENTAHO_HOME/server/data-integration-server/data/postgresql/create_quartz_postgresql.sql
	
	# Pentaho Operations Mart 
    psql -U $PGUSER -h $PGHOST -d $PGDATABASE -f $PENTAHO_HOME/server/data-integration-server/data/postgresql/pentaho_mart_postgresql.sql

  fi

  #Set Up Quartz on PostgreSQL DI Repository Database 
    #This part of the instructions require no change.
	
  #Set Hibernate Settings for PostgreSQL - Change DB name & connection information
  sed -r -i -- "s:connection.password\">password:connection.password\">$hibuser_pwd:g" $PENTAHO_HOME/server/data-integration-server/pentaho-solutions/system/hibernate/postgresql.hibernate.cfg.xml
  sed -i -- "s:localhost:$PGHOST:g" $PENTAHO_HOME/server/data-integration-server/pentaho-solutions/system/hibernate/postgresql.hibernate.cfg.xml
  #Modify Jackrabbit Repository Information for PostgreSQL  - Change DB name & connection information
  sed -r -i -- "s:value=\"password:value=\"$jcr_user_pwd:g" $PENTAHO_HOME/server/data-integration-server/pentaho-solutions/system/jackrabbit/repository.xml
  sed -i -- "s:localhost:$PGHOST:g" $PENTAHO_HOME/server/data-integration-server/pentaho-solutions/system/jackrabbit/repository.xml
  #Modify JDBC Connection Information in the Tomcat context.xml File  - Change DB name & connection information
  sed -r -i -- "s:username=\"hibuser\"\spassword=\"\w+:username=\"hibuser\" password=\"$hibuser_pwd:g" $PENTAHO_HOME/server/data-integration-server/tomcat/webapps/pentaho-di/META-INF/context.xml
  sed -r -i -- "s:username=\"pentaho_user\"\spassword=\"\w+:username=\"pentaho_user\" password=\"$pentaho_user_pwd:g" $PENTAHO_HOME/server/data-integration-server/tomcat/webapps/pentaho-di/META-INF/context.xml
  sed -i -- "s:localhost:$PGHOST:g" $PENTAHO_HOME/server/data-integration-server/tomcat/webapps/pentaho-di/META-INF/context.xml
fi

echo "Done DB Initialization."
