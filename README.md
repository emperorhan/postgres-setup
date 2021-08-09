
# Pre-Run

```bash
# build dockerfile
$ docker build -f postgres/Dockerfile -t postgres-custom .
```

or

```bash
# build dockerfile
$ docker build -f postgres/Dockerfile-hasura-pg -t postgres-custom .
```

# Run

```bash
# exec run.sh
$ ./script/run.sh --help
```

# init.sql

`fill-pg` sets up a bare database without indexes and query functions. After `fill-pg` is caught up to the chain, stop it then run `init.sql` in this repository's source directory. e.g. `docker exec -it postgres psql --username=postgres -f /var/lib/postgresql/data/pgdata/init.sql`.

## stop fill-pg

```bash
# stop fill-pg
$ docker stop fill-pg
```

## run init.sql

```bash
# run init.sql
$ docker exec -it postgres psql --username=postgres -f /var/lib/postgresql/data/pgdata/init.sql
```
