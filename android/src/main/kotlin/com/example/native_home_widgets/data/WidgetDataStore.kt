package com.example.native_home_widgets.data

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map

/// DataStore-backed persistence for widget data.
///
/// Keys are optionally scoped by widgetId, allowing multiple widgets
/// to maintain independent data stores within the same DataStore file.
class WidgetDataStore(private val context: Context) {

    private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(
        name = "native_home_widgets"
    )

    /// Saves a key-value pair, optionally scoped to a specific widget.
    suspend fun save(key: String, value: String, widgetId: String? = null) {
        val dataKey = buildKey(key, widgetId)
        context.dataStore.edit { prefs ->
            prefs[dataKey] = value
        }
    }

    /// Reads a value by key, returns [defaultValue] if not found.
    suspend fun get(key: String, widgetId: String? = null, defaultValue: String? = null): String? {
        val dataKey = buildKey(key, widgetId)
        return context.dataStore.data.map { prefs ->
            prefs[dataKey] ?: defaultValue
        }.first()
    }

    /// Removes a specific key.
    suspend fun remove(key: String, widgetId: String? = null) {
        val dataKey = buildKey(key, widgetId)
        context.dataStore.edit { prefs ->
            prefs.remove(dataKey)
        }
    }

    /// Clears all data for a widget, or all data if [widgetId] is null.
    suspend fun clear(widgetId: String? = null) {
        context.dataStore.edit { prefs ->
            if (widgetId == null) {
                prefs.clear()
            } else {
                val prefix = "$widgetId:"
                val keysToRemove = prefs.asMap().keys.filter { it.name.startsWith(prefix) }
                keysToRemove.forEach { prefs.remove(it) }
            }
        }
    }

    /// Returns all stored entries as a map (for debugging / export).
    suspend fun getAll(): Map<String, String> {
        return context.dataStore.data.map { prefs ->
            prefs.asMap().mapKeys { it.key.name }
        }.first()
    }

    private fun buildKey(key: String, widgetId: String?): Preferences.Key<String> {
        val name = if (widgetId != null) "$widgetId:$key" else "global:$key"
        return stringPreferencesKey(name)
    }
}
