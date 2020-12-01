//
//  ChannelDataProviderMock.swift
//  Tests
//
//  Created by Артур Гнедой on 30.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

@testable import t_chat
import Foundation

class ChannelDataProviderMock: ChannelProvider {
    var delegate: ChannelProviderDelegate?
    
    var addCallsCount: Int = 0
    var getCallsCount: Int = 0
    var deleteCallsCount: Int = 0
    
    func get() {
        delegate?.fetched(.success([Channel(identifier: "id", name: "testName", lastMessage: "", lastActivity: Date())]))
        getCallsCount += 1
    }
    
    func add(withName name: String, completion: @escaping (Error?) -> Void) {
        addCallsCount += 1
        if name == "failedName" {
            completion(NetworkError.wrongData)
        } else {
            completion(nil)
        }
        
    }
    
    func delete(withUID uid: String, completion: @escaping (Error?) -> Void) {
        deleteCallsCount += 1
    }
    
}
