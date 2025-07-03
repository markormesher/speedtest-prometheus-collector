FROM docker.io/golang:1.24.4@sha256:20a022e5112a144aa7b7aeb3f22ebf2cdaefcc4aac0d64e8deeee8cdc18b9c0f as builder
WORKDIR /app

COPY go.mod ./
RUN go mod download

COPY ./cmd ./cmd

RUN go build -o ./build/main ./cmd/...

# ---

FROM debian:bookworm-slim@sha256:6ac2c08566499cc2415926653cf2ed7c3aedac445675a013cc09469c9e118fdd as speedtest-dl
WORKDIR /

RUN apt update \
  && apt install -y --no-install-recommends ca-certificates wget

RUN wget https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-x86_64.tgz
RUN tar xf ookla-speedtest-1.2.0-linux-x86_64.tgz speedtest

# ---

FROM debian:bookworm-slim@sha256:6ac2c08566499cc2415926653cf2ed7c3aedac445675a013cc09469c9e118fdd
WORKDIR /app

LABEL image.registry=ghcr.io
LABEL image.name=markormesher/speedtest-prometheus-collector

RUN apt update \
  && apt install -y --no-install-recommends ca-certificates \
  && apt clean

COPY --from=builder /app/build/main /usr/local/bin/speedtest-prometheus-collector
COPY --from=speedtest-dl /speedtest /usr/local/bin/speedtest

CMD ["/usr/local/bin/speedtest-prometheus-collector"]
