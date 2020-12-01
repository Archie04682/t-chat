//
//  PresentaionAssembly.swift
//  t-chat
//
//  Created by Артур Гнедой on 13.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

protocol PresentationAssembly: AnyObject {
    
    func createRootViewController(withStartScreen screen: AvailableScreen) -> UINavigationController
    
}

final class PresentationAssemblyImplementation: PresentationAssembly {
    var rootNavigator: RootNavigator
    
    private let serviceAssembly: ServiceAssembly
    
    init(serviceAssembly: ServiceAssembly) {
        self.serviceAssembly = serviceAssembly
        self.rootNavigator = RootNavigator(navigationController: UINavigationController())
        
        rootNavigator.createConversationView = conversationViewController(for:)
        rootNavigator.createSettingsView = themesViewController
        rootNavigator.createProfileView = profileViewController
        rootNavigator.createNetworkImagesView = networkImagesViewController
    }
    
    func createRootViewController(withStartScreen screen: AvailableScreen = .conversationsList) -> UINavigationController {
        switch screen {
        case .themes:
            rootNavigator.navigationController.viewControllers = [themesViewController()]
        case .profile:
            rootNavigator.navigationController.viewControllers = [profileViewController()]
        default:
            rootNavigator.navigationController.viewControllers = [conversationsListViewController()]
        }
        
        return rootNavigator.navigationController
    }
    
    private func conversationsListViewController() -> ConversationsListViewController {
        let vc = ConversationsListViewController(themeManager: self.serviceAssembly.themeManager,
                                               channelsService: self.serviceAssembly.channelService,
                                               profileService: self.serviceAssembly.profileService)
        vc.navigate = rootNavigator.navigate
        return vc
    }
    
    private func conversationViewController(for channel: Channel) -> ConversationViewController {
        return ConversationViewController(profileService: self.serviceAssembly.profileService,
                                          messageService: self.serviceAssembly.messageService(for: channel),
                                          themeManager: self.serviceAssembly.themeManager)
    }
    
    private func themesViewController() -> ThemesViewController {
        return ThemesViewController(themeManager: self.serviceAssembly.themeManager)
    }
    
    private func profileViewController() -> ProfileViewController {
        let vc = ProfileViewController(model: ProfileModel(profileService: self.serviceAssembly.profileService),
                                     imagePicker: self.serviceAssembly.imagePicker,
                                     themeManager: self.serviceAssembly.themeManager)
        vc.navigate = rootNavigator.navigate
        
        return vc
    }
    
    private func networkImagesViewController() -> NetworkImagesViewController {
        return NetworkImagesViewController(networkImageService: self.serviceAssembly.networkImageService, themeManager: self.serviceAssembly.themeManager)
    }
}

enum AvailableScreen: String {
    case conversationsList = "conversations"
    case profile = "profile"
    case themes = "themes"
}
