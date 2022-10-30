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

FROM ubuntu:22.04 AS runtime

COPY --from=builder /build/factorio/ /app/

ENV PATH $PATH:/app/bin/x64

RUN factorio --create my-server

FROM runtime

EXPOSE 34197

ENTRYPOINT ["factorio", "--start-server", "my-server"]