![logo](https://raw.githubusercontent.com/unifiedstreaming/origin/master/unifiedstreaming-logo-black.png)

Live Origin
-----------
This image can be used as a Live streaming Origin for a single channel. 


What is Unified Origin?
-----------------------
Unified Origin offers one solution for just-in-time packaging to MPEG-DASH, Apple (HLS), Adobe (HDS) and Microsoft (MSS). Our added features include content protection, restart TV, time-shift, catchup-TV, subtitles, and multiple language and audio tracks.

Further documentation is available at: <http://docs.unified-streaming.com>

Usage
-----
This image is usable out of the box, but must be configured using environment variables.

Available variables are:

|Variable        |Usage   |Mandatory?|
|----------------|--------|----------|
|UspLicenseKey |Your license key. To evaluate the software you can create an account at <https://www.unified-streaming.com/get-started>|Yes|
|CHANNEL|Channel name, the publishing point URL will be http://<container\>/CHANNEL/CHANNEL.isml|Yes|
|PUB_POINT_OPTS  |Options to use when creating the publishing point. See http://docs.unified-streaming.com/faqs/general/options.html|No|
|LOG_LEVEL|Sets the Apache error log level|No|
|LOG_FORMAT|Sets a custom Apache log format|No|


More detailed documentation is available at: <http://docs.unified-streaming.com/documentation/live/index.html>

Example
-------
A simple example, running locally on port 1080 with a channel named test01:

```bash
docker run \
  -e UspLicenseKey=<license_key> \
  -e CHANNEL=test01 \
  -e PUB_POINT_OPTS="--archiving=1 --archive_length=600 --archive_segment_length=60 --dvr_window_length=30 --restart_on_encoder_reconnect" \
  -p 1080:80 \
  unifiedstreaming/live
```

The publishing point will be created at <http://localhost:1080/test01/test01.isml>.
Its state can be checked by running:

```bash
curl http://localhost:1080/test01/test01.isml/state
```

```xml
<?xml version="1.0" encoding="utf-8"?>
<!-- Created with Unified Streaming Platform  (version=1.11.1-24062) -->
<smil
  xmlns="http://www.w3.org/2001/SMIL20/Language">
  <head>
    <meta
      name="updated"
      content="2021-06-15T08:32:44.910401Z">
    </meta>
    <meta
      name="state"
      content="idle">
    </meta>
  </head>
</smil>
```
