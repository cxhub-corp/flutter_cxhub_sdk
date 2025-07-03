import Flutter
import UIKit
import UserNotifications
import UserNotificationsUI
import CXHubCore
import CXHubNotify
import Dispatch

public class CxhubSdkPlugin: NSObject, FlutterPlugin, FlutterApplicationLifeCycleDelegate, UIApplicationDelegate {
    
    public static var _channel : FlutterMethodChannel?
    @objc dynamic var deviceToken : String = ""
    public static let instance = CxhubSdkPlugin()
    public static var apiIsInitialized :  Bool = false
    public var bigContentImage: UIImageView?
    var extensionContext: NSExtensionContext?
    
    var deviceTokenObserver: NSKeyValueObservation?
    var isEmitPushToken: Bool = false
    var isSubscribeToPushToken: Bool = false
    
    override init() {
        super.init()
        if !CxhubSdkPlugin.apiIsInitialized {CxhubSdkPlugin.apiIsInitialized = CxhubSdkPlugin.initCXHubSDK()}
        if !Bundle.main.bundlePath.hasSuffix(".appex") {
            self.deviceTokenObserver = self.observe(\.deviceToken, options: .new, changeHandler: { (self, change) in
                guard let newValue = change.newValue else {return}
                if newValue != "" {
                    DispatchQueue.main.async {
                        if self.isEmitPushToken {
                            CxhubSdkPlugin._channel!.invokeMethod("emitPushToken", arguments: self.deviceToken)
                            self.isEmitPushToken = false
                        }
                        if self.isSubscribeToPushToken {
                            CxhubSdkPlugin._channel!.invokeMethod("emitPushTokenSub", arguments: self.deviceToken)
                        }
                    }
                }
            })
        }
    }
    
    deinit {
        deviceTokenObserver?.invalidate()
    }
    
    /* - Test channel messaging
    private func emitSubGeneratorTest () {
        self.tokenPrefix = self.tokenPrefix + 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let newToken = "\(self.tokenPrefix)_" + self.deviceToken
            CxhubSdkPlugin._channel!.invokeMethod("emitPushTokenSub", arguments: newToken)
            self.emitSubGeneratorTest()
        }
    }
    */
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        _channel = FlutterMethodChannel(name: "cxhub_sdk", binaryMessenger: registrar.messenger())
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = instance
        
        if !CxhubSdkPlugin.apiIsInitialized {CxhubSdkPlugin.apiIsInitialized = CxhubSdkPlugin.initCXHubSDK()}
        
        if !Bundle.main.bundlePath.hasSuffix(".appex") {
            //instance.addObservers() - deprecated
            if apiIsInitialized {
                CXHubSDKAPIBridge.getInstance.setDelegate(instance)
            }
        }
    
        //CXApp.setUnhandledErrorReceiver(NotifyHandler())
        //CXApp.setMonitoringEventReceiver(NotifyHandler())
        
        
        
