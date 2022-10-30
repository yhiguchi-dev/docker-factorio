FROM ubuntu:22.04 AS builder

WORKDIR /build

RUN \
  apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    xz-utils \
  && rm -rf /var/lib/apt/lists/*
RUN curl -L -o factorio-headless.tar.xz "https://factorio.com/get-download/stable/headless/linux64"
RUN tar Jxvf ./factorio-headless.tar.xz
RUN chmod +x /build/factorio/bin/x64/factorio

FROM ubuntu:22.04 AS runtime

COPY --from=builder /build/factorio/ /app/

ENV PATH $PATH:/app/bin/x64

RUN factorio --create my-server

FROM runtime

EXPOSE 34197

ENTRYPOINT ["factorio", "--start-server", "my-server"]