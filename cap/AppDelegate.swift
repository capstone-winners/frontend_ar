//
//  AppDelegate.swift
//  cap
//
//  Created by Andrew Tu on 1/16/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // (1)
    window = UIWindow(frame: UIScreen.main.bounds)
    
    #if targetEnvironment(simulator)
      let viewController = ViewControllerNoAR()
    #else
      let viewController = ViewControllerAR()
    #endif
    
    window?.rootViewController = viewController
    
    // (3)
    window?.makeKeyAndVisible()
    
    return true
  }
  
}

