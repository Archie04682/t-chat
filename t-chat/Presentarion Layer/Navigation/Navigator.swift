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
    
    func navigate(to destination: Dest)
    
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
    
    func nav(_ rootVC: UIViewController?, destination: RootDestination, modal: Bool = false) {
        if let root = rootVC {
            if let vc = createNetworkImagesView?() {
                vc.delegate = root as? NetworkImagesViewDelegate
                let nvc = UINavigationController(rootViewController: vc)
                
                root.present(nvc, animated: true, completion: nil)
            }
        }
    }
    
    func navigate(to destination: RootDestination) {
        switch destination {
        case .conversation(let channel):
            if let controller = createConversationView?(channel) {
                navigationController.pushViewController(controller, animated: true)
            }
        case .settings:
            if let controller = createSettingsView?() {
                navigationController.pushViewController(controller, animated: true)
            }
        case .profile:
            if let vc = createProfileView?() {
                vc.navigate = nav
                vc.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(close))
                presentModal(vc)
            }
        case .networkImages:
            if let vc = createNetworkImagesView?() {
                vc.delegate = navigationController.topViewController as? NetworkImagesViewDelegate
                presentModal(vc)
            }
        }
        
    }
    
    private func presentModal(_ vc: UIViewController) {
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(close))
        let nvc = UINavigationController(rootViewController: vc)
        
        if let top = navigationController.topViewController {
            top.present(nvc, animated: true, completion: nil)
        }
    }
    
    @objc func close(_ button: UIBarButtonItem) {
//        viewController.navigationController?.dismiss(animated: true, completion: nil)
//        navigationController.dismiss(animated: true)
//        navigationController.topViewController?.viewWillAppear(true)
    }
}
