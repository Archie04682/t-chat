//
//  ProfileServiceDelegateMock.swift
//  Tests
//
//  Created by Артур Гнедой on 02.12.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

@testable import t_chat

import Foundation

class ProfileServiceDelegateMock: ProfileServiceDelegate {
    
    var profileLastCallParameter: Result<UserProfile, Error>?
    var profileCallsCount = 0
    
    func profile(updated: Result<UserProfile, Error>) {
        profileLastCallParameter = updated
        profileCallsCount += 1
    }
    
}
