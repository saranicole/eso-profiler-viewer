FROM node:20-bookworm AS builder

ENV PERFETTO_VERSION=v38.0

RUN apt-get update && apt-get install -y \
    git \
    python3 \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# copy project FIRST (important)
COPY . /files

WORKDIR /tmp

RUN git clone --depth 1 https://android.googlesource.com/platform/external/perfetto -b $PERFETTO_VERSION

WORKDIR /tmp/perfetto

RUN tools/install-build-deps --ui

# copy plugin INTO cloned repo
RUN mkdir -p ui/src/tracks/eso_profiler
RUN cp -R /files/src-perfetto/plugin/* ui/src/tracks/eso_profiler/

RUN ui/build

FROM nginx:alpine

COPY --from=builder /tmp/perfetto/ui/out/dist/ /usr/share/nginx/html/

EXPOSE 80
