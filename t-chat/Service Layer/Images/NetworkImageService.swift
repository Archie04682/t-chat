//
//  NetworkImageService.swift
//  t-chat
//
//  Created by Артур Гнедой on 18.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit
import Foundation

protocol NetworkImageService {
    func get(limit: Int,
             withTags tags: [String]?,
             completion: @escaping (Result<[NetworkPhoto], Error>) -> Void)
    
    func downloadImage(fromURL url: URL, completion: @escaping (Result<UIImage, Error>) -> Void)
}

final class PixabayImageService: NetworkImageService {
    private let networkProvider: NetworkProvider
    private let parser: Parser
    private let configurationService: ConfigurationService
    
    init(networkProvider: NetworkProvider, parser: Parser, configurationService: ConfigurationService) {
        self.networkProvider = networkProvider
        self.parser = parser
        self.configurationService = configurationService
    }
    
    func get(limit: Int,
             withTags tags: [String]? = [],
             completion: @escaping (Result<[NetworkPhoto], Error>) -> Void) {
        
        guard let apiURL = configurationService.get(forKey: PixabayConfigurationSettings.api.rawValue) as? String,
            let apiKey = configurationService.get(forKey: PixabayConfigurationSettings.apiKey.rawValue) as? String else {
                completion(.failure(ConfigurationServiceError.missingKey))
                return
        }
        
        var queryParams = [URLQueryItem(name: "key", value: apiKey),
                           URLQueryItem(name: "image_type", value: "photo"),
                           URLQueryItem(name: "per_page", value: "\(limit)")]
        
        if let tags = tags {
            queryParams.append(URLQueryItem(name: "q", value: tags.joined(separator: "+")))
        }
        
        var components = URLComponents(string: apiURL)
        
        components?.queryItems = queryParams
        
        guard let url = components?.url else {
            completion(.failure(NetworkError.badURL))
            return
        }
        
        networkProvider.get(with: url) {[weak self] result in
            switch result {
                
            case .success(let data):
                switch self?.parser.photoList(from: data) {
                case .success(let photos):
                    completion(.success(photos))
                case .failure(let error):
                    completion(.failure(error))
                case .none:
                    fatalError("Something went wrong")
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func downloadImage(fromURL url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        networkProvider.get(with: url) { result in
            switch result {
            case .success(let data):
                guard let image = UIImage(data: data) else {
                    completion(.failure(NetworkError.wrongData))
                    return
                }
                
                completion(.success(image))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}

enum NetworkError: Error {
    case badURL
    case wrongData
}
