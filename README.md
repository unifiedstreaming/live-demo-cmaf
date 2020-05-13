![Image](../master/unifiedstreaming-logo-black.jpg?raw=true)
# Unified Streaming Live Origin Demo - DASH-IF Live Media Ingest Protocal - Interface 1 (CMAF)

This demonstration shows a [Unified Streaming](http://www.unified-streaming.com/products/unified-origin) Origin setup with a Live publishing point and [FFmpeg](https://ffmpeg.org/) as an encoder to push CMAF a live ingest stream.

The demo consists of two Docker containers which are deployed using Docker Compose.

## Overview
The demo generates the following stream configuration:
- Video Track 1 - 1280x720 1000k AVC 96GOP@50FPS
- Video Track 2 - 1024x576 500k AVC 48GOP@25FPS
- Audio Track 1 - 128kbs 48kHz AAC-LC - English language 
- Audio Track 2 - 64kbs 48kHz AAC-LC - Dutch language

## Setup

1. Install [Docker](http://docker.io)
2. Install [Docker Compose](http://docs.docker.com/compose/install/)
3. Download this demo's [Compose file](https://github.com/unifiedstreaming/live-demo/blob/master/docker-compose.yaml)


## Build FFmpeg

As this demonstration contains will generate the following stream configurations, so the Docker image needs to be built locally.

This can be done by running the following command in the directory of this demo's Compose file:

```bash
#!/bin/sh
docker-compose build ffmpeg
```

Which will create a Docker image called livedemo_ffmpeg with the patch applied.


## Usage

You need a license key to use this software. To evaluate you can create an account at [Unified Streaming Registration](https://www.unified-streaming.com/licenses/access).

The license key is passed to containers using the *USP_LICENSE_KEY* environment variable.

Start the stack using *docker-compose*:

```bash
#!/bin/sh
export USP_LICENSE_KEY=<your_license_key>
docker-compose up
```

You can also choose to run it in background (detached mode):

```bash
#!/bin/sh
export USP_LICENSE_KEY=<your_license_key>
docker-compose up -d
```

Now that the stack is running the live stream should be available in all streaming formats at the following URLs:

| Streaming Format | Playout URL |
|------------------|-------------|
| MPEG-DASH | http://localhost/test/test.isml/.mpd |
| HLS | http://localhost/test/test.isml/.m3u8 |
| Microsoft Smooth Streaming | http://localhost/test/test.isml/Manifest |
| Adobe HTTP Dynamic Streaming | http://localhost/test/test.isml/.f4m |


Watching the stream can be done using your player of choice, for example FFplay.

```bash
#!/bin/sh
ffplay http://localhost/test/test.isml/.m3u8
```

And it should look something like:

![example](https://raw.githubusercontent.com/unifiedstreaming/live-demo-cmaf/master/ffmpeg/example_cmaf.png)

