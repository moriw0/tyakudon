#!/bin/bash
set -e

rm -f /tyakudon/tmp/pids/server.pid

if [ "$RAILS_ENV" = "production" ]; then
  RAILS_ENV=production bundle exec rails db:migrate
  RAILS_ENV=production bundle exec rails assets:precompile
fi

exec "$@"
