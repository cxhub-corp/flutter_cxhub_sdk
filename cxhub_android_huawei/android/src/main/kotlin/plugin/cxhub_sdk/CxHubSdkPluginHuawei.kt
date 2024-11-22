package plugin.cxhub_sdk

import cxhub.api.HuaweiPlatformManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import plugin.cxhub_sdk.CxHubSdkPluginCommon

/** CxhubSdkPlugin */
class CxHubSdkPluginHuawei : FlutterPlugin {
  private lateinit var pluginCommon: CxHubSdkPluginCommon

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    pluginCommon = CxHubSdkPluginCommon(flutterPluginBinding, HuaweiPlatformManager.getInstance())
  }


  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    pluginCommon.dispose()
  }
}
