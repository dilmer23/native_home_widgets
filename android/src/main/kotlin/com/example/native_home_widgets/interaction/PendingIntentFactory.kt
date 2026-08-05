package com.example.native_home_widgets.interaction

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.app.PendingIntent
import android.os.Build

/// Factory for building PendingIntents used by widget click actions.
///
/// PendingIntents are required for widget interactivity because widgets
/// run in the system process and need explicit Intents to trigger actions
/// in the host app.
object PendingIntentFactory {

    private const val PREFS_NAME = "native_home_widgets_clicks"
    private const val KEY_LAST_CLICK = "last_click"

    /// Creates a PendingIntent for a widget click action.
    fun createClickPendingIntent(
        context: Context,
        widgetId: String,
        actionId: String
    ): PendingIntent {
        val intent = Intent(context, WidgetClickReceiver::class.java).apply {
            action = WidgetClickReceiver.ACTION_WIDGET_CLICK
            putExtra(WidgetClickReceiver.EXTRA_WIDGET_ID, widgetId)
            putExtra(WidgetClickReceiver.EXTRA_ACTION_ID, actionId)
        }

        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        return PendingIntent.getBroadcast(
            context,
            widgetId.hashCode(),
            intent,
            flags
        )
    }

    /// Creates a PendingIntent that opens the host app.
    fun createOpenAppPendingIntent(context: Context): PendingIntent {
        val packageManager = context.packageManager
        val intent = packageManager.getLaunchIntentForPackage(context.packageName)
            ?.apply { flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP }

        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        return PendingIntent.getActivity(context, 0, intent, flags)
    }

    /// Stores the most recent click event for Flutter to read.
    fun storeClickEvent(context: Context, widgetId: String, actionId: String) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_LAST_CLICK, "$widgetId:$actionId")
            .apply()
    }

    /// Reads and clears the most recent click event.
    fun consumeClickEvent(context: Context): Pair<String, String>? {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val raw = prefs.getString(KEY_LAST_CLICK, null) ?: return null
        prefs.edit().remove(KEY_LAST_CLICK).apply()
        val parts = raw.split(":", limit = 2)
        return if (parts.size == 2) Pair(parts[0], parts[1]) else null
    }

    /// Requests the system to pin a widget (Android 8+).
    fun requestPinWidget(context: Context): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
        val appWidgetManager = AppWidgetManager.getInstance(context) ?: return false
        val provider = ComponentName(context, SmallWidgetReceiver::class.java)
        return try {
            appWidgetManager.requestPinAppWidget(provider, null, null)
        } catch (_: Exception) {
            false
        }
    }
}
