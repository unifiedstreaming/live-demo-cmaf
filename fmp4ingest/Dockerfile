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

RUN git clone https://github.com/unifiedstreaming/fmp4-ingest.git && cd fmp4-ingest/ingest-tools && git clone https://github.com/unifiedstreaming/EventMessageTrack.git event && cmake CMakeLists.txt && make

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

WORKDIR /media

ENTRYPOINT [ "/home/entrypoint.sh" ]
