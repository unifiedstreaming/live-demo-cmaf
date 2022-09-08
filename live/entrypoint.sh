#!/bin/sh

# set env vars to defaults if not already set
if [ -z "$LOG_LEVEL" ]
  then
  export LOG_LEVEL=warn
fi

if [ -z "$LOG_FORMAT" ]
  then
  export LOG_FORMAT="%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\" %D"
fi

# validate required variables are set
if [ -z "$UspLicenseKey" ] && [ -z "$USP_LICENSE_KEY" ]
  then
    echo >&2 "Error: UspLicenseKey environment variable is required but not set."
    exit 1
elif [ -z "$UspLicenseKey" ]
  then
    export UspLicenseKey="$USP_LICENSE_KEY"
fi

if [ -z "$CHANNEL" ]
  then
  echo >&2 "Error: CHANNEL environment variable is required but not set."
  exit 1
fi


# update configuration based on env vars
/bin/sed "s/{{LOG_LEVEL}}/${LOG_LEVEL}/g; s/{{LOG_FORMAT}}/'${LOG_FORMAT}'/g" /etc/apache2/conf.d/unified-origin.conf.in > /etc/apache2/conf.d/unified-origin.conf

# USP license
echo $UspLicenseKey > /etc/usp-license.key

# create publishing point
if [ ! -f /var/www/live/$CHANNEL/$CHANNEL.isml ]
  then
    mkdir -p /var/www/live/$CHANNEL
    chown -R apache:apache /var/www/live
    mp4split \
      -o /var/www/live/$CHANNEL/$CHANNEL.isml \
      $PUB_POINT_OPTS
fi

rm -f /run/apache2/httpd.pid

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
  set -- httpd "$@"
fi

exec "$@"
