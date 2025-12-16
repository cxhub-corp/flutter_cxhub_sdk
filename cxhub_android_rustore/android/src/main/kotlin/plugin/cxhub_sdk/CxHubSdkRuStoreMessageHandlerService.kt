package plugin.cxhub_sdk

import android.util.Log
import org.json.JSONObject
import ru.rustore.sdk.pushclient.messaging.exception.RuStorePushClientException
import ru.rustore.sdk.pushclient.messaging.model.RemoteMessage
import ru.rustore.sdk.pushclient.messaging.service.RuStoreMessagingService
import cxhub.api.NotificationFactory
import cxhub.api.PlatformManager

class CxHubSdkRuStoreMessageHandlerService: RuStoreMessagingService() {
    override fun onNewToken(token: String) {
        if (isCurrentPlatform()) {
            Log.v(LOG_TAG, "token refresh. onNewToken: $token")
            NotificationFactory.refreshPushToken(this)
        } else {
            Log.w(LOG_TAG, "Ignore refresh token : $token")
        }
    }

    override fun onMessageReceived(message: RemoteMessage) {
        val data = message.data
        val dataStr = data["data"]
        if (dataStr.isNullOrEmpty()) {
            Log.d(LOG_TAG, "Remote message is null or empty, ignore")
            return
        }
        val dataMap = JSONObject(dataStr).toMap()

        if (isCurrentPlatform()) {
            Log.d(LOG_TAG, String.format("onMessageReceived deliver with %s", data))
            NotificationFactory.deliverPushMessageIntent(this, dataMap)
        } else {
            Log.w(LOG_TAG, "Ignore message with data $data")
        }
    }

    private fun isCurrentPlatform() =
        NotificationFactory.getPlatformName() == PlatformManager.PLATFORM_RUSTORE
    private fun JSONObject.toMap(): Map<String, String> =
        keys().asSequence().associateWith { this[it].toString() }

    override fun onError(errors: List<RuStorePushClientException>) {
        errors.forEach { error -> error.printStackTrace() }
    }

    override fun onDeletedMessages() { }

    companion object {
        private const val LOG_TAG = "CxHubSdkRuStoreMessageHandlerService"
    }
}