//
//  ChannelsRepository.swift
//  t-chat
//
//  Created by Артур Гнедой on 27.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import CoreData
import Foundation

class ChannelRepository {
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    func fetchBy(uid: String) throws -> ChannelEntity? {
        let fetchRequest: NSFetchRequest<ChannelEntity> = ChannelEntity.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "uid = \"\(uid)\"")
        return (try coreDataStack.mainContext.fetch(fetchRequest) as [ChannelEntity]).first
    }
    
    func add(channel: Channel) {
        coreDataStack.save { context in
            ChannelEntity(with: channel, in: context)
        }
    }
    
    func add(channels: [Channel]) {
        coreDataStack.save { context in
            channels.forEach { ChannelEntity(with: $0, in: context) }
        }
    }
    
    func addMessages(messages: [Message], toObjectWithID channelID: NSManagedObjectID) {
        coreDataStack.save { context in
            do {
                if let existingChannel = try context.existingObject(with: channelID) as? ChannelEntity {
                    messages.compactMap { MessageEntity(with: $0, in: context) }.forEach { existingChannel.addToMessages($0) }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func addMessages(messages: [Message], to channel: Channel) {
        let fetchRequest: NSFetchRequest<ChannelEntity> = ChannelEntity.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "uid = \"\(channel.identifier)\"")
        coreDataStack.save { context in
            do {
                if let channel = (try context.fetch(fetchRequest) as [ChannelEntity]).first {
                    messages.compactMap { MessageEntity(with: $0, in: context) }.forEach { channel.addToMessages($0) }
                }
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
