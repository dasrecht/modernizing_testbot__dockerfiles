#!/bin/bash

if [ ! -z $(pg_lsclusters | grep -c ' main ') ]; 
    then
    echo "rebuilding PostgreSQL database cluster"
    # stop and drop the cluster
    pg_dropcluster 9.1 main --stop
    # create a fresh new cluster
    pg_createcluster 9.1 main --start
    # create a new user
    PGPASSWORD=drupaltestbotpw createuser -d -E -l -R -S drupaltestbot
    # create a new default database for the user
    createdb -O drupaltestbot drupaltestbot
    # stop the cluster
    pg_ctlcluster 9.1 main stop
fi

/usr/lib/postgresql/9.1/bin/postgres -D /var/lib/postgresql/9.1/main -c config_file=/etc/postgresql/9.1/main/postgresql.conf
echo "pgsql died at $(date)";

