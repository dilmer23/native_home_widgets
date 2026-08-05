package com.example.native_home_widgets.interaction

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.os.Bundle

/// Configuration activity for widgets.
///
/// Shown when a user adds a widget that has `android:configure` set
/// in its provider info. Currently a stub — the developer can extend
/// it or the plugin handles configuration via data store.
class WidgetConfigurationActivity : Activity() {

    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setResult(RESULT_CANCELED)

        appWidgetId = intent?.extras?.getInt(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID

        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        // Auto-accept configuration for now.
        // Future: show a Flutter screen or native UI for widget setup.
        val resultValue = Intent().apply {
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        }
        setResult(RESULT_OK, resultValue)
        finish()
    }
}
