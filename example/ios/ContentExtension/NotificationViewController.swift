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

class NotificationViewController: UIViewController, UNNotificationContentExtension, CXContentExtensionDelegate {
    
    private var apiIsInitialized :  Bool = false
    
    var bigContentImage: UIImageView?
    
    /*override func awakeFromNib() {
        super.awakeFromNib()
        apiIsInitialized = CxhubSdkPlugin.initCXHubSDK()
    }*/
    
    /*required init(coder: NSCoder) {
        super.init(coder: coder)!
        
    }*/
    
    /*override func loadView() {
        self.view = UIView(frame: .zero)
        super.loadView()
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.bigContentImage == nil {
            self.bigContentImage = UIImageView.init(frame: .zero)//self.view.bounds)//
            self.bigContentImage!.contentMode = UIView.ContentMode.top//scaleAspectFit
            self.view.addSubview(self.bigContentImage!)
            
            let constWidth:NSLayoutConstraint = NSLayoutConstraint(item: self.bigContentImage!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0);
            self.view.addConstraint(constWidth);
            
            let constHeight:NSLayoutConstraint = NSLayoutConstraint(item: self.bigContentImage!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: 0);
            self.view.addConstraint(constHeight);
            
            let constX:NSLayoutConstraint = NSLayoutConstraint(item: self.bigContentImage!, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0);
            self.view.addConstraint(constX);
            
            //let constTop:NSLayoutConstraint = NSLayoutConstraint(item: self.bigContentImage!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0);
            //self.view.addConstraint(constTop);
            
            let constY:NSLayoutConstraint = NSLayoutConstraint(item: self.bigContentImage!, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0);
            self.view.addConstraint(constY);
            
            self.bigContentImage!.layer.borderColor = UIColor.red.cgColor
            self.bigContentImage!.layer.borderWidth = 4.0
            
            self.view!.layer.borderColor = UIColor.green.cgColor
            self.view!.layer.borderWidth = 2.0
            
            apiIsInitialized = CxhubSdkPlugin.initCXHubSdkWithContentExtensionImage(bigImage: self.bigContentImage!)
        }
    }
    
    override func viewWillLayoutSubviews() {
        self.bigContentImage!.frame = self.view.bounds
        self.bigContentImage!.center = CGPoint(x: self.view.bounds.size.width/2.0, y: self.view.bounds.size.height/2.0)
        self.view.updateConstraints()
        super.viewWillLayoutSubviews()
    }
    
    func didReceive(_ notification: UNNotification) {
        let processed = apiIsInitialized && CxhubSdkPlugin.instance.didReceive(notification)
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
            let superView : UIView? = self.bigContentImage!.superview
            let imageSize = self.bigContentImage!.image?.size
            if superView != nil && imageSize != .zero {
                let heightV = superView!.bounds.height
                let heightImg = imageSize!.height
                let coefH = heightImg/heightV
                let constHeight:NSLayoutConstraint = NSLayoutConstraint(item: self.bigContentImage!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.height, multiplier: coefH, constant: 0);
                superView!.addConstraint(constHeight);
                superView!.updateConstraints()
                
            //    superView?.layoutIfNeeded()//setNeedsDisplay()//setNeedsLayout()
            }
            //self.bigContentImage!.superview?.layoutIfNeeded()
        }
    }
}
