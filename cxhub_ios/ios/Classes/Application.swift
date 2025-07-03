//
//  Application.swift
//  cxhub_ios
//
//  Created by cxhub.mail.ru on 04.12.2024.
//

import Foundation

open class Application {
    static var shared: UIApplication {
        let sharedSelector = NSSelectorFromString("sharedApplication")
        guard UIApplication.responds(to: sharedSelector) else {
            fatalError("[Extensions can't access Application]")
        }
        let shared = UIApplication.perform(sharedSelector)
        return shared?.takeUnretainedValue() as! UIApplication
    }
}
