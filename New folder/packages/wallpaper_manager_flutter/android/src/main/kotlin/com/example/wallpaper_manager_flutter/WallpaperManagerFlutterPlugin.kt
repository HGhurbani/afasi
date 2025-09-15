package com.example.wallpaper_manager_flutter

import android.app.WallpaperManager
import android.content.Context
import android.graphics.BitmapFactory
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File

class WallpaperManagerFlutterPlugin : FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(binding.binaryMessenger, "wallpaper_manager_flutter")
    channel.setMethodCallHandler(this)
    context = binding.applicationContext
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "setWallpaper") {
      val filePath = call.argument<String>("filePath")
      val location = call.argument<Int>("location") ?: 1
      if (filePath == null) {
        result.error("INVALID_ARGUMENT", "filePath is required", null)
        return
      }
      val file = File(filePath)
      if (!file.exists()) {
        result.error("FILE_NOT_FOUND", "File not found", null)
        return
      }
      val bitmap = BitmapFactory.decodeFile(filePath)
      val wm = WallpaperManager.getInstance(context)
      try {
        when (location) {
          1 -> wm.setBitmap(bitmap, null, true, WallpaperManager.FLAG_SYSTEM)
          2 -> wm.setBitmap(bitmap, null, true, WallpaperManager.FLAG_LOCK)
          3 -> {
            wm.setBitmap(bitmap, null, true, WallpaperManager.FLAG_SYSTEM)
            wm.setBitmap(bitmap, null, true, WallpaperManager.FLAG_LOCK)
          }
          else -> wm.setBitmap(bitmap)
        }
        result.success(null)
      } catch (e: Exception) {
        result.error("SET_WALLPAPER_FAILED", e.message, null)
      }
    } else {
      result.notImplemented()
    }
  }
}
