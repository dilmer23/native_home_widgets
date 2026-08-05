package com.example.native_home_widgets.util

import android.appwidget.AppWidgetManager
import android.content.Context
import android.os.Bundle

/// Resolves widget sizes from AppWidgetManager options.
object AppWidgetSizeResolver {

    /// Maps AppWidgetManager OPTION_APPWIDGET_MIN_WIDTH/HEIGHT to a size enum.
    fun resolveSize(context: Context, appWidgetId: Int): String {
        val options = AppWidgetManager.getInstance(context).getAppWidgetOptions(appWidgetId)
        val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 0)
        val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0)

        return when {
            minWidth >= 250 || minHeight >= 250 -> "large"
            minWidth >= 180 || minHeight >= 180 -> "medium"
            else -> "small"
        }
    }
}
