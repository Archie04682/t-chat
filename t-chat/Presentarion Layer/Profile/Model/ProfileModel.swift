//
//  ProfileViewModel.swift
//  t-chat
//
//  Created by Артур Гнедой on 13.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import Foundation
import UIKit

class ProfileModel {
    
    weak var delegate: ProfileModelDelegate?
    private var profileService: ProfileService
    
    private var userProfile: UserProfile = UserProfile(username: "", about: "", photoURL: nil, photoData: nil)
    private(set) var identifier = UIDevice.current.identifierForVendor!.uuidString
    
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
            
            delegate?.isDirty(changed)
        }
    }
    
    init(profileService: ProfileService) {
        self.profileService = profileService
        
        self.profileService.delegate = self
        if let p = self.profileService.profile {
            self.userProfile = p
        }
    }
    
    func save(with type: ManagerType) {
        profileService.save(with: type, data: changedData) { [weak self] failedProperties, error in
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

extension ProfileModel: ProfileServiceDelegate {
    
    func profile(updated: Result<UserProfile, Error>) {
        switch updated {
        case .success(let profile):
            self.userProfile = profile
        case .failure(let error):
            delegate?.didFailUpdate(error)
        }
    }
    
}

protocol ProfileModelDelegate: class {
    
    func didUpdate(provider: ManagerType, userProfile: UserProfile, failToUpdateProperties: [UserProfile.Keys: Error]?)
    
    func didFailUpdate(_ error: Error)
    
    func isDirty(_ value: Bool)
}
