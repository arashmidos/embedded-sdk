package com.example.sample_outline_sdk

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

import mobileproxy.Mobileproxy
import mobileproxy.Proxy

class MainActivity : FlutterActivity() {
  private var proxy: Proxy? = null
  private var port: String? = null
  private var key: String? = null
  private val CHANNEL = "sample.example.com/proxy"

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler(
      { call, result ->
        if (call.method == "startOutlineProxy") {
          startOutlineProxy(call, result)
        } else if (call.method == "stopOutlineProxy") {
          stopOutlineProxy(result)
        } else {
          result.notImplemented()
        }
      }
    )
  }

  private fun startOutlineProxy(call: MethodCall, result: MethodChannel.Result) {
    try {
      key = call.argument("key")
      port = call.argument("port")
      proxy = Mobileproxy.runProxy("localhost:" + port, Mobileproxy.newStreamDialerFromConfig(key))
      result.success("${proxy?.address()}")
    } catch (e: Exception) {
      // Handle different exception like address already in use or other exceptions
    }
  }

  private fun stopOutlineProxy(result: MethodChannel.Result) {
    if (proxy != null) {
      proxy?.stop(0)
      result.success("Proxy stopped successfully")
    } else {
      result.error("ProxyNotSet", "Proxy not set", null)
    }
  }

  // stop proxy when app is destroyed
  override fun onDestroy() {
    if (proxy != null) {
      proxy?.stop(0)
    }
    super.onDestroy()
  }
}
