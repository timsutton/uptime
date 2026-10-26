package ca.macops.uptime

import android.app.Activity
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.view.Gravity
import android.widget.LinearLayout
import android.widget.TextView

/** Seconds since boot, including time spent in deep sleep. */
fun uptimeInSeconds(): Long = SystemClock.elapsedRealtime() / 1000

fun formatUptime(seconds: Long): String {
    val days = seconds / 86_400
    val hours = seconds % 86_400 / 3_600
    val minutes = seconds % 3_600 / 60
    val secs = seconds % 60
    return listOf(days to "d", hours to "h", minutes to "m")
        .dropWhile { it.first == 0L }
        .joinToString(" ") { "${it.first}${it.second}" }
        .let { if (it.isEmpty()) "${secs}s" else "$it ${secs}s" }
}

class UptimeActivity : Activity() {
    private val handler = Handler(Looper.getMainLooper())
    private lateinit var formatted: TextView
    private lateinit var seconds: TextView

    private val tick = object : Runnable {
        override fun run() {
            val uptime = uptimeInSeconds()
            formatted.text = formatUptime(uptime)
            seconds.text = "$uptime seconds"
            handler.postDelayed(this, 1000)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        formatted = centeredText(34f)
        seconds = centeredText(15f)
        setContentView(
            LinearLayout(this).apply {
                orientation = LinearLayout.VERTICAL
                gravity = Gravity.CENTER
                addView(centeredText(17f).apply { text = "Uptime" })
                addView(formatted)
                addView(seconds)
            },
        )
    }

    private fun centeredText(size: Float) = TextView(this).apply {
        textSize = size
        gravity = Gravity.CENTER
    }

    override fun onResume() {
        super.onResume()
        handler.post(tick)
    }

    override fun onPause() {
        handler.removeCallbacks(tick)
        super.onPause()
    }
}
