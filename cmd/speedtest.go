package main

import (
	"encoding/json"
	"fmt"
	"os/exec"
)

type SpeedtestResult struct {
	DownloadBits  float64
	UploadBits    float64
	PingLatencyMs float64
	PingJitterMs  float64
}

type SpeedtestRawResult struct {
	// note: only the fields we care about

	Download struct {
		BandwidthBytes float64 `json:"bandwidth"`
	} `json:"download"`

	Upload struct {
		BandwidthBytes float64 `json:"bandwidth"`
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
		DownloadBits:  raw.Download.BandwidthBytes * 8,
		UploadBits:    raw.Upload.BandwidthBytes * 8,
		PingLatencyMs: raw.Ping.Latency,
		PingJitterMs:  raw.Ping.Jitter,
	}, nil
}
