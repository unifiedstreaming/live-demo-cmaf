# FFmpeg in Docker

This repository provides a Docker version of [FFmpeg](https://ffmpeg.org/) based on Alpine linux, 
to demonstrate live streaming using Smooth Streaming.

By default it can be used to push a stream of SMPTE colour bars with a burnt in UTC timecode and silent audio.

It is designed to stream to a [Unified Streaming](http://www.unified-streaming.com/products/unified-origin) publishing point.


## Building

To build the image run:

```bash
docker build -t ffmpeg .
```


## Usage

The default command generates a stream with colour bars, BITC, a logo and silent audio.

```bash
ffmpeg -re -f lavfi -i smptehdbars=size=1280x720 \
            -f lavfi -i anullsrc \
            $LOGO_OVERLAY \
            -filter_complex \
                "drawbox=y=25: x=iw/2-iw/7: c=0x00000000@1: w=iw/3.5: h=36: t=max, \
                 drawtext=timecode_rate=${FRAME_RATE}: timecode='$(date -u +%H\\:%M\\:%S)\\${FRAME_SEP}$(($(date +%3N)/$(($FRAME_RATE))))': tc24hmax=1: fontsize=32: x=(w-tw)/2+tw/2: y=30: fontcolor=white, \
                 drawtext=text='%{gmtime\:%Y-%m-%d}\ ': fontsize=32: x=(w-tw)/2-tw/2: y=30: fontcolor=white${OVERLAY_FILTER}" \
            -g $GOP_LENGTH \
            -r $FRAME_RATE \
            -keyint_min $GOP_LENGTH \
            -c:v libx264 \
            -c:a aac \
            -map 0:v \
            -map 1:a \
            -fflags +genpts \
            -movflags isml+frag_keyframe \
            -ism_offset $(($(date +%s)*10000000)) \
            -f ismv \
            $PUB_POINT_URI
```


Configuration is done by passing in environment variables.

| Variable           | Mandatory | Usage                                    |
|--------------------|-----------|------------------------------------------|
| PUB_POINT_URI      | yes       | Publishing point to stream to            |
| FRAME_RATE         | no        | Video frame rate, default 25             |
| GOP_LENGTH         | no        | Video GOP length, default to frame rate  |
| LOGO_OVERLAY       | no        | Logo to overlay, defaults to USP logo. Set to empty if no logo is wanted    |

### Example 1 - default USP logo

```bash
docker run \
  -e "PUB_POINT_URI=http://192.168.1.21:1080/test01/test01.isml/Streams(ffmpeg)" \
  -e FRAME_RATE=25 \
  ffmpeg
```

Should produce a stream which looks like:

![example](https://raw.githubusercontent.com/unifiedstreaming/live-demo/master/ffmpeg/example_logo.png)


### Example 2 - no logo

```bash
docker run \
  -e "PUB_POINT_URI=http://192.168.1.21:1080/test01/test01.isml/Streams(ffmpeg)" \
  -e FRAME_RATE=25 \
  -e LOGO_OVERLAY= \
  ffmpeg
```

Should produce a stream which looks like:

![example](https://raw.githubusercontent.com/unifiedstreaming/live-demo/master/ffmpeg/example.png)