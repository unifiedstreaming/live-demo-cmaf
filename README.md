![Image](unifiedstreaming-logo-black.jpg?raw=true)
# Unified Streaming Live Origin Demo <br/> DASH-IF Live Media Ingest Protocol - Interface 1 (CMAF)

> [!WARNING]
> This repository and associated container images are **for demo purposes
> only**.
>
> Please refer to our [Installation
> documentation](https://docs.unified-streaming.com/installation/distributions.html)
> on how to install Unified Origin on your desired operating system and
> architecture where addition configuration options maybe required.

## Overview
This project demonstrates the use of [FFmpeg](https://ffmpeg.org/) and [Unified Streaming - Origin Live](http://www.unified-streaming.com/products/unified-origin) to present a Live Adaptive Bitrate presentation.

FFMPEG delivers CMAF tracks to Unified Origin using the [DASH-IF Live Media Ingest Protocol - Interface 1](https://dashif.org/Ingest/#interface-1)

### What to expect from this demo

The 2x FFmpeg containers send synchronized Video & Audio fragments to Unified Origin. To achieve this, each encoder using its internal system clock (UTC) as reference stamps the fragment with a decode time offset based upon the same algorithm (UTC + Time Scale x Sample Duration).

The default track configuration created is below, however encoding parameters can be updated within the [ffmpeg/entrypoint.py](entrypoint.py).
- Video Track 1 - 1280x720 500k AVC 48GOP@25FPS
- Video Track 2 - 640x360 300k AVC 48GOP@25FPS
- Audio Track 1 - 64kbps 48kHz AAC-LC - English language
- Audio Track 2 - 64kbps 48kHz AAC-LC - Dutch language

## Disclaimer
This demo utilises software which is still in development and is therefore not intended for production use. A list of known issues affecting this demo can be tracked [here](https://github.com/unifiedstreaming/live-demo-cmaf/issues).


## Prerequisites
Docker, if not already installed see: https://docs.docker.com/get-docker/

Internet access on host through ports 53 and 80; needed to check license key

## Step 1
Start by cloning the Live streaming trial from GitHub and starting the Docker Compose stack:

```
git clone https://github.com/unifiedstreaming/live-demo-cmaf.git

cd live-demo-cmaf

export UspLicenseKey=<your_license_key>

docker compose up -d
```
## Step 2
Wait for all the Docker images to build and services to start, you can view the status by checking the logs with:

```
docker compose logs
```

And checking the origin is available by querying it with curl:

```
curl http://localhost/channel1/channel1.isml/state
```

Which should respond:

```xml
<?xml version="1.0" encoding="utf-8"?>
<!-- Created with Unified Streaming Platform  (version=1.12.1-28247) -->
<smil
  xmlns="http://www.w3.org/2001/SMIL20/Language">
  <head>
    <meta
      name="updated"
      content="2023-01-20T15:38:30.557813Z">
    </meta>
    <meta
      name="state"
      content="started">
    </meta>
  </head>
</smil>
```
## Step 3
Play the live stream from host running container:

* Open [DASH stream (http://localhost/channel1/channel1.isml/.mpd)](https://shaka-player-demo.appspot.com/demo/#audiolang=en-GB;textlang=en-GB;uilang=en-GB;asset=http://localhost/channel1/channel1.isml/.mpd;panel=CUSTOM%20CONTENT;build=uncompiled) in latest shaka player
* Open [HLS TS stream (http://localhost/channel1/channel1.isml/.m3u8)](https://hls-js.netlify.app/demo/?src=http://localhost/channel1/channel1.isml/.m3u8) in latest hls.js
* Open [HLS CMAF stream (http://localhost/channel1/channel1.isml/.m3u8?hls_fmp4)](https://hls-js.netlify.app/demo/?src=http://localhost/channel1/channel1.isml/.m3u8?hls_fmp4) in latest hls.js

> **_NOTE:_**
The FFmpeg container is configured to encode multiple video and audio tracks in
realtime. Therefore buffering or stalled experienced when playing the stream
from Unified Origin is subject to the performance of the FFmpeg container. If issues persists, please follow step 4.

## Step 4
Stop the services by running:

```
docker compose down
```

### Tips
To check when your license key expires:
```
docker exec -it live-demo-cmaf-live-origin-1 mp4split
--show_license
```

To print and tail origin container's logs:
```
docker logs -f live-demo-cmaf-live-origin-1
```
To get into origin container's shell:
```
docker exec -it -w /var/www/unified-origin live-demo-cmaf-live-origin-1 /bin/sh
```

## What's next?
[Learn more about the key features and benefits of using Unified Origin for live streaming](https://docs.unified-streaming.com/documentation/live/index.html)

or

[Contact us](mailto:%20sales@unified-streaming.com) to purchase a license

Watching the stream can be done using your player of choice, for example FFplay.

```bash
#!/bin/sh
ffplay http://localhost/test/test.isml/.m3u8
```

And it should look something like:

![example](./ffmpeg/example_cmaf.png?raw=true)
