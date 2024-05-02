#!/bin/bash

kotlinc -verbose -include-runtime -d Uptime.jar Uptime.kt

JAVA_HOME=/Library/Java/JavaVirtualMachines/graalvm-21.jdk/Contents/Home
"${JAVA_HOME}/bin/native-image" -jar Uptime.jar -march=native Uptime

./Uptime
