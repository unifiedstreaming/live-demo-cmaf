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

#if [ -n "${LOGO_OVERLAY}" ]; then
#  export LOGO_OVERLAY="-i ${LOGO_OVERLAY}"
#  export OVERLAY_FILTER=", overlay=eval=init:x=W-15-w:y=15"
#fi

# validate required variables are set
if [ -z "${PUB_POINT_URI}" ]; then
  echo >&2 "Error: PUB_POINT_URI environment variable is required but not set."
  exit 1
fi

PUB_POINT=${PUB_POINT_URI}
# Python arithmatic to create accurate timing
VIDEO_ISM_OFFSET=`python3 -c "import time; print(int(time.time() * 10000000))"`
AUDIO_ISM_OFFSET=`python3 -c "import time; print(int(time.time() * 48000))"`
DATE_MICRO=`python3 -c "import time; print($VIDEO_ISM_OFFSET / 10000000)"`
DATE_PART1=`python3 -c "import time; print(repr($DATE_MICRO).split('.')[0])"`
DATE_PART2=`python3 -c "import time; print(repr($DATE_MICRO).split('.')[1][:3])"`
DATE_MOD_DAYS=`python3 -c "import time; print((int($DATE_PART1) % 86400))"`

set -x
exec ffmpeg -re \
-f lavfi \
-i smptehdbars=size=${V1_ASPECT_W}x${V1_ASPECT_H}:rate=${V1_FRAME_RATE} \
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
[a1]showwaves=mode=p2p:colors=white:size=${V1_ASPECT_W}x100:scale=lin:rate=$((${V1_FRAME_RATE}))[waves]; \
color=size=${V1_ASPECT_W}x100:color=black[blackbg]; \
[blackbg][waves]overlay[waves2]; \
[0][waves2]overlay=y=620[v]; \
[v]drawbox=y=25: x=iw/2-iw/7: c=0x00000000@1: w=iw/3.5: h=36: t=fill, \
drawtext=text='DASH-IF Live Media Ingest Protocol': fontsize=32: x=(w-text_w)/2: y=75: fontsize=32: fontcolor=white,\
drawtext=text='Interface 1 - CMAF': fontsize=32: x=(w-text_w)/2: y=125: fontsize=32: fontcolor=white, \
drawtext=text='%{pts\:gmtime\:${DATE_PART1}\:%Y-%m-%d}%{pts\:hms\:${DATE_MOD_DAYS}.${DATE_PART2}}':\
fontsize=32: x=(w-tw)/2: y=30: fontcolor=white[v+tc]; \
[v+tc][1]overlay=eval=init:x=W-15-w:y=15[vid]; \
[vid]split=2[vid0][vid1]" \
-map "[vid0]" -s ${V1_ASPECT_W}x${V1_ASPECT_H} -c:v ${V1_CODEC} -b:v ${V1_BITRATE} -profile:v main -preset ultrafast -tune zerolatency \
-g ${V1_GOP_LENGTH} \
-r ${V1_FRAME_RATE} \
-keyint_min ${V1_GOP_LENGTH} \
-fflags +genpts \
-movflags +frag_keyframe+empty_moov+separate_moof+default_base_moof \
-global_sidx 1 \
-write_prft pts \
-video_track_timescale 10000000 \
-ism_offset $VIDEO_ISM_OFFSET \
-f mp4 "${PUB_POINT}/Streams(video-${V1_ASPECT_W}p${V1_FRAME_RATE}-${V1_BITRATE}.cmfv)" \
-map "[vid1]" -s ${V2_ASPECT_W}x${V2_ASPECT_H} -c:v ${V2_CODEC} -b:v ${V2_BITRATE} -profile:v main -preset ultrafast -tune zerolatency \
-g ${V2_GOP_LENGTH} \
-r ${V2_FRAME_RATE} \
-keyint_min ${V2_GOP_LENGTH} \
-fflags +genpts \
-movflags +frag_keyframe+empty_moov+separate_moof+default_base_moof \
-write_prft pts \
-global_sidx 1 \
-video_track_timescale 10000000 \
-ism_offset $VIDEO_ISM_OFFSET \
-f mp4 "${PUB_POINT}/Streams(video-${V2_ASPECT_W}p${V2_FRAME_RATE}-${V2_BITRATE}.cmfv)" \
-map "[a2]" -c:a ${A1_CODEC} -b:v ${A1_BITRATE}  -metadata:s:a:0 language=${A1_LANGUAGE} \
-fflags +genpts \
-frag_duration $AUDIO_FRAG_DUR_MICROS \
-min_frag_duration $AUDIO_FRAG_DUR_MICROS \
-movflags +empty_moov+separate_moof+default_base_moof \
-write_prft pts \
-global_sidx 1 \
-video_track_timescale 48000 \
-ism_offset $AUDIO_ISM_OFFSET \
-f mp4  "$PUB_POINT/Streams(audio-${A1_CODEC}-${A1_BITRATE}.cmfa)" \
-map "[a3]" -c:a ${A2_CODEC} -b:v ${A2_BITRATE}  -metadata:s:a:0 language=${A2_LANGUAGE} \
-fflags +genpts \
-frag_duration $AUDIO_FRAG_DUR_MICROS \
-min_frag_duration $AUDIO_FRAG_DUR_MICROS \
-movflags +empty_moov+separate_moof+default_base_moof \
-write_prft pts \
-global_sidx 1 \
-video_track_timescale 48000 \
-ism_offset $AUDIO_ISM_OFFSET \
-f mp4  "$PUB_POINT/Streams(audio-${A2_CODEC}-${A2_BITRATE}.cmfa)" \
