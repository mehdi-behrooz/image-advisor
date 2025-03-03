# Image Advisor

## Introduction

A complementary Prometheus exporter to cAdvisor which exports data related to docker images and volumes and docker container's healthcheck states. 

## How to use

```yaml

  iadvisor:
    image: ghcr.io/mehdi-behrooz/image-advisor:latest
    container_name: iadvisor
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro

```
