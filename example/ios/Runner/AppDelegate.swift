import Flutter
import UIKit
import CXHubCore
import CXHubNotify
import cxhub_ios

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        application.delegate = self;
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        CxhubSdkPlugin.instance.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        return super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        CxhubSdkPlugin.instance.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
        return super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }

}
