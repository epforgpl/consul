#!/bin/sh -x

rm -f /var/www/consul/tmp/pids/server.pid
bundle exec rails server -b 0.0.0.0
