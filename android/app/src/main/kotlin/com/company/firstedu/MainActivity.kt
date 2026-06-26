package com.firstedu.app

import android.os.Build
import android.provider.MediaStore
import android.content.ContentValues
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.OutputStream

class MainActivity : FlutterActivity() {

    private val CHANNEL = "download_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->

                if (call.method == "saveFile") {

                    val fileName = call.argument<String>("fileName")
                    val bytes = call.argument<ByteArray>("bytes")

                    if (fileName == null || bytes == null) {
                        result.error("ERROR", "Invalid data", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val resolver = applicationContext.contentResolver

                        val contentValues = ContentValues().apply {
                            put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                            put(MediaStore.MediaColumns.MIME_TYPE, "application/pdf")
                            put(MediaStore.MediaColumns.RELATIVE_PATH, "Download/")
                        }

                        val uri: Uri? = resolver.insert(
                            MediaStore.Downloads.EXTERNAL_CONTENT_URI,
                            contentValues
                        )

                        if (uri != null) {
                            val outputStream: OutputStream? =
                                resolver.openOutputStream(uri)

                            outputStream?.write(bytes)
                            outputStream?.close()

                            result.success("File saved to Downloads")
                        } else {
                            result.error("ERROR", "Failed to create file", null)
                        }

                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
            }
    }
}