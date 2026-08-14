ARG FREEBSD_RELEASE

FROM ghcr.io/appjail-makejails/core:${FREEBSD_RELEASE}

ARG NO_PKGCLEAN

LABEL org.opencontainers.image.title="Gonic" \
    org.opencontainers.image.description="Music streaming server / subsonic server API implementation" \
    org.opencontainers.image.source="https://github.com/AppJail-makejails/gonic" \
    org.opencontainers.image.url="https://github.com/AppJail-makejails/gonic" \
    org.opencontainers.image.vendor="DtxdF" \
    org.opencontainers.image.authors="Jesús Daniel Colmenares Oviedo <dtxdf@disroot.org>"

RUN set -xe; \
    \
    pkg update; \
    pkg install gonic; \
    \
    if [ -z "${NO_PKGCLEAN}" ]; then \
        pkg clean -a; \
        rm -rf /var/cache/pkg/*; \
    fi; \
    rm -rf /var/db/pkg/repos/*

COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh

VOLUME ["/cache", "/data", "/music", "/podcasts", "/playlists"]

RUN mkdir -p /cache /data /music /podcasts /playlists

EXPOSE 8080

ENV TZ=
ENV GONIC_DB_PATH=/data/gonic.db
ENV GONIC_LISTEN_ADDR=:8080
ENV GONIC_MUSIC_PATH=/music
ENV GONIC_PODCAST_PATH=/podcasts
ENV GONIC_CACHE_PATH=/cache
ENV GONIC_PLAYLISTS_PATH=/playlists

ENTRYPOINT ["/entrypoint.sh"]
CMD ["gonic"]
