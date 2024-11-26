package plugin.cxhub_sdk

import android.app.Application
import android.util.Log
import cxhub.api.FirebasePlatformManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import plugin.cxhub_sdk.CxHubSdkPluginCommon

/** CxhubSdkPlugin */
class CxHubSdkPluginFirebase : FlutterPlugin {
    private lateinit var pluginCommon: CxHubSdkPluginCommon
    
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        pluginCommon = CxHubSdkPluginCommon(flutterPluginBinding) {
            FirebasePlatformManager.getInstance()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        pluginCommon.dispose()
    }
}