package com.example.native_home_widgets

import android.content.Context
import com.example.native_home_widgets.data.WidgetDataStore
import com.example.native_home_widgets.data.WidgetDataSerializer
import com.example.native_home_widgets.glance.widget.GlanceWidgetController
import com.example.native_home_widgets.interaction.DeepLinkHandler
import com.example.native_home_widgets.interaction.PendingIntentFactory
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/**
 * NativeHomeWidgetsPlugin — Flutter plugin entry point for Android.
 *
 * Handles MethodChannel calls from Dart, routes them to the appropriate
 * service, and streams events back to Dart via EventChannel.
 */
class NativeHomeWidgetsPlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext

        methodChannel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL_NAME)
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, EVENT_CHANNEL_NAME)
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                // Event sink stored for native → Dart communication
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            // ── Platform info ──────────────────────────────
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }

            // ── Data ────────────────────────────────────────
            "widget.saveData" -> handleSaveData(call, result)
            "widget.getData" -> handleGetData(call, result)
            "widget.removeData" -> handleRemoveData(call, result)
            "widget.clearData" -> handleClearData(call, result)

            // ── Lifecycle ───────────────────────────────────
            "widget.update" -> handleUpdate(call, result)
            "widget.updateAll" -> handleUpdateAll(result)
            "widget.reloadAll" -> handleReloadAll(result)

            // ── Query ───────────────────────────────────────
            "widget.getAll" -> handleGetAll(result)
            "widget.isInstalled" -> handleIsInstalled(call, result)

            // ── Accessibility ───────────────────────────────
            "widget.setAccessibility" -> handleSetAccessibility(call, result)

            // ── Deep Links ───────────────────────────────────
            "widget.saveDeepLink" -> handleSaveDeepLink(call, result)
            "widget.getDeepLink" -> handleGetDeepLink(call, result)
            "widget.openDeepLink" -> handleOpenDeepLink(call, result)

            // ── Configuration ───────────────────────────────
            "widget.pin" -> handlePin(result)
            "widget.openConfiguration" -> handleOpenConfiguration(result)

            else -> result.notImplemented()
        }
    }

    // ── Data handlers ─────────────────────────────────────

    private fun handleSaveData(call: MethodCall, result: MethodChannel.Result) {
        val key = call.argument<String>("key") ?: run {
            result.error("DATA_ERROR", "Missing key", null)
            return
        }
        val value = call.argument<Any>("value")
        val widgetId = call.argument<String>("widgetId")

        CoroutineScope(Dispatchers.IO).launch {
            try {
                val store = WidgetDataStore(context)
                store.save(key, WidgetDataSerializer.serialize(value), widgetId)
                withContext(Dispatchers.Main) { result.success(true) }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("STORAGE_ERROR", e.message, null)
                }
            }
        }
    }

    private fun handleGetData(call: MethodCall, result: MethodChannel.Result) {
        val key = call.argument<String>("key") ?: run {
            result.error("DATA_ERROR", "Missing key", null)
            return
        }
        val widgetId = call.argument<String>("widgetId")
        val defaultValue = call.argument<Any>("defaultValue")

        CoroutineScope(Dispatchers.IO).launch {
            try {
                val store = WidgetDataStore(context)
                val raw = store.get(key, widgetId, null)
                val deserialized = WidgetDataSerializer.deserialize(raw) ?: defaultValue
                withContext(Dispatchers.Main) { result.success(deserialized) }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("STORAGE_ERROR", e.message, null)
                }
            }
        }
    }

    private fun handleRemoveData(call: MethodCall, result: MethodChannel.Result) {
        val key = call.argument<String>("key") ?: run {
            result.error("DATA_ERROR", "Missing key", null)
            return
        }
        val widgetId = call.argument<String>("widgetId")

        CoroutineScope(Dispatchers.IO).launch {
            try {
                val store = WidgetDataStore(context)
                store.remove(key, widgetId)
                withContext(Dispatchers.Main) { result.success(true) }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("STORAGE_ERROR", e.message, null)
                }
            }
        }
    }

    private fun handleClearData(call: MethodCall, result: MethodChannel.Result) {
        val widgetId = call.argument<String>("widgetId")

        CoroutineScope(Dispatchers.IO).launch {
            try {
                val store = WidgetDataStore(context)
                store.clear(widgetId)
                withContext(Dispatchers.Main) { result.success(true) }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("STORAGE_ERROR", e.message, null)
                }
            }
        }
    }

    // ── Lifecycle handlers ───────────────────────────────

    private fun handleUpdate(call: MethodCall, result: MethodChannel.Result) {
        val widgetId = call.argument<String>("widgetId")
        try {
            GlanceWidgetController.updateWidget(context, widgetId)
            result.success(true)
        } catch (e: Exception) {
            result.error("WIDGET_NOT_FOUND", e.message, null)
        }
    }

    private fun handleUpdateAll(result: MethodChannel.Result) {
        try {
            GlanceWidgetController.updateAllWidgets(context)
            result.success(true)
        } catch (e: Exception) {
            result.error("WIDGET_NOT_FOUND", e.message, null)
        }
    }

    private fun handleReloadAll(result: MethodChannel.Result) {
        try {
            GlanceWidgetController.updateAllWidgets(context)
            result.success(true)
        } catch (e: Exception) {
            result.error("WIDGET_NOT_FOUND", e.message, null)
        }
    }

    // ── Query handlers ───────────────────────────────────

    private fun handleGetAll(result: MethodChannel.Result) {
        try {
            val widgetInfo = GlanceWidgetController.getInstalledWidgetInfo(context)
            result.success(widgetInfo)
        } catch (e: Exception) {
            result.error("STORAGE_ERROR", e.message, null)
        }
    }

    private fun handleIsInstalled(call: MethodCall, result: MethodChannel.Result) {
        val widgetId = call.argument<String>("widgetId") ?: run {
            result.error("DATA_ERROR", "Missing widgetId", null)
            return
        }
        try {
            val ids = GlanceWidgetController.getInstalledWidgetIds(context)
            result.success(ids.contains(widgetId))
        } catch (e: Exception) {
            result.success(false)
        }
    }

    // ── Accessibility handlers ─────────────────────────────

    private fun handleSetAccessibility(call: MethodCall, result: MethodChannel.Result) {
        val widgetId = call.argument<String>("widgetId") ?: run {
            result.error("DATA_ERROR", "Missing widgetId", null)
            return
        }
        val label = call.argument<String>("label")
        val hint = call.argument<String>("hint")
        val value = call.argument<String>("value")
        val isButton = call.argument<Boolean>("isButton") ?: false
        val isHeader = call.argument<Boolean>("isHeader") ?: false

        try {
            val store = WidgetDataStore(context)
            if (label != null) store.save("_a11y_label", label, widgetId)
            if (hint != null) store.save("_a11y_hint", hint, widgetId)
            if (value != null) store.save("_a11y_value", value, widgetId)
            store.save("_a11y_isButton", isButton.toString(), widgetId)
            store.save("_a11y_isHeader", isHeader.toString(), widgetId)
            result.success(true)
        } catch (e: Exception) {
            result.error("STORAGE_ERROR", e.message, null)
        }
    }

    // ── Deep link handlers ─────────────────────────────────

    private fun handleSaveDeepLink(call: MethodCall, result: MethodChannel.Result) {
        val widgetId = call.argument<String>("widgetId") ?: run {
            result.error("DATA_ERROR", "Missing widgetId", null)
            return
        }
        val uri = call.argument<String>("uri") ?: run {
            result.error("DATA_ERROR", "Missing uri", null)
            return
        }
        try {
            DeepLinkHandler.saveDeepLink(context, widgetId, uri)
            result.success(true)
        } catch (e: Exception) {
            result.error("STORAGE_ERROR", e.message, null)
        }
    }

    private fun handleGetDeepLink(call: MethodCall, result: MethodChannel.Result) {
        val widgetId = call.argument<String>("widgetId") ?: run {
            result.error("DATA_ERROR", "Missing widgetId", null)
            return
        }
        try {
            val uri = DeepLinkHandler.getDeepLink(context, widgetId)
            result.success(uri)
        } catch (e: Exception) {
            result.error("STORAGE_ERROR", e.message, null)
        }
    }

    private fun handleOpenDeepLink(call: MethodCall, result: MethodChannel.Result) {
        val widgetId = call.argument<String>("widgetId") ?: run {
            result.error("DATA_ERROR", "Missing widgetId", null)
            return
        }
        try {
            DeepLinkHandler.openDeepLink(context, widgetId)
            result.success(true)
        } catch (e: Exception) {
            result.error("DATA_ERROR", e.message, null)
        }
    }

    // ── Configuration handlers ────────────────────────────

    private fun handlePin(result: MethodChannel.Result) {
        val success = PendingIntentFactory.requestPinWidget(context)
        if (success) {
            result.success(true)
        } else {
            result.error("PINNING_FAILED", "Widget pinning not supported or failed", null)
        }
    }

    private fun handleOpenConfiguration(result: MethodChannel.Result) {
        // Configuration is handled via the config activity.
        // On Android, the system opens it when adding the widget.
        result.success(true)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        eventSink = null
    }

    companion object {
        const val METHOD_CHANNEL_NAME = "native_home_widgets/method"
        const val EVENT_CHANNEL_NAME = "native_home_widgets/events"

        @Volatile
        private var eventSink: EventChannel.EventSink? = null

        /// Sends an event from native to Dart via the EventChannel.
        fun sendEvent(eventType: String, data: Map<String, Any>) {
            val payload = mutableMapOf<String, Any>("eventType" to eventType)
            payload.putAll(data)
            eventSink?.success(payload)
        }
    }
}
