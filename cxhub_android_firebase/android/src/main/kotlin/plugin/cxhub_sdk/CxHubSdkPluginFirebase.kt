package plugin.cxhub_sdk

import cxhub.api.FirebasePlatformManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding


/** CxhubSdkPlugin */
class CxHubSdkPluginFirebase : FlutterPlugin, ActivityAware {
    private lateinit var pluginCommon: CxHubSdkPluginCommon
    
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPluginBinding) {

        pluginCommon = CxHubSdkPluginCommon(flutterPluginBinding) {
            FirebasePlatformManager.getInstance()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        pluginCommon.dispose()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        pluginCommon.activityBinding = binding
    }

    override fun onDetachedFromActivityForConfigChanges() {
        pluginCommon.activityBinding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        pluginCommon.activityBinding = binding
    }

    override fun onDetachedFromActivity() {
        pluginCommon.activityBinding = null
    }
}