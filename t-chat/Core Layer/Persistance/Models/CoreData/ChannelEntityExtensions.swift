//
//  ChannelEntityExtensions.swift
//  t-chat
//
//  Created by Артур Гнедой on 27.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import CoreData
import Foundation

extension ChannelEntity {
    convenience init(uid: String, name: String, lastMessage: String?, lastActivity: Date?, in context: NSManagedObjectContext) {
        self.init(context: context)
        self.uid = uid
        self.name = name
        self.lastMessage = lastMessage
        self.lastActivity = lastActivity
    }
    
    @discardableResult
    convenience init(with channel: Channel, in context: NSManagedObjectContext) {
        self.init(context: context)
        self.uid = channel.identifier
        self.name = channel.name
        self.lastMessage = channel.lastMessage
        self.lastActivity = channel.lastActivity
    }
}
