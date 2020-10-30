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
    
    private(set) lazy var viewContext: NSManagedObjectContext = {
        return coreDataStack.mainContext
    }()
    
    func add(channel: Channel) {
        coreDataStack.save { context in
            ChannelEntity(with: channel, in: context)
        }
    }
    
    func add(channels: [Channel]) {
        coreDataStack.save { context in
            let existingUIDRequest: NSFetchRequest<NSFetchRequestResult> = ChannelEntity.fetchRequest()
            existingUIDRequest.propertiesToFetch = ["uid"]
            existingUIDRequest.resultType = .dictionaryResultType
            
            do {
                var uids = try context.fetch(existingUIDRequest) as? [[String: String]]
                channels.forEach { channel in
                    let fetchRequest: NSFetchRequest<ChannelEntity> = ChannelEntity.fetchRequest()
                    fetchRequest.fetchLimit = 1
                    fetchRequest.predicate = NSPredicate(format: "uid == %@", channel.identifier)
                    if let existing = try? context.fetch(fetchRequest).first {
                        if existing.name != channel.name { existing.name = channel.name }
                        if existing.lastMessage != channel.lastMessage { existing.lastMessage = channel.lastMessage }
                        if existing.lastActivity != channel.lastActivity { existing.lastActivity = channel.lastActivity }
                        if let index = uids?.firstIndex(where: { $0["uid"] == existing.uid }) {
                            uids?.remove(at: index)
                        }
                    } else {
                        ChannelEntity(with: channel, in: context)
                    }
                }
                
                if let uids = uids, !uids.isEmpty {
                    uids.forEach { dict in
                        guard let uid = dict["uid"] else { return }
                        let fetchRequest: NSFetchRequest<ChannelEntity> = ChannelEntity.fetchRequest()
                        fetchRequest.fetchLimit = 1
                        fetchRequest.predicate = NSPredicate(format: "uid == %@", uid)
                        if let object = try? context.fetch(fetchRequest).first {
                            context.delete(object)
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
    func delete(with id: NSManagedObjectID) {
        coreDataStack.save { context in
            guard let existing = try? context.existingObject(with: id) else { return }
            context.delete(existing)
        }
    }
    
    func addMessages(messages: [Message], toObjectWithID channelID: NSManagedObjectID) {
        coreDataStack.save { context in
            do {
                if let existingChannel = try context.existingObject(with: channelID) as? ChannelEntity {
                    for message in messages {
                        if let uid = message.uid {
                            let fetchRequest: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
                            fetchRequest.predicate = NSPredicate(format: "uid == %@", uid)
                            if let count = try? context.count(for: fetchRequest), count == 0, let entity = MessageEntity(with: message, in: context) {
                                existingChannel.addToMessages(entity)
                            }
                        }
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
