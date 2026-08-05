package com.example.native_home_widgets.data

import org.json.JSONArray
import org.json.JSONObject

/// Serializes and deserializes widget data for storage and transport.
///
/// Handles the conversion between Kotlin types and their string
/// representations stored in DataStore.
object WidgetDataSerializer {

    /// Serializes a value to its string representation for storage.
    fun serialize(value: Any?): String {
        return when (value) {
            null -> "null"
            is String -> value
            is Int -> value.toString()
            is Long -> value.toString()
            is Double -> value.toString()
            is Boolean -> value.toString()
            is List<*> -> JSONArray(value).toString()
            is Map<*, *> -> JSONObject(value).toString()
            else -> value.toString()
        }
    }

    /// Deserializes a stored string back to a typed value.
    fun deserialize(value: String?): Any? {
        if (value == null || value == "null") return null
        return when {
            value.toIntOrNull() != null -> value.toInt()
            value.toLongOrNull() != null -> value.toLong()
            value.toDoubleOrNull() != null -> value.toDouble()
            value == "true" -> true
            value == "false" -> false
            value.startsWith("[") -> parseJsonArray(value)
            value.startsWith("{") -> parseJsonObject(value)
            else -> value
        }
    }

    private fun parseJsonArray(json: String): List<Any?> {
        val arr = JSONArray(json)
        return (0 until arr.length()).map { deserialize(arr.optString(it)) }
    }

    private fun parseJsonObject(json: String): Map<String, Any?> {
        val obj = JSONObject(json)
        val map = mutableMapOf<String, Any?>()
        obj.keys().forEach { key ->
            map[key] = deserialize(obj.optString(key))
        }
        return map
    }
}
