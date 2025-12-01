package plugin.cxhub_sdk

import android.util.Log
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import cxhub.api.NotificationFactory
import cxhub.api.PlatformManager


class CxHubSdkFirebaseMessagingService : FirebaseMessagingService() {
    override fun onMessageReceived(message: RemoteMessage) {
        super.onMessageReceived(message)
        val data = message.data

        if (isCurrentPlatform()) {
            NotificationFactory.deliverPushMessageIntent(this, data)
        } else {
            Log.w(LOG_TAG, "Ignore message with data $data")
        }

        NotificationFactory.deliverPushMessageIntent(this, data)
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
        NotificationFactory.getPlatformName() == PlatformManager.PLATFORM_FIREBASE

    companion object {
        private const val LOG_TAG = "CxHubSdkFirebaseMessagingService"
    }
}