//go:build darwin
// +build darwin

package main

import (
	"fmt"
	"syscall"
	"time"
	"unsafe"
)

func uptime() {
	// Define the sysctl mib (Management Information Base)
	mib := []int32{1, 21} // CTL_KERN, KERN_BOOTTIME

	// Get the size of the returned data
	size := uintptr(0)
	_, _, _ = syscall.Syscall6(syscall.SYS___SYSCTL, uintptr(unsafe.Pointer(&mib[0])), 2, 0, uintptr(unsafe.Pointer(&size)), 0, 0)

	// Define a timeval struct to receive the data
	tv := syscall.Timeval{}

	// Call sysctl again, this time with a buffer
	_, _, err := syscall.Syscall6(syscall.SYS___SYSCTL, uintptr(unsafe.Pointer(&mib[0])), 2, uintptr(unsafe.Pointer(&tv)), uintptr(unsafe.Pointer(&size)), 0, 0)
	if err != 0 {
		fmt.Println("Error: ", err)
		return
	}

	// Calculate and print the uptime
	uptime := time.Since(time.Unix(tv.Sec, int64(tv.Usec*1000)))
	fmt.Printf("%d\n", int64(uptime.Seconds()))
}

func main() {
	uptime()
}
