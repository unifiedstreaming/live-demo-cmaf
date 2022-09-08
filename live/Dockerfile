FROM unifiedstreaming/origin:1.11.17
LABEL maintainer "Unified Streaming <support@unified-streaming.com>"

# overwrite config and entrypoint
COPY unified-origin.conf.in /etc/apache2/conf.d/unified-origin.conf.in
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

RUN mv /var/www/unified-origin /var/www/live
