![CircleCI](https://img.shields.io/circleci/build/github/markormesher/speedtest-prometheus-collector)

# Speedtest.net Prometheus Collector

Bare-bones Prometheus collector to provide metrics on your Internet speed via [Speedtest.net](https://speedtest.net).

:rocket: Jump to [quick-start example](#quick-start-docker-compose-example).

:whale: See releases on [ghcr.io](https://ghcr.io/markormesher/speedtest-prometheus-collector).

Note that speed tests take some time to execute; no metrics will be emitted until one test has completed, to avoid emitting misleading zero values.

> [!IMPORTANT]
> By using this collector, you will be accepting the [Terms of Use](https://www.speedtest.net/about/terms) and [Privacy Policy](https://www.speedtest.net/about/privacy) of Speedtest.net.

## Measurements

| Measurement                 | Description                                  | Labels |
| --------------------------- | -------------------------------------------- | ------ |
| `speedtest_tests_started`   | Number of tests started.                     | none   |
| `speedtest_tests_finished`  | Number of tests finished successfully.       | none   |
| `speedtest_tests_failed`    | Number of tests failed.                      | none   |
| `speedtest_download_bps`    | Download bandwidth in Bps (bits per second). | none   |
| `speedtest_upload_bps`      | Upload bandwidth in Bps (bits per second).   | none   |
| `speedtest_ping_latency_ms` | Ping latency in ms (milliseconds).           | none   |
| `speedtest_ping_jitter_ms`  | Ping jitter in ms (milliseconds).            | none   |

## Configuration

Configuration is via the following environment variables:

| Variable           | Required? | Description               | Default                 |
| ------------------ | --------- | ------------------------- | ----------------------- |
| `TEST_INTERVAL_MS` | no        | How often to run tests.   | 900000ms (= 15 minutes) |
| `LISTEN_PORT`      | no        | Server port to listen on. | 9030                    |

## Quick-Start Docker-Compose Example

```yaml
services:
  speedtest-prometheus-collector:
    image: ghcr.io/markormesher/speedtest-prometheus-collector:VERSION
    restart: unless-stopped
    ports:
      - 9030:9030
```
