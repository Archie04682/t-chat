//
//  ChannelsRepository.swift
//  t-chat
//
//  Created by Артур Гнедой on 27.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import CoreData
import Foundation

final class ChannelRepository {
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    func add(channels: [Channel], completion: @escaping (Error?) -> Void) {
        coreDataStack.save({ context in
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
                completion(error)
            }
        }, completion: { error in
            completion(error)
        })
    }
    
    func addMessages(messages: [Message], toObjectWithID channelID: NSManagedObjectID, completion: @escaping (Error?) -> Void) {
        coreDataStack.save({ context in
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
        }, completion: { error in
            completion(error)
        })
    }
    
    func createChannelsFetchResultsController(sortBy sortField: String,
                                              ascending: Bool,
                                              fetchBatchSize: Int = 20,
                                              withCache: Bool = false) -> NSFetchedResultsController<ChannelEntity> {
        let request: NSFetchRequest<ChannelEntity> = ChannelEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: sortField, ascending: ascending)]
        request.fetchBatchSize = fetchBatchSize
        let controller = NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: coreDataStack.mainContext,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: withCache ? "ChannelsCache" : nil)
        
        return controller
    }
    
    func createMessagesFetchResultsController(forChannel channelId: NSManagedObjectID,
                                              sortBy sortField: String,
                                              ascending: Bool,
                                              fetchBatchSize: Int = 20,
                                              withCache: Bool = false) -> NSFetchedResultsController<MessageEntity> {
        let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(MessageEntity.channel), channelId)
        request.sortDescriptors = [NSSortDescriptor(key: sortField, ascending: ascending)]
        request.fetchBatchSize = fetchBatchSize
        let controller = NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: coreDataStack.mainContext,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: withCache ? "MessagesCache" : nil)
        
        return controller
    }
}
