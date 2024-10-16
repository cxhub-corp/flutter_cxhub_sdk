package plugin.cxhub_sdk

import cxhub.api.FirebasePlatformManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import plugin.common.CxHubSdkPluginCommon

/** CxhubSdkPlugin */
class CxHubSdkPluginFirebase : FlutterPlugin {
    private lateinit var pluginCommon: CxHubSdkPluginCommon

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        pluginCommon = CxHubSdkPluginCommon(flutterPluginBinding, FirebasePlatformManager.getInstance())
    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        pluginCommon.dispose()
    }
}