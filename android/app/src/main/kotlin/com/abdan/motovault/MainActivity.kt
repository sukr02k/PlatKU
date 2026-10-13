package com.abdan.motovault

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val channelName = "com.abdan.motovault/backup"
    private val pickDbRequestCode = 9401
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "pickBackupFile" -> {
                        if (pendingResult != null) {
                            result.error("BUSY", "File picker sedang aktif", null)
                            return@setMethodCallHandler
                        }
                        pendingResult = result
                        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                            addCategory(Intent.CATEGORY_OPENABLE)
                            type = "*/*"
                        }
                        startActivityForResult(intent, pickDbRequestCode)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == pickDbRequestCode) {
            val res = pendingResult
            pendingResult = null
            if (res == null) return

            if (resultCode == Activity.RESULT_OK && data?.data != null) {
                val uri = data.data!!
                try {
                    val tempFile = File(cacheDir, "imported_motovault_backup.db")
                    contentResolver.openInputStream(uri)?.use { input ->
                        FileOutputStream(tempFile).use { output ->
                            input.copyTo(output)
                        }
                    }
                    res.success(tempFile.absolutePath)
                } catch (e: Exception) {
                    res.error("IO_ERROR", "Gagal membaca file: ${e.message}", null)
                }
            } else {
                res.success(null)
            }
        }
    }
}
