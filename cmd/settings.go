package main

import (
	"fmt"
	"os"
	"strconv"
)

type Settings struct {
	TestIntervalMs int
	ListenPort     int
}

func loadSettings() (Settings, error) {
	testIntervalMsStr := os.Getenv("TEST_INTERVAL_MS")
	if testIntervalMsStr == "" {
		testIntervalMsStr = "900000"
	}
	testIntervalMs, err := strconv.Atoi(testIntervalMsStr)
	if err != nil {
		return Settings{}, fmt.Errorf("Could not parse test interval as an integer: %w", err)
	}

	listenPortStr := os.Getenv("LISTEN_PORT")
	if listenPortStr == "" {
		listenPortStr = "9030"
	}
	listenPort, err := strconv.Atoi(listenPortStr)
	if err != nil {
		return Settings{}, fmt.Errorf("Could not parse listen port as an integer: %w", err)
	}

	return Settings{
		TestIntervalMs: testIntervalMs,
		ListenPort:     listenPort,
	}, nil
}
