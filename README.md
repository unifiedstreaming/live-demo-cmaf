![Image](../master/unifiedstreaming-logo-black.jpg?raw=true)

# Unified Streaming Live Origin Demo 
# DASH-IF Live Media Ingest Protocal - Interface 2 (DASH/HLS)

## Overview
This project demonstrates the use of [FFmpeg](https://ffmpeg.org/) and [Unified Streaming - Origin Live](http://www.unified-streaming.com/products/unified-origin) to present a Live Adaptive Bitrate presentation. 

FFmpeg delivers HLS/DASH CMAF tracks to Unified Origin using the [DASH-IF Live Media Ingest Protocal - Interface 2](https://dashif-documents.azurewebsites.net/Ingest/master/DASH-IF-Ingest.html).

For more information about Unified Origin or you have any questions please visit see our [Documentation](http://docs.unified-streaming.com/) or contact us at [support@unified-streaming.com](mailto:support@unified-streaming.com?subject=[GitHub]%20CMAF%20Ingest%20Live%20Demo).
![Image](../master/cmaf_flow.png?raw=true)

The demo consists of two Docker containers which are deployed using Docker Compose, alongside 4 optional ffmpeg scripts.

The default track configuration created is below, however encoding parameters can be updated within each script.
- Video Track 1 - 1280x720 1000k AVC 48GOP@25FPS
- Audio Track 1 - 64kbs 48kHz AAC-LC - English language 

## Disclaimer

This demo utilises software which is still in development and is therefore not intended for production use. A list of known issues affecting this demo can be tracked [here](https://github.com/unifiedstreaming/live-demo-cmaf/issues).

## Setup

1. Install [Docker](http://docker.io)
2. Install [Docker Compose](http://docs.docker.com/compose/install/)
3. Download this demo's [Compose file](https://github.com/unifiedstreaming/live-demo/blob/master/docker-compose.yaml)

## FFmpeg Scripts

The ffmpeg folder contains 4 scripts which can be used to overwrite the `ffmpeg/entrypoint.sh` containing the encoding configuration. 

Choices are:
* ffmpeg_dash_chunked.sh	
* ffmpeg_dash_singlefile.sh
* ffmpeg_hls_chunked.sh
* ffmpeg_hls_singlefile.sh

This can be done by running the following command in the directory of this demo: 
```bash
#!/bin/sh
cp ffmpeg/ffmpeg_dash_chunked.sh ffmpeg/entrypoint.sh
```

## Build FFmpeg

Once the `entrypoint.sh` has been overwritten the Docker image needs to be built locally.

This can be done by running the following command in the directory of this demo's Compose file:

```bash
#!/bin/sh
docker-compose build ffmpeg
```

Which will create a Docker image called livedemo_ffmpeg.

## Build Live-Origin

As this demostation utilises apache 'mod_rewrite' as an additional configuration the Docker image needs to be build locally.

```bash
#!/bin/sh
docker-compose build live-origin
```

Which will create a Docker image called livedemo_live-origin.

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

HLS Ingest will look something like:

![example](./ffmpeg/example_hls.png?raw=true)

DASH Ingest will look something like:

![example2](./ffmpeg/example_dash.png?raw=true)
