package plugin.cxhub_sdk

import android.util.Log
import org.json.JSONObject
import ru.rustore.sdk.pushclient.messaging.exception.RuStorePushClientException
import ru.rustore.sdk.pushclient.messaging.model.RemoteMessage
import ru.rustore.sdk.pushclient.messaging.service.RuStoreMessagingService

class CxHubSdkRuStoreMessageHandlerService: RuStoreMessagingService() {
    override fun onNewToken(token: String) {
        Log.d(LOG_TAG, "onNewToken token = $token")
        PlatformInternalFactory.getMessageHandler()?.onNewToken(this, token)
    }

    override fun onMessageReceived(message: RemoteMessage) {
        val data = message.data
        Log.d(LOG_TAG, String.format("onMessageReceived with %s", data))

        val dataStr = data["data"]
        if (dataStr.isNullOrEmpty()) {
            Log.d(LOG_TAG, "Remote message is null or empty, ignore")
            return
        }
        val dataMap = JSONObject(dataStr).toMap()
        PlatformInternalFactory.getMessageHandler()?.onMessageReceived(this, dataMap)
    }

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