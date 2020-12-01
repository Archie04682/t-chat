//
//  ChannelServiceMock.swift
//  Tests
//
//  Created by Артур Гнедой on 30.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

@testable import t_chat

class ChannelRepositoryMock: ChannelRepository {
    var delegate: ChannelRepositoryDelegate?
    var addCallsCount: Int = 0
    
    func add(channels: [Channel], completion: @escaping (Error?) -> Void) {
        addCallsCount += 1
        completion(nil)
    }

}
