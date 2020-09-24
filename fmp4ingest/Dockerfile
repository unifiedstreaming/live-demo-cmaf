FROM ubuntu:18.04

WORKDIR /home

RUN apt-get update && apt-get -y upgrade && apt-get -y install wget

RUN apt-get -y --no-install-recommends install \
  aptitude \
  bash-completion \
  build-essential \
  cmake \
  coreutils \
  gcc \
  g++ \
  gdb \
  git-core \
  ncdu \
  unzip \
  vim \
  libcurl4-openssl-dev

RUN git clone https://github.com/unifiedstreaming/fmp4-ingest.git && cd fmp4-ingest/ingest-tools && cmake CMakeLists.txt && make

CMD seconds_since_epoch=$(date +%s) && \
  integer_multiple_gops_since_epoch=$(expr $seconds_since_epoch / $INTEGER_MULTIPLE_GOP) && \
  ism_offset=$(expr $(expr $integer_multiple_gops_since_epoch + 1) \* $INTEGER_MULTIPLE_GOP) && \
  sleep $(expr $INTEGER_MULTIPLE_GOP - 1) && \
  fmp4-ingest/ingest-tools/fmp4ingest $CMD_ARGS -u $PUB_POINT_URI --avail $AVAIL_INTERVAL $AVAIL_LENGTH