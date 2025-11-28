package plugin.cxhub_sdk

import android.util.Log
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import cxhub.api.PlatformInternalFactory


class CxHubSdkFirebaseMessagingService : FirebaseMessagingService() {
    override fun onMessageReceived(message: RemoteMessage) {
        val data = message.getData()

        Log.d(LOG_TAG, String.format("onMessageReceived with %s", data))
        //!!!
        PlatformInternalFactory.getMessageHandler()?.onMessageReceived(this, data)
    }

    override fun onNewToken(token: String) {
        Log.d(LOG_TAG, String.format("onNewToken %s", token))
        //!!!
        PlatformInternalFactory.getMessageHandler()?.onNewToken(this, token)
    }



    companion object {
        private const val LOG_TAG = "CxHubSdkFirebaseMessagingService"
    }
}