//
//  Parser.swift
//  t-chat
//
//  Created by Артур Гнедой on 18.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import Foundation
import UIKit

protocol Parser {
    
    func photoList(from data: Data) -> Result<[NetworkPhoto], Error>
    
}

final class PixabayParser: Parser {
    
    func photoList(from data: Data) -> Result<[NetworkPhoto], Error> {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                return .failure(JsonParseError.badJSON)
            }
            
            guard let images = json["hits"] as? [[String: Any]] else {
                return .failure(JsonParseError.emptyData)
            }
            
            var photos: [NetworkPhoto] = []
            
            for image in images {
                if let preview = image["previewURL"] as? String, let photo = image["largeImageURL"] as? String {
                    guard let previewURL = URL(string: preview), let imageURL = URL(string: photo) else {
                        return .failure(JsonParseError.badJSON)
                    }
                    
                    photos.append(NetworkPhoto(previewURL: previewURL, imageURL: imageURL))
                }
            }
            
            return .success(photos)
            
        } catch {
            return .failure(JsonParseError.badJSON)
        }
    }
    
}

enum JsonParseError: Error {
    case badJSON
    case emptyData
}
