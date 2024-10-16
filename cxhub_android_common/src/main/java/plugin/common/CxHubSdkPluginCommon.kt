package plugin.common

import android.content.Context
import android.util.Log
import core.api.BackgroundAwakeMode
import core.api.NetworkSyncMode
import cxhub.api.NotificationApi.PushTokenListener
import cxhub.api.NotificationFactory
import cxhub.api.PlatformManager
import cxhub.api.UserProperty
import cxhub.api.UserPropertyApi
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch

class CxHubSdkPluginCommon(
    flutterPluginBinding: FlutterPluginBinding,
    manager: PlatformManager
) : MethodCallHandler {
    private val channel: MethodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "cxhub_sdk")
    private val context: Context = flutterPluginBinding.applicationContext

    init {
        channel.setMethodCallHandler(this)

        NotificationFactory.setPlatformManagers(manager)
        NotificationFactory.initialize(context)
        NotificationFactory.setBackgroundAwakeMode(BackgroundAwakeMode.DEFAULT)
        NotificationFactory.setNetworkSyncMode(NetworkSyncMode.DEFAULT)

        NotificationFactory.setPushListener { eventType, pushId, message ->
            Log.d("CxhHubFirebase", "CxHubPushListener $eventType $pushId" + "\nobj ${message?.obj}")
        }

        NotificationFactory.bootstrap(context)
    }

    private var pushListener: PushTokenListener? = null

    @Suppress("UNCHECKED_CAST")
    override fun onMethodCall(call: MethodCall, result: Result) {
        try {
            val api = NotificationFactory.get(context)
            val version = "Android ${android.os.Build.VERSION.RELEASE} firebase impl\nmobileId: ${api.mobileInstance}"

            when (call.method) {
                "getPlatformVersion" -> result.success(version)

                "getMobileInstance" -> result.success(api.mobileInstance)

                "getPushToken" -> {
                    api.getPushToken { token ->
                        MainScope().launch {
                            channel.invokeMethod(
                                "emitPushToken",
                                token,
                                ResultCallback("CxHubSdkPlugin", "emitPushToken")
                            )
                        }
                    }

                    // чтобы отработать асинк мы возвращаем успех сразу,
                    // потом лисенер дернет инвок и мы получим результат по каналу
                    result.success(true)
                }

                "subscribeToPushToken" -> {
                    if (pushListener != null) {
                        result.error("001", "Already listening to push token!", null)
                    } else {
                        pushListener = PushTokenListener {
                            MainScope().launch {
                                channel.invokeMethod(
                                    "emitPushTokenSub",
                                    it,
                                    ResultCallback("CxHubSdkPlugin", "emitPushTokenSub")
                                )
                            }
                        }

                        api.subscribeToPushToken(pushListener!!)
                        result.success(true)
                    }
                }

                "unsubscribeToPushToken" -> {
                    if (pushListener != null)
                        api.unsubscribeToPushToken(pushListener!!)

                    pushListener = null
                    result.success(true)
                }

                "getUserId" -> {
                    api.getLastUserId { idType, idValue ->
                        MainScope().launch {
                            channel.invokeMethod(
                                "emitUserId",
                                mapOf("idType" to idType, "idValue" to idValue!!),
                                ResultCallback("CxHubPlugin", "getUserId")
                            )
                        }
                    }

                    result.success(true)
                }

                "setUserId" -> {
                    val map = call.arguments as Map<String, Any>
                    api.setUserId(map["idType"]!!.toString(), map["idValue"]!!.toString(), map["synchronous"]!! as Boolean)

                    result.success(true)
                }

                "setUserProperties" -> {
                    val map = call.arguments!! as Map<String, String>
                    val listener = object : UserPropertyApi.OnResultListener {
                        override fun onSuccess() {
                            MainScope().launch {
                                channel.invokeMethod(
                                    "emitSetPropsResult",
                                    null,
                                    ResultCallback("CxHubPlugin", "emitSetPropsResult")
                                )
                            }
                        }

                        override fun onFailed(t: Throwable) {
                            MainScope().launch {
                                channel.invokeMethod(
                                    "emitSetPropsResult",
                                    mapOf(
                                        "message" to t.message,
                                        "cause" to t.cause?.message
                                    ),
                                    ResultCallback("CxHubPlugin", "emitSetPropsResult")
                                )
                            }
                        }
                    }

                    api.setUserProperty(map.entries.map { UserProperty(it.key, it.value) } as MutableList, listener)
                    result.success(true)
                }

                "collectEvent" -> {
                    val map = call.arguments!! as Map<String, Any>
                    val key = map["key"] as String
                    val deliverImmediately = map["deliverImmediately"] as Boolean
                    val value = map["value"] as String?
                    val properties = map["properties"] as Map<String, String>?

                    if (value == null && properties == null)
                        api.collectEvent(key, deliverImmediately)
                    else if (value == null)
                        api.collectEvent(key, properties!!, deliverImmediately)
                    else if (properties == null)
                        api.collectEvent(key, value, deliverImmediately)
                    else
                        api.collectEvent(key, value, properties, deliverImmediately)

                    result.success(true)
                }

                else -> result.notImplemented()
            }
        } catch (t: Throwable) {
            result.error("002", t.message, t.cause?.message)
        }
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
    }
}

class ResultCallback(private val tag: String, private val method: String) : Result {
    override fun success(result: Any?) {
        Log.d(tag, "$method(): $result")
    }

    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        Log.d(tag, "$method() error code: $errorCode")
        Log.d(tag, "$method() error message: $errorMessage")
        Log.d(tag, "$method() error details: $errorDetails")
    }

    override fun notImplemented() {
        Log.d(tag, "$method() notImplemented")
    }
}
