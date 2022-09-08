#!/bin/bash

set -x

seconds_since_epoch=$(date +%s)
integer_multiple_gops_since_epoch=$(expr $seconds_since_epoch / $INTEGER_MULTIPLE_GOP_LENGTH)
ism_offset=$(expr $(expr $integer_multiple_gops_since_epoch + 1) \* $INTEGER_MULTIPLE_GOP_LENGTH)

sleep_seconds=$(( $ism_offset - $seconds_since_epoch - 1 ))
sleep $sleep_seconds

/home/fmp4-ingest/ingest-tools/push_markers --track_id 100 --announce 4000 --seg_dur 1920 --vtt -r -u $PUB_POINT_URI --avail $AVAIL_INTERVAL $AVAIL_LENGTH 
