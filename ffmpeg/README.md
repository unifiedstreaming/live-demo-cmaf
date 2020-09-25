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
The following folder contains 4 scripts which can be used to overwrite the `ffmpeg/entrypoint.sh` containing the encoding configuration. 

Choices are:
* ffmpeg_dash_chunked.sh	
* ffmpeg_dash_singlefile.sh
* ffmpeg_hls_chunked.sh
* ffmpeg_hls_singlefile.sh
