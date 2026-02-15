package com.daronec.smart_video_info

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import com.smartmedia.ffmpeg.SmartFfmpegBridge

class SmartVideoInfoPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "smart_video_info")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getInfo" -> {
                val path = call.argument<String>("path")
                if (path == null) {
                    result.error("INVALID_ARGUMENT", "Path is required", null)
                    return
                }
                
                scope.launch {
                    try {
                        val json = SmartFfmpegBridge.getVideoMetadataJson(path)
                        withContext(Dispatchers.Main) {
                            result.success(json)
                        }
                    } catch (e: Exception) {
                        withContext(Dispatchers.Main) {
                            result.error("METADATA_ERROR", e.message, null)
                        }
                    }
                }
            }
            "getBatch" -> {
                val paths = call.argument<List<String>>("paths")
                if (paths == null || paths.isEmpty()) {
                    result.error("INVALID_ARGUMENT", "Paths list is required", null)
                    return
                }
                
                scope.launch {
                    try {
                        val results = paths.map { path ->
                            SmartFfmpegBridge.getVideoMetadataJson(path)
                        }
                        withContext(Dispatchers.Main) {
                            result.success(results)
                        }
                    } catch (e: Exception) {
                        withContext(Dispatchers.Main) {
                            result.error("METADATA_ERROR", e.message, null)
                        }
                    }
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        scope.cancel()
        channel.setMethodCallHandler(null)
    }
}
