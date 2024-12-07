//
//  NotificationService.swift
//  ServiceExtension
//
//  Created by Vladimir Kukhar on 07.12.2024.
//

import UserNotifications
import cxhub_ios
import CXHubCore
import CXHubNotify

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    private var apiIsInitialized :  Bool = false
    
    override init() {
        apiIsInitialized = CxhubSdkPlugin.initCXHubSDK()
    }
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            //bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
            
            if apiIsInitialized {
                if CxhubSdkPlugin.didReceive(request, withContentHandler: contentHandler) {
                    return
                }
                else {
                    contentHandler(bestAttemptContent)
                }
            }
            
            else {
                contentHandler(bestAttemptContent)
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            if apiIsInitialized {
                if CxhubSdkPlugin.serviceExtensionTimeWillExpire() {
                    return
                }
                else {
                    contentHandler(bestAttemptContent)
                }
            }
            
            else {
                contentHandler(bestAttemptContent)
            }
        }
    }
    
}
