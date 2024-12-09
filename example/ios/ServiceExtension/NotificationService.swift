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
