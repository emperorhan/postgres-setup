#!/bin/bash

function usage() {
    printf "Usage: $0 OPTION...
    -n, --name                  History-tools Container name
    -i, --init                  fill-pg init
    -e, --endpoint ENDPOINT     State history plugin node endpoint
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
SHIP_ENDPOINT="127.0.0.1:8080"

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
        shift
        ;;
    -i | --init)
        SUB_COMMAND+=" --fpg-drop --fpg-create"
        shift
        ;;
    -e | --endpoint)
        SHIP_ENDPOINT="$2"
        shift
        ;;
    -s | --skip)
        SUB_COMMAND+=" --fill-skip-to=$2"
        shift
        ;;
    --db-name)
        POSTGRES_DB="$2"
        shift
        ;;
    --db-user)
        POSTGRES_USER="$2"
        shift
        ;;
    --db-passwd)
        POSTGRES_PASSWORD="$2"
        shift
        ;;
    --db-host)
        POSTGRES_HOST="$2"
        shift
        ;;
    --db-port)
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

echo "SHIP_ENDPOINT: $SHIP_ENDPOINT"
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
    eosio/history-tools:9415f91 \
    /bin/sh -c "
        echo Waiting for nodeos service start...;
        while ! nc -z $SHIP_ENDPOINT; do
          sleep 1;
        done;
        fill-pg --fill-connect-to=$SHIP_ENDPOINT --fill-trx=\"-:executed::led:onblock\" --fill-trx=\"+:executed:::\" $SUB_COMMAND
      "
