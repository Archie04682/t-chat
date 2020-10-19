//
//  FirestoreProvider.swift
//  t-chat
//
//  Created by Артур Гнедой on 17.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import Foundation
import Firebase

class FirestoreProvider {
    lazy var db = Firestore.firestore()
    
    func getChannels(completion: @escaping ([Channel]?, Error?) -> Void) -> ListenerRegistration {
        return db.collection("channels").addSnapshotListener { snapshot, error in
            if let error = error {
                completion(nil, error)
            } else if let documents = snapshot?.documents {
                let channels = documents.map {
                    Channel(identifier: $0.documentID,
                            name: $0["name"] as? String ?? "",
                            lastMessage: $0["lastMessage"] as? String ?? "",
                            lastActivity: ($0["lastActivity"] as? Timestamp)?.dateValue())
                }.filter { $0.name.count > 0 }.sorted(by: { first, second in
                    guard let firstDate = first.lastActivity else { return false }
                    guard let secondDate = second.lastActivity else { return true }
                    return firstDate > secondDate
                })
                
                completion(channels, nil)
            }
        }
    }
    
    func createChannel(withName name: String, completion: @escaping (Error?) -> Void) {
        db.collection("channels").addDocument(data: ["name": name]) { error in
            completion(error)
        }
    }
    
    func getMessages(forChannel channelId: String, completion: @escaping ([Message]?, Error?) -> Void) -> ListenerRegistration {
        return db.collection("channels").document(channelId).collection("messages").addSnapshotListener { snapshot, error in
            if let error = error {
                completion(nil, error)
            } else if let messages = snapshot?.documents {
                let messages = messages.map {
                    Message(content: $0["content"] as? String ?? "",
                            created: ($0["created"] as? Timestamp)?.dateValue() ?? Date(),
                            senderId: $0["senderId"] as? String ?? "",
                            senderName: $0["senderName"] as? String ?? "")
                }.sorted(by: { $0.created < $1.created })

                completion(messages, nil)
            }
        }
    }
}
