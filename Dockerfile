# syntax=docker/dockerfile:1

FROM alpine:3

RUN apk update \
    && apk add --no-cache lighttpd curl tini jq

COPY lighttpd.conf /etc/lighttpd/lighttpd.conf
COPY --chmod=755 run.sh /usr/bin/run.sh
COPY --chmod=755 exporter.sh /usr/bin/exporter.sh

EXPOSE 8080

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/bin/run.sh"]

HEALTHCHECK --interval=30s \
    --start-interval=10s \
    --start-period=30s \
    CMD pgrep run.sh && curl -f http://127.0.0.1:8080/metrics
