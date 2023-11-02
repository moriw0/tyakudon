#!/bin/bash
set -e

bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed

exec "$@"
