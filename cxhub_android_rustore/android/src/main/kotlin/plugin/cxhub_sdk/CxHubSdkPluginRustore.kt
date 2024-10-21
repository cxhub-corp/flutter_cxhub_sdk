package plugin.cxhub_sdk

import cxhub.api.RuStorePlatformManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import plugin.common.CxHubSdkPluginCommon

/** CxhubSdkPlugin */
class CxHubSdkPluginRuStore : FlutterPlugin {
    private lateinit var pluginCommon: CxHubSdkPluginCommon

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        pluginCommon = CxHubSdkPluginCommon(flutterPluginBinding, RuStorePlatformManager.getInstance())
    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        pluginCommon.dispose()
    }
}