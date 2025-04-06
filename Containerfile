FROM docker.io/golang:1.24.2@sha256:991aa6a6e4431f2f01e869a812934bd60fbc87fb939e4a1ea54b8494ab9d2fc6 as builder
WORKDIR /app

COPY go.mod ./
RUN go mod download

COPY ./cmd ./cmd

RUN go build -o ./build/main ./cmd/...

# ---

FROM debian:bookworm-slim@sha256:1209d8fd77def86ceb6663deef7956481cc6c14a25e1e64daec12c0ceffcc19d as speedtest-dl
WORKDIR /

RUN apt update \
  && apt install -y --no-install-recommends ca-certificates wget

RUN wget https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-x86_64.tgz
RUN tar xf ookla-speedtest-1.2.0-linux-x86_64.tgz speedtest

# ---

FROM debian:bookworm-slim@sha256:1209d8fd77def86ceb6663deef7956481cc6c14a25e1e64daec12c0ceffcc19d
WORKDIR /app

LABEL image.registry=ghcr.io
LABEL image.name=markormesher/speedtest-prometheus-collector

RUN apt update \
  && apt install -y --no-install-recommends ca-certificates \
  && apt clean

COPY --from=builder /app/build/main /usr/local/bin/speedtest-prometheus-collector
COPY --from=speedtest-dl /speedtest /usr/local/bin/speedtest

CMD ["/usr/local/bin/speedtest-prometheus-collector"]
