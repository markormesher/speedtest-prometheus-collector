FROM docker.io/golang:1.25.4@sha256:e68f6a00e88586577fafa4d9cefad1349c2be70d21244321321c407474ff9bf2 as builder
WORKDIR /app

COPY go.mod ./
RUN go mod download

COPY ./cmd ./cmd

RUN go build -o ./build/main ./cmd/...

# ---

FROM debian:13.2-slim@sha256:9812458f2932ede726468ba07bcb9e51bceb1f0c7f16ee30baa789ccee7cc202 as speedtest-dl
WORKDIR /

RUN apt update \
  && apt install -y --no-install-recommends ca-certificates wget

RUN wget https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-x86_64.tgz
RUN tar xf ookla-speedtest-1.2.0-linux-x86_64.tgz speedtest

# ---

FROM debian:13.2-slim@sha256:9812458f2932ede726468ba07bcb9e51bceb1f0c7f16ee30baa789ccee7cc202
WORKDIR /app

LABEL image.registry=ghcr.io
LABEL image.name=markormesher/speedtest-prometheus-collector

RUN apt update \
  && apt install -y --no-install-recommends ca-certificates \
  && apt clean

COPY --from=builder /app/build/main /usr/local/bin/speedtest-prometheus-collector
COPY --from=speedtest-dl /speedtest /usr/local/bin/speedtest

CMD ["/usr/local/bin/speedtest-prometheus-collector"]
