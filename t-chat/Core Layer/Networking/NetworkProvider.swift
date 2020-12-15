//
//  NetworkProvider.swift
//  t-chat
//
//  Created by Артур Гнедой on 18.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import Foundation

protocol NetworkProvider {
    
    func get(with url: URL, completion: @escaping (Result<Data, Error>) -> Void)
    
}

final class NetworkProviderImplementation: NetworkProvider {
    
    func get(with url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data {
                completion(.success(data))
            }
        }.resume()
    }
    
}
