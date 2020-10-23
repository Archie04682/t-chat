//
//  OperationsUserProfileManager.swift
//  t-chat
//
//  Created by Артур Гнедой on 10.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import Foundation

class OperationsUserProfileManager: UserProfileDataManager {
    private let operationQueue: OperationQueue
    private let applicationFileProvider: ApplicationFileProvider
    init() {
        operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 3
        operationQueue.qualityOfService = .userInitiated
        applicationFileProvider = ApplicationFileProvider()
    }
    
    func read(completion: @escaping (UserProfile?, Error?) -> ()) {
        do {
            let userProfileFolder = try applicationFileProvider.getApplicationFolder()
            var operations: [Operation] = UserProfile.Keys.allCases.map {
                FileReadOperation(url: userProfileFolder.appendingPathComponent(ApplicationFileProvider.provideFileName(for: $0)), forKey: $0)
            }
            
            let adapter = UserProfileAdapterOperation()
            adapter.completionBlock = {
                if let error = adapter.error {
                    completion(nil, error)
                } else {
                    completion(adapter.output, nil)
                }
            }
            
            operations.forEach { adapter.addDependency($0) }
            operations.append(adapter)
            
            operationQueue.addOperations(operations, waitUntilFinished: true)
        } catch {
            completion(nil, error)
        }
    }
    
    func write(_ data: [UserProfile.Keys:Data?], completion: @escaping ([UserProfile.Keys : Error]?, Error?) -> ()) {
        do {
            let userProfileFolder = try applicationFileProvider.getApplicationFolder()
            var operations: [Operation] = []
            for item in data {
                let url = userProfileFolder.appendingPathComponent(ApplicationFileProvider.provideFileName(for: item.key))
                if let value = item.value {
                    operations.append(FileWriteOperation(atPath: url, contents: value, forKey: item.key))
                } else {
                    operations.append(FileDeleteOperation(atPath: url))
                }
            }
            
            let completeOperation = ProfileWriteCompleteOperation()
            operations.forEach {
                completeOperation.addDependency($0)
            }
            
            completeOperation.completionBlock = {
                completion(completeOperation.errors, nil)
            }
            
            operations.append(completeOperation)
            
            operationQueue.addOperations(operations, waitUntilFinished: false)
        } catch {
            completion(nil, error)
        }
    }
    
}
