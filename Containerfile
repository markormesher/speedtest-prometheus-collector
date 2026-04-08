FROM docker.io/golang:1.26.2@sha256:2a2b4b5791cea8ae09caecba7bad0bd9631def96e5fe362e4a5e67009fe4ae61 as builder
WORKDIR /app

COPY go.mod ./
RUN go mod download

COPY ./cmd ./cmd

RUN go build -o ./build/main ./cmd/...

# ---

FROM docker.io/debian:13.4-slim@sha256:26f98ccd92fd0a44d6928ce8ff8f4921b4d2f535bfa07555ee5d18f61429cf0c as speedtest-dl
WORKDIR /

RUN apt update \
  && apt install -y --no-install-recommends ca-certificates wget

RUN wget https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-x86_64.tgz
RUN tar xf ookla-speedtest-1.2.0-linux-x86_64.tgz speedtest

# ---

FROM docker.io/debian:13.4-slim@sha256:26f98ccd92fd0a44d6928ce8ff8f4921b4d2f535bfa07555ee5d18f61429cf0c
WORKDIR /app

RUN apt update \
  && apt install -y --no-install-recommends ca-certificates \
  && apt clean

COPY --from=builder /app/build/main /usr/local/bin/speedtest-prometheus-collector
COPY --from=speedtest-dl /speedtest /usr/local/bin/speedtest

CMD ["/usr/local/bin/speedtest-prometheus-collector"]

LABEL image.name=markormesher/speedtest-prometheus-collector
LABEL image.registry=ghcr.io
LABEL org.opencontainers.image.description=""
LABEL org.opencontainers.image.documentation=""
LABEL org.opencontainers.image.title="speedtest-prometheus-collector"
LABEL org.opencontainers.image.url="https://github.com/markormesher/speedtest-prometheus-collector"
LABEL org.opencontainers.image.vendor=""
LABEL org.opencontainers.image.version=""
