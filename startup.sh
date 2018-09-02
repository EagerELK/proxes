#!/bin/sh
set -e
echo "DATABASE_URL: $DATABASE_URL"
echo "ELASTICSEARCH_URL: $ELASTICSEARCH_URL"
echo "APP_ROOT: $APP_ROOT"

cd $APP_ROOT

echo "Starting"
if [ "$1" = 'web-proxes' ]
then
  bundle exec rake ditty:generate_tokens
  bundle exec rake ditty:migrate
  bundle exec rake ditty:seed
  exec bundle exec pumactl start "$@"
fi

exec "$@"
