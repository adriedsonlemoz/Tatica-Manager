package com.taticamanager.tatica_manager

import android.app.ActivityManager
import android.content.ContentValues
import android.content.Context
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import com.badlogic.gdx.backends.android.AndroidFragmentApplication
import com.taticamanager.tatica_manager.matchgdx.LibGdxMatchPitchFactory
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.PrintWriter
import java.io.StringWriter
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class MainActivity : FlutterFragmentActivity(), AndroidFragmentApplication.Callbacks {
    private val channelName = "tatica_manager/diagnostics"
    private val nativeCrashFile by lazy { File(filesDir, "diagnostic_native_last.txt") }

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        installNativeCrashRecorder()
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "tatica_manager/libgdx_match_pitch",
            LibGdxMatchPitchFactory(this, flutterEngine.dartExecutor.binaryMessenger),
        )
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "deviceInfo" -> result.success(buildDeviceInfo())
                "clearNative" -> {
                    if (nativeCrashFile.exists()) nativeCrashFile.delete()
                    result.success(null)
                }
                "exportTxt" -> {
                    val contents = call.argument<String>("contents").orEmpty()
                    val fileName = call.argument<String>("fileName") ?: "tatica-manager-diagnostico.txt"
                    try { result.success(exportTxt(contents, fileName)) } catch (error: Throwable) { result.error("EXPORT_FAILED", error.message, null) }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun installNativeCrashRecorder() {
        val previous = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
            try {
                val stack = StringWriter().also { throwable.printStackTrace(PrintWriter(it)) }.toString()
                nativeCrashFile.writeText("${Date()} • ${thread.name}\n$stack")
            } catch (_: Throwable) {}
            previous?.uncaughtException(thread, throwable)
        }
    }

    private fun buildDeviceInfo(): Map<String, Any?> {
        val data = linkedMapOf<String, Any?>(
            "manufacturer" to Build.MANUFACTURER,
            "model" to Build.MODEL,
            "android" to Build.VERSION.RELEASE,
            "sdk" to Build.VERSION.SDK_INT,
            "abis" to Build.SUPPORTED_ABIS.joinToString(", "),
            "nativeCrash" to if (nativeCrashFile.exists()) nativeCrashFile.readText().take(24000) else null,
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val manager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            val exit = manager.getHistoricalProcessExitReasons(packageName, 0, 1).firstOrNull()
            if (exit != null) {
                data["lastExit"] = exitReason(exit.reason)
                data["lastExitTimestamp"] = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ", Locale.ROOT).format(Date(exit.timestamp))
                data["lastExitDescription"] = exit.description
                data["lastExitTrace"] = try { exit.traceInputStream?.bufferedReader()?.use { it.readText().take(24000) } } catch (_: Throwable) { null }
            }
        }
        return data
    }

    private fun exitReason(reason: Int): String = when (reason) {
        0 -> "UNKNOWN"
        1 -> "EXIT_SELF"
        2 -> "SIGNALED"
        3 -> "LOW_MEMORY"
        4 -> "CRASH"
        5 -> "CRASH_NATIVE"
        6 -> "ANR"
        7 -> "INITIALIZATION_FAILURE"
        8 -> "PERMISSION_CHANGE"
        9 -> "EXCESSIVE_RESOURCE_USAGE"
        10 -> "USER_REQUESTED"
        11 -> "USER_STOPPED"
        12 -> "DEPENDENCY_DIED"
        13 -> "OTHER"
        14 -> "FREEZER"
        15 -> "PACKAGE_STATE_CHANGE"
        16 -> "PACKAGE_UPDATED"
        else -> "REASON_$reason"
    }

    private fun exportTxt(contents: String, fileName: String): String {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val values = ContentValues().apply {
                put(MediaStore.Downloads.DISPLAY_NAME, fileName)
                put(MediaStore.Downloads.MIME_TYPE, "text/plain")
                put(MediaStore.Downloads.RELATIVE_PATH, "${Environment.DIRECTORY_DOWNLOADS}/TaticaManager")
            }
            val uri = contentResolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                ?: error("Não foi possível criar o arquivo")
            contentResolver.openOutputStream(uri)?.bufferedWriter()?.use { it.write(contents) }
                ?: error("Não foi possível abrir o destino")
            "Downloads/TaticaManager/$fileName"
        } else {
            val root = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
            val folder = File(root, "TaticaManager").apply { mkdirs() }
            File(folder, fileName).apply { writeText(contents) }.absolutePath
        }
    }
    override fun exit() {
        // libGDX is embedded only as the match renderer. Flutter owns navigation.
    }

}
