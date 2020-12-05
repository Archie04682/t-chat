//
//  ConfigurationService.swift
//  t-chat
//
//  Created by Артур Гнедой on 05.12.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import Foundation

protocol ConfigurationService {
    func get(forKey key: String) -> Any?
}

enum PixabayConfigurationSettings: String {
    case api = "Pixabay Api", apiKey = "Pixabay Api Key"
}

enum ConfigurationServiceError: Error {
    case missingKey
}

final class DefaultConfigurationService: ConfigurationService {
    func get(forKey key: String) -> Any? {
        return Bundle.main.object(forInfoDictionaryKey: key)
    }
}
