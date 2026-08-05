package com.example.native_home_widgets.glance

import android.content.Context
import android.os.Build
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import com.example.native_home_widgets.data.WidgetDataStore
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking

/// Resolves widget theme configuration from stored data.
///
/// Supports:
/// - Light/Dark mode (reads `_theme_brightness` from data store)
/// - Material You dynamic colors (Android 12+, reads `_theme_material_you`)
/// - RTL layout direction (reads `_direction`)
object WidgetThemeResolver {

    data class WidgetTheme(
        val isDark: Boolean,
        val useMaterialYou: Boolean,
        val isRtl: Boolean,
    )

    fun resolve(context: Context): WidgetTheme {
        val dataStore = WidgetDataStore(context)
        val data = runBlocking { dataStore.getAll() }

        val brightnessStr = data.filterKeys { it.endsWith(":_theme_brightness") }
            .values.firstOrNull() as? String
        val isDark = brightnessStr == "dark"

        val materialYouStr = data.filterKeys { it.endsWith(":_theme_material_you") }
            .values.firstOrNull() as? String
        val useMaterialYou = materialYouStr == "true"

        val directionStr = data.filterKeys { it.endsWith(":_direction") }
            .values.firstOrNull() as? String
        val isRtl = directionStr == "rtl"

        return WidgetTheme(isDark = isDark, useMaterialYou = useMaterialYou, isRtl = isRtl)
    }

    /// Returns the background color based on theme.
    fun backgroundColor(context: Context, theme: WidgetTheme): Int {
        return if (theme.isDark) {
            android.graphics.Color.parseColor("#1C1B1F")
        } else {
            android.graphics.Color.parseColor("#FFFFFF")
        }
    }

    /// Returns the primary text color based on theme.
    fun textPrimaryColor(context: Context, theme: WidgetTheme): Int {
        return if (theme.isDark) {
            android.graphics.Color.parseColor("#E6E1E5")
        } else {
            android.graphics.Color.parseColor("#DE000000")
        }
    }

    /// Returns the secondary text color based on theme.
    fun textSecondaryColor(context: Context, theme: WidgetTheme): Int {
        return if (theme.isDark) {
            android.graphics.Color.parseColor("#CAC4D0")
        } else {
            android.graphics.Color.parseColor("#8A000000")
        }
    }

    /// Returns the accent color, using Material You if available.
    fun accentColor(context: Context, theme: WidgetTheme): Int {
        if (theme.useMaterialYou && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            return try {
                val colorScheme = if (theme.isDark) {
                    dynamicDarkColorScheme(context)
                } else {
                    dynamicLightColorScheme(context)
                }
                colorScheme.primary.toArgb()
            } catch (_: Exception) {
                android.graphics.Color.parseColor("#6200EE")
            }
        }
        return android.graphics.Color.parseColor("#6200EE")
    }

    private fun androidx.compose.material3.ColorScheme.toArgb(): Int {
        return android.graphics.Color.argb(
            (alpha * 255).toInt(),
            (red * 255).toInt(),
            (green * 255).toInt(),
            (blue * 255).toInt(),
        )
    }
}
