#!/bin/bash

function usage() {
    printf "Usage: $0 OPTION...
    -n, --name                  History-tools Container name
    -i, --init                  fill-pg init
    -h, --host HOST             State history plugin node host
    -p, --port PORT             State history plugin node port
    -s, --skip BLOCK_NUM        fill-pg skip block number
    --db-name                   PostgreSQL Database name
    --db-user                   PostgreSQL User name
    --db-passwd                 PostgreSQL Password
    --db-host                   PostgreSQL Host Ip
    --db-port                   PostgreSQL Host Port
    -h, --help                  How to use history-tools.sh
    \\n" "$0" 1>&2
    exit 1
}

[ $# -eq 0 ] && usage

CONTAINER_NAME="fill-pg"
SHIP_HOST="127.0.0.1"
SHIP_PORT="8080"

SUB_COMMAND=""

POSTGRES_DB="postgres"
POSTGRES_USER="postgres"
POSTGRES_PASSWORD=""
POSTGRES_HOST=""
POSTGRES_PORT="5432"

while [[ "$#" -gt 0 ]]; do
    case $1 in
    -n | --name)
        CONTAINER_NAME="$2"
        shift 2
        ;;
    -i | --init)
        SUB_COMMAND+=" --fpg-drop --fpg-create"
        shift
        ;;
    -h | --host)
        SHIP_HOST="$2"
        shift 2
        ;;
    -p | --port)
        SHIP_PORT="$2"
        shift 2
        ;;
    -s | --skip)
        SUB_COMMAND+=" --fill-skip-to=$2"
        shift 2
        ;;
    --db-name)
        POSTGRES_DB="$2"
        shift 2
        ;;
    --db-user)
        POSTGRES_USER="$2"
        shift 2
        ;;
    --db-passwd)
        POSTGRES_PASSWORD="$2"
        shift 2
        ;;
    --db-host)
        POSTGRES_HOST="$2"
        shift 2
        ;;
    --db-port)
        POSTGRES_PORT="$2"
        shift 2
        ;;
    -h | --help)
        usage
        ;;
    *)
        echo "Unknown parameter passed: $1"
        usage
        ;;
    esac
done

echo "CONTAINER_NAME: $CONTAINER_NAME"

echo "SHIP_HOST: $SHIP_HOST"
echo "SHIP_PORT: $SHIP_PORT"
echo "SUB_COMMAND: $SUB_COMMAND"

echo "POSTGRES_DB: $POSTGRES_DB"
echo "POSTGRES_USER: $POSTGRES_USER"
echo "POSTGRES_PASSWORD: $POSTGRES_PASSWORD"
echo "POSTGRES_HOST: $POSTGRES_HOST"
echo "POSTGRES_PORT: $POSTGRES_PORT"

docker run -d --name $CONTAINER_NAME \
    -e PGUSER=$POSTGRES_USER \
    -e PGPASSWORD=$POSTGRES_PASSWORD \
    -e PGDATABASE=$POSTGRES_DB \
    -e PGHOST=$POSTGRES_HOST \
    -e PGPORT=$POSTGRES_PORT \
    ibct/history-tools:2.0.7 \
    /bin/sh -c "
        echo Waiting for nodeos service start...;
        while ! nc -z $SHIP_HOST $SHIP_PORT; do
          sleep 1;
        done;
        fill-pg --fill-connect-to=$SHIP_HOST:$SHIP_PORT --fill-trx=\"-:executed::led:onblock\" --fill-trx=\"+:executed:::\" $SUB_COMMAND
      "
