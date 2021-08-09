#!/bin/bash

function usage() {
    printf "Usage: $0 OPTION...
    -n, --name              Hasura Container name
    -p, --port              Hasura Port
    -s, --secret            Hasura Admin Secret
    -k, --jwt-public-key    Hasura Jwt PublicKey
    --db-name               PostgreSQL Database name
    --db-user               PostgreSQL User name
    --db-passwd             PostgreSQL Password
    --db-host               PostgreSQL Host Ip
    --db-port               PostgreSQL Host Port
    -h, --help              How to use hasura.sh
    \\n" "$0" 1>&2
    exit 1
}

[ $# -eq 0 ] && usage

CONTAINER_NAME="postgres"
HASURA_PORT="8080"
HASURA_GRAPHQL_ADMIN_SECRET="qwerqwerqwer"
HASURA_GRAPHQL_JWT_PUBLIC_KEY=""
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
    -p | --port)
        HASURA_PORT="$2"
        shift
        ;;
    -s | --secret)
        HASURA_GRAPHQL_ADMIN_SECRET="$2"
        shift
        ;;
    -k | --jwt-public-key)
        HASURA_GRAPHQL_JWT_PUBLIC_KEY="$2"
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

echo "HASURA_PORT: $HASURA_PORT"
echo "HASURA_GRAPHQL_ADMIN_SECRET: $HASURA_GRAPHQL_ADMIN_SECRET"
echo "HASURA_GRAPHQL_JWT_PUBLIC_KEY: $HASURA_GRAPHQL_JWT_PUBLIC_KEY"

echo "POSTGRES_DB: $POSTGRES_DB"
echo "POSTGRES_USER: $POSTGRES_USER"
echo "POSTGRES_PASSWORD: $POSTGRES_PASSWORD"
echo "POSTGRES_HOST: $POSTGRES_HOST"
echo "POSTGRES_PORT: $POSTGRES_PORT"

docker run -d --name $CONTAINER_NAME \
    -e HASURA_GRAPHQL_DATABASE_URL=postgres://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB \
    -e HASURA_GRAPHQL_ENABLE_CONSOLE="true" \
    -e HASURA_GRAPHQL_ENABLED_LOG_TYPES="startup, http-log, webhook-log, websocket-log, query-log" \
    -e HASURA_GRAPHQL_ADMIN_SECRET=$HASURA_GRAPHQL_ADMIN_SECRET \
    -e HASURA_GRAPHQL_JWT_SECRET="{\"type\": \"RS256\", \"key\": \"$HASURA_GRAPHQL_JWT_PUBLIC_KEY\", \"claims_namespace\": \"claims\", \"claims_format\": \"json\"}" \
    -e HASURA_GRAPHQL_UNAUTHORIZED_ROLE=anonymous \
    -p $HASURA_PORT:8080 \
    hasura/graphql-engine:v2.0.3
