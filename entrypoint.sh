#!/bin/sh

. /lib.subr

set -e

create_user

chown -R noroot:noroot /cache /data /podcasts /playlists

if [ "${1#-}" != "$1" ]; then
    set -- gonic "$@"
fi

if [ "$1" = "gonic" ]; then
    set -- su-exec noroot "$@"
fi

exec "$@"
