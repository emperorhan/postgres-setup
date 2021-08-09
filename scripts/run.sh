#!/bin/bash

function usage() {
    printf "Usage: $0 OPTION...
    -n, --name          PostgreSQL Container name
    -d, --database      PostgreSQL Database name
    -u, --user          PostgreSQL User name
    -p, --passwd        PostgreSQL Password
    -P, --port          PostgreSQL Host Port
    -D, --dir           PostgreSQL Host Directory
    -h, --help          How to use run.sh
    \\n" "$0" 1>&2
    exit 1
}

[ $# -eq 0 ] && usage

CONTAINER_NAME="postgres"
POSTGRES_DB="postgres"
POSTGRES_USER="postgres"
POSTGRES_PASSWORD=""
POSTGRES_PORT="5432"
PGDATA="/var/lib/postgresql/data/pgdata"

while [[ "$#" -gt 0 ]]; do
    case $1 in
    -n | --name)
        CONTAINER_NAME="$2"
        shift
        ;;
    -d | --database)
        POSTGRES_DB="$2"
        shift
        ;;
    -u | --user)
        POSTGRES_USER="$2"
        shift
        ;;
    -p | --passwd)
        POSTGRES_PASSWORD="$2"
        shift
        ;;
    -P | --port)
        POSTGRES_PORT="$2"
        shift
        ;;
    -h | --help)
        usage
        ;;
    *)
        echo "Unknown parameter passed: $1"
        usage
        ;;
    esac
    shift
done

echo "CONTAINER_NAME: $CONTAINER_NAME"
echo "POSTGRES_DB: $POSTGRES_DB"
echo "POSTGRES_USER: $POSTGRES_USER"
echo "POSTGRES_PASSWORD: $POSTGRES_PASSWORD"
echo "POSTGRES_PORT: $POSTGRES_PORT"

docker run -d --name $CONTAINER_NAME \
    -e POSTGRES_DB=$POSTGRES_DB \
    -e POSTGRES_USER=$POSTGRES_USER \
    -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
    -e PGDATA=$PGDATA \
    -p $POSTGRES_PORT:5432 \
    -v `pwd -P`/postgres/conf/postgresql.conf:/tmp/postgresql.conf \
    -v `pwd -P`/postgres/conf/init.sql:/tmp/init.sql \
    -v `pwd -P`/postgres/postgres:/var/lib/postgresql/data/pgdata \
    postgres-custom \
