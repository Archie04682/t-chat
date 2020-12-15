//
//  Channel.swift
//  t-chat
//
//  Created by Артур Гнедой on 17.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import Foundation
import Firebase

struct Channel {
    let identifier: String
    let name: String
    let lastMessage: String?
    let lastActivity: Date?
    
    enum CodingKeys: String, CodingKey {
        case identifier
        case name
        case lastMessage
        case laseActivity
    }
    
    init(identifier: String, name: String, lastMessage: String?, lastActivity: Date?) {
        self.identifier = identifier
        self.name = name
        self.lastMessage = lastMessage
        self.lastActivity = lastActivity
    }

    init?(_ dictionary: [String: Any]) {
        guard let identifier = dictionary["documentID"] as? String,
            let name = dictionary["name"] as? String else { return nil }

        self.identifier = identifier
        self.name = name

        self.lastMessage = dictionary["lastMessage"] as? String

        self.lastActivity = (dictionary["lastActivity"] as? Timestamp)?.dateValue()
    }
    
    init(from entity: ChannelEntity) {
        self.identifier = entity.uid
        self.name = entity.name
        self.lastActivity = entity.lastActivity
        self.lastMessage = entity.lastMessage
    }

    func toDictionary() -> [String: Any] {
        return ["name": name]
    }
}
