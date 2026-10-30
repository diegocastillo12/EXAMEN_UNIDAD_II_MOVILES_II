package com.example.flutter_application_entrehuellas

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.RenderMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.flutter_application_entrehuellas.security.OfflineListCipher
import com.example.flutter_application_entrehuellas.security.SecureScreenProtection
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    // Flutter pixels share the secure window instead of a separate SurfaceView.
    override fun getRenderMode(): RenderMode = RenderMode.texture
    private val cryptoExecutor = Executors.newSingleThreadExecutor()
    private val offlineCipher by lazy { OfflineListCipher() }
    private val screenProtection by lazy { SecureScreenProtection(this) }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "entrehuellas/screen-protection")
            .setMethodCallHandler { call, result ->
                if (call.method != "setProtected") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val token = call.argument<String>("token")
                val enabled = call.argument<Boolean>("enabled")
                if (token == null || enabled == null) {
                    result.error("invalid_input", "Pantalla no disponible", null)
                    return@setMethodCallHandler
                }
                try {
                    screenProtection.setProtected(token, enabled)
                    result.success(null)
                } catch (_: Exception) {
                    screenProtection.setProtected(token, false)
                    result.error("protection_failed", "Pantalla no disponible", null)
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "entrehuellas/offline-list-cipher")
            .setMethodCallHandler { call, result ->
                if (call.method !in listOf("encrypt", "decrypt", "deleteKeys")) {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val owner = call.argument<String>("owner")
                val data = call.argument<ByteArray>("data")
                if (call.method != "deleteKeys" && (owner == null || data == null)) {
                    result.error("invalid_input", "Datos locales no disponibles", null)
                    return@setMethodCallHandler
                }
                cryptoExecutor.execute {
                    try {
                        val output = when (call.method) {
                            "deleteKeys" -> { offlineCipher.deleteKeys(); null }
                            "encrypt" -> offlineCipher.encrypt(owner!!, data!!)
                            else -> offlineCipher.decrypt(owner!!, data!!)
                        }
                        runOnUiThread { result.success(output) }
                    } catch (_: Exception) {
                        runOnUiThread { result.error("offline_crypto_failed", "Datos locales no disponibles", null) }
                    }
                }
            }
    }

    override fun onDestroy() {
        cryptoExecutor.shutdown()
        super.onDestroy()
    }

    override fun onUserLeaveHint() {
        screenProtection.onBackground()
        super.onUserLeaveHint()
    }

    override fun onPause() {
        screenProtection.onBackground()
        super.onPause()
    }

    override fun onResume() {
        super.onResume()
        screenProtection.onForeground()
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        screenProtection.onFocusChanged(hasFocus)
    }
}