        registrar.addMethodCallDelegate(instance, channel: _channel!)
        
    }
    
    public class func initCXHubSdkWithContentExtensionImage(bigImage: UIImageView) -> Bool {
        apiIsInitialized = CxhubSdkPlugin.initCXHubSDK()
        if apiIsInitialized {
            CxhubSdkPlugin.instance.bigContentImage = bigImage;
            return true
        }
        return false
    }
    
    public class func initCXHubSDK() -> Bool {
        guard let configFile = Bundle.main.path(forResource: "Notify", ofType: "plist") else { fatalError() };
        guard let config = CXAppConfig(config: configFile) else { fatalError() }
        let _apiIsInitialized = CXHubSDKAPIBridge.initWith(config: config, eventsReceiver: nil)
        return _apiIsInitialized
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let application = Application.shared
        switch call.method {
        case "init":
            let message = "CxhubSdkPlugin is initialized"
            result(message)
            break
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
            break
        case "requestPermission":
            self.requestPermission(result: result)
            break
        case "checkPermission":
            self.checkPermission(result: result)
            break
        case "registerForPushNotifications":
            self.registerForPushNotifications(application: application, result: result)
            break
        case "getPushToken":
            self.getPushToken(result: result)
            break
        case "subscribeToPushToken":
            self.subscribeToPushToken(result: result)
            break
        case "unsubscribeToPushToken":
            self.unsubscribeToPushToken(result: result)
            break
        
        case "getMobileInstance":
            self.getMobileInstance(result: result)
            break
        case "getUserId":
            self.getUserId(result: result)
            break
        case "setUserId":
            guard let args = call.arguments as? Dictionary<String, Any> else {return}
            let userIdType : String = args["idType"] as! String
            let userIdValue : String = args["idValue"] as! String
            let synchronous : Bool = args["synchronous"] as! Bool
            self.setUserId(idType: userIdType , idValue: userIdValue, synchronous: synchronous, result: result)
            break
        case "setUserProperties":
            guard let args = call.arguments as? Dictionary<String, Any> else {return}
            var props : Dictionary <String, String> = Dictionary()
            for propKey in args.keys {
                let propValue = args[propKey] as! String
                props[propKey] = propValue
            }
            self.setUserProperties(properties: props, result: result)
            break
        case "collectEvent":
            guard let args = call.arguments as? Dictionary<AnyHashable, Any> else {return}
            let key : String? = args["key"] as? String
            if key != nil {
                let value : String? = args["value"] as? String
                CXHubSDKAPIBridge.getInstance.collectEvent(key!, withValue: (value ?? "") as String as NSObject, withProperties: nil)
                result("Event collected")
                break
            }
            result("Event is not collected. Key is nil!")
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func subscribeToPushToken(result: @escaping FlutterResult) {
        self.isSubscribeToPushToken = true
        self.registerAndRetrievePushToken(result: result)
    }
    
    public func unsubscribeToPushToken(result: @escaping FlutterResult) {
        self.isSubscribeToPushToken = false
        result("Unsubscribe succeeded")
    }

    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        self.deviceToken = token
        CXApp.applicationDidRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }
        
    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        CXApp.applicationDidFailToRegisterForRemoteNotificationsWithError(error)
        self.deviceToken = "Fail to get device token (pushToken)"
    }
    
    
    private func requestPermission(result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    result(FlutterError(code: "PERMISSION_ERROR", message: "Failed to request permissions", details: error.localizedDescription))
                    CxhubSdkPlugin._channel!.invokeMethod("emitPermissionResult", arguments: "unknown")
                    return
                }
                var resultString: String = "unknown"
                
                switch granted {
                case true:
                    resultString = "granted"
                    break
                case false:
                    resultString = "denied"
                    break
                }
                
                CxhubSdkPlugin._channel!.invokeMethod("emitPermissionResult", arguments: resultString)
                result(resultString)
            }
        }
    }
    
    public func checkPermission(result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                var settingsStateString: String = "unknown"
                switch settings.authorizationStatus {
                case .authorized:
                    settingsStateString = "granted"//"authorized"
                    break
                case .ephemeral:
                    settingsStateString = "granted"//"ephemeral"
                    break
                case .provisional:
                    settingsStateString = "granted"//"provisional"
                    break
                case .denied:
                    settingsStateString = "denied"//"denied"
                    break
                default:
                    settingsStateString = "unknown"//"notDetermined"
                    break
                }
                CxhubSdkPlugin._channel!.invokeMethod("emitCheckResult", arguments: settingsStateString)
                result(settingsStateString)
            }
        }
    }
    
    public func registerForPushNotifications(application: UIApplication, result: @escaping FlutterResult) {
        application.registerForRemoteNotifications()
        result("Device Token registration initiated")
    }
    
    public func getPushToken(result: @escaping FlutterResult) {
        self.isEmitPushToken = true
        self.registerAndRetrievePushToken(result: result)
    }
    
    private func registerAndRetrievePushToken(result: @escaping FlutterResult) {
        if(deviceToken.isEmpty) {
            //DispatchQueue.main.async {
                //UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound, .carPlay]) { (granted, error) in
                //    if let error = error {
                //        NSLog("Something was wrong: \(error)")
                //    } else if !granted {
                //        NSLog("Push notifications disabled")
                //    }
                    
                    //Anyway try to register, checking notifications settings first
                    DispatchQueue.main.async {
                        UNUserNotificationCenter.current().getNotificationSettings { settings in
                            switch settings.authorizationStatus {
                            case .authorized:
                                DispatchQueue.main.async {
                                    Application.shared.registerForRemoteNotifications()
                                    result("DeviceToken registration initiated. Authorized")
                                }
                                break
                            //case .ephemeral:
                            //    break
                            //case .provisional:
                            //    break
                            default:
                                NSLog("User didn't give you permissions for notifications, but you still may register to receive notifications in silent mode")
                                DispatchQueue.main.async {
                                    Application.shared.registerForRemoteNotifications()
                                    result("DeviceToken registration initiated. Unknown")
                                }
                            }
                        }
                    }
                }
            //}
        //}
        else {
            if self.isEmitPushToken {
                CxhubSdkPlugin._channel!.invokeMethod("emitPushToken", arguments: self.deviceToken)
                self.isEmitPushToken = false
                result("Device Token sent (getPushToken)")
            }
            if self.isSubscribeToPushToken {
                CxhubSdkPlugin._channel!.invokeMethod("emitPushTokenSub", arguments: self.deviceToken)
                result("Device Token sent (subscribe)")
            }
        
        }
    }
    
    private func getMobileInstance(result: @escaping FlutterResult) {
        result(CXHubSDKAPIBridge.getInstance.getInstanceId())
    }
    
    private func getUserId(result: @escaping FlutterResult) {
        result(CXHubSDKAPIBridge.getInstance.getUserId())
    }
    
    public func setUserProperties(properties : Dictionary<String, String>, result: @escaping FlutterResult) {
        for propKey in properties.keys {
            let propVal : String = properties[propKey]!
            CXHubSDKAPIBridge.getInstance.setInstanceProperty(propKey, withStringValue: propVal)
        }
        result(true)
    }
    
    public func collectEvent(key: String, value: String, properties: Dictionary<String, NSCoding & NSObjectProtocol>, result: @escaping FlutterResult) {
        CXHubSDKAPIBridge.getInstance.collectEvent(key, withValue: value as NSObject, withProperties: properties)
        NSLog("key: %@,\n value: %@,\n properties: %@", key, value, properties)
    }
    
    public func setUserId(idType : String, idValue: String, synchronous: Bool, result: @escaping FlutterResult) {
        CXHubSDKAPIBridge.getInstance.setUserId(idValue, ofType: idType)
        result(true)
    }
    
    @nonobjc public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let joinedCompletionHandler = CXApp.didReceiveRemoteNotification(userInfo, fetchCompletionHandler: completionHandler)
        //Do here your application specific push processing logic.
        joinedCompletionHandler(.noData)
    }
}

