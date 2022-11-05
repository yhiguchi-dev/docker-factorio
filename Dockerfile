FROM ubuntu:22.04 AS setup-builder

WORKDIR /build

RUN \
  apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates=20211016 \
    curl=7.81.0-1ubuntu1.6 \
    xz-utils=5.2.5-2ubuntu1 \
  && rm -rf /var/lib/apt/lists/*
RUN curl -L -o factorio-headless.tar.xz "https://factorio.com/get-download/stable/headless/linux64"
RUN tar Jxvf ./factorio-headless.tar.xz
RUN chmod +x /build/factorio/bin/x64/factorio

FROM setup-builder AS builder

WORKDIR /mods

RUN curl -o sonaxaton-infinite-resources_0.4.8.zip "https://factorio-launcher-mods.storage.googleapis.com/sonaxaton-infinite-resources/0.4.8.zip"
RUN curl -o Krastorio2_1.3.6.zip "https://factorio-launcher-mods.storage.googleapis.com/Krastorio2/1.3.6.zip"
RUN curl -o flib_0.11.2.zip "https://factorio-launcher-mods.storage.googleapis.com/flib/0.11.2.zip"
RUN curl -o Krastorio2Assets_1.2.0.zip "https://factorio-launcher-mods.storage.googleapis.com/Krastorio2Assets/1.2.0.zip"

RUN mv /mods /build/factorio/mods

FROM ubuntu:22.04 AS runtime

WORKDIR /app

COPY --from=builder /build/factorio/ /app/

ENV PATH $PATH:/app/bin/x64

RUN factorio --create my-server

FROM runtime

EXPOSE 34197/udp

ENTRYPOINT ["factorio", "--start-server", "my-server"]