//
//  ChannelEntity+CoreDataProperties.swift
//  t-chat
//
//  Created by Артур Гнедой on 27.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//
//

import Foundation
import CoreData

extension ChannelEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChannelEntity> {
        return NSFetchRequest<ChannelEntity>(entityName: "ChannelEntity")
    }

    @NSManaged public var uid: String
    @NSManaged public var name: String
    @NSManaged public var lastMessage: String?
    @NSManaged public var lastActivity: Date?
    @NSManaged public var messages: NSSet?

}

// MARK: Generated accessors for messages
extension ChannelEntity {

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: MessageEntity)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: MessageEntity)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)

}
