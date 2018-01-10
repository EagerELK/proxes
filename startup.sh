#!/bin/sh
set -e

echo "DATABASE_URL: $DATABASE_URL"
echo "ELASTICSEARCH_URL: $ELASTICSEARCH_URL"
echo "APP_ROOT: $APP_ROOT"

if [ "$1" = 'web-proxes' ]
then
  cd /usr/src/app
  bundle exec rake ditty:generate_tokens
  bundle exec rake ditty:migrate
  bundle exec rake ditty:seed
  bundle exec whenever --update-crontab
  crond
  exec bundle exec pumactl start "$@"
fi

exec "$@"
