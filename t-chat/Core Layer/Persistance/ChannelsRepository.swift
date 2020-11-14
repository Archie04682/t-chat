//
//  ChannelsRepository.swift
//  t-chat
//
//  Created by Артур Гнедой on 27.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import CoreData
import Foundation

protocol ChannelRepositoryDelegate: AnyObject {
    func channelsUpdated(_ data: Result<[ObjectChanges<Channel>], Error>)
}

protocol ChannelRepository {
    var delegate: ChannelRepositoryDelegate? { get set }
    
    func add(channels: [Channel], completion: @escaping (Error?) -> Void)
}

final class CoreDataChannelRepository: NSObject, ChannelRepository {
    private let coreDataStack: CoreDataStack
    private var updated: [ObjectChanges<Channel>] = []
    
    private var frc: NSFetchedResultsController<ChannelEntity>?
    
    weak var delegate: ChannelRepositoryDelegate? {
        didSet {
            frc = createChannelsFetchResultsController(sortBy: #keyPath(ChannelEntity.lastActivity), ascending: false)
            frc?.delegate = self
            
            do {
                if let frc = frc {
                    
                    try frc.performFetch()
                    
                    if let enumerated = frc.fetchedObjects?.enumerated() {
                        for (index, ent) in enumerated {
                            let channel = Channel(from: ent)
                            updated.append(ObjectChanges<Channel>(index: nil, object: channel, newIndex: index, changeType: .insert))
                        }
                    }
                    
                    delegate?.channelsUpdated(.success(updated))
                    updated.removeAll()
                }
            } catch {
                delegate?.channelsUpdated(.failure(error))
            }
            
        }
    }
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
        
        super.init()
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

extension CoreDataChannelRepository: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updated.removeAll()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        if let object = anObject as? ChannelEntity {
            updated.append(ObjectChanges<Channel>(index: indexPath?.row, object: Channel(from: object), newIndex: newIndexPath?.row, changeType: ChangeType(from: type)))
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if !updated.isEmpty {
            delegate?.channelsUpdated(.success(updated))
        }
    }
}
