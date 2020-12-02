//
//  ProfileServiceTests.swift
//  Tests
//
//  Created by Артур Гнедой on 02.12.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

@testable import t_chat
import XCTest

class ProfileServiceTests: XCTestCase {
    
    func testShouldLoadUserProfileOnInit() {
        
        let delegate = ProfileServiceDelegateMock()
        let profileManagerFactory = ProfileManagerFactoryMock()
        
        let sut = UserProfileService(profileManagerFactory: profileManagerFactory)
        sut.delegate = delegate
        
        if let profile = sut.profile {
            XCTAssertEqual("Username", profile.username)
            XCTAssertEqual("About", profile.about)
        } else {
            XCTFail("Failed init profile")
        }
        
    }
    
}
