//
//  ProfileService.swift
//  t-chat
//
//  Created by Артур Гнедой on 13.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import Foundation

protocol ProfileServiceDelegate: AnyObject {
    func profile(updated: Result<UserProfile, Error>)
}

protocol ProfileService {
    var delegate: ProfileServiceDelegate? { get set }
    
    func load()
    
    func save(with type: ManagerType, data: [UserProfile.Keys: Data?], completion: @escaping ([UserProfile.Keys: Error]?, Error?) -> Void)
}

final class UserProfileService: ProfileService {
    private let profileManagerFactory: ProfileManagerFactory
    
    weak var delegate: ProfileServiceDelegate?
    
    init(profileManagerFactory: ProfileManagerFactory) {
        self.profileManagerFactory = profileManagerFactory
    }
    
    func load() {
        self.profileManagerFactory.getDefault().read { [weak self] profile, error in
            if let error = error {
                self?.delegate?.profile(updated: .failure(error))
            }
            
            if let profile = profile {
                self?.delegate?.profile(updated: .success(profile))
            }
        }
    }
    
    func save(with type: ManagerType, data: [UserProfile.Keys: Data?], completion: @escaping ([UserProfile.Keys: Error]?, Error?) -> Void) {
        self.profileManagerFactory.create(ofType: type).write(data) { failed, error in
            
            if let failed = failed {
                completion(failed, error)
            }
            
            if let error = error {
                completion(nil, error)
            }
        }
    }
}
