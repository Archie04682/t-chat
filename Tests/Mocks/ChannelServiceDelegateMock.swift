//
//  ChannelServiceDelegateMock.swift
//  Tests
//
//  Created by Артур Гнедой on 30.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

@testable import t_chat
import Foundation

class ChannelServiceDelegateMock: ChannelServiceDelegate {
    
    var delegateCallsCount: Int = 0
    
    func data(_ result: Result<[ObjectChanges<Channel>], Error>) {
        delegateCallsCount += 1
    }
    
}
