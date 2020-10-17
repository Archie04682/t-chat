//
//  ProfileViewModel.swift
//  t-chat
//
//  Created by Артур Гнедой on 13.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import Foundation

class ProfileModel {
    
    weak var delegate: ProfileModelDelegate?
    
    private let factory: UserProfileDataManagerFactory
    private var userProfile: UserProfile = UserProfile(username: "", about: "", photoURL: nil, photoData: nil)
    
    var photoData: Data? {
        return userProfile.photoData
    }
    
    var username: String {
        return userProfile.username
    }
    
    var about: String {
        return userProfile.about
    }
    
    var changedData: [UserProfile.Keys: Data?] = [:] {
        didSet {
            var changed = !changedData.isEmpty
            
            if let u = changedData[.username], let data = u {
                changed = changed && data.count > 0
            }
            
            self.delegate?.isDirty(changed)
        }
    }
    
    init() {
        factory = UserProfileDataManagerFactory()
    }
    
    func load(with type: ManagerType = .GCD, completion: @escaping (UserProfile?, Error?) -> Void) {
        factory.create(ofType: type).read {[weak self] profile, error in
            if let error = error {
                completion(nil, error)
            } else if let profile = profile {
                self?.userProfile = profile
                
                completion(profile, nil)
            }
        }
    }
    
    func save(with type: ManagerType) {
        factory.create(ofType: type).write(changedData) {[weak self] failedProperties, error in
            if let self = self {
                if let error = error {
                    self.delegate?.didFailUpdate(error)
                } else {
                    for item in self.changedData.filter({ key, _ in failedProperties?.index(forKey: key) == nil }) {
                        self.userProfile.setValue(forKey: item.key, value: item.value)
                        self.changedData.removeValue(forKey: item.key)
                    }
                    print(self.userProfile)
                    self.delegate?.didUpdate(provider: type, userProfile: self.userProfile, failToUpdateProperties: failedProperties)
                }
            }
        }
    }
    
    func photoIsSame(with data: Data?) -> Bool {
        return userProfile.photoData == data
    }
}

protocol ProfileModelDelegate: class {
    
    func didUpdate(provider: ManagerType, userProfile: UserProfile, failToUpdateProperties: [UserProfile.Keys: Error]?)
    
    func didFailUpdate(_ error: Error)
    
    func isDirty(_ value: Bool)
}
