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
    
    var layer: CAEmitterLayer?
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        logTransition(nextState: .inactive, in: #function)
        FirebaseApp.configure()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        let root = RootAssembly()
        
        window.rootViewController = root.presentationAssembly.rootNavigator.navigationController
        
        window.makeKeyAndVisible()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandle(_:)))
        tap.cancelsTouchesInView = false
        
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(panHandle(_:)))
        longTap.cancelsTouchesInView = false
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panHandle(_:)))
        pan.cancelsTouchesInView = false
        
        window.addGestureRecognizer(tap)
        window.addGestureRecognizer(longTap)
        window.addGestureRecognizer(pan)
        
        self.window = window
        
        return true
    }
    
    @objc func tapHandle(_ gestureRecognizer: UITapGestureRecognizer) {
        if let window = window {
            let flakes = TinkoffFlakesEmitter().createLayer(position: gestureRecognizer.location(in: gestureRecognizer.view?.window), size: window.bounds.size)
            window.layer.addSublayer(flakes)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                flakes.removeFromSuperlayer()
            }
        }
    }
    
    @objc func panHandle(_ gestureRecognizer: UIGestureRecognizer) {
        if let window = window {
            switch gestureRecognizer.state {
            case .began:
                let flakes = TinkoffFlakesEmitter().createLayer(position: gestureRecognizer.location(in: gestureRecognizer.view?.window),
                                                                size: window.bounds.size)
                window.layer.addSublayer(flakes)
                layer = flakes
            case .changed:
                layer?.emitterPosition = gestureRecognizer.location(in: gestureRecognizer.view?.window)
            case .ended, .cancelled:
                layer?.removeFromSuperlayer()
            case .failed, .possible:
                print("")
            @unknown default:
                fatalError()
            }
        }
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
