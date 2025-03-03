#!/bin/sh

lighttpd -f /etc/lighttpd/lighttpd.conf 3>&1

trap exit SIGTERM SIGINT

while true; do

    /usr/bin/exporter.sh >/var/www/metrics
    sleep 10 &
    wait

done
