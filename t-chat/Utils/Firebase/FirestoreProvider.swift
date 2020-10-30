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
                let channels = documents.compactMap { document -> Channel? in
                    var dict = document.data()
                    dict["documentID"] = document.documentID
                    return Channel(dict)
                }.sorted(by: { first, second in
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
    
    func deleteChannel(atPath path: String) {
        db.collection("channels").document(path).delete { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    func getMessages(forChannel channelId: String, completion: @escaping ([Message]?, Error?) -> Void) -> ListenerRegistration {
        return db.collection("channels").document(channelId).collection("messages").addSnapshotListener { snapshot, error in
            if let error = error {
                completion(nil, error)
            } else if let documents = snapshot?.documents {
                completion(documents.compactMap { document -> Message? in
                    var dict = document.data()
                    dict["uid"] = document.documentID
                    return Message(dict)
                }.sorted(by: { $0.created > $1.created }), nil)
            }
        }
    }
    
    func sendMessage(toChannel channelId: String, message: Message, completion: @escaping (Error?) -> Void) {
        db.collection("channels").document(channelId).collection("messages")
            .addDocument(data: message.toDictionary()) { error in
                                    completion(error)
        }
    }
}
