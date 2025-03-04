#!/bin/sh

lighttpd -f /etc/lighttpd/lighttpd.conf 3>&1

while true; do

    /usr/bin/exporter.sh >/var/www/metrics
    sleep $INTERVAL

done
