FROM node:20-bookworm AS builder

ENV PERFETTO_VERSION=v38.0

RUN apt-get update && apt-get install -y \
    git python3 curl build-essential \
    && rm -rf /var/lib/apt/lists/*

# clone Perfetto (external dependency)
RUN git clone --depth 1 \
    https://android.googlesource.com/platform/external/perfetto \
    -b $PERFETTO_VERSION /tmp/perfetto

WORKDIR /tmp/perfetto

RUN tools/install-build-deps --ui

# ONLY your plugin
COPY src-perfetto/plugin /tmp/perfetto/ui/src/tracks/eso_profiler

RUN ui/build

FROM nginx:alpine

COPY --from=builder \
    /tmp/perfetto/ui/out/dist/ \
    /usr/share/nginx/html/

EXPOSE 80
