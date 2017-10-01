//
//  AppDelegate.swift
//  TT_VirtualTourist
//
//  Created by Tigran Tshorokhyan on 9/22/17.
//  Copyright © 2017 Tigran Tshorokhyan. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let themeColor = UIColor.blue


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window?.tintColor = themeColor
        return true
    }

}

