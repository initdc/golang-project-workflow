package world

import (
	hello "lib/hello"
)

func World() string {
	return "World!"
}

func HelloWorld() string {
	return hello.Hello() + World()
}
