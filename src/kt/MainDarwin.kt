import oshi.SystemInfo

fun main() {
  try {
    val si = SystemInfo()
    println(si.operatingSystem.systemUptime)
  } catch (e: Exception) {
    e.printStackTrace()
  }
}
