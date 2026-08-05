package com.example.native_home_widgets.interaction

import android.content.Context
import android.content.Intent
import android.net.Uri

/// Handles deep links from widget clicks.
///
/// Supports two modes:
/// 1. Open app via launch intent (default)
/// 2. Open specific screen via deep link URI
///
/// Deep link URIs are passed through the widget data store under the key
/// `deeplink` with the target screen as the value.
object DeepLinkHandler {

    /// Stores a deep link URI for a specific widget.
    fun saveDeepLink(context: Context, widgetId: String, uri: String) {
        val store = com.example.native_home_widgets.data.WidgetDataStore(context)
        // Use a synchronous approach for simplicity — DataStore is suspend,
        // so we store the deep link in SharedPreferences as well for synchronous read
        context.getSharedPreferences("native_home_widgets_deeplinks", Context.MODE_PRIVATE)
            .edit()
            .putString("deeplink:$widgetId", uri)
            .apply()
    }

    /// Returns the stored deep link URI for a widget, or null.
    fun getDeepLink(context: Context, widgetId: String): String? {
        return context.getSharedPreferences("native_home_widgets_deeplinks", Context.MODE_PRIVATE)
            .getString("deeplink:$widgetId", null)
    }

    /// Opens a deep link, falling back to the app launcher if no link is stored.
    fun openDeepLink(context: Context, widgetId: String) {
        val link = getDeepLink(context, widgetId)
        val intent = if (link != null) {
            Intent(Intent.ACTION_VIEW, Uri.parse(link)).apply {
                setPackage(context.packageName)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
        } else {
            context.packageManager.getLaunchIntentForPackage(context.packageName)?.apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
        }
        if (intent != null) {
            context.startActivity(intent)
        }
    }

    /// Removes a stored deep link for a widget.
    fun removeDeepLink(context: Context, widgetId: String) {
        context.getSharedPreferences("native_home_widgets_deeplinks", Context.MODE_PRIVATE)
            .edit()
            .remove("deeplink:$widgetId")
            .apply()
    }
}
