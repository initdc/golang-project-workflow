package main

import (
	"regexp"
	"strings"
	"testing"
)

func MatchLine(t *testing.T, re, line string) {
	want := regexp.MustCompile(re)
	if !want.MatchString(line) {
		t.Errorf("want match for %s, got %s", want, line)
	}
}
func TestInfo(t *testing.T) {
	got := Info()

	os := "OS: "
	os_re := `[a-z]{2,9}\d?`

	arch := "Architecture: "
	arch_re := `[a-z]{0,5}\d{0,3}[el]?[el]?x?`

	ver := "Version: "
	ver_re := `go\d\.\d{1,2}\.\d{1,2}`

	lines := strings.Split(got, "\n")
	MatchLine(t, os+os_re, lines[0])
	MatchLine(t, arch+arch_re, lines[1])
	MatchLine(t, ver+ver_re, lines[2])
}
