#! /bin/bash

set -e

if [ "$1" = "sleep" ]; then
  sleep 99999999999
else
  # We copy assets only for web application
  bundle exec puma -e ${RAILS_ENV} -C config/puma.rb
fi
