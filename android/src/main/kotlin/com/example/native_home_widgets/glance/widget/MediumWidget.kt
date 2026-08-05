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
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.width
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import com.example.native_home_widgets.data.WidgetDataStore
import com.example.native_home_widgets.interaction.WidgetClickReceiver
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking

/// Medium home screen widget (2x2 cells).
///
/// Displays title, value, and description with a click action.
class MediumWidget : GlanceAppWidget() {

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val dataStore = WidgetDataStore(context)
        val data = runBlocking { dataStore.getAll() }

        val title = data.filterKeys { it.endsWith(":title") }
            .values.firstOrNull() ?: "Widget"
        val value = data.filterKeys { it.endsWith(":value") }
            .values.firstOrNull() ?: ""
        val description = data.filterKeys { it.endsWith(":description") }
            .values.firstOrNull() ?: ""

        provideContent {
            MediumWidgetContent(
                title = title,
                value = value,
                description = description
            )
        }
    }

    @Composable
    private fun MediumWidgetContent(
        title: String,
        value: String,
        description: String
    ) {
        Row(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(ColorProvider(android.graphics.Color.WHITE))
                .padding(16.dp)
                .clickable(actionRunCallback<MediumWidgetClickAction>()),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(
                modifier = GlanceModifier.defaultWeight()
            ) {
                Text(
                    text = title,
                    style = TextStyle(
                        color = ColorProvider(android.graphics.Color.parseColor("#8A000000")),
                        fontSize = androidx.glance.unit.TextUnit(14f),
                    )
                )
                Spacer(modifier = GlanceModifier.height(4.dp))
                Text(
                    text = value,
                    style = TextStyle(
                        color = ColorProvider(android.graphics.Color.parseColor("#DE000000")),
                        fontSize = androidx.glance.unit.TextUnit(28f),
                        fontWeight = FontWeight.Bold,
                    )
                )
                if (description.isNotEmpty()) {
                    Spacer(modifier = GlanceModifier.height(4.dp))
                    Text(
                        text = description,
                        style = TextStyle(
                            color = ColorProvider(android.graphics.Color.parseColor("#61000000")),
                            fontSize = androidx.glance.unit.TextUnit(12f),
                        )
                    )
                }
            }
        }
    }
}

/// Callback invoked when the medium widget is clicked.
class MediumWidgetClickAction : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        WidgetClickReceiver.sendClickEvent(context, glanceId.toString(), "default")
    }
}
