//
//  PresentaionAssembly.swift
//  t-chat
//
//  Created by Артур Гнедой on 13.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

protocol PresentationAssembly {
    func conversationsListViewController() -> ConversationsListViewController
    func conversationViewController(for channel: Channel) -> ConversationViewController
    var initial: UIViewController { get }
}

final class PresentationAssemblyImplementation: PresentationAssembly {
    
    private let serviceAssembly: ServiceAssembly
    
    var initial: UIViewController {
        return conversationsListViewController()
    }
    
    init(serviceAssembly: ServiceAssembly) {
        self.serviceAssembly = serviceAssembly
    }
    
    func conversationsListViewController() -> ConversationsListViewController {
        return ConversationsListViewController(themeManager: self.serviceAssembly.themeManager,
                                               channelsService: self.serviceAssembly.channelService,
                                               profileService: self.serviceAssembly.profileService)
    }
    
    func conversationViewController(for channel: Channel) -> ConversationViewController {
        return ConversationViewController(profileService: self.serviceAssembly.profileService,
                                          messageService: self.serviceAssembly.messageService(for: channel),
                                          themeManager: self.serviceAssembly.themeManager)
    }
}
