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
    var tokenWaitingQueue: DispatchSerialQueue?
    @objc dynamic var deviceTokenSemaphore: DispatchSemaphore?
    
    override init() {
        super.init()
        if !CxhubSdkPlugin.apiIsInitialized {CxhubSdkPlugin.apiIsInitialized = CxhubSdkPlugin.initCXHubSDK()}
        if !Bundle.main.bundlePath.hasSuffix(".appex") {
            tokenWaitingQueue = DispatchSerialQueue(label: "com.cxhubsdk.register_for_notifications_queue", qos: DispatchQoS.userInitiated,
                                                    attributes: DispatchSerialQueue.Attributes())
            if(deviceTokenSemaphore == nil) {
                deviceTokenSemaphore = DispatchSemaphore(value: 0)
            }
            self.deviceTokenObserver = self.observe(\.deviceToken, options: .new, changeHandler: { (self, change) in
                guard let newValue = change.newValue else {return}
                if newValue != "" {
                    DispatchQueue.main.async {
                        CxhubSdkPlugin._channel!.invokeMethod("emitPushToken", arguments: self.deviceToken)
                    }
                }
            })
            //Application.shared.registerForRemoteNotifications()
        }
    }
    
    deinit {
        deviceTokenObserver?.invalidate()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        _channel = FlutterMethodChannel(name: "cxhub_sdk", binaryMessenger: registrar.messenger())
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = instance
        
        if !CxhubSdkPlugin.apiIsInitialized {CxhubSdkPlugin.apiIsInitialized = CxhubSdkPlugin.initCXHubSDK()}
        
        if !Bundle.main.bundlePath.hasSuffix(".appex") {
            instance.addObservers()
            if apiIsInitialized {
                CXHubSDKAPIBridge.getInstance.setDelegate(instance)
            }
            //if CxhubSdkPlugin.instance.deviceToken == "" {Application.shared.registerForRemoteNotifications()}
        }
    
        //CXApp.setUnhandledErrorReceiver(NotifyHandler())
        //CXApp.setMonitoringEventReceiver(NotifyHandler())
        
        
        
        registrar.addMethodCallDelegate(instance, channel: _channel!)
        
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "deviceToken" && change != nil {
            NSLog("change: %@",change!)
            if self.deviceToken != "" { //&& change![oldKey] != change![newKey] {
                DispatchQueue.main.async {
                    CxhubSdkPlugin._channel!.invokeMethod("emitPushToken", arguments: self.deviceToken)
                }
            }
            //else {
                //result(FlutterError(code: "UNAVAILABLE", message: "Device token not available", details: nil))
            //}
        }
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
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
        case "requestNotificationPermissions":
            self.requestNotificationPermissions(result: result)
            break
        case "registerForPushNotifications":
            self.registerForPushNotifications(application: application, result: result)
            break
        case "getPushToken":
            self.getPushToken(result: result)
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

    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        self.deviceToken = token
        CXApp.applicationDidRegisterForRemoteNotifications(withDeviceToken: deviceToken)
        //self.releaseSemaphore()
    }
    
    private func releaseSemaphore() {
        self.tokenWaitingQueue!.async(qos: .userInitiated) {
            if self.deviceTokenSemaphore != nil {
                self.deviceTokenSemaphore!.signal()
            }
        }
    }
    
    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        CXApp.applicationDidFailToRegisterForRemoteNotificationsWithError(error)
        self.deviceToken = "Fail to get device token (pushToken)"
        //self.releaseSemaphore()
    }
    
    
    private func requestNotificationPermissions(result: @escaping FlutterResult) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                result(FlutterError(code: "PERMISSION_ERROR", message: "Failed to request permissions", details: error.localizedDescription))
                return
            }
            result(granted)
        }
    }
    
    public func registerForPushNotifications(application: UIApplication, result: @escaping FlutterResult) {
        application.registerForRemoteNotifications()
        result("Device Token registration initiated")
    }
    
    public func getPushToken(result: @escaping FlutterResult) {
        if(deviceToken.isEmpty) {
            DispatchQueue.main.async {
                Application.shared.registerForRemoteNotifications()
                result("DeviceToken registration initiated")
            }
            //Application.shared.registerForRemoteNotifications()
            //let application = Application.shared
            //application.registerForRemoteNotifications()
            //self.tokenWaitingQueue!.async(qos: .userInitiated) {
            //    self.deviceTokenSemaphore!.wait()
            //    self.deviceTokenSemaphore = nil
            //    if self.deviceToken != "" {
            //        DispatchQueue.main.async {
            //            CxhubSdkPlugin._channel!.invokeMethod("emitPushToken", arguments: self.deviceToken)
            //        }
            //    }
            //    else {
            //        result(FlutterError(code: "UNAVAILABLE", message: "Device token not available", details: nil))
            //    }
            //}
            //result("Device Token registration initiated")
        }
        else {
            //result(self.deviceToken)
            CxhubSdkPlugin._channel!.invokeMethod("emitPushToken", arguments: self.deviceToken)
            result("Device Token sent")
        }
    }
    
    private func getDeviceToken(result: @escaping FlutterResult) {
        if(deviceToken.isEmpty) {
            result(FlutterError(code: "UNAVAILABLE", message: "Device token not available", details: nil))
        } else{
            result(deviceToken)
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
    
    @nonobjc  func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        if let joinedCompletionHandler = CXApp.performFetch(completionHandler: completionHandler) {
            //Simulate some application specific background data processing
            Thread.sleep(forTimeInterval: 1)
            //When all down call an aggregated callback to give ability to CXHubSDK complete all it's
            //background tasks
            joinedCompletionHandler(.newData)
        } else {
            completionHandler(.newData)
        }
    }
    
    private func handleNotification(userInfo: [AnyHashable: Any]) {
        let window = Application.shared.delegate?.window
        let controller: FlutterViewController = window??.rootViewController as! FlutterViewController
        let pushNotificationChannel = FlutterMethodChannel(name: "cxhub_sdk",binaryMessenger: controller.binaryMessenger)
        if let customData = userInfo as? AnyHashable /*["customKey"] as? String*/ {
            pushNotificationChannel.invokeMethod("onPushNotification", arguments: customData)
        }
    }
    
}

