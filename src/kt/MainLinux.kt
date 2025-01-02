import java.io.File

fun main() {
  try {
    val lines = File("/proc/stat").readLines()
    val btimeLine = lines.first { it.startsWith("btime") }
    val bootTimeSeconds = btimeLine.split(" ")[1].toLong()

    val currentTimeSeconds = System.currentTimeMillis() / 1000
    val uptimeSeconds = currentTimeSeconds - bootTimeSeconds

    println("$uptimeSeconds")
  } catch (e: Exception) {
    e.printStackTrace()
  }
}
