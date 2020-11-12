//
//  MessageDataProvider.swift
//  t-chat
//
//  Created by Артур Гнедой on 13.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import Firebase
import Foundation

protocol MessageProviderDelegate: AnyObject {
    
    func fetched(_ result: Result<[Message], Error>)
    
}

protocol MessageProvider {
    var delegate: MessageProviderDelegate? { get set }
    
    func get(forChannelWithUID: String)
    
    func add(_ message: Message, inChannelWithUID uid: String, completion: @escaping (Error?) -> Void)
}

final class FirestoreMessageProvider: MessageProvider {
    private var firestoreProvider: FirestoreProvider
    private var listener: ListenerRegistration?
    
    weak var delegate: MessageProviderDelegate?
    
    init(firestoreProvider: FirestoreProvider) {
        self.firestoreProvider = firestoreProvider
    }
    
    func get(forChannelWithUID uid: String) {
        listener?.remove()
        
        listener = firestoreProvider.getMessages(forChannel: uid) { [weak self] messages, error in
            if let error = error {
                self?.delegate?.fetched(.failure(error))
            }
            
            if let messages = messages {
                self?.delegate?.fetched(.success(messages))
            }
        }
    }
    
    func add(_ message: Message, inChannelWithUID uid: String, completion: @escaping (Error?) -> Void) {
        firestoreProvider.sendMessage(toChannel: uid, message: message, completion: completion)
    }

}
