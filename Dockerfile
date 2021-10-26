ARG DEBIAN_BASE_IMAGE=buster-slim
FROM debian:${DEBIAN_BASE_IMAGE} AS builder
ARG DEBIAN_RELEASE=buster-backports
ARG PREFIX_DIR=/usr/local/guacamole
ARG BUILD_DIR=/tmp/guacd-docker-BUILD
ARG BUILD_DEPENDENCIES="              \
        autoconf                      \
        automake                      \
        freerdp2-dev                  \
        gcc                           \
        libcairo2-dev                 \
        libgcrypt-dev                 \
        libjpeg62-turbo-dev           \
        libossp-uuid-dev              \
        libpango1.0-dev               \
        libpulse-dev                  \
        libssh2-1-dev                 \
        libssl-dev                    \
        libtelnet-dev                 \
        libtool                       \
        libvncserver-dev              \
        libwebsockets-dev             \
        libwebp-dev                   \
        make"
ARG DEBIAN_FRONTEND=noninteractive

RUN grep " ${DEBIAN_RELEASE} " /etc/apt/sources.list || echo >> /etc/apt/sources.list \
    "deb http://deb.debian.org/debian ${DEBIAN_RELEASE} main contrib non-free"

RUN apt-get update                                              && \
    apt-get install -t ${DEBIAN_RELEASE} git $BUILD_DEPENDENCIES && \
    rm -rf /var/lib/apt/lists/*

ADD https://github.com/apache/guacamole-server/archive/refs/tags/1.3.0.tar.gz /tmp

RUN tar -zxvf /tmp/1.3.0.tar.gz -C /tmp \
    && mv /tmp/guacamole-server-1.3.0 ${BUILD_DIR} \
    && cp -r ${BUILD_DIR}/src/guacd-docker/bin "${PREFIX_DIR}/" \
    && ${PREFIX_DIR}/bin/build-guacd.sh "$BUILD_DIR" "$PREFIX_DIR"

RUN ${PREFIX_DIR}/bin/list-dependencies.sh     \
        ${PREFIX_DIR}/sbin/guacd               \
        ${PREFIX_DIR}/lib/libguac-client-*.so  \
        ${PREFIX_DIR}/lib/freerdp2/*guac*.so   \
        > ${PREFIX_DIR}/DEPENDENCIES

FROM debian:${DEBIAN_BASE_IMAGE}

ARG DEBIAN_RELEASE=buster-backports
ARG PREFIX_DIR=/usr/local/guacamole
ARG DEBIAN_FRONTEND=noninteractive
ARG UID=1000
ARG GID=1000
ENV LC_ALL=C.UTF-8
ENV LD_LIBRARY_PATH=${PREFIX_DIR}/lib
ENV GUACD_LOG_LEVEL=info

ARG RUNTIME_DEPENDENCIES="            \
        netcat-openbsd                \
        ca-certificates               \
        ghostscript                   \
        fonts-liberation              \
        fonts-dejavu                  \
        xfonts-terminus"

RUN grep " ${DEBIAN_RELEASE} " /etc/apt/sources.list || echo >> /etc/apt/sources.list \
    "deb http://deb.debian.org/debian ${DEBIAN_RELEASE} main contrib non-free"

COPY --from=builder ${PREFIX_DIR} ${PREFIX_DIR}

RUN apt-get update                                                                                       && \
    apt-get install -t ${DEBIAN_RELEASE} -y --no-install-recommends $RUNTIME_DEPENDENCIES                && \
    apt-get install -t ${DEBIAN_RELEASE} -y --no-install-recommends $(cat "${PREFIX_DIR}"/DEPENDENCIES)  && \
    rm -rf /var/lib/apt/lists/*

RUN ${PREFIX_DIR}/bin/link-freerdp-plugins.sh \
        ${PREFIX_DIR}/lib/freerdp2/libguac*.so

HEALTHCHECK --interval=5m --timeout=5s CMD nc -z 127.0.0.1 4822 || exit 1

RUN groupadd --gid $GID guacd
RUN useradd --system --create-home --shell /usr/sbin/nologin --uid $UID --gid $GID guacd

USER guacd
EXPOSE 4822

CMD /usr/local/guacamole/sbin/guacd -b 0.0.0.0 -L $GUACD_LOG_LEVEL -f
