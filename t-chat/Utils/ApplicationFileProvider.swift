//
//  FolderStructure.swift
//  t-chat
//
//  Created by Артур Гнедой on 10.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import Foundation

enum ApplicationFileProviderError: Error {
    case badAccessToFilesystem
}

final class ApplicationFileProvider {
    static let folderName = "t_chat_UserProfile"
    
    static func provideFileName(for key: UserProfile.Keys) -> String {
        switch key {
        case .username:
            return "username.txt"
        case .about:
            return "about_user.txt"
        case .photoData:
            return "profile_photo.png"
        }
    }
    
    func getApplicationFolder() throws -> URL {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let directory = documentDirectory.first {
            let userProfileFolder = URL(fileURLWithPath: directory).appendingPathComponent(ApplicationFileProvider.folderName)
            var dir = ObjCBool(true)
            if !FileManager.default.fileExists(atPath: userProfileFolder.path, isDirectory: &dir) {
                do {
                    try FileManager.default.createDirectory(at: userProfileFolder, withIntermediateDirectories: true, attributes: nil)
                    
                } catch {
                    throw error
                }
            }
            
            return userProfileFolder
        }
        
        throw ApplicationFileProviderError.badAccessToFilesystem
    }
    
    static func isFirstLaunch() -> Bool {
        var dir = ObjCBool(true)
        return !FileManager.default.fileExists(atPath: URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
            .appendingPathComponent(ApplicationFileProvider.folderName).path,
                                               isDirectory: &dir)
    }
}
