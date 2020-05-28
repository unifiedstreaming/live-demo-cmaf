# Unified Streaming Live Origin 

## Build Live-Origin

As this demostation utilises apache 'mod_rewrite' as an additional configuration the Docker image needs to be build locally.

```bash
#!/bin/sh
docker-compose build live-origin
```

Which will create a Docker image called livedemo_live-origin.

To enable DASH/HLS ingest to Unified-Origin re-write rules must be applied to the apache virtual host configuration. This github project contains the followingrules allowing both chunked and single file ingest of HLS/DASH fragments to
Unified-Origin. 

```bash
  RewriteEngine On
  # rewrite DASH Init '/test/test.isml/init-stream1.m4s' -> '/test/test.isml/Streams(stream1)'
  # rewrite DASH Chunk '/test/test.isml/chunk-stream1-00001.m4s' -> '/test.isml/Streams(stream1)'
  # rewrite DASH single_file '/test/test.isml/Streams(test-stream1.mp4' -> '/test/test.isml/Streams(stream1)'
  # rewrite HLS Init '/test/test.isml/init-stream1.m4s' -> '/test/test.isml/Streams(stream1)'
  # rewrite HLS Chunk '/test/test.isml/test-stream1.000.m4s' -> '/test/test.isml/Streams(stream1)'
  # rewrite HLS single_file '/test/test.isml/Streams(test-stream1.m4s' -> '/test/test.isml/Streams(stream1)'
  RewriteCond %{REQUEST_METHOD} ^(PUT|POST)
  RewriteRule "^(/test/.*\.isml)/(test-|init-|chunk-|Streams\(test-)(stream\d+).*\.(mp4|m4s)$" "$1/Streams($3)" [PT,L]
  # Redirect posing of Manifests and DELETE requests
  RewriteRule "^(/test/.*\.isml)/(Streams\(.*\.mpd\)|.*\.m3u8\))$" "/nothing" [R=204,L]
  RewriteCond %{REQUEST_METHOD} DELETE
  RewriteRule "^(/test/.*\.isml)/.*$" "/nothing" [R=204,L]
```
