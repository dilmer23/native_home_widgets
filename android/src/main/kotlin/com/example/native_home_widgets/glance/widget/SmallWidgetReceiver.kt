package com.example.native_home_widgets.glance.widget

import android.content.Context
import androidx.glance.appwidget.GlanceAppWidgetReceiver

/// BroadcastReceiver that manages the [SmallWidget] GlanceAppWidget.
///
/// Handles system widget lifecycle events (update, delete, etc.) and
/// routes them to the GlanceAppWidget instance.
class SmallWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = SmallWidget()
}
