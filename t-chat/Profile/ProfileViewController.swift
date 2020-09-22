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
    
    
    @IBOutlet weak var profileImageContainer: UIView!
    @IBOutlet weak var editProfileImageButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!

    
    private var profileImageURL: URL?
    private var initialsLabel: UILabel?
    private var profileImageView: UIImageView?
    private let imagePicker = ImagePicker()
    
    private let username = "Marina Dudarenko"
    
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
        print(saveButton.frame)
        setupViews()
        self.imagePicker.delegate = self
        self.imagePicker.viewController = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /*
        Значения Frame разные, потому что сначала вычисляются значения frame по констрейнтам. Это Update этап.
        
        Далее, идет этап Layout, который отвечает за размеров и позиций View и его Subviews на экране.
        
        Если выставить девайс в Storyboard IPhone 11 Pro, то разницы между выводимыми сообщениями не будет. Как я понял, это потому, что высота и ширина экрана будет одинаковой у девайса в Storyboard и эмулятора.
        */
        print(saveButton.frame)
    }
    
    @IBAction func editProfileImageButtonPressed(_ sender: Any) {
        editProfilePhoto()
    }
}

extension ProfileViewController {
    
    func setupViews() {
        profileImageContainer.layer.cornerRadius = profileImageContainer.frame.width / 2

        saveButton.layer.cornerRadius = 14
        saveButton.clipsToBounds = true
        
        usernameLabel.text = username
        displayProfileImage()
    }
    
    func displayProfileImage() {
        if profileImageURL == nil {
            profileImageView?.removeFromSuperview()
            profileImageView = nil
            createInitialsPlaceholder()
        } else {
            initialsLabel?.removeFromSuperview()
            initialsLabel = nil
            createProfileImage()
        }
    }

    func createInitialsPlaceholder() {
        let initials = username.components(separatedBy: " ").map { word in
            if let firstLetter = word.first {
                return String(firstLetter)
            }

            return ""
        }.joined()

        let label = UILabel()

        label.text = initials
        label.font = UIFont.systemFont(ofSize: 120)
        label.textAlignment = .center

        profileImageContainer.addSubview(label)
        label.centerIn(superview: profileImageContainer)
        initialsLabel = label
    }
    
    func createProfileImage() {
        if let imageURL = profileImageURL {
            do {
                if let image = try ImageManager.getImageFrom(url: imageURL) {
                    let imageView = UIImageView(image: image)
                    imageView.frame = CGRect(x: 0, y: 0, width: 240, height: 240)
                    imageView.layer.cornerRadius = imageView.frame.width / 2
                    imageView.contentMode = UIView.ContentMode.scaleAspectFill
                    imageView.clipsToBounds = true

                    profileImageContainer.addSubview(imageView)
                    imageView.centerIn(superview: profileImageContainer)

                    profileImageView = imageView
                }
                
            } catch {
                let ac = UIAlertController(title: "Ошибка", message: "Произошла ошибка при загрузке изображения.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
                present(ac, animated: true) {
                    self.createInitialsPlaceholder()
                }
            }
        }
    }
    
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func editProfilePhoto() {
        let ac = TCAlertController(title: "Изменить фото", message: nil, preferredStyle: .actionSheet)

        ac.addAction(UIAlertAction(title: "Выбрать из галлереи", style: .default) { _ in
            self.imagePicker.pickImage(with: .photoLibrary)
        })
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            ac.addAction(UIAlertAction(title: "Сделать фото", style: .default) { _ in
                self.imagePicker.pickImage(with: .camera)
            })
        }
        
        ac.addAction(UIAlertAction(title: "Удалить изображение", style: .destructive) {[weak self] _ in
            guard let self = self else { return }
            self.profileImageURL = nil
            self.displayProfileImage()
        })
        ac.addAction(UIAlertAction(title: "Отменить", style: .cancel))
        present(ac, animated: true)
    }
    
}

extension ProfileViewController: ImagePickerDelegate {
    
    func didSelectImage(url: URL?) {
        self.profileImageURL = url
        self.displayProfileImage()
    }
    
}

extension UIView {
    func centerIn(superview: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: superview.centerYAnchor).isActive = true
        self.widthAnchor.constraint(equalTo: superview.widthAnchor).isActive = true
        self.heightAnchor.constraint(equalTo: superview.heightAnchor).isActive = true
    }
}
