//
//  ImagePicker.swift
//  t-chat
//
//  Created by Артур Гнедой on 22.09.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit
import Photos

protocol ImagePickerDelegate: class {
    func didSelectImage(url: URL?)
}

class ImagePicker: NSObject {
    
    private let imagePickerController: UIImagePickerController
    weak var viewController: UIViewController?
    weak var delegate: ImagePickerDelegate?
    
    override init() {
        self.imagePickerController = UIImagePickerController()
        super.init()
        self.imagePickerController.delegate = self
    }
    
    func pickImage(with sourceType: UIImagePickerController.SourceType) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            showImagePicker(for: sourceType)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] updatedStatus in
                guard let self = self else { return }
                if updatedStatus == .authorized {
                    DispatchQueue.main.async {
                        self.showImagePicker(for: sourceType)
                    }
                } else {
                    self.showGoToSettingsAlert()
                }
            }
        default:
            showGoToSettingsAlert()
        }
    }
    
    private func showImagePicker(for sourceType: UIImagePickerController.SourceType) {
        self.imagePickerController.sourceType = sourceType
        self.imagePickerController.allowsEditing = false
        self.viewController?.present(self.imagePickerController, animated: true)
    }
    
    private func showGoToSettingsAlert() {
        let alertController = UIAlertController(title: "Нет разрешения", message: "Чтобы использовать фотографии из галереи или сделать фото, приложению необходим доступ к Фото и Камере.", preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: "К настройкам", style: .default) { (_) -> Void in

            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Отмена", style: .default, handler: nil)
        alertController.addAction(cancelAction)

        self.viewController?.present(alertController, animated: true, completion: nil)
    }
    
    private func didSelectImage(_ imagePickerController: UIImagePickerController, url: URL?) {
        imagePickerController.dismiss(animated: true) {
            self.delegate?.didSelectImage(url: url)
        }
    }

}

extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let url = info[.imageURL] as? URL {
            self.didSelectImage(picker, url: url)
        } else if let image = info[.originalImage] as? UIImage {
            ImageManager.saveToCameraRoll(image) { [weak self] url in
                guard let self = self, let url = url else { return }
                self.didSelectImage(picker, url: url)
            }
        }
    }
}
