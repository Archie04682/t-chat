//
//  ProfileManagerFactoryMock.swift
//  Tests
//
//  Created by Артур Гнедой on 02.12.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

@testable import t_chat

import Foundation

final class UserProfileDataManagerMock: UserProfileDataManager {
    
    var writeLastCallParameter: [UserProfile.Keys: Data?] = [:]
    var writeCallsCount = 0
    
    func write(_ data: [UserProfile.Keys: Data?], completion: @escaping ([UserProfile.Keys: Error]?, Error?) -> Void) {
        writeCallsCount += 1
        writeLastCallParameter = data
        
        completion(nil, nil)
    }
    
    func read(completion: @escaping (UserProfile?, Error?) -> Void) {
        completion(UserProfile(username: "Username", about: "About", photoURL: nil, photoData: nil), nil)
    }
    
}

final class ProfileManagerFactoryMock: ProfileManagerFactory {
    
    func getDefault() -> UserProfileDataManager {
        return self.create(ofType: .GCD)
    }
    
    func create(ofType type: ManagerType) -> UserProfileDataManager {
        return UserProfileDataManagerMock()
    }
    
}
