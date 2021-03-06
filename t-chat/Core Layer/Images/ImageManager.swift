//
//  ImageManager.swift
//  t-chat
//
//  Created by Артур Гнедой on 21.09.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit
import Photos

protocol ImageManager {
    
    func getImageFrom(url: URL) throws -> UIImage?

    func save(_ image: UIImage, completion: @escaping (URL?) -> Void)
    
}

class LocalImageManager: ImageManager {
    
    func getImageFrom(url: URL) throws -> UIImage? {
        let data = try Data(contentsOf: url)
        return UIImage(data: data)
    }
    
    func save(_ image: UIImage, completion: @escaping (URL?) -> Void) {
        var placeHolder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            placeHolder = creationRequest.placeholderForCreatedAsset
        }, completionHandler: { success, _ in
            guard success, let placeholder = placeHolder else {
                completion(nil)
                return
            }
            let assets = PHAsset.fetchAssets(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
            guard let asset = assets.firstObject else {
                completion(nil)
                return
            }
            asset.requestContentEditingInput(with: nil, completionHandler: { (editingInput, _) in
                completion(editingInput?.fullSizeImageURL)
            })
        })
    }
    
}
