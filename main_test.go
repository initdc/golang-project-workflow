package main

import (
	"regexp"
	"testing"
)

func TestHello(t *testing.T) {
	got := hello()
	str := `(OS: \w+\nArchitecture: \w+\nVersion: go\d+\.\d+\.\d\n)`
	re := regexp.MustCompile(str)
	if !re.MatchString(got) {
		t.Errorf("got '%s' want '%s'", got, re)
	}
}
