FROM ubuntu:22.04 AS builder

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

RUN curl -L -o Krastorio2_1.3.6.zip "https://factorio-launcher-mods.storage.googleapis.com/Krastorio2/1.3.6.zip"
RUN curl -L -o flib_0.11.2.zip "https://factorio-launcher-mods.storage.googleapis.com/flib/0.11.2.zip"
RUN curl -L -o Krastorio2Assets_1.2.0.zip "https://factorio-launcher-mods.storage.googleapis.com/Krastorio2Assets/1.2.0.zip"

FROM ubuntu:22.04 AS runtime

WORKDIR /app

COPY --from=builder /build/factorio/ /app/
COPY --from=builder /build/Krastorio2_1.3.6.zip /app/mods/
COPY --from=builder /build/flib_0.11.2.zip /app/mods/
COPY --from=builder /build/Krastorio2Assets_1.2.0.zip /app/mods/

ENV PATH $PATH:/app/bin/x64

RUN factorio --create my-server

FROM runtime

EXPOSE 34197/udp

ENTRYPOINT ["factorio", "--start-server", "my-server"]