package plugin.cxhub_sdk

import android.util.Log
import com.huawei.hms.push.HmsMessageService
import com.huawei.hms.push.RemoteMessage
import cxhub.api.NotificationFactory
import cxhub.api.PlatformManager

class CxSdkHmsMessageService : HmsMessageService() {
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        val data = remoteMessage.dataOfMap
        Log.d(LOG_TAG, String.format("onMessageReceived with %s", data))
        //!!!
        PlatformInternalFactory.getMessageHandler()?.onMessageReceived(this, data)
    }

    override fun onNewToken(token: String) {
        Log.d(LOG_TAG, String.format("onNewToken %s", token))
        //!!!
        PlatformInternalFactory.getMessageHandler()?.onNewToken(this, token)
    }

    override fun onDestroy() {
        Log.v(LOG_TAG, "service destroyed")
    }

    companion object {
        private const val LOG_TAG = "CxHubSdkHmsMessageService"
    }
}