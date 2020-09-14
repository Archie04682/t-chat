//
//  AppDelegate.swift
//  t-chat
//
//  Created by Артур Гнедой on 11.09.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, StateLoggable {

    var window: UIWindow?
    
    var currentState: AppState = .notLaunched
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        self.changeState(to: .notRunning, in: #function)
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.changeState(to: .inactive, in: #function)
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        self.changeState(to: .inactive, in: #function)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        self.changeState(to: .active, in: #function)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        self.changeState(to: .inactive, in: #function)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.changeState(to: .background, in: #function)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.changeState(to: .notRunning, in: #function)
    }

}

