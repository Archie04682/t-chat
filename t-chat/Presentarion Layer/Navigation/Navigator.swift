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
}

final class RootNavigator: Navigator {
    
    var navigationController: UINavigationController
    
    var createConversationView: ((Channel) -> ConversationViewController)?
    var createSettingsView: (() -> ThemesViewController)?
    var createProfileView: (() -> ProfileViewController)?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
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
                vc.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeProfilePage))
                vc.title = "My profile"
                let nvc = UINavigationController(rootViewController: vc)
        
                if let top = navigationController.topViewController {
                    top.present(nvc, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func closeProfilePage() {
        navigationController.dismiss(animated: true)
        navigationController.topViewController?.viewWillAppear(true)
    }
}
