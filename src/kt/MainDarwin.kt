import java.io.BufferedReader
import java.io.InputStreamReader

import java.lang.management.ManagementFactory
import java.time.Instant
import java.util.concurrent.TimeUnit

fun main() {
    try {
        // TODO: don't use shell out, actually use the sysctl C API
        // or try out OSHI: https://github.com/oshi/oshi
        val process = ProcessBuilder("sysctl", "kern.boottime")
            .redirectErrorStream(true)
            .start()

        val input = BufferedReader(InputStreamReader(process.inputStream))
        val output = input.readText()
        input.close()

        val bootTime = output.substringAfter("sec = ").substringBefore(",")
        var currentTime = System.currentTimeMillis() / 1000
        println("%s".format(currentTime - bootTime.toLong()))

    } catch (e: Exception) {
        e.printStackTrace()
    }
}
