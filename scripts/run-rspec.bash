#!/usr/bin/env bash

set -e

cd "${0%/*}/.."

echo "Running tests"
docker-compose -f dev-compose.yaml run --rm web bundle exec rspec
