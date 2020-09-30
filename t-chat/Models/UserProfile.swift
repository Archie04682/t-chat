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
    
    var initials: String {
        let components = username.components(separatedBy: " ").filter { !$0.isEmpty }
        if components.count <= 0 { return "" }
        if components.count <= 2 {
            return components.map { word in
                if let firstLetter = word.first {
                    return String(firstLetter)
                }

                return ""
            }.joined()
        }
        
        return "\(components.first ?? "")\(components.last ?? "")"
    }
}
