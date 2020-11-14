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
}

enum RootDestination {
    case conversation(channel: Channel)
    case settings
}

final class RootNavigator: Navigator {
    
    var navigationController: UINavigationController
    
    var createConversationView: ((Channel) -> ConversationViewController)?
    var createSettingsView: (() -> ThemesViewController)?
    
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
        }
    }
}