//MARK:  UNUserNotificationCenterDelegate

extension CxhubSdkPlugin:  UNUserNotificationCenterDelegate {

    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .list, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        if let joinedCompletionHandler = CXApp.didReceive(response, withCompletionHandler: completionHandler) {
            joinedCompletionHandler()
        } else {
            completionHandler()
        }
    }
}


//MARK: CXNotifyDelegate
extension CxhubSdkPlugin: CXNotifyDelegate {

    //MARK: @required:

    /**
     This method is called when user select action open_main
     on landing. It's called in main thread.
     */
    public func cxOpenMainInterface() -> Bool {
        //you may provide some specific logic (i.e. open any other ViewController here)
        //return 'true' if your logic succeeded, otherwise 'false'.
        //if 'true', then 'NotifyMessageLandingOpened' event is sent to CXHub-server
        return true
    }
    
    //MARK: @optional:

    public var activityTitleFont: UIFont {
        let baseFont = UIFont.systemFont(ofSize: 24.0, weight: .heavy)
        if #available(iOS 11.0, *) {
            return UIFontMetrics.init(forTextStyle: .title1).scaledFont(for: baseFont)
        } else {
            return baseFont
        }
    }

    public var activityBodyFont: UIFont {
        let baseFont = UIFont.systemFont(ofSize: 14.0, weight: .regular)
        if #available(iOS 11.0, *) {
            return UIFontMetrics.init(forTextStyle: .body).scaledFont(for: baseFont)
        } else {
            return baseFont
        }
    }

    public var activityButtonTitleFont: UIFont {
        let baseFont = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
        if #available(iOS 11.0, *) {
            return UIFontMetrics.init(forTextStyle: .subheadline).scaledFont(for: baseFont)
        } else {
            return baseFont
        }
    }

}

//MARK: NotificationService
extension CxhubSdkPlugin {
    public class func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) -> Bool {
        return CXApp.didReceiveExtensionNotificationRequest(request, withContentHandler: contentHandler)
    }
    
    public class func serviceExtensionTimeWillExpire() -> Bool {
        return CXApp.serviceExtensionTimeWillExpire()
    }
}

//MARK: ContentExtension

extension CxhubSdkPlugin : CXContentExtensionDelegate {
    
    public func didReceive(_ notification: UNNotification) -> Bool {
        var result : Bool = false
        result = CXNotify.requestNotificationExtensionContent(notification, with: self)
        return result
    }
    
    public func didReceive(_ notification: UNNotification, delegate: CXContentExtensionDelegate) -> Bool {
        var result : Bool = false
        result = CXNotify.requestNotificationExtensionContent(notification, with: delegate)
        return result
    }
    
    public func didReceive(_ response: UNNotificationResponse, context: NSExtensionContext?, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) -> Bool {
        if context == nil {
            return false
        }
        self.extensionContext = context!
        CXApp.didReceiveExtensionNotificationResponse(response, in: context!, completionHandler: completion)
        return true
    }
    
    public func onContentUpdated(_ content: CXContentExtensionData?, for notification: UNNotification, withError error: Error?) {
        let localContent: CXContentExtensionData? = content

        DispatchQueue.main.async {
            guard let content = localContent, let attachmentData = content.attachmentData, error == nil else {
                return
            }
            if self.bigContentImage == nil {
                self.bigContentImage = UIImageView()
            }
            self.bigContentImage!.image = UIImage(data: attachmentData)
        }
    }
}
