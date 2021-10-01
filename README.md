![Image](unifiedstreaming-logo-black.jpg?raw=true)
# Unified Streaming Live Origin Demo <br/> FFmpeg RTMP -> CMAF bridge

## Overview
This demo shows a simple example of using FFmpeg to bridge from RTMP input and
output CMAF which can be ingested by Unified Origin.

Unified Origin then dynamically packages to HLS, DASH, etc.


## Setup

1. Install [Docker](http://docker.io)
2. Install [Docker Compose](http://docs.docker.com/compose/install/)
3. Clone this repository
4. checkout the ``rtmp`` branch


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

Now that the stack is running you can start delivering RTMP to ``rtmp://localhost/live``.

FFmpeg will transcode and then deliver as CMAF to the Unified Origin.

Streams from the Origin will the be available as normal:

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

