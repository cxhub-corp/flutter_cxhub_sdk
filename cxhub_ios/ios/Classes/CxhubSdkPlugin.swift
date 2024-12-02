import Flutter
import UIKit
import CXHubCore
import CXHubNotify


public class CxhubSdkPlugin: NSObject, FlutterPlugin, FlutterApplicationLifeCycleDelegate, UIApplicationDelegate {
    var deviceToken : String = ""
    public static let instance = CxhubSdkPlugin()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "cxhub_sdk", binaryMessenger: registrar.messenger())
        
        guard let config = CXAppConfig.default() else { fatalError() }
        CXApp.initWith(config, withEventsReceiver: nil)
        //CXApp.setUnhandledErrorReceiver(NotifyHandler())
        //CXApp.setMonitoringEventReceiver(NotifyHandler())
        
        // Setup delegate to get requests from CXHubSDK
        CXNotify.getInstance()?.setDelegate(instance)
        
        instance.addObservers()
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = instance
        
        UIApplication.shared.registerForRemoteNotifications()
        
        registrar.addMethodCallDelegate(instance, channel: channel)
        /*instance.requestNotificationPermissions(result: {_ in (() -> Void).self
            instance.registerForPushNotifications(application: UIApplication.shared, result: {_ in (() -> Void).self
            })
        })*/
        
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        //let application = UIApplication.shared
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
            break
        case "requestNotificationPermissions":
            self.requestNotificationPermissions(result: result)
        //case "registerForPushNotifications":
        //    self.registerForPushNotifications(application: application, result: result)
            break
        case "retrieveDeviceToken":
            self.getDeviceToken(result: result)
            break
        case "getMobileInstance":
            self.getMobileInstance(result: result)
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
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        self.deviceToken = token
        NSLog("%@",token)
        CXApp.applicationDidRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }
    
    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        CXApp.applicationDidFailToRegisterForRemoteNotificationsWithError(error)
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
    
    private func getDeviceToken(result: @escaping FlutterResult) {
        if(deviceToken.isEmpty){
            result(FlutterError(code: "UNAVAILABLE", message: "Device token not available", details: nil))
        } else{
            result(deviceToken)
        }
    }
    
    private func getMobileInstance(result: @escaping FlutterResult) {
        result(CXNotify.getInstance()?.getInstanceId())
    }
    
    public func setUserProperties(properties : Dictionary<String, String>, result: @escaping FlutterResult) {
        for propKey in properties.keys {
            let propVal : String = properties[propKey]!
            CXNotify.getInstance()?.setInstanceProperty(propKey, withStringValue: propVal)
        }
        result(true)
    }
    
    public func setUserId(idType : String, idValue: String, synchronous: Bool, result: @escaping FlutterResult) {
        CXNotify.getInstance()?.setUserId(idValue, ofType: idType)
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
        let window = UIApplication.shared.delegate?.window
        let controller: FlutterViewController = window??.rootViewController as! FlutterViewController
        let pushNotificationChannel = FlutterMethodChannel(name: "cxhub_sdk",binaryMessenger: controller.binaryMessenger)
        if let customData = userInfo as? AnyHashable /*["customKey"] as? String*/ {
            pushNotificationChannel.invokeMethod("onPushNotification", arguments: customData)
        }
    }
    
}

// MARK: Add observers
extension CxhubSdkPlugin {
    public func addObservers () {
        NotificationCenter.default.addObserver(CxhubSdkPlugin.instance, selector: #selector(CxhubSdkPlugin.instance.applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: UIApplication.shared)
        
        NotificationCenter.default.addObserver(CxhubSdkPlugin.instance, selector: #selector(CxhubSdkPlugin.instance.applicationWillEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: UIApplication.shared)
        
        NotificationCenter.default.addObserver(CxhubSdkPlugin.instance, selector: #selector(CxhubSdkPlugin.instance.applicationWillResignActive(_:)), name: UIApplication.willResignActiveNotification, object: UIApplication.shared)
        
        NotificationCenter.default.addObserver(CxhubSdkPlugin.instance, selector: #selector(CxhubSdkPlugin.instance.applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: UIApplication.shared)
        
        NotificationCenter.default.addObserver(CxhubSdkPlugin.instance, selector: #selector(CxhubSdkPlugin.instance.applicationWillTerminate(_:)), name: UIApplication.willTerminateNotification, object: UIApplication.shared)
        
        NotificationCenter.default.addObserver(CxhubSdkPlugin.instance, selector: #selector(CxhubSdkPlugin.instance.applicationSignificantTimeChange(_:)), name: UIApplication.significantTimeChangeNotification, object: UIApplication.shared)
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
        let userInfo = response.notification.request.content.userInfo
        handleNotification(userInfo: userInfo)
        completionHandler()
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
        UIApplication.shared.delegate?.window??.rootViewController?.present(vc, animated: true, completion: nil)
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

