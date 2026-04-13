import oshi.SystemInfo

fun main() {
  try {
    val uptimeSeconds = SystemInfo().operatingSystem.systemUptime
    println(uptimeSeconds)
  } catch (e: Exception) {
    e.printStackTrace()
  }
}
