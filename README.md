![CircleCI](https://img.shields.io/circleci/build/github/markormesher/speedtest-prometheus-collector)

# Speedtest.net Prometheus Collector

Bare-bones Prometheus collector to provide metrics on your Internet speed via [Speedtest.net](https://speedtest.net), via the [speedtest-net](https://www.npmjs.com/package/speedtest-net) Node.js library.

:rocket: Jump to [quick-start example](#quick-start-docker-compose-example).

:whale: See releases on [ghcr.io](https://ghcr.io/markormesher/speedtest-prometheus-collector).

Note that speed tests take some time to execute, so this collector runs asynchronously. Tests are run on a configurable interval and every request to the `/metrics` endpoint will return the most recent results. Emitted metrics are timestamped, so this approach does not result in out of date data being logged.

## Measurements

| Measurement                 | Description                                  | Labels |
| --------------------------- | -------------------------------------------- | ------ |
| `speedtest_download_bps`    | Download bandwidth in Bps (bits per second). | none   |
| `speedtest_upload_bps`      | Upload bandwidth in Bps (bits per second).   | none   |
| `speedtest_ping_latency_ms` | Ping latency in ms (milliseconds).           | none   |
| `speedtest_ping_jitter_ms`  | Ping jitter in ms (milliseconds).            | none   |

## Configuration

Configuration is via the following environment variables:

| Variable           | Required? | Description             | Default                 |
| ------------------ | --------- | ----------------------- | ----------------------- |
| `TEST_INTERVAL_MS` | no        | How often to run tests. | 900000ms (= 15 minutes) |

## Quick-Start Docker-Compose Example

```yaml
version: "3.8"

services:
  speedtest-prometheus-collector:
    image: ghcr.io/markormesher/speedtest-prometheus-collector:VERSION
    restart: unless-stopped
    ports:
      - 9030:9030
```
