//
//  MessageEntityExtensions.swift
//  t-chat
//
//  Created by Артур Гнедой on 27.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import CoreData
import Foundation

extension MessageEntity {
    convenience init(uid: String, content: String, created: Date, senderId: String, senderName: String, in context: NSManagedObjectContext) {
        self.init(context: context)
        self.uid = uid
        self.content = content
        self.created = created
        self.senderId = senderId
        self.senderName = senderName
    }
    
    convenience init?(with message: Message, in context: NSManagedObjectContext) {
        self.init(context: context)
        
        guard let uid = message.uid else {
            return nil
        }
        
        self.uid = uid
        self.content = message.content
        self.created = message.created
        self.senderId = message.senderId
        self.senderName = message.senderName
    }
}
