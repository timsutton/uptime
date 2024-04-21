//go:build linux
// +build linux

package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

func uptime() {
	data, err := ioutil.ReadFile("/proc/uptime")
	if err != nil {
		fmt.Println("Error: ", err)
		return
	}

	// The uptime is the first field in the file
	fields := strings.Fields(string(data))
	uptime, err := strconv.ParseFloat(fields[0], 64)
	if err != nil {
		fmt.Println("Error: ", err)
		return
	}

	// Print the uptime
	fmt.Printf("%d\n", int64(uptime))
}

func main() {
	uptime()
}
