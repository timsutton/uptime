#!/bin/bash

set -eux -o pipefail

clang uptime.c -o uptime

cargo build --release
