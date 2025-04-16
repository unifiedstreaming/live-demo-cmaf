#!/bin/sh
set -e

# Validate license key variable is set
if [ -z "$UspLicenseKey" ] && [ -z "$USP_LICENSE_KEY" ]
  then
  echo >&2 "Error: UspLicenseKey environment variable is required but not set."
  exit 1
elif [ -z "$UspLicenseKey" ]
  then
  export UspLicenseKey=$USP_LICENSE_KEY
fi

# write license key to file
echo "$UspLicenseKey" > /etc/usp-license.key

# If specified, override default log level and format config
if [ "$LOG_FORMAT" ]
then
  export EXTRA_OPTIONS="$EXTRA_OPTIONS -D LOG_FORMAT"
fi
if [ "$LOG_LEVEL" ]
then
  export EXTRA_OPTIONS="$EXTRA_OPTIONS -D LOG_LEVEL"
fi

# Remote storage URL and storage proxy config
if [ "$REMOTE_STORAGE_URL" ]
then
  export EXTRA_OPTIONS="$EXTRA_OPTIONS -D REMOTE_STORAGE_URL"
  if [ -z "$REMOTE_PATH" ]
  then
    export REMOTE_PATH=remote
  fi
fi
if [ "$S3_ACCESS_KEY" ]
then
  export EXTRA_OPTIONS="$EXTRA_OPTIONS -D S3_ACCESS_KEY"
fi
if [ "$S3_SECRET_KEY" ]
then
  export EXTRA_OPTIONS="$EXTRA_OPTIONS -D S3_SECRET_KEY"
fi
if [ "$S3_SECURITY_TOKEN" ]
then
  export EXTRA_OPTIONS="$EXTRA_OPTIONS -D S3_SECURITY_TOKEN"
fi
if [ "$S3_REGION" ]
then
  export EXTRA_OPTIONS="$EXTRA_OPTIONS -D S3_REGION"
fi

# REST API
if [ "$REST_API_PORT" ]
  then
  export EXTRA_OPTIONS="$EXTRA_OPTIONS -D REST_API_PORT"
fi

# Change 'Listen 80' to 'Listen 0.0.0.0:80' to avoid some strange issues when IPv6 is available
/bin/sed -i "s@Listen 80@Listen 0.0.0.0:80@g" /etc/apache2/httpd.conf

rm -f /run/apache2/httpd.pid

# create ingest publishing point
if [ ! -f /var/www/unified-origin/$PUB_POINT_NAME/$PUB_POINT_NAME.isml ]
  then
    mkdir -p /var/www/unified-origin/$PUB_POINT_NAME
    chown -R apache:apache /var/www/unified-origin/$PUB_POINT_NAME
    mp4split \
      -o "/var/www/unified-origin/$PUB_POINT_NAME/$PUB_POINT_NAME.isml" \
      $PUB_POINT_OPTS
fi


# First arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
  set -- httpd $EXTRA_OPTIONS "$@"
fi

exec "$@"
