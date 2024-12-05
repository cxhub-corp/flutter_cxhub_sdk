package plugin.cxhub_sdk

import cxhub.api.RuStorePlatformManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import plugin.cxhub_sdk.CxHubSdkPluginCommon
import ru.rustore.sdk.pushclient.RuStorePushClient;

/** CxhubSdkPlugin */
class CxHubSdkPluginRuStore : FlutterPlugin {
    private lateinit var pluginCommon: CxHubSdkPluginCommon

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        pluginCommon = CxHubSdkPluginCommon(flutterPluginBinding) {
            RuStorePushClient.INSTANCE.init(flutterPluginBinding.applicationContext as Application, it)
            RuStorePlatformManager.getInstance()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        pluginCommon.dispose()
    }
}