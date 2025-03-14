#!/usr/bin/env bash

set -x
set -eo pipefail

if ! [ -x "$(command -v psql)" ]; then
  echo >&2 "Error: psql not installed"
  exit 1
fi

if ! [ -x "$(command -v sqlx)" ]; then
  echo >&2 "Error: sqlx not installed"
  exit 1
fi

if [[ -z "${SKIP_DOCKER}" ]]
then
  DB_USER="${POSTGRES_USER:=postgres}"
  DB_PASSWORD="${POSTGRES_PASSWORD:=password}"
  DB_NAME="${POSTGRES_NAME:=newsletter}"
  DB_PORT="${POSTGRES_PORT:=5432}"
  DB_HOST="${POSTGRES_HOST:=localhost}"

  docker run \
    -e POSTGRES_USER=${DB_USER} \
    -e POSTGRES_PASSWORD=${DB_PASSWORD} \
    -e POSTGRES_NAME=${DB_NAME} \
    -p "${DB_PORT}":5432 \
    -d postgres \
    postgres -N 1000
fi
  
export PGPASSWORD="${DB_PASSWORD}"
until psql -h "${DB_HOST}" -U "${DB_USER}" -p "${DB_PORT}" -d "postgres" -c '\q'; do
  >&2 echo "Postgres is still unavailable - sleeping"
  sleep 1
done

>&2 echo "Postgres is up and running on port ${DB_PORT}"

DATABASE_URL=postgres://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}
export DATABASE_URL
sqlx database create
sqlx migrate run

>&2 echo "Postgres has been migrated, ready to go!"
