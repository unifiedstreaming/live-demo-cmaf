#!/bin/sh

# set env vars to defaults if not already set
if [ ! $FRAME_RATE ]
  then
  export FRAME_RATE=25
fi

if [ ! $GOP_LENGTH ]
  then
  export GOP_LENGTH=$FRAME_RATE
fi

export FRAME_SEP=\:
if [ $FRAME_RATE == "30000/1001" ] || [ $FRAME_RATE == "60000/1001" ]
  then
  echo "drop frame"
  export FRAME_SEP=\.
fi

if [ -z ${LOGO_OVERLAY+x$LOGO_OVERLAY} ]
  then
  export LOGO_OVERLAY="https://raw.githubusercontent.com/unifiedstreaming/live-demo/ffmpeg/master/usp_logo_white.png"
fi

if [ ! -z $LOGO_OVERLAY ]
  then
  export LOGO_OVERLAY="-i ${LOGO_OVERLAY}"
  export OVERLAY_FILTER=", overlay=eval=init:x=W-15-w:y=15"
fi

# validate required variables are set
if [ ! $PUB_POINT_URI ]
  then
  echo >&2 "Error: PUB_POINT_URI environment variable is required but not set."
  exit 1
fi


exec "$@"