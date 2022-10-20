package hello

import (
	"testing"
)

func TestHello(t *testing.T) {
	got := Hello()
	want := "Hello, "
	if got != want {
		t.Errorf("got '%s' want '%s'", got, want)
	}
}
