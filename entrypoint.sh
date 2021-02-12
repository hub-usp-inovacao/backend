#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f $APP_PATH/tmp/pids/server.pid

# Set up the crontab
bundle exec whenever --update-crontab && crond

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
