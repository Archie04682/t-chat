//
//  MessageService.swift
//  t-chat
//
//  Created by Артур Гнедой on 13.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import Foundation

protocol MessageServiceDelegate: AnyObject {
    func data(_ result: Result<[ObjectChanges<Message>], Error>)
}

protocol MessageService {
    var delegate: MessageServiceDelegate? { get set }
    
    var channel: Channel { get }
    
    func add(_ message: Message, completion: @escaping (Error?) -> Void)
}

final class CombinedMessageService: MessageService {
    private var messageProvider: MessageProvider
    private var messageRepository: MessageRepository
    
    private var isLaunched = false
    let channel: Channel
    
    weak var delegate: MessageServiceDelegate? {
        didSet {
            messageRepository.delegate = self
            messageRepository.fetch(forChannelWithUID: channel.identifier)
        }
    }
    
    init(messageProvider: MessageProvider, messageRepository: MessageRepository, channel: Channel) {
        self.messageProvider = messageProvider
        self.messageRepository = messageRepository
        self.channel = channel
    }
    
    func add(_ message: Message, completion: @escaping (Error?) -> Void) {
        messageProvider.add(message, inChannelWithUID: channel.identifier, completion: completion)
    }
    
}

extension CombinedMessageService: MessageProviderDelegate {
    
    func fetched(_ result: Result<[Message], Error>) {
        switch result {
        case .success(let messages):
            messageRepository.add(messages, forChannelWithUID: channel.identifier) {[weak self] error in
                if let error = error {
                    self?.delegate?.data(.failure(error))
                }
            }
        case .failure(let error):
            delegate?.data(.failure(error))
        }
    }

}

extension CombinedMessageService: MessageRepositoryDelegate {
    
    func messagesUpdated(_ data: Result<[ObjectChanges<Message>], Error>) {
        func channelsUpdated(_ data: Result<[ObjectChanges<Message>], Error>) {
            switch data {
            case .success(let objects):
                delegate?.data(.success(objects))
                if !isLaunched {
                    messageProvider.delegate = self
                    
                    isLaunched = true
                }
            case .failure(let error):
                delegate?.data(.failure(error))
            }
        }
    }
    
}
