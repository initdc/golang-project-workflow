package main

import (
	"fmt"
	"runtime"
)

func Info() string {
	return fmt.Sprintf("OS: %s\n", runtime.GOOS) +
		fmt.Sprintf("Architecture: %s\n", runtime.GOARCH) +
		fmt.Sprintf("Version: %s\n", runtime.Version())
}

func main() {
	fmt.Print(Info())
}
