#!/usr/bin/env bash

cat /tmp/postgresql.conf > /var/lib/postgresql/data/pgdata/postgresql.conf
cat /tmp/init.sql > /var/lib/postgresql/data/pgdata/init.sql

/etc/init.d/postgresql restart

