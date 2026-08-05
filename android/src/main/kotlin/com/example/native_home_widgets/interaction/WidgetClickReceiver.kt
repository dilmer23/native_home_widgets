package com.example.native_home_widgets.interaction

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.example.native_home_widgets.glance.widget.GlanceWidgetController

/// BroadcastReceiver that captures widget click events and forwards them
/// to the Flutter side.
///
/// Click events are stored in SharedPreferences for the Flutter side
/// to read, and also broadcast via an explicit Intent. Deep links are
/// resolved and launched when a widget with a configured deep link is tapped.
class WidgetClickReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            ACTION_WIDGET_CLICK -> {
                val widgetId = intent.getStringExtra(EXTRA_WIDGET_ID) ?: return
                val actionId = intent.getStringExtra(EXTRA_ACTION_ID) ?: "default"

                // Store the click event for Flutter to pick up
                PendingIntentFactory.storeClickEvent(context, widgetId, actionId)

                // Send a broadcast that Flutter can listen to
                val eventIntent = Intent(ACTION_WIDGET_CLICK).apply {
                    setPackage(context.packageName)
                    putExtra(EXTRA_WIDGET_ID, widgetId)
                    putExtra(EXTRA_ACTION_ID, actionId)
                }
                context.sendBroadcast(eventIntent)

                // If a deep link is configured, open it
                val deepLink = DeepLinkHandler.getDeepLink(context, widgetId)
                if (deepLink != null) {
                    DeepLinkHandler.openDeepLink(context, widgetId)
                }
            }
            AppWidgetManager.ACTION_APPWIDGET_UPDATE -> {
                // System update — refresh all widgets
                GlanceWidgetController.updateAllWidgets(context)
            }
        }
    }

    companion object {
        const val ACTION_WIDGET_CLICK = "com.example.native_home_widgets.WIDGET_CLICK"
        const val EXTRA_WIDGET_ID = "widgetId"
        const val EXTRA_ACTION_ID = "actionId"

        /// Creates a click event from a Glance action callback.
        fun sendClickEvent(context: Context, widgetId: String, actionId: String) {
            val intent = Intent(context, WidgetClickReceiver::class.java).apply {
                action = ACTION_WIDGET_CLICK
                putExtra(EXTRA_WIDGET_ID, widgetId)
                putExtra(EXTRA_ACTION_ID, actionId)
            }
            context.sendBroadcast(intent)
        }
    }
}
