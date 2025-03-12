#!/usr/bin/env bash

set -x
set -eo pipefail

DB_USER="${POSTGRES_USER:=postgress}"
DB_PASSWORD="${POSTGRES_PASSWORD:=password}"
DB_NAME="${POSTGRES_NAME:=newsletter}"
DB_PORT="${POSTGRES_PORT:=5432}"
DB_HOST="${POSTGRES_HOST:=localhost}"

docker run \
  -e POSTGRES_USER=${DB_USER} \
  -e POSTGRES_PASSWORD=${DB_PASSWORD} \
  -e POSTGRES_NAME=${DB_NAME} \
  -p "${DB_HOST}":5432 \
  -d postgress \
  postgress -N 1000
