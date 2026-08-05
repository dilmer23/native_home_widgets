package com.example.native_home_widgets.glance.widget

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import androidx.compose.runtime.Composable
import androidx.core.graphics.drawable.IconCompat
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.action.ActionParameters
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import com.example.native_home_widgets.data.WidgetDataStore
import com.example.native_home_widgets.interaction.WidgetClickReceiver
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking

/// Progress widget — displays a task with progress bar and percentage.
class ProgressWidget : GlanceAppWidget() {

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val dataStore = WidgetDataStore(context)
        val data = runBlocking { dataStore.getAll() }

        val title = data.filterKeys { it.endsWith(":title") }
            .values.firstOrNull() ?: "Progress"
        val progressStr = data.filterKeys { it.endsWith(":progress") }
            .values.firstOrNull() ?: "0"
        val progress = (progressStr as? Number)?.toFloat() ?: 0f
        val label = data.filterKeys { it.endsWith(":label") }
            .values.firstOrNull() ?: ""

        provideContent {
            ProgressWidgetContent(title = title, progress = progress / 100f, label = label)
        }
    }

    @Composable
    private fun ProgressWidgetContent(title: String, progress: Float, label: String) {
        Column(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(ColorProvider(android.graphics.Color.WHITE))
                .padding(16.dp)
                .clickable(actionRunCallback<ProgressClickAction>())
        ) {
            Text(
                text = title,
                style = TextStyle(
                    color = ColorProvider(android.graphics.Color.parseColor("#8A000000")),
                    fontSize = androidx.glance.unit.TextUnit(14f),
                )
            )
            Spacer(modifier = GlanceModifier.height(8.dp))

            // Progress bar background
            Box(
                modifier = GlanceModifier
                    .fillMaxWidth()
                    .height(8.dp)
                    .background(ColorProvider(android.graphics.Color.parseColor("#E0E0E0")))
            ) {
                // Progress bar fill
                Box(
                    modifier = GlanceModifier
                        .width((200 * progress).dp)
                        .height(8.dp)
                        .background(ColorProvider(android.graphics.Color.parseColor("#6200EE")))
                )
            }

            Spacer(modifier = GlanceModifier.height(8.dp))
            Row {
                Text(
                    text = "${(progress * 100).toInt()}%",
                    style = TextStyle(
                        color = ColorProvider(android.graphics.Color.parseColor("#DE000000")),
                        fontSize = androidx.glance.unit.TextUnit(20f),
                        fontWeight = FontWeight.Bold,
                    )
                )
                if (label.isNotEmpty()) {
                    Spacer(modifier = GlanceModifier.width(8.dp))
                    Text(
                        text = label,
                        style = TextStyle(
                            color = ColorProvider(android.graphics.Color.parseColor("#61000000")),
                            fontSize = androidx.glance.unit.TextUnit(12f),
                        )
                    )
                }
            }
        }
    }
}

class ProgressClickAction : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        WidgetClickReceiver.sendClickEvent(context, glanceId.toString(), "progress")
    }
}

/// Battery widget — displays current battery level and charging status.
class BatteryWidget : GlanceAppWidget() {

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val batteryLevel = getBatteryLevel(context)
        val isCharging = isCharging(context)

        provideContent {
            BatteryWidgetContent(level = batteryLevel, isCharging = isCharging)
        }
    }

    @Composable
    private fun BatteryWidgetContent(level: Int, isCharging: Boolean) {
        Column(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(ColorProvider(android.graphics.Color.WHITE))
                .padding(16.dp)
                .clickable(actionRunCallback<BatteryClickAction>()),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "$level%",
                style = TextStyle(
                    color = ColorProvider(
                        if (level > 20) android.graphics.Color.parseColor("#4CAF50")
                        else android.graphics.Color.parseColor("#F44336")
                    ),
                    fontSize = androidx.glance.unit.TextUnit(32f),
                    fontWeight = FontWeight.Bold,
                )
            )
            if (isCharging) {
                Text(
                    text = "Charging",
                    style = TextStyle(
                        color = ColorProvider(android.graphics.Color.parseColor("#6200EE")),
                        fontSize = androidx.glance.unit.TextUnit(12f),
                    )
                )
            }
        }
    }

    private fun getBatteryLevel(context: Context): Int {
        val batteryIntent = context.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        val level = batteryIntent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
        val scale = batteryIntent?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
        return if (level >= 0 && scale > 0) (level * 100 / scale) else 0
    }

    private fun isCharging(context: Context): Boolean {
        val batteryIntent = context.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        val status = batteryIntent?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
        return status == BatteryManager.BATTERY_STATUS_CHARGING ||
               status == BatteryManager.BATTERY_STATUS_FULL
    }
}

class BatteryClickAction : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        WidgetClickReceiver.sendClickEvent(context, glanceId.toString(), "battery")
    }
}

/// Clock widget — displays current time and date.
class ClockWidget : GlanceAppWidget() {

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val now = java.util.Calendar.getInstance()
        val timeFormat = java.text.SimpleDateFormat("HH:mm", java.util.Locale.getDefault())
        val dateFormat = java.text.SimpleDateFormat("EEE, MMM d", java.util.Locale.getDefault())

        val timeText = timeFormat.format(now.time)
        val dateText = dateFormat.format(now.time)

        provideContent {
            ClockWidgetContent(time = timeText, date = dateText)
        }
    }

    @Composable
    private fun ClockWidgetContent(time: String, date: String) {
        Column(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(ColorProvider(android.graphics.Color.WHITE))
                .padding(16.dp)
                .clickable(actionRunCallback<ClockClickAction>()),
            verticalAlignment = Alignment.CenterVertically,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = time,
                style = TextStyle(
                    color = ColorProvider(android.graphics.Color.parseColor("#DE000000")),
                    fontSize = androidx.glance.unit.TextUnit(36f),
                    fontWeight = FontWeight.Bold,
                )
            )
            Spacer(modifier = GlanceModifier.height(4.dp))
            Text(
                text = date,
                style = TextStyle(
                    color = ColorProvider(android.graphics.Color.parseColor("#8A000000")),
                    fontSize = androidx.glance.unit.TextUnit(14f),
                )
            )
        }
    }
}

class ClockClickAction : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        WidgetClickReceiver.sendClickEvent(context, glanceId.toString(), "clock")
    }
}
