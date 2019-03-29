#!/bin/sh -x

USER_UID=$(stat -c %u /var/www/consul/Gemfile)
USER_GID=$(stat -c %g /var/www/consul/Gemfile)

export USER_UID
export USER_GID

usermod -u "$USER_UID" consul 2> /dev/null
groupmod -g "$USER_GID" consul 2> /dev/null
usermod -g "$USER_GID" consul 2> /dev/null

chown -R -h "$USER_UID" "$BUNDLE_PATH" /var/www/consul/log /var/www/consul/tmp
chgrp -R -h "$USER_GID" "$BUNDLE_PATH" /var/www/consul/log /var/www/consul/tmp

/usr/bin/sudo -EH -u consul "$@"

