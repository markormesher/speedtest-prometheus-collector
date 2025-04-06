package main

import (
	"encoding/json"
	"fmt"
	"os/exec"
)

type SpeedtestResult struct {
	DownloadBps   float64
	UploadBps     float64
	PingLatencyMs float64
	PingJitterMs  float64
}

type SpeedtestRawResult struct {
	// note: only the fields we care about

	Download struct {
		Bandwidth float64 `json:"bandwidth"`
	} `json:"download"`

	Upload struct {
		Bandwidth float64 `json:"bandwidth"`
	} `json:"upload"`

	Ping struct {
		Latency float64 `json:"latency"`
		Jitter  float64 `json:"jitter"`
	} `json:"ping"`
}

func runSpeedtest() (SpeedtestResult, error) {
	cmd := exec.Command("/usr/local/bin/speedtest", "--accept-license", "--accept-gdpr", "--format", "json")
	output, err := cmd.Output()
	if err != nil {
		return SpeedtestResult{}, fmt.Errorf("error running speedtest: %w", err)
	}

	var raw SpeedtestRawResult
	err = json.Unmarshal(output, &raw)
	if err != nil {
		return SpeedtestResult{}, fmt.Errorf("error parsing speedtest result: %w", err)
	}

	return SpeedtestResult{
		DownloadBps:   raw.Download.Bandwidth,
		UploadBps:     raw.Upload.Bandwidth,
		PingLatencyMs: raw.Ping.Latency,
		PingJitterMs:  raw.Ping.Jitter,
	}, nil
}
