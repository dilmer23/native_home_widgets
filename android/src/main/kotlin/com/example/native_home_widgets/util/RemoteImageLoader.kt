package com.example.native_home_widgets.util

import android.content.Context
import android.graphics.Bitmap
import android.graphics.drawable.Drawable
import androidx.glance.ImageProvider
import coil.ImageLoader
import coil.request.ImageRequest
import coil.target.Target
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/// Loads remote images for use in Glance widgets via Coil.
object RemoteImageLoader {

    /// Loads a bitmap from a URL asynchronously.
    fun loadBitmap(context: Context, url: String, onResult: (Bitmap?) -> Unit) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val loader = ImageLoader(context)
                val request = ImageRequest.Builder(context)
                    .data(url)
                    .allowHardware(false)
                    .build()
                val drawable = loader.execute(request).drawable
                val bitmap = drawable?.let { convertDrawableToBitmap(it) }
                withContext(Dispatchers.Main) {
                    onResult(bitmap)
                }
            } catch (_: Exception) {
                withContext(Dispatchers.Main) {
                    onResult(null)
                }
            }
        }
    }

    private fun convertDrawableToBitmap(drawable: Drawable): Bitmap {
        val bitmap = Bitmap.createBitmap(
            drawable.intrinsicWidth.coerceAtLeast(1),
            drawable.intrinsicHeight.coerceAtLeast(1),
            Bitmap.Config.ARGB_8888
        )
        val canvas = android.graphics.Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        return bitmap
    }

    /// Creates a [ImageProvider] from a bitmap for Glance.
    fun toImageProvider(bitmap: Bitmap): ImageProvider {
        return ImageProvider(bitmap)
    }
}
