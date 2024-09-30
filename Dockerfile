# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine:3.20

# set version label
ARG BUILD_DATE
ARG VERSION
ARG WHISPARR_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="Roxedus,thespad"

# environment settings
ARG WHISPARR_BRANCH="nightly"
ENV XDG_CONFIG_HOME="/config/xdg" \
  COMPlus_EnableDiagnostics=0 \
  TMPDIR=/run/whisparr-temp

RUN \
  echo "**** install packages ****" && \
  apk add -U --upgrade --no-cache \
    icu-libs \
    sqlite-libs \
    xmlstarlet && \
  echo "**** install whisparr ****" && \
  mkdir -p /app/whisparr/bin && \
  if [ -z ${WHISPARR_RELEASE+x} ]; then \
    WHISPARR_RELEASE=$(curl -sL "https://whisparr.servarr.com/v1/update/${WHISPARR_BRANCH}/changes?runtime=netcore&os=linuxmusl" \
    | jq -r '.[0].version'); \
  fi && \
  curl -o \
    /tmp/whisparr.tar.gz -L \
    "https://whisparr.servarr.com/v1/update/${WHISPARR_BRANCH}/updatefile?version=${WHISPARR_RELEASE}&os=linuxmusl&runtime=netcore&arch=x64" && \
  tar xzf \
    /tmp/whisparr.tar.gz -C \
    /app/whisparr/bin --strip-components=1 && \
  echo -e "UpdateMethod=docker\nBranch=${WHISPARR_BRANCH}\nPackageVersion=${VERSION}\nPackageAuthor=[linuxserver.io](https://linuxserver.io)" > /app/whisparr/package_info && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  rm -rf \
    /app/whisparr/bin/Whisparr.Update \
    /tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 6969

VOLUME /config
