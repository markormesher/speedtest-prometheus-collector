package main

import (
	"fmt"
	"strings"
)

type Metric struct {
	Name  string
	Type  string
	Help  string
	Value float64
}

func (m *Metric) Set(value float64) {
	m.Value = value
}

func (m *Metric) Increment() {
	m.Value += 1
}

func (m *Metric) Write(sb *strings.Builder) {
	if m.Type != "" {
		sb.WriteString(fmt.Sprintf("# TYPE %s %s\n", m.Name, m.Type))
	}

	if m.Help != "" {
		sb.WriteString(fmt.Sprintf("# HELP %s %s\n", m.Name, m.Help))
	}

	sb.WriteString(fmt.Sprintf("%s %f\n", m.Name, m.Value))
}
