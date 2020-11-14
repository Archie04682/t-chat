//
//  ChannelService.swift
//  t-chat
//
//  Created by Артур Гнедой on 12.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import Foundation

protocol ChannelServiceDelegate: AnyObject {
    func data(_ result: Result<[ObjectChanges<Channel>], Error>)
}

protocol ChannelService {
    var delegate: ChannelServiceDelegate? { get set }
    
    func add(withName name: String, completion: @escaping (Error?) -> Void)
    
    func delete(withUID uid: String, completion: @escaping (Error?) -> Void)
}

final class CombinedChannelService: ChannelService {
    private var channelProvider: ChannelProvider
    private var channelRepository: ChannelRepository
    
    private var isLaunched = false
    
    weak var delegate: ChannelServiceDelegate? {
        didSet {
            channelRepository.delegate = self
        }
    }
    
    init(channelDataProvider: ChannelProvider, channelRepository: ChannelRepository) {
        self.channelProvider = channelDataProvider
        self.channelRepository = channelRepository
    }
    
    func add(withName name: String, completion: @escaping (Error?) -> Void) {
        channelProvider.add(withName: name, completion: completion)
    }
    
    func delete(withUID uid: String, completion: @escaping (Error?) -> Void) {
        channelProvider.delete(withUID: uid, completion: completion)
    }
}

extension CombinedChannelService: ChannelProviderDelegate {
    
    func fetched(_ result: Result<[Channel], Error>) {
        switch result {
        case .success(let channels):
            channelRepository.add(channels: channels) {[weak self] error in
                if let error = error {
                    self?.delegate?.data(.failure(error))
                }
            }
        case .failure(let error):
            delegate?.data(.failure(error))
        }
    }

}

extension CombinedChannelService: ChannelRepositoryDelegate {
    
    func channelsUpdated(_ data: Result<[ObjectChanges<Channel>], Error>) {
        switch data {
        case .success(let objects):
            delegate?.data(.success(objects))
            if !isLaunched {
                channelProvider.delegate = self
                channelProvider.get()
                isLaunched = true
            }
        case .failure(let error):
            delegate?.data(.failure(error))
        }
    }
    
}
