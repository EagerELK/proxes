#!/bin/sh
set -e

echo "DATABASE_URL: $DATABASE_URL"
echo "ELASTICSEARCH_URL: $ELASTICSEARCH_URL"
echo "APP_ROOT: $APP_ROOT"
bundle show ditty
bundle show proxes

if [ "$1" = 'web-proxes' ]
then
  cd $APP_ROOT
  bundle exec rake ditty:generate_tokens
  bundle exec rake ditty:migrate
  bundle exec rake ditty:seed
  exec bundle exec pumactl start "$@"
fi

exec "$@"
