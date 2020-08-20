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

CMD fmp4-ingest/ingest-tools/fmp4ingest -u $PUB_POINT_URI $AVAIL