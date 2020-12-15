//
//  Message.swift
//  t-chat
//
//  Created by Артур Гнедой on 17.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import Foundation
import Firebase

// Я так и не понял, как можно реализовать через Codable конвертацию из [String: Any] в модели. Проблема в FIRTimestamp, который нужно как то сереализовать перед декодингом.
// Я не нашел как это сделать без пакета FirebaseFirestore.

struct Message {
    let uid: String?
    let content: String
    let created: Date
    let senderId: String
    let senderName: String
    
    init(content: String, created: Date, senderId: String, senderName: String, uid: String? = nil) {
        self.content = content
        self.created = created
        self.senderId = senderId
        self.senderName = senderName
        self.uid = uid
    }
    
    init?(_ dictionary: [String: Any]) {
        guard let uid = dictionary["uid"] as? String,
            let content = dictionary["content"] as? String,
            let created = dictionary["created"] as? Timestamp,
            let senderId = dictionary["senderId"] as? String,
            let senderName = dictionary["senderName"] as? String else { return nil }
        self.init(content: content, created: created.dateValue(), senderId: senderId, senderName: senderName, uid: uid)
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "created": Timestamp(date: created),
            "content": content,
            "senderId": senderId,
            "senderName": senderName
        ]
    }
}
