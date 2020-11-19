//
//  Navigator.swift
//  t-chat
//
//  Created by Артур Гнедой on 14.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import Foundation
import UIKit

protocol Navigator {
    associatedtype Dest
    
    func navigate(_ rootVC: UIViewController?, destination: Dest, modal: Bool)
    
    var navigationController: UINavigationController { get }
    
    var createSettingsView: (() -> ThemesViewController)? { get }
    
    var createProfileView: (() -> ProfileViewController)? { get }
}

enum RootDestination {
    case conversation(channel: Channel)
    case settings
    case profile
    case networkImages
}

final class RootNavigator: Navigator {
    
    var navigationController: UINavigationController
    
    var createConversationView: ((Channel) -> ConversationViewController)?
    var createSettingsView: (() -> ThemesViewController)?
    var createProfileView: (() -> ProfileViewController)?
    var createNetworkImagesView: (() -> NetworkImagesViewController)?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func navigate(_ rootVC: UIViewController?, destination: RootDestination, modal: Bool = false) {
        if let root = rootVC {
            var vc: UIViewController?
            
            switch destination {
            case .conversation(let channel):
                vc = createConversationView?(channel)
            case .settings:
                vc = createSettingsView?()
            case .profile:
                vc = createProfileView?()
            case .networkImages:
                let networkImages = createNetworkImagesView?()
                networkImages?.delegate = rootVC as? NetworkImagesViewDelegate
                vc = networkImages
            }
            
            if let vc = vc {
                if modal {
                    let nvc = UINavigationController(rootViewController: vc)
                    
                    let closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(close(_:)))
                    vc.navigationItem.leftBarButtonItem = closeButton
                    
                    root.present(nvc, animated: true, completion: nil)
                } else {
                    navigationController.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    @objc func close(_ button: UIBarButtonItem) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            topController.dismiss(animated: true, completion: nil)
        }
        
        navigationController.topViewController?.viewWillAppear(true)
    }
}
