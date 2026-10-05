# Gonic

Gonic is a FLOSS alternative to subsonic music streaming server / subsonic API written in Go.

Features:

*  browsing by folder (keeping your full tree intact)
*  browsing by tags (using taglib - supports mp3, opus, flac, ape, m4a, wav,
   etc.)
*  on-the-fly audio transcoding and caching (requires ffmpeg) (thank you spijet)
*  pretty fast scanning (with my library of ~27k tracks, initial scan takes
   about 10m, and about 5s after incrementally)
*  multiple users, each with their own transcoding preferences, playlists, top
   tracks, top artists, etc.
*  last.fm scrobbling
*  artist similarities and biographies from the last.fm api
*  a web interface for configuration (set up last.fm, manage users, start scans,
   etc.)
*  support for the album-artist tag, to not clutter your artist list with
   compilation album appearances
*  written in go, so lightweight and suitable for a raspberry pi, etc.
*  newer salt and token auth
*  tested on dsub, jamstash, sublime music, and soundwaves

github.com/sentriz/gonic

<img src="https://github.com/sentriz/gonic/blob/master/.github/logo.png?raw=true" width="30%" height="auto" alt="Gonic logo">

## How to use this Makejail

### Standalone

```console
$ mkdir -p /var/appjail-volumes/gonic/data
$ appjail oci run -Pd \
    -o overwrite=force \
    -o virtualnet=":<random> default" \
    -o nat \
    -o fstab="/var/appjail-volumes/gonic/data /data" \
    -o fstab="/path/to/music /music nullfs ro" \
    -o fstab="/path/to/podcasts /podcasts" \
    -o fstab="/path/to/playlists /playlists" \
    -o fstab="/path/to/cache /cache" \
    ghcr.io/appjail-makejails/gonic gonic
```

### Deploy using `appjail-director`

```yaml
options:
  - virtualnet: ':<random> default'
  - nat:

services:
  gonic:
    name: gonic
    makejail: gh+AppJail-makejails/gonic
    options:
      - expose: '4747:8080' # for external hosts
      - container: 'args:--pull'
      # set the following if you've enabled jukebox
      - mount_devfs:
      - device: 'include $devfsrules_hide_all'
      - device: 'include $devfsrules_unhide_basic'
      - device: 'include $devfsrules_unhide_login'
      - device: "path 'dsp*' unhide"
    volumes:
      - data: /data # gonic db etc
      - music: /music # your music
      - podcasts: /podcasts # your podcasts
      - playlists: /playlists # your playlists
      - cache: /cache # transcode / covers / etc cache dir
    oci:
      environment:
        - TZ: !ENV '${TZ}'
        # optionally, see more available env vars in the readme: https://github.com/sentriz/gonic/wiki/installation#with-docker

volumes:
  data:
    device: /var/appjail-volumes/gonic/data
  music:
    device: /path/to/music
    options: ro
  podcasts:
    device: /path/to/podcasts
  playlists:
    device: /path/to/playlists
  cache:
    device: /path/to/cache
```

### Arguments (stage: build)

* `gonic_from` (default: `ghcr.io/appjail-makejails/gonic`): Location of OCI image. See also [OCI Configuration](#oci-configuration).
* `gonic_tag` (default: `latest`): OCI image tag. See also [OCI Configuration](#oci-configuration).

### Environment (OCI image)

* `PGID` (default: `1000`): Equivalent to `PUID` but for the Process Group ID.
* `PUID` (default: `1000`): Process User ID for the container's main process, allowing you to match the owner of files written to mounted host volumes to your host system's user. Writable volumes are changed based on this environment variable.
* `UMASK` (default: `0022`): Override default umask setting.

### Volumes

| Name | Owner | Group | Perm | Type | Mountpoint |
| --- | --- | --- | --- | --- | --- |
| appjail-263aca83a3-data | `${PUID}` | `${PGID}` | - | - | /data |
| appjail-3e431e873f-music | - | - | - | - | /music |
| appjail-58d2e6e563-podcasts | `${PUID}` | `${PGID}` | - | - | /podcasts |
| appjail-e1002a08c2-playlists | `${PUID}` | `${PGID}` | - | - | /playlists |
| appjail-fbfced411c-cache | `${PUID}` | `${PGID}` | - | - | /cache |

## OCI Configuration

```yaml
build:
  variants:
    - tag: 15.1
      containerfile: Containerfile
      aliases: ["latest"]
      default: true
      args:
        FREEBSD_RELEASE: "15.1"
        NO_PKGCLEAN: "1"
      cache_dirs: ["pkgcache0:/var/cache/pkg"]
```
