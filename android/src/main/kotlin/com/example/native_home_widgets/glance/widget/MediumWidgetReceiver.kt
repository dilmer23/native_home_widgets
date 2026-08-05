package com.example.native_home_widgets.glance.widget

import android.content.Context
import androidx.glance.appwidget.GlanceAppWidgetReceiver

/// BroadcastReceiver that manages the [MediumWidget] GlanceAppWidget.
class MediumWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = MediumWidget()
}
