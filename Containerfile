FROM docker.io/golang:1.27.1@sha256:1cfcdb11f37fce9429f617100f39e0251748bbaba454bd431275155701765058 as builder
WORKDIR /app

COPY go.mod ./
RUN go mod download

COPY ./cmd ./cmd

RUN go build -o ./build/main ./cmd/...

# ---

FROM docker.io/debian:13.7-slim@sha256:a99cfc517144bc59b1978475ec53b46ecabec7e43635402ee5b77cc54cd1b20a as speedtest-dl
WORKDIR /

RUN apt update \
  && apt install -y --no-install-recommends ca-certificates wget

RUN wget https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-x86_64.tgz
RUN tar xf ookla-speedtest-1.2.0-linux-x86_64.tgz speedtest

# ---

FROM docker.io/debian:13.7-slim@sha256:a99cfc517144bc59b1978475ec53b46ecabec7e43635402ee5b77cc54cd1b20a
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
LABEL org.opencontainers.image.url=""
LABEL org.opencontainers.image.vendor=""
LABEL org.opencontainers.image.version=""
