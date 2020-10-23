//
//  UserProfileDataManager.swift
//  t-chat
//
//  Created by Артур Гнедой on 10.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import Foundation

protocol UserProfileDataManager {
    
    func write(_ data: [UserProfile.Keys:Data?], completion: @escaping ([UserProfile.Keys : Error]?, Error?) -> ())
    
    func read(completion: @escaping (UserProfile?, Error?) -> ())  
}

class UserProfileDataManagerFactory {
    
    func getDefault() -> UserProfileDataManager {
        return create(ofType: .GCD)
    }
    
    func create(ofType type: ManagerType) -> UserProfileDataManager {
        switch type {
        case .GCD:
            return GCDUserProfileDataManager()
        case .operations:
            return OperationsUserProfileManager()
        }
    }
}

enum ManagerType {
    case GCD, operations
}
