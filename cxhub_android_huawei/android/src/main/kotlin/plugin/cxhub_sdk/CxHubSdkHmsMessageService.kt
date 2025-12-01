package plugin.cxhub_sdk

import android.util.Log
import com.huawei.hms.push.HmsMessageService
import com.huawei.hms.push.RemoteMessage
import cxhub.api.NotificationFactory
import cxhub.api.PlatformManager

class CxSdkHmsMessageService : HmsMessageService() {
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)
        val data = remoteMessage.dataOfMap
        if (isCurrentPlatform()) {
            NotificationFactory.deliverPushMessageIntent(this, data)
        } else {
            Log.w(LOG_TAG, "Ignore message with data $data")
        }
    }

    override fun onNewToken(token: String) {
        if (isCurrentPlatform()) {
            Log.v(LOG_TAG, "token refresh. onNewToken: $token")
            NotificationFactory.refreshPushToken(this)
        } else {
            Log.w(LOG_TAG, "Ignore refresh token : $token")
        }
    }

    private fun isCurrentPlatform() =
        NotificationFactory.getPlatformName() == PlatformManager.PLATFORM_HUAWEI
    override fun onDestroy() {
        Log.v(LOG_TAG, "service destroyed")
    }

    companion object {
        private const val LOG_TAG = "CxHubSdkHmsMessageService"
    }
}