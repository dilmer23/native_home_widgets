package com.example.native_home_widgets.glance.widget

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.action.ActionParameters
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.padding
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import com.example.native_home_widgets.data.WidgetDataStore
import com.example.native_home_widgets.glance.WidgetThemeResolver
import com.example.native_home_widgets.interaction.WidgetClickReceiver
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking

/// Small home screen widget (2x1 cells).
///
/// Displays a title and value pair with theme support (dark mode, Material You).
class SmallWidget : GlanceAppWidget() {

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val dataStore = WidgetDataStore(context)
        val data = runBlocking { dataStore.getAll() }
        val theme = WidgetThemeResolver.resolve(context)

        val title = data.filterKeys { it.endsWith(":title") }
            .values.firstOrNull() ?: "Widget"
        val value = data.filterKeys { it.endsWith(":value") }
            .values.firstOrNull() ?: ""

        provideContent {
            SmallWidgetContent(
                title = title,
                value = value,
                theme = theme,
                context = context
            )
        }
    }

    @Composable
    private fun SmallWidgetContent(
        title: String,
        value: String,
        theme: WidgetThemeResolver.WidgetTheme,
        context: Context
    ) {
        Box(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(ColorProvider(WidgetThemeResolver.backgroundColor(context, theme)))
                .padding(16.dp)
                .clickable(actionRunCallback<WidgetClickAction>()),
            contentAlignment = Alignment.CenterStart
        ) {
            Column {
                Text(
                    text = title,
                    style = TextStyle(
                        color = ColorProvider(WidgetThemeResolver.textSecondaryColor(context, theme)),
                        fontSize = androidx.glance.unit.TextUnit(14f),
                    )
                )
                Text(
                    text = value,
                    style = TextStyle(
                        color = ColorProvider(WidgetThemeResolver.textPrimaryColor(context, theme)),
                        fontSize = androidx.glance.unit.TextUnit(24f),
                        fontWeight = FontWeight.Bold,
                    )
                )
            }
        }
    }
}

/// Callback invoked when the small widget is clicked.
class WidgetClickAction : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        WidgetClickReceiver.sendClickEvent(context, glanceId.toString(), "default")
    }
}
