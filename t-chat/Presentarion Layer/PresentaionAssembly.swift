//
//  PresentaionAssembly.swift
//  t-chat
//
//  Created by Артур Гнедой on 13.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

protocol PresentationAssembly: AnyObject {
//    func conversationsListViewController() -> ConversationsListViewController
//    func conversationViewController(for channel: Channel) -> ConversationViewController
    var rootNavigator: RootNavigator { get }
}

final class PresentationAssemblyImplementation: PresentationAssembly {
    var rootNavigator: RootNavigator
    
    private let serviceAssembly: ServiceAssembly
    
    init(serviceAssembly: ServiceAssembly) {
        self.serviceAssembly = serviceAssembly
        self.rootNavigator = RootNavigator(navigationController: UINavigationController())
        rootNavigator.navigationController.viewControllers = [conversationsListViewController()]
        rootNavigator.createConversationView = conversationViewController(for:)
    }
    
    private func conversationsListViewController() -> ConversationsListViewController {
        return ConversationsListViewController(themeManager: self.serviceAssembly.themeManager,
                                               channelsService: self.serviceAssembly.channelService,
                                               profileService: self.serviceAssembly.profileService,
                                               navigator: self.rootNavigator)
    }
    
    private func conversationViewController(for channel: Channel) -> ConversationViewController {
        return ConversationViewController(profileService: self.serviceAssembly.profileService,
                                          messageService: self.serviceAssembly.messageService(for: channel),
                                          themeManager: self.serviceAssembly.themeManager)
    }
}
