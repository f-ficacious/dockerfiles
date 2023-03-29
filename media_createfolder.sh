#!/bin/bash

source "./.env"

folders=( "${CONF_PATH:-/opt/appdata}/beets" \
"${CONF_PATH:-/opt/appdata}/deemix" \
"${CONF_PATH:-/opt/appdata}/gluetun" \
"${CONF_PATH:-/opt/appdata}/jackett" \
"${CONF_PATH:-/opt/appdata}/lidarr" \
"${CONF_PATH:-/opt/appdata}/nzbhydra" \
"${CONF_PATH:-/opt/appdata}/pyload-ng" \
"${CONF_PATH:-/opt/appdata}/radarr" \
"${CONF_PATH:-/opt/appdata}/sabnzbd" \
"${CONF_PATH:-/opt/appdata}/sonarr" \
"${CONF_PATH:-/opt/appdata}/swag" \
"${CONF_PATH:-/opt/appdata}/ytdl-material" \
"${CONF_PATH:-/opt/appdata}/ytdl-mong-db" \
"${CONF_PATH:-/opt/appdata}/ytdl-subscriptions" \
"${CONF_PATH:-/opt/appdata}/ytdl-users" \
"${DATA_PATH:-/opt/data}/downloads" \
"${DATA_PATH:-/opt/data}/downloads/apps" \
"${DATA_PATH:-/opt/data}/downloads/audiobooks" \
"${DATA_PATH:-/opt/data}/downloads/deemix" \
"${DATA_PATH:-/opt/data}/downloads/misc" \
"${DATA_PATH:-/opt/data}/downloads/movies" \
"${DATA_PATH:-/opt/data}/downloads/music" \
"${DATA_PATH:-/opt/data}/downloads/stash" \
"${DATA_PATH:-/opt/data}/downloads/tv" \
"${DATA_PATH:-/opt/data}/downloads/ytdl-audio" \
"${DATA_PATH:-/opt/data}/downloads/ytdl-video" \
"${DATA_PATH:-/opt/data}/media" \
"${DATA_PATH:-/opt/data}/media/audiobooks" \
"${DATA_PATH:-/opt/data}/media/movies" \
"${DATA_PATH:-/opt/data}/media/music" \
"${DATA_PATH:-/opt/data}/media/tv" \
"${TEMPDATA_PATH:-/opt/temp}/blackhole/nzb" \
"${TEMPDATA_PATH:-/opt/temp}/blackhole/torrent" \
"${TEMPDATA_PATH:-/opt/temp}/incomplete" )

for folder in "${folders[@]}"; do
  [[ ! -f "${folder}" ]] && printf "Creating: %s\n" "${folder}" && mkdir -p "${folder}"
done


printf "\nWarning! Deemix, Pyload-NG, Beets are listening on 0.0.0.0 on default NOT localhost. For Example try 0.0.0.0:6595 for Deemix.\n"
