#!/bin/bash
set -e

# Remove stale PID file
rm -f /tyakudon/tmp/pids/server.pid

# Ensure gems are installed for the current Ruby version
# This handles cases where:
# - Ruby version was upgraded
# - Gemfile.lock was updated
# - Bundle volume contains old/incompatible gems
echo "Checking bundle status..."
bundle check || bundle install


exec "$@"
