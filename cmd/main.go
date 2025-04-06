package main

import (
	"fmt"
	"net/http"
	"strings"
	"time"
)

var (
	testStarted  = &Metric{Name: "speedtest_tests_started", Type: "counter", Help: "Number of tests started."}
	testFinished = &Metric{Name: "speedtest_tests_finished", Type: "counter", Help: "Number of tests started."}
	testFailed   = &Metric{Name: "speedtest_tests_failed", Type: "counter", Help: "Number of tests started."}

	downloadBps   = &Metric{Name: "speedtest_download_bps", Type: "gauge", Help: "Download bandwidth in bps."}
	uploadBps     = &Metric{Name: "speedtest_upload_bps", Type: "gauge", Help: "Upload bandwidth in bps."}
	pingLatencyMs = &Metric{Name: "speedtest_ping_latency_ms", Type: "gauge", Help: "Ping latency in ms."}
	pingJitterMs  = &Metric{Name: "speedtest_ping_jitter_ms", Type: "gauge", Help: "Ping jitter in ms."}
)

var allMetrics = []*Metric{
	testStarted, testFinished, testFailed, downloadBps, uploadBps, pingLatencyMs, pingJitterMs,
}

func main() {
	settings, err := loadSettings()
	if err != nil {
		l.Error("failed to load settings")
		panic(err)
	}

	go func() {
		for ; true; <-time.Tick(time.Duration(settings.TestIntervalMs) * time.Millisecond) {
			l.Info("test started")
			testStarted.Increment()

			result, err := runSpeedtest()
			if err != nil {
				l.Error("test failed", "error", err)
				testFailed.Increment()
				continue
			}

			l.Info("test finished")
			testFinished.Increment()
			downloadBps.Set(result.DownloadBits)
			uploadBps.Set(result.UploadBits)
			pingLatencyMs.Set(result.PingLatencyMs)
			pingJitterMs.Set(result.PingJitterMs)
		}
	}()

	http.HandleFunc("/", httpHandler)
	err = http.ListenAndServe(fmt.Sprintf("0.0.0.0:%d", settings.ListenPort), nil)
	if err != nil {
		l.Error("failed to start server")
		panic(err)
	}
}

func httpHandler(res http.ResponseWriter, req *http.Request) {
	res.Header().Set("content-type", "text/plain")

	sb := strings.Builder{}
	for _, m := range allMetrics {
		if m.Value == 0 && !strings.HasPrefix(m.Name, "speedtest_tests_") {
			// skip zero values for actual test results
			continue
		}

		m.Write(&sb)
	}
	res.Write([]byte(sb.String()))
}
