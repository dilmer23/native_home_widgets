package com.example.native_home_widgets.glance.widget

import android.content.Context
import androidx.glance.appwidget.GlanceAppWidgetReceiver

/// BroadcastReceiver that manages the [LargeWidget] GlanceAppWidget.
class LargeWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = LargeWidget()
}
