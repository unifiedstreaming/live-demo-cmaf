#!/bin/bash

set -x

seconds_since_epoch=$(date +%s)
integer_multiple_gops_since_epoch=$(expr $seconds_since_epoch / $INTEGER_MULTIPLE_GOP_LENGTH)
ism_offset=$(expr $(expr $integer_multiple_gops_since_epoch + 1) \* $INTEGER_MULTIPLE_GOP_LENGTH)

sleep_seconds=$(( $ism_offset - $seconds_since_epoch - 1 ))
sleep $sleep_seconds

/home/fmp4-ingest/ingest-tools/fmp4ingest -r --ism_offset $ism_offset -u $PUB_POINT_URI --avail $AVAIL_INTERVAL $AVAIL_LENGTH $CMFT
