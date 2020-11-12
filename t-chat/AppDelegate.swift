//
//  AppDelegate.swift
//  t-chat
//
//  Created by Артур Гнедой on 11.09.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, StateLoggable {

    var window: UIWindow?
    
    var currentState: AppState = .notRunning
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        logTransition(nextState: .inactive, in: #function)
        FirebaseApp.configure()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        LocalThemeManager.shared.apply(theme: LocalThemeManager.shared.currentTheme)
        
        var coreDataStack: CoreDataStack = NewWaveStack(withModel: "Chats")
        coreDataStack.didUpdateDatabase = { stack in
            stack.printStatictics()
        }
        
        coreDataStack.enableObservers()
        
        let channelRepository = CoreDataChannelRepository(coreDataStack: coreDataStack)
        let navigationController = UINavigationController()
        let conversationsListViewController = ConversationsListViewController(channelRepository: channelRepository)
        navigationController.viewControllers = [conversationsListViewController]
        
        if ApplicationFileProvider.isFirstLaunch() {
            let model = ProfileModel()
            model.changedData[.username] = "Artur Gnedoy".data(using: .utf8)
            model.changedData[.about] = "Some description".data(using: .utf8)
            model.save(with: .GCD)
        }
        
        navigationController.viewControllers = [conversationsListViewController]
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        self.window = window
        
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        logTransition(nextState: .inactive, in: #function)
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        logTransition(nextState: .inactive, in: #function)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        logTransition(nextState: .active, in: #function)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        logTransition(nextState: .inactive, in: #function)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        logTransition(nextState: .background, in: #function)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        logTransition(nextState: .notRunning, in: #function)
    }

}
