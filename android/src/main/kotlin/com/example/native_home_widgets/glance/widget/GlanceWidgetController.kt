package com.example.native_home_widgets.glance.widget

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import androidx.glance.appwidget.GlanceAppWidgetManager
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

/// Controls Glance widget lifecycle — creation, update, and deletion.
object GlanceWidgetController {

    /// Updates a specific widget by its ID.
    fun updateWidget(context: Context, widgetId: String?) {
        val manager = GlanceAppWidgetManager(context)
        CoroutineScope(Dispatchers.Main).launch {
            try {
                if (widgetId == null) {
                    updateAllWidgets(context)
                } else {
                    updateWidgetById(context, widgetId, manager)
                }
            } catch (_: Exception) {
                // Widget may not exist yet; ignore.
            }
        }
    }

    private suspend fun updateWidgetById(
        context: Context,
        widgetId: String,
        manager: GlanceAppWidgetManager
    ) {
        for ((widgetClass, _) in allWidgetTypes) {
            val glanceIds = manager.getGlanceIds(widgetClass)
            val target = glanceIds.find { it.toString() == widgetId }
            if (target != null) {
                when (widgetClass) {
                    SmallWidget::class.java -> SmallWidget().update(context, target)
                    MediumWidget::class.java -> MediumWidget().update(context, target)
                    LargeWidget::class.java -> LargeWidget().update(context, target)
                    ProgressWidget::class.java -> ProgressWidget().update(context, target)
                    BatteryWidget::class.java -> BatteryWidget().update(context, target)
                    ClockWidget::class.java -> ClockWidget().update(context, target)
                }
                return
            }
        }
    }

    /// Updates all widgets of all types.
    fun updateAllWidgets(context: Context) {
        val manager = GlanceAppWidgetManager(context)
        CoroutineScope(Dispatchers.Main).launch {
            try {
                for ((widgetClass, _) in allWidgetTypes) {
                    val glanceIds = manager.getGlanceIds(widgetClass)
                    glanceIds.forEach { id ->
                        when (widgetClass) {
                            SmallWidget::class.java -> SmallWidget().update(context, id)
                            MediumWidget::class.java -> MediumWidget().update(context, id)
                            LargeWidget::class.java -> LargeWidget().update(context, id)
                            ProgressWidget::class.java -> ProgressWidget().update(context, id)
                            BatteryWidget::class.java -> BatteryWidget().update(context, id)
                            ClockWidget::class.java -> ClockWidget().update(context, id)
                        }
                    }
                }
            } catch (_: Exception) {
                // Ignore update errors during bulk operation.
            }
        }
    }

    /// Returns detailed info about all installed widgets.
    fun getInstalledWidgetInfo(context: Context): List<Map<String, Any>> {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val result = mutableListOf<Map<String, Any>>()

        for ((receiver, size) in allReceivers) {
            try {
                val provider = ComponentName(context, receiver)
                appWidgetManager.getAppWidgetIds(provider).forEach { id ->
                    result.add(
                        mapOf(
                            "id" to id.toString(),
                            "size" to size,
                            "isInstalled" to true,
                            "lastUpdated" to System.currentTimeMillis()
                        )
                    )
                }
            } catch (_: Exception) {}
        }
        return result
    }

    /// Returns the list of all installed widget IDs across all types.
    fun getInstalledWidgetIds(context: Context): List<String> {
        return getInstalledWidgetInfo(context).map { it["id"] as String }
    }

    private val allWidgetTypes = listOf(
        SmallWidget::class.java to "small",
        MediumWidget::class.java to "medium",
        LargeWidget::class.java to "large",
        ProgressWidget::class.java to "small",
        BatteryWidget::class.java to "small",
        ClockWidget::class.java to "small"
    )

    private val allReceivers = listOf(
        SmallWidgetReceiver::class.java to "small",
        MediumWidgetReceiver::class.java to "medium",
        LargeWidgetReceiver::class.java to "large",
        ProgressWidgetReceiver::class.java to "small",
        BatteryWidgetReceiver::class.java to "small",
        ClockWidgetReceiver::class.java to "small"
    )
}
