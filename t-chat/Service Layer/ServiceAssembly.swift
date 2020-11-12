//
//  ServiceAssembly.swift
//  t-chat
//
//  Created by Артур Гнедой on 13.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import Foundation

protocol ServiceAssembly {
    func messageService(for channel: Channel) -> MessageService
    
    var channelService: ChannelService { get }
    
    var themeManager: ThemeManager { get }
    
    var profileService: ProfileService { get }
}

final class ServiceAssemblyImplementation: ServiceAssembly {
    private let coreAssembly: CoreAssembly
    
    init(coreAssembly: CoreAssembly) {
        self.coreAssembly = coreAssembly
    }
    
    func messageService(for channel: Channel) -> MessageService {
        return CombinedMessageService(messageProvider: self.coreAssembly.messageProvider, messageRepository: self.coreAssembly.messageRepository, channel: channel)
    }
    
    lazy var channelService: ChannelService = CombinedChannelService(channelDataProvider: self.coreAssembly.channelProvider, channelRepository: self.coreAssembly.channelRepository)
    
    lazy var themeManager: ThemeManager = UserDafaultsThemeManager()
    
    lazy var profileService: ProfileService = UserProfileService(profileManagerFactory: self.coreAssembly.profileManagerFactory)
}
