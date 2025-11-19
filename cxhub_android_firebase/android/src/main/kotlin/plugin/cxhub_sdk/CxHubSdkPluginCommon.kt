package plugin.cxhub_sdk

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.edit
import core.api.BackgroundAwakeMode
import core.api.NetworkSyncMode
import cxhub.api.NotificationApi.PushTokenListener
import cxhub.api.NotificationFactory
import cxhub.api.PlatformManager
import cxhub.api.UserProperty
import cxhub.api.UserPropertyApi
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import kotlin.math.log


const val PREFS_NAME = "CxHubSdkPluginPrefs"
const val PERMISSION_KEY = "POST_NOTIFICATION_REQUESTED"
const val REQUEST_CODE = 223322

class CxHubSdkPluginCommon(
    flutterPluginBinding: FlutterPluginBinding,
    val managerFactory: (String?) -> PlatformManager
) : MethodCallHandler {
    private val channel: MethodChannel =
        MethodChannel(flutterPluginBinding.binaryMessenger, "cxhub_sdk")
    private val context: Context = flutterPluginBinding.applicationContext
    private var manager: PlatformManager? = null
    var activityBinding: ActivityPluginBinding? = null

    init {
        channel.setMethodCallHandler(this)
    }

    fun initSdk(param: String?) {
        Log.d("CxhHubSdkPlugin","init CxHubFirebase implementation...")
        manager = managerFactory.invoke(param)
        NotificationFactory.setPlatformManagers(manager)
        NotificationFactory.initialize(context)
        NotificationFactory.setBackgroundAwakeMode(BackgroundAwakeMode.DEFAULT)
        NotificationFactory.setNetworkSyncMode(NetworkSyncMode.DEFAULT)

        NotificationFactory.setPushListener { eventType, pushId, message ->
            Log.d(
                "CxhHubFirebase",
                "CxHubPushListener $eventType $pushId" + "\nobj ${message?.obj}"
            )
        }

        NotificationFactory.bootstrap(context)
        Log.d("CxhHubSdkPlugin","CxHubFirebasePlugin inited")
    }

    private var pushListener: PushTokenListener? = null


    @SuppressLint("InlinedApi")
    @Suppress("UNCHECKED_CAST")
    override fun onMethodCall(call: MethodCall, result: Result) {
        try {
            if (manager == null && call.method != "init") {
                result.error("001", "CxHubSdk not initialized! Run init() first!", null)
                return
            }

            val api = NotificationFactory.get(context)

            when (call.method) {
                "init" -> {
                    initSdk(call.arguments?.toString())
                }

                "getPlatformVersion" -> {
                    val version = "${manager?.name} impl"
                    result.success(version)
                }

                "getMobileInstance" -> result.success(api.mobileInstance)

                "getPushToken" -> {
                    api.getPushToken { token ->
                        MainScope().launch {
                            if (token == null)
                                Log.d("CxHubSdkPlugin", "token is null")

                            token?.let {
                                channel.invokeMethod(
                                    "emitPushToken",
                                    token,
                                    ResultCallback("CxHubSdkPlugin", "emitPushToken")
                                )
                            }
                        }
                    }

                    // чтобы отработать асинк мы возвращаем успех сразу,
                    // потом лисенер дернет инвок и мы получим результат, но не как результат вызова, а как вызов
                    result.success(true)
                }

                "subscribeToPushToken" -> {
                    if (pushListener != null) {
                        result.error("002", "Already listening to push token!", null)
                    } else {
                        pushListener = PushTokenListener {
                            MainScope().launch {
                                if (it == null)
                                    Log.d("CxHubSdkPlugin", "token is null")

                                it?.let {
                                    channel.invokeMethod(
                                        "emitPushTokenSub",
                                        it,
                                        ResultCallback("CxHubSdkPlugin", "emitPushTokenSub")
                                    )
                                }
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
                    api.setUserId(
                        map["idType"]!!.toString(),
                        map["idValue"]!!.toString(),
                        map["synchronous"]!! as Boolean
                    )

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

                    api.setUserProperty(
                        map.entries.map { UserProperty(it.key, it.value) },
                        listener
                    )
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

                "requestPermission" -> {
                    val sharedPreferences =
                        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

                    val wasRequested = sharedPreferences.getBoolean(PERMISSION_KEY, false)

                    val isGranted = Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
                            ContextCompat.checkSelfPermission(
                                context,
                                Manifest.permission.POST_NOTIFICATIONS
                            ) == PackageManager.PERMISSION_GRANTED

                    if (isGranted) {
                        MainScope().launch {
                            channel.invokeMethod(
                                "emitPermissionResult",
                                "granted",
                                ResultCallback("CxHubPlugin", "emitPermissionResult")
                            )
                        }

                        result.success(true)
                        return
                    }


                    val isNeedRationale = activityBinding?.let {
                        ActivityCompat.shouldShowRequestPermissionRationale(
                            it.activity, Manifest.permission.POST_NOTIFICATIONS
                        )
                    } ?: false

                    if (!isNeedRationale && wasRequested) {
                        MainScope().launch {
                            channel.invokeMethod(
                                "emitPermissionResult",
                                "denied",
                                ResultCallback("CxHubPlugin", "emitPermissionResult")
                            )
                        }

                        result.success(true)
                        return
                    }

                    val listener = { requestCode: Int, _: Array<String>, results: IntArray ->
                        if (requestCode != REQUEST_CODE)
                            false
                        else {
                            sharedPreferences.edit {
                                putBoolean(PERMISSION_KEY, true)
                                apply()
                            }

                            if (
                                results.isNotEmpty() &&
                                results[0] == PackageManager.PERMISSION_GRANTED
                            ) {
                                channel.invokeMethod(
                                    "emitPermissionResult",
                                    "granted",
                                    ResultCallback("CxHubPlugin", "emitPermissionResult")
                                )
                            } else {
                                val needRationale =
                                    ActivityCompat.shouldShowRequestPermissionRationale(
                                        activityBinding?.activity!!,
                                        Manifest.permission.POST_NOTIFICATIONS
                                    )

                                MainScope().launch {
                                    channel.invokeMethod(
                                        "emitPermissionResult",
                                        if (needRationale) "unknown" else "denied",
                                        ResultCallback("CxHubPlugin", "emitPermissionResult")
                                    )
                                }
                            }

                            true
                        }
                    }

                    activityBinding?.addRequestPermissionsResultListener(listener)

                    activityBinding?.activity?.requestPermissions(
                        arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                        REQUEST_CODE
                    )

                    result.success(true)
                }

                "checkPermission" -> {
                    val sharedPreferences =
                        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

                    val wasRequested = sharedPreferences.getBoolean(PERMISSION_KEY, false)

                    val isGranted = Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
                            ContextCompat.checkSelfPermission(
                                context,
                                Manifest.permission.POST_NOTIFICATIONS
                            ) == PackageManager.PERMISSION_GRANTED

                    val isNeedRationale = activityBinding?.let {
                        ActivityCompat.shouldShowRequestPermissionRationale(
                            it.activity, Manifest.permission.POST_NOTIFICATIONS
                        )
                    } ?: false

                    MainScope().launch {
                        channel.invokeMethod(
                            "emitCheckResult",
                            if (isGranted) "granted" else if (isNeedRationale || !wasRequested) "unknown" else "denied",
                            ResultCallback("CxHubPlugin", "emitCheckResult")
                        )
                    }

                    result.success(true)
                }

                else -> result.notImplemented()
            }
        } catch (t: Throwable) {
            result.error("003", t.message, t.cause?.message)
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
