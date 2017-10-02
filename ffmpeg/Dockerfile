# ffmpeg - http://ffmpeg.org/download.html
# based on image from 
# https://hub.docker.com/r/jrottenberg/ffmpeg/
#
#
FROM        alpine:3.4


ENV         X264_VERSION=20160826-2245-stable \
            PKG_CONFIG_PATH=/usr/local/lib/pkgconfig \
            SRC=/usr/local

COPY ism_movenc.patch /root/ism_movenc.patch

RUN     buildDeps="autoconf \
                   automake \
                   bash \
                   binutils \
                   bzip2 \
                   cmake \
                   curl \
                   coreutils \
                   g++ \
                   gcc \
                   git \
                   libtool \
                   make \
                   openssl-dev \
                   tar \
                   yasm \
                   zlib-dev" && \
        export MAKEFLAGS="-j$(($(grep -c ^processor /proc/cpuinfo) + 1))" && \
        apk  add --update ${buildDeps} freetype-dev fontconfig-dev ttf-droid libgcc libstdc++ ca-certificates && \

        DIR=$(mktemp -d) && cd ${DIR} && \
## x264 http://www.videolan.org/developers/x264.html
        curl -sL https://ftp.videolan.org/pub/videolan/x264/snapshots/x264-snapshot-${X264_VERSION}.tar.bz2 | \
        tar -jx --strip-components=1 && \
        ./configure --prefix="${SRC}" --bindir="${SRC}/bin" --enable-pic --enable-shared --disable-cli && \
        make && \
        make install && \
        rm -rf ${DIR}


## ffmpeg source from github
RUN     DIR=$(mktemp -d) && cd ${DIR} && \
        git clone https://github.com/FFmpeg/FFmpeg.git . && \
        git checkout -b ism_build cf3d2d52b59ddfc2a7c65a8e66f7698c4b837e51 && \
        git apply /root/ism_movenc.patch && \
        ./configure --prefix="${SRC}" \
        --extra-cflags="-I${SRC}/include" \
        --extra-ldflags="-L${SRC}/lib" \
        --bindir="${SRC}/bin" \
        --disable-doc \
        --disable-static \
        --enable-shared \
        --disable-ffplay \
        --extra-libs=-ldl \
        --enable-version3 \
        --enable-libx264 \
        --enable-libfontconfig \
        --enable-libfreetype \
        --enable-gpl \
        --enable-avresample \
        --enable-postproc \
        --enable-nonfree \
        --disable-debug \
        --enable-openssl && \
        make && \
        make install && \
        make distclean && \
        hash -r && \
        rm -rf ${DIR} && \
# cleanup
        cd && \
        apk del ${buildDeps} && \
        rm -rf /var/cache/apk/* /usr/local/include && \
        ffmpeg -buildconf

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD  ffmpeg -re -f lavfi -i smptehdbars=size=1280x720 \
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