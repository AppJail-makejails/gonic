# Gonic

Gonic is a FLOSS alternative to subsonic music streaming server / subsonic API written in Go.

## Features

* Browsing by folder (keeping your full tree intact).
* Browsing by tags (using taglib - supports mp3, opus, flac, ape, m4a, wav, etc.)
* On-the-fly audio transcoding and caching.
* Jukebox mode.
* Support for podcasts.
* Pretty fast scanning.
* Multiple users, each with their own transcoding preferences, playlists, top tracks, top artists, etc.
* last.fm scrobbling.
* listenbrainz scrobbling.
* Artist similarities and biographies from the last.fm api.
* Multiple genre support.
* A web interface for configuration (set up last.fm, manage users, start scans, etc.).
* Support for the album-artist tag, to not clutter your artist list with compilation album appearances.
* Written in go, so lightweight and suitable for a raspberry pi. 
* Newer salt and token auth.
* Tested on airsonic-refix, symfonium, dsub, jamstash, sublime music, soundwaves, stmp, strawberry, and ultrasonic.

github.com/sentriz/gonic

<img src="https://github.com/sentriz/gonic/raw/master/.github/logo.png?raw=true" alt="gonic logo" width="60%" height="auto">

## How to use this Makejail

### Basic usage

```
INCLUDE options/network.makejail
INCLUDE gh+AppJail-makejails/gonic

OPTION expose=4747

ARG datadir=/var/gonic/data
ARG cachedir=/var/gonic/cache
ARG musicdir=/var/gonic/music
ARG podcastsdir=/var/gonic/podcasts
ARG playlistsdir=/var/gonic/playlists

CMD echo "======> Mounting directories... <======"

MOUNT "${datadir}" /var/db/gonic/data
MOUNT "${cachedir}" /var/cache/gonic
MOUNT "${musicdir}" /var/db/gonic/music
MOUNT "${podcastsdir}" /var/db/gonic/podcasts
MOUNT "${playlistsdir}" /var/db/gonic/playlists

CMD chown -R gonic:gonic /var/db/gonic
CMD chown -R gonic:gonic /var/cache/gonic

CMD echo
CMD echo "===> Done <==="
CMD echo

STAGE cmd

USER gonic
ENV GONIC_DB_PATH=/var/db/gonic/data/gonic.db
ENV GONIC_LISTEN_ADDR=:4747
ENV GONIC_MUSIC_PATH=/var/db/gonic/music
ENV GONIC_PODCAST_PATH=/var/db/gonic/podcasts
ENV GONIC_CACHE_PATH=/var/cache/gonic
ENV GONIC_PLAYLISTS_PATH=/var/db/gonic/playlists
ENV GONIC_SCAN_INTERVAL=3
ENV GONIC_SCAN_AT_START_ENABLED=1
ENV GONIC_SCAN_WATCHED_ENABLED=1
ENV GONIC_JUKEBOX_ENABLED=1
RUN gonic
```

Where `options/network.makejail` are the options that suit your environment, for example:

```
ARG network?
ARG interface=gonic

OPTION virtualnet=${network}:${interface} default
OPTION nat
```

Open a shell and run `appjail makejail`:

```sh
appjail makejail -j gonic
# or use a network explicitly
appjail makejail -j gonic -- --network development
```

### Jukebox

If you want to use jukebox mode you need to put in your `devfs.rules(5)` file:

```
[devfsrules_gonic=12]
add include $devfsrules_jail
add path 'dsp*' unhide
```

and:

```sh
service devfs restart
appjail-config set -j gonic devfs_ruleset=12
appjail restart gonic 
```

### Arguments

* `gonic_tag` (default: `13.5-full`): see [#tags](#tags).
* `gonic_ajspec` (default: `gh+AppJail-makejails/gonic`): Entry point where the `appjail-ajspec(5)` file is located.

### Volumes

| Name        | Owner | Group | Perm | Type | Mountpoint          |
| ----------- | ----- | ----- | ---- | ---- | ------------------- |
| gonic-db    | 1001  | 1001  |  -   |  -   | /var/db/gonic       |
| gonic-cache | 1001  | 1001  |  -   |  -   | /var/cache/gonic    |
| gonic-music | 1001  | 1001  |  -   |  -   | /var/db/gonic/music |

## Tags

| Tag            | Arch     | Version        | Type   | `gonic_jukebox` | `gonic_transcode_audio` |
| -------------- | -------- | -------------- | ------ | --------------- | ----------------------- |
| `13.5-full`    | `amd64`  | `13.5-RELEASE` | `thin` |      `1`        |           `1`           |
| `13.5-minimal` | `amd64`  | `13.5-RELEASE` | `thin` |      `0`        |           `0`           |
| `14.3-full`    | `amd64`  | `14.3-RELEASE` | `thin` |      `1`        |           `1`           |
| `14.3-minimal` | `amd64`  | `14.3-RELEASE` | `thin` |      `0`        |           `0`           |
