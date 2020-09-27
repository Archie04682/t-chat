//
//  UserProfileViewController.swift
//  t-chat
//
//  Created by Артур Гнедой on 18.09.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit
import Photos

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: ProfileImageView!
    @IBOutlet weak var editProfileImageButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    private var userProfile = UserProfile(username: "Marina Dudarenko", about: "UX/UI designer, web-designer Moscow, Russia")

    private let imagePicker = ImagePicker()
    
    required init?(coder: NSCoder) {
        /*
         Нельзя получить доступ к saveButton, т.к. при инициализации VC он еще не создан и saveButton == nil.
         Обернул в if let чтобы не возникало ошибки.
         */
        if let button = saveButton {
            print(button.frame)
        }
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(#function):\t\t \(saveButton.frame)")
        setupViews()
        imagePicker.delegate = self
        imagePicker.viewController = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /*
         Значения отличаются, т.к. на этапе viewDidLoad() мы получаем значения frame по констрейнтам и размерам экрана в Storyboard и пока у нас нет размеров девайса, на котором мы запустили.
         Контролы заресайзятся и расположатся в layoutSubviews и мы получим реальные значения на девайсе, где запустили приложение.
        
        Если выставить девайс в Storyboard IPhone 11 Pro, то разницы между выводимыми сообщениями не будет.
        */
        print("\(#function):\t \(saveButton.frame)")
    }
    
    @IBAction func editProfileImageButtonPressed(_ sender: Any) {
        editProfilePhoto()
    }
}

extension ProfileViewController {
    
    func setupViews() {
        saveButton.layer.cornerRadius = 14
        saveButton.clipsToBounds = true
        
        usernameLabel.text = userProfile.username
        aboutLabel.text = userProfile.about

        updateProfileImage()
    }
    
    func updateProfileImage() {
        if userProfile.photoURL == nil {
            setInitials()
        } else {
            setProfileImage()
        }
    }

    func setInitials() {
        profileImageView.initials = userProfile.initials
    }
    
    func setProfileImage() {
        if let imageURL = userProfile.photoURL {
            do {
                if let image = try ImageManager.shared.getImageFrom(url: imageURL) {
                    profileImageView.image = image
                }
                
            } catch {
                let ac = UIAlertController(title: "Ошибка", message: "Произошла ошибка при загрузке изображения.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
                present(ac, animated: true) {
                    self.setInitials()
                }
            }
        }
    }
    
    func editProfilePhoto() {
        let ac = AlertController(title: "Изменить фото", message: nil, preferredStyle: .actionSheet)

        ac.addAction(UIAlertAction(title: "Выбрать из галлереи", style: .default) { _ in
            self.imagePicker.pickImage(with: .photoLibrary)
        })
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            ac.addAction(UIAlertAction(title: "Сделать фото", style: .default) { _ in
                self.imagePicker.pickImage(with: .camera)
            })
        }
        
        if userProfile.photoURL != nil {
            ac.addAction(UIAlertAction(title: "Удалить изображение", style: .destructive) { _ in
                self.userProfile.photoURL = nil
                self.updateProfileImage()
            })
        }
        
        ac.addAction(UIAlertAction(title: "Отменить", style: .cancel))
        present(ac, animated: true)
    }
    
}

extension ProfileViewController: ImagePickerDelegate {
    
    func didSelectImage(url: URL?) {
        self.userProfile.photoURL = url
        self.updateProfileImage()
    }
    
}
