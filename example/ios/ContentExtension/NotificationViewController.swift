//
//  NotificationViewController.swift
//  ContentExtension
//
//  Created by Vladimir Kukhar on 09.12.2024.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import cxhub_ios
import CXHubNotify

class NotificationViewController: UIViewController, UNNotificationContentExtension /*,CXContentExtensionDelegate*/ {
    
    private var apiIsInitialized :  Bool = false
    
    // The following is required if you are going to use Storyboard for ContentExtension UI implementation. Using storyboard is really the better choice
    // Example of storyboard can be found here as "MainInterface.storyboard"
    // But in this case you need to edit Info.plist file as follows:
    // - remove NSExtensionPrincipalClass = ContentExtension.NotificationViewController row
    // - add NSExtensionMainStoryboard = MainInterface
    // Then:
    // - comment or remove var bigContentImage: UIImageView?
    // - uncomment awakeFromNib() implementation together with @IBOutlet var bigContentImage: UIImageView!
    // - connect BigContentImage (UIImageView in storyboard) to bigContentImage outlet
    // - comment or remove viewDidLoad implementation below
    // - comment or remove viewWillLayoutSubviews() implementation below
    
    var bigContentImage: UIImageView?
    //@IBOutlet var bigContentImage: UIImageView!
    
    /*
    override func awakeFromNib() {
        super.awakeFromNib()
        apiIsInitialized = CxhubSdkPlugin.initCXHubSdkWithContentExtensionImage(bigImage: self.bigContentImage)
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.bigContentImage == nil {
            self.bigContentImage = UIImageView.init(frame: self.view.bounds)
            self.view.addSubview(self.bigContentImage!)
            let constWidth:NSLayoutConstraint = NSLayoutConstraint(item: self.bigContentImage!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0);
            self.view.addConstraint(constWidth);
            
            let constHeight:NSLayoutConstraint = NSLayoutConstraint(item: self.bigContentImage!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: 0);
            self.view.addConstraint(constHeight);
             
            
            let constX:NSLayoutConstraint = NSLayoutConstraint(item: self.bigContentImage!, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0);
            self.view.addConstraint(constX);
            
            let constY:NSLayoutConstraint = NSLayoutConstraint(item: self.bigContentImage!, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0);
            self.view.addConstraint(constY);
            
            //self.bigContentImage!.layer.borderColor = UIColor.red.cgColor
            //self.bigContentImage!.layer.borderWidth = 4.0
            
            //self.view!.layer.borderColor = UIColor.green.cgColor
            //self.view!.layer.borderWidth = 2.0
            
            //The following is the only call, which is required to initialize CXHubSDK correctly to work with ContentExtension
            //If you plan to use Storyboard for ContentExtension interface, then this call has to be made inside awakeFromNib() implementation (see above)
            
            apiIsInitialized = CxhubSdkPlugin.initCXHubSdkWithContentExtensionImage(bigImage: self.bigContentImage!)
            self.view.updateConstraints()
        }
    }
    
    func didReceive(_ notification: UNNotification) {
        //This variant is for CxhubSdkPlugin as CXContentExtensionDelegate
        let processed = apiIsInitialized && CxhubSdkPlugin.instance.didReceive(notification)
        
        //This variant is to use ContentExtension itself as CXContentExtensionDelegate
        //let processed = apiIsInitialized && CxhubSdkPlugin.instance.didReceive(notification, delegate: self)
        
        if (!processed) {
            //Do some custom logic with a particular notification as it is not originated from CXHubSDK API.
        }
        
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        if apiIsInitialized {
            if !CxhubSdkPlugin.instance.didReceive(response, context: self.extensionContext, completionHandler: completion) {
                //Catch action with UNNotificationContentExtensionResponseOption yourself
            }
        }
        else {
            //Catch action with UNNotificationContentExtensionResponseOption yourself, cause CXHubSDK wasn't initialized correctly
        }
    }
    
    //If you use ContentExtension as CXContentExtensionDelegate, then you need to implement the following method (below is example, the same imlementation is used inside CxhubSdkPlugin). You don't need this, if you use CxhubSdkPlugin as CXContentExtensionDelegate
    /*
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
    }*/
}
