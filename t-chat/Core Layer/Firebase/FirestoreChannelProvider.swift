//
//  ChannelDataProvider.swift
//  t-chat
//
//  Created by Артур Гнедой on 12.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import Firebase
import Foundation

protocol ChannelProviderDelegate: AnyObject {
    
    func fetched(_ result: Result<[Channel], Error>)
    
}

protocol ChannelProvider {
    var delegate: ChannelProviderDelegate? { get set }
    func get()
    
    func add(withName name: String, completion: @escaping (Error?) -> Void)
    
    func delete(withUID uid: String, completion: @escaping (Error?) -> Void)
}

final class FirestoreChannelProvider: ChannelProvider {
    weak var delegate: ChannelProviderDelegate?
    private var firestoreProvider: FirestoreProvider
    
    private var listener: ListenerRegistration?
    
    init(firestoreProvider: FirestoreProvider) {
        self.firestoreProvider = firestoreProvider
    }
    
    func get() {
        listener?.remove()
        
        listener = firestoreProvider.getChannels { [weak self] channels, error in
            if let error = error {
                self?.delegate?.fetched(.failure(error))
            }
            
            if let channels = channels {
                self?.delegate?.fetched(.success(channels))
            }
        }
    }
    
    func add(withName name: String, completion: @escaping (Error?) -> Void) {
        firestoreProvider.createChannel(withName: name, completion: completion)
    }
    
    func delete(withUID uid: String, completion: @escaping (Error?) -> Void) {
        firestoreProvider.deleteChannel(atPath: uid, completion: completion)
    }
    
    deinit {
        listener?.remove()
    }
}
