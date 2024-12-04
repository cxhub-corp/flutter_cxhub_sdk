//
//  CHubSDKAPIBridge.swift
//  cxhub_ios
//
//  Created by Vladimir Kukhar on 04.12.2024.
//

import Foundation
import CXHubCore
import CXHubNotify


open class CXHubSDKAPIBridge  {
    static var getInstance: CXNotifyApi {
        let instanceSelector = NSSelectorFromString("getInstance")
        guard CXNotify.responds(to: instanceSelector) else {
            fatalError("[Extensions can't access getInstance()]")
        }
        let instance = CXNotify.perform(instanceSelector)
        return instance?.takeUnretainedValue() as! CXNotifyApi
    }
    
    static var getExtensionInstance: CXNotifyExtensionApi {
        let instanceSelector = NSSelectorFromString("getExtensionInstance")
        guard CXNotify.responds(to: instanceSelector) else {
            fatalError("[App shouldn't access getExtensionInstance()]")
        }
        let instance = CXNotify.perform(instanceSelector)
        return instance?.takeUnretainedValue() as! CXNotifyExtensionApi
    }
    
    @objc public class func initWith( config: CXAppConfig, eventsReceiver:  CXUnhandledErrorReceiver?) -> Bool {
        var initSelector : Selector = NSSelectorFromString("initWith(config:eventsReceiver:)")
        if Bundle.main.bundlePath.hasSuffix(".appex") {
            initSelector = NSSelectorFromString("initExtensionWith(config:eventsReceiver:)")
        }
        guard CXApp.responds(to: initSelector) else {
            fatalError("[Extensions can't access initWith: eventsReceiver:]")
        }
        guard let result = CXApp.perform(initSelector) else {
            return false
        }
        
        return true
    }
}
