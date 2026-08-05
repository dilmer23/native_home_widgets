package com.example.native_home_widgets.glance.widget

import android.content.Context
import androidx.glance.appwidget.GlanceAppWidgetReceiver

/// BroadcastReceiver for the [ProgressWidget].
class ProgressWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = ProgressWidget()
}

/// BroadcastReceiver for the [BatteryWidget].
class BatteryWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = BatteryWidget()
}

/// BroadcastReceiver for the [ClockWidget].
class ClockWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = ClockWidget()
}
