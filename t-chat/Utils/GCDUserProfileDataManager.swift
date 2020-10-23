//
//  GCDDataManager.swift
//  t-chat
//
//  Created by Артур Гнедой on 09.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import Foundation

class GCDUserProfileDataManager: UserProfileDataManager {
    private let dispatchQueue: DispatchQueue
    private let applicationFileProvider: ApplicationFileProvider
    init() {
        dispatchQueue = DispatchQueue(label: "UserProfileService", qos: .userInitiated, attributes: [], autoreleaseFrequency: .inherit, target: nil)
        applicationFileProvider = ApplicationFileProvider()
    }
    
    func read(completion: @escaping (UserProfile?, Error?) -> ()){
        let dispatchGroup = DispatchGroup()
        do {
            let userProfileFolder = try applicationFileProvider.getApplicationFolder()
            var userProfile = UserProfile(username: "", about: "", photoURL: nil, photoData: nil)
            for property in UserProfile.Keys.allCases {
                dispatchGroup.enter()
                let fileURL = userProfileFolder.appendingPathComponent(ApplicationFileProvider.provideFileName(for: property))
                
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    userProfile.setValue(forKey: property, value: try Data(contentsOf: fileURL))
                }
                
                dispatchGroup.leave()
            }
            
            dispatchGroup.notify(queue: dispatchQueue) {
                completion(userProfile, nil)
            }
        } catch {
            completion(nil, error)
        }
    }
    
    func write(_ data: [UserProfile.Keys:Data?], completion: @escaping ([UserProfile.Keys : Error]?, Error?) -> ()) {
        var errors: [UserProfile.Keys : Error] = [:]
        let group = DispatchGroup()
        do {
            let userProfileFolder = try applicationFileProvider.getApplicationFolder()
            for item in data {
                let url = userProfileFolder.appendingPathComponent(ApplicationFileProvider.provideFileName(for: item.key))
                if let dataToSave = item.value, dataToSave.count > 0 {
                    group.enter()
                    write(contents: dataToSave, atPath: url) { error in
                        if let error = error {
                            errors[item.key] = error
                        }
                        
                        group.leave()
                    }
                } else {
                    group.enter()
                    delete(at: url) { error in
                        if let error = error {
                            errors[item.key] = error
                        }
                        
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: dispatchQueue) {
                completion(errors, nil)
            }
            
        } catch {
            completion(nil, error)
        }
    }
    
    private func write(contents: Data, atPath url: URL, completion: @escaping (Error?) -> ()) {
        dispatchQueue.async {
            do {
                try contents.write(to: url, options: .atomicWrite)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    private func delete(at url: URL, completion: @escaping (Error?) -> ()) {
        do {
            try FileManager.default.removeItem(at: url)
            completion(nil)
        } catch {
            completion(error)
        }
    }
}
