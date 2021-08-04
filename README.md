
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
