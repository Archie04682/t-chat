//
//  PresentaionAssembly.swift
//  t-chat
//
//  Created by Артур Гнедой on 13.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import Foundation

protocol PresentationAssembly {
    func conversationsListViewController() -> ConversationsListViewController
}

final class PresentationAssemblyImplementation: PresentationAssembly {
    
    private let serviceAssembly: ServiceAssembly
    
    init(serviceAssembly: ServiceAssembly) {
        self.serviceAssembly = serviceAssembly
    }
    
    func conversationsListViewController() -> ConversationsListViewController {
        return ConversationsListViewController(themeManager: self.serviceAssembly.themeManager,
                                               channelsService: self.serviceAssembly.channelService,
                                               profileService: self.serviceAssembly.profileService)
    }
}
