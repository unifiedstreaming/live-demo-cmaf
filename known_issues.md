# Known Issues

* Audio tracks contain no bitrate information (affected both Interface 1/2)
* Video tracks contain no bitrate information (affects interface 2 only)
* CMAF subtitles (not supported in ffmpeg)
* FFmpeg subtitle Codec ID "tx3g" now supported by Unified Origin
* Timed Metadata (unable to generate dynamically/requires external tooling)
* Unable to compile/run natively on ubuntu (av_interleaved_write_frame(): Broken
  pipe) errors
* ffmpeg unable to handle remix drefs
* Dash chunked mode using ``-streaming`` switch causes small fragments in hls
  manifest (not in dash)
* Unable to find sidx box in archive segments when enabling
  ``-global_sidx`` in ffmpeg
* libx265 + mp4 muxer doesn't post data to origin
* Dual Encoder ingest not possible, due to lack of sync between FFmpeg containers
