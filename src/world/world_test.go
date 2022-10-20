package world

import (
	"testing"
)

func TestWorld(t *testing.T) {
	got := World()
	want := "World!"
	if got != want {
		t.Errorf("got '%s' want '%s'", got, want)
	}
}

func TestHelloWorld(t *testing.T) {
	got := HelloWorld()
	want := "Hello, World!"
	if got != want {
		t.Errorf("got '%s' want '%s'", got, want)
	}
}
