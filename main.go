package main

import "fmt"
import "runtime"

func main() {
    fmt.Printf("OS: %s\n", runtime.GOOS)
    fmt.Printf("Architecture: %s\n", runtime.GOARCH)
    fmt.Printf("Version: %s\n", runtime.Version())
}