//
//  UserProfile.swift
//  t-chat
//
//  Created by Артур Гнедой on 22.09.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import Foundation

struct UserProfile {
    var username: String
    var about: String
    var photoURL: URL?
    var photoData: Data?
    
    enum Keys: CaseIterable {
        case username, about, photoData
    }
    
    mutating func setValue(forKey key: Keys, value: Data?) {
            switch key {
            case .username:
                if let data = value {
                    self.username = String(data: data, encoding: .utf8) ?? ""
                }
            case .about:
                if let data = value {
                    self.about = String(data: data, encoding: .utf8) ?? ""
                }
            case .photoData:
                self.photoData = value
            }
    }
}


