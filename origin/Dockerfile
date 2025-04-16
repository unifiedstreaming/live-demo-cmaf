ARG ALPINEVERSION=3.21

FROM alpine:$ALPINEVERSION

# ARGs declared before FROM are in a different scope, so need to be stated again
# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG ALPINEVERSION
ARG REPO=https://stable.apk.unified-streaming.com/alpine
ARG VERSION=1.15.5

# Get USP public key
RUN wget -q -O /etc/apk/keys/alpine@unified-streaming.com.rsa.pub \
    https://stable.apk.unified-streaming.com/alpine@unified-streaming.com.rsa.pub

# Install Origin
RUN apk \
    --update \
    --repository $REPO/v$ALPINEVERSION \
    add \
        mp4split~$VERSION \
        mp4split-ffmpeg-plugins~$VERSION \
        mod_smooth_streaming~$VERSION \
        mod_unified_s3_auth~$VERSION \
        manifest-edit~$VERSION \
&&  rm -f /var/cache/apk/*

# Set up directories and log file redirection
RUN mkdir -p /run/apache2 \
    && ln -s /dev/stderr /var/log/apache2/error.log \
    && ln -s /dev/stdout /var/log/apache2/access.log \
    && mkdir -p /var/www/unified-origin \
    && rm -f /etc/apache2/conf.d/default.conf \
        /etc/apache2/conf.d/info.conf \
        /etc/apache2/conf.d/languages.conf \
        /etc/apache2/conf.d/mpm.conf \
        /etc/apache2/conf.d/proxy.conf \
        /etc/apache2/conf.d/ssl.conf \
        /etc/apache2/conf.d/userdir.conf

# Enable default Manifest Edit pipelines
RUN mkdir -p /etc/manifest-edit \
    && cp -R /usr/share/manifest-edit/* /etc/manifest-edit/

# Copy apache config and entrypoint script
COPY conf.d /etc/apache2/conf.d
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

# Copy webpage
COPY html /var/www/unified-origin/

# Copy Transcoder Config for ffmpeg-usp
COPY ffmpeg-transcoders.usp /etc/ffmpeg-transcoders.usp

# set Apache as owner of /var/www/unified-origin so it can write from API
RUN chown apache:apache /var/www/unified-origin

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["-D", "FOREGROUND"]
