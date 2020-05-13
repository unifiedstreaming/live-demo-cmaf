# FFmpeg in Docker

This repository provides a Docker version of [FFmpeg](https://ffmpeg.org/) based on Alpine linux, 
to demonstrate live streaming using CMAF.

By default it can be used to push mulitple streams of SMPTE colour bars with a burnt in UTC timecode audio.

It is designed to stream to a [Unified Streaming](http://www.unified-streaming.com/products/unified-origin) publishing point.


## Building

To build the image run:

```bash
docker build -t ffmpeg .
```


## Usage

The default command generates a stream with EBU colour bars, BITC, logo and
audio (1kHz tone) with various bitrates and framerate. 

```bash
ffmpeg -re \
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
-video_track_timescale 10000000 \
-ism_offset $VIDEO_ISM_OFFSET \
-f mp4 "${PUB_POINT}/Streams(video-${V2_ASPECT_W}p${V2_FRAME_RATE}-${V2_BITRATE}.cmfv)" \
-map "[a2]" -c:a ${A1_CODEC} -b:a ${A1_BITRATE}  -metadata:s:a:0 language=${A1_LANGUAGE} \
-fflags +genpts \
-frag_duration $AUDIO_FRAG_DUR_MICROS \
-min_frag_duration $AUDIO_FRAG_DUR_MICROS \
-movflags +empty_moov+separate_moof+default_base_moof \
-write_prft pts \
-video_track_timescale 48000 \
-ism_offset $AUDIO_ISM_OFFSET \
-f mp4  "$PUB_POINT/Streams(audio-${A1_CODEC}-${A1_BITRATE}.cmfa)" \
-map "[a3]" -c:a ${A2_CODEC} -b:a ${A2_BITRATE}  -metadata:s:a:0 language=${A2_LANGUAGE} \
-fflags +genpts \
-frag_duration $AUDIO_FRAG_DUR_MICROS \
-min_frag_duration $AUDIO_FRAG_DUR_MICROS \
-movflags +empty_moov+separate_moof+default_base_moof \
-write_prft pts \
-video_track_timescale 48000 \
-ism_offset $AUDIO_ISM_OFFSET \
-f mp4  "$PUB_POINT/Streams(audio-${A2_CODEC}-${A2_BITRATE}.cmfa)" \
```

Configuration is done by passing in environment variables defined in the docker-compose.yaml.
