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
    
    var currentState: AppState = .notRunning
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        processState(nextState: .inactive, in: #function)
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        processState(nextState: .inactive, in: #function)
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        processState(nextState: .inactive, in: #function)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        processState(nextState: .active, in: #function)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        processState(nextState: .inactive, in: #function)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        processState(nextState: .background, in: #function)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        processState(nextState: .notRunning, in: #function)
    }

}
