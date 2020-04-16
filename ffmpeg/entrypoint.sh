#!/bin/sh

# set env vars to defaults if not already set
export FRAME_RATE="${FRAME_RATE:-25}"
export GOP_LENGTH="${GOP_LENGTH:-${FRAME_RATE}}"
export AUDIO_FRAG_DUR_MICROS="${AUDIO_FRAG_DUR_MICROS:-1920000}"

if [ "${FRAME_RATE}" = "30000/1001" -o "${FRAME_RATE}" = "60000/1001" ]; then
  echo "drop frame"
  export FRAME_SEP="."
else
  export FRAME_SEP=":"
fi

export LOGO_OVERLAY="${LOGO_OVERLAY-https://raw.githubusercontent.com/unifiedstreaming/live-demo/master/ffmpeg/usp_logo_white.png}"

if [ -n "${LOGO_OVERLAY}" ]; then
  export LOGO_OVERLAY="-i ${LOGO_OVERLAY}"
  export OVERLAY_FILTER=", overlay=eval=init:x=W-15-w:y=15"
fi

# validate required variables are set
if [ -z "${PUB_POINT_URI}" ]; then
  echo >&2 "Error: PUB_POINT_URI environment variable is required but not set."
  exit 1
fi

timecode=$(date +%H\\:%M\\:%S).00
PUB_POINT=${PUB_POINT_URI}

set -x
exec ffmpeg -re \
-f lavfi \
-i smptehdbars=size=1280x720 \
-i "https://raw.githubusercontent.com/unifiedstreaming/live-demo/master/ffmpeg/usp_logo_white.png" \
-filter_complex \
"sine=frequency=1:beep_factor=480:sample_rate=48000, \
atempo=0.5[a1]; \
sine=frequency=1:beep_factor=960:sample_rate=48000, \
atempo=0.5, \
adelay=1000[a2]; \
[a1][a2]amix, \
highpass=40, \
adelay='$(date +%3N)', \
asplit=3[a1][a2][a3]; \
[a1]showwaves=mode=p2p:colors=white:size=1280x100:scale=lin:rate=$(($FRAME_RATE))[waves]; \
color=size=1280x100:color=black[blackbg]; \
[blackbg][waves]overlay[waves2]; \
[0][waves2]overlay=y=620[v]; \
[v]drawbox=y=25: x=iw/2-iw/7: c=0x00000000@1: w=iw/3.5: h=36: t=fill, \
drawtext=text='DASH-IF Live Media Ingest Protocol': fontsize=32: x=(w-text_w)/2: y=75: fontsize=32: fontcolor=white,\
drawtext=text='Interface 1 - CMAF': fontsize=32: x=(w-text_w)/2: y=125: fontsize=32: fontcolor=white, \
drawtext=timecode_rate=${FRAME_RATE}: timecode='$(date -u +%H\\:%M\\:%S)\\${FRAME_SEP}$(($(date +%3N)/$((1000/$FRAME_RATE))))': tc24hmax=1: fontsize=32: x=(w-tw)/2+tw/2: y=30: fontcolor=white, \
drawtext=text='%{gmtime\:%Y-%m-%d}\ ': fontsize=32: x=(w-tw)/2-tw/2: y=30: fontcolor=white[v+tc]; \
[v+tc][1]overlay=eval=init:x=W-15-w:y=15[vid];
[vid]split=2[vid0][vid1]" \
-map "[vid0]" -s 1024x576 -c:v libx264 -b:v 500k -profile:v main -preset ultrafast -tune zerolatency \
-g $GOP_LENGTH \
-r $FRAME_RATE \
-keyint_min $GOP_LENGTH \
-fflags +genpts \
-movflags +frag_keyframe+empty_moov+separate_moof+default_base_moof \
-video_track_timescale 10000000 \
-ism_offset $(($(date +%s)*10000000)) \
-f mp4 "$PUB_POINT/Streams(video-576p25-500k.cmfv)" \
-map "[vid1]" -s 1280x720 -c:v libx264 -b:v 1000k -profile:v main -preset ultrafast -tune zerolatency \
-g $GOP_LENGTH \
-r $FRAME_RATE \
-keyint_min $GOP_LENGTH \
-fflags +genpts \
-movflags +frag_keyframe+empty_moov+separate_moof+default_base_moof \
-video_track_timescale 10000000 \
-ism_offset $(($(date +%s)*10000000)) \
-f mp4 "$PUB_POINT/Streams(video-720p25-1000k.cmfv)" \
-map "[a2]" -c:a aac -b:a 64k  -metadata:s:a:0 language=dut \
-fflags +genpts \
-frag_duration $AUDIO_FRAG_DUR_MICROS \
-min_frag_duration $AUDIO_FRAG_DUR_MICROS \
-movflags +empty_moov+separate_moof+default_base_moof \
-video_track_timescale 48000 \
-ism_offset $(($(date +%s)*48000)) \
-f mp4  "$PUB_POINT/Streams(audio-aac-64k.cmfa)" \
-map "[a3]" -c:a aac -b:a 128k  -metadata:s:a:0 language=eng \
-fflags +genpts \
-frag_duration $AUDIO_FRAG_DUR_MICROS \
-min_frag_duration $AUDIO_FRAG_DUR_MICROS \
-movflags +empty_moov+separate_moof+default_base_moof \
-video_track_timescale 48000 \
-ism_offset $(($(date +%s)*48000)) \
-f mp4  "$PUB_POINT/Streams(audio-aac-128k.cmfa)"
