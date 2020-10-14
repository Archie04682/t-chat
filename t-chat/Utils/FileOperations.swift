//
//  ReadOperation.swift
//  t-chat
//
//  Created by Артур Гнедой on 10.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import Foundation

class FileReadOperation: Operation {
    private var url: URL
    let key: UserProfile.Keys
    var output: Data?
    var error: Error?
    
    init(url: URL, forKey key: UserProfile.Keys) {
        self.url = url
        self.key = key
        super.init()
    }
    
    override func main() {
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                output = try Data(contentsOf: url)
            } catch {
                self.error = error
            }
        }
    }
}

class UserProfileAdapterOperation: Operation {
    var output: UserProfile = UserProfile(username: "", about: "", photoURL: nil, photoData: nil)
    var readOperations: [FileReadOperation] {
        if let readOperations = dependencies as? [FileReadOperation] {
            return readOperations
        }
        
        return []
    }
    
    var error: Error? {
        if let readOperations = dependencies.filter({ $0 is FileReadOperation }) as? [FileReadOperation], !readOperations.isEmpty {
            return readOperations.filter({ $0.error != nil }).first?.error
        }
        
        return nil
    }
    
    override func main() {
        for operation in readOperations {
            self.output.setValue(forKey: operation.key, value: operation.output)
        }
    }
}

class FileWriteOperation: Operation {
    private var url: URL
    var contents: Data
    var error: Error?
    let key: UserProfile.Keys
    
    init(atPath url: URL, contents: Data, forKey key: UserProfile.Keys) {
        self.url = url
        self.contents = contents
        self.key = key
        super.init()
    }
    
    override func main() {
        do {
            try contents.write(to: url, options: .atomicWrite)
//            try contents.write(to: URL(string: "Broken")!, options: .atomicWrite)
        } catch {
            self.error = error
        }
    }
}

class ProfileWriteCompleteOperation: Operation {
    var errors: [UserProfile.Keys:Error] {
        
        if let writeOperations = dependencies.filter({ $0 is FileWriteOperation }) as? [FileWriteOperation], !writeOperations.isEmpty {
            return Dictionary(uniqueKeysWithValues: writeOperations.filter {$0.error != nil}.map {($0.key, $0.error!)})
        }
        
        return [:]
        
    }
}

class FileDeleteOperation: Operation {
    private let url: URL
    
    var error: Error?
    
    init(atPath url: URL) {
        self.url = url
    }
    
    override func main() {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            self.error = error
        }
    }
}
