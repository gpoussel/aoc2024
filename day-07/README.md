# Day 7: PostgreSQL

## Launching

```
docker run --rm -e POSTGRES_PASSWORD=postgres -e POSTGRES_PORT=5555 -v %cd%:/docker-entrypoint-initdb.d:ro postgres:17.2
```
