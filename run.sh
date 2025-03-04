#!/bin/sh

lighttpd -f /etc/lighttpd/lighttpd.conf 3>&1

while true; do

    /usr/bin/exporter.sh >/tmp/metrics
    mv /tmp/metrics /var/www/metrics

    sleep $INTERVAL

done