// MARK: Add observers
extension CxhubSdkPlugin {
    private func addObservers () {
        
        NotificationCenter.default.addObserver(CxhubSdkPlugin.instance, selector: #selector(CxhubSdkPlugin.instance.applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: Application.shared)
        
        NotificationCenter.default.addObserver(CxhubSdkPlugin.instance, selector: #selector(CxhubSdkPlugin.instance.applicationWillEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: Application.shared)
        
        NotificationCenter.default.addObserver(CxhubSdkPlugin.instance, selector: #selector(CxhubSdkPlugin.instance.applicationWillResignActive(_:)), name: UIApplication.willResignActiveNotification, object: Application.shared)
        
        NotificationCenter.default.addObserver(CxhubSdkPlugin.instance, selector: #selector(CxhubSdkPlugin.instance.applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: Application.shared)
        
        NotificationCenter.default.addObserver(CxhubSdkPlugin.instance, selector: #selector(CxhubSdkPlugin.instance.applicationWillTerminate(_:)), name: UIApplication.willTerminateNotification, object: Application.shared)
        
        NotificationCenter.default.addObserver(CxhubSdkPlugin.instance, selector: #selector(CxhubSdkPlugin.instance.applicationSignificantTimeChange(_:)), name: UIApplication.significantTimeChangeNotification, object: Application.shared)
    }
}

// MARK: UIApplicationDelegate
extension CxhubSdkPlugin  {   //UIApplicationDelegate

    public func applicationWillEnterForeground(_ application: UIApplication) {
        //Forward system call to CXHubSDK
        CXApp.applicationWillEnterForeground(application)
    }

    public func applicationDidBecomeActive(_ application: UIApplication) {
        //Forward system call to CXHubSDK
        CXApp.applicationDidBecomeActive(application)
    }

    public func applicationWillResignActive(_ application: UIApplication) {
        //Forward system call to CXHubSDK
        CXApp.applicationWillResignActive(application)
    }
    
    public func applicationDidEnterBackground(_ application: UIApplication) {
        //Forward system call to CXHubSDK
        CXApp.applicationDidEnterBackground(application)
    }
    
    public func applicationWillTerminate(_ application: UIApplication) {
        //Forward system call to CXHubSDK
        CXApp.applicationWillTerminate(application)
    }

    public func applicationSignificantTimeChange(_ application: UIApplication) {
        //Forward system call to CXHubSDK
        CXApp.applicationSignificantTimeChange(application)
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
        //let userInfo = response.notification.request.content.userInfo
        //handleNotification(userInfo: userInfo)
        //completionHandler()
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

    /**
     You may implement this method in your class.
     All incoming pushes with url will be tried to open url with this method.
     If your implementation returns true handling of url will be completed
     else logic will call method -[UIApplication openUrl:].
     This method will be called in the main thread.
     */
    public func open(_ url: URL) -> Bool {
        //Example implementation
        let preferences = UserDefaults.standard
        if(!preferences.bool(forKey: "CX_CatchDeepLink")) {
            return false
        }
        let vc = UIAlertController(title: "App is handling url", message: url.absoluteString, preferredStyle: .alert)
        Application.shared.delegate?.window??.rootViewController?.present(vc, animated: true, completion: nil)
        return true;
    }

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
