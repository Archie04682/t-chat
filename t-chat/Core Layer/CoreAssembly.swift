//
//  CoreAssembly.swift
//  t-chat
//
//  Created by Артур Гнедой on 13.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import Foundation

protocol CoreAssembly {
    
    var channelRepository: ChannelRepository { get }
    var messageRepository: MessageRepository { get }
    
    var channelProvider: ChannelProvider { get }
    var messageProvider: MessageProvider { get }
    
    var profileManagerFactory: ProfileManagerFactory { get }
    var imageManager: ImageManager { get }
    var networkProvider: NetworkProvider { get }
}

final class CoreAssemblyImplementation: CoreAssembly {
    private let firestoreProvider = FirestoreProvider()
    private lazy var coreDataStack: CoreDataStack = NewWaveStack(withModel: "Chats")
    
    lazy var channelRepository: ChannelRepository = CoreDataChannelRepository(coreDataStack: self.coreDataStack)
    lazy var messageRepository: MessageRepository = CoreDataMessageRepository(coreDataStack: self.coreDataStack)
    
    lazy var channelProvider: ChannelProvider = FirestoreChannelProvider(firestoreProvider: self.firestoreProvider)
    lazy var messageProvider: MessageProvider = FirestoreMessageProvider(firestoreProvider: self.firestoreProvider)
    
    lazy var profileManagerFactory: ProfileManagerFactory = UserProfileDataManagerFactory()
    lazy var imageManager: ImageManager = LocalImageManager()
    lazy var networkProvider: NetworkProvider = NetworkProviderImplementation()
}
