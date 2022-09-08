#!/bin/bash

set -x

sleep 5

/home/fmp4-ingest/ingest-tools/push_markers --track_id 100 --announce 4000 --seg_dur 1920 --vtt -r -u $PUB_POINT_URI --avail $AVAIL_INTERVAL $AVAIL_LENGTH 
