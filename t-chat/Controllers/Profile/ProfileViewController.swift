//
//  UpdatedProfileViewController.swift
//  t-chat
//
//  Created by Артур Гнедой on 27.09.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    private lazy var profileImageContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var profileImageView: ProfileImageView = {
        let view = ProfileImageView(frame: CGRect.init(origin: CGPoint.zero, size: CGSize(width: 240, height: 240)))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.89, green: 0.91, blue: 0.17, alpha: 1.00)
        
        return view
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var aboutUserLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
        button.layer.cornerRadius = 14
        
        return button
    }()
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let imagePicker = ImagePicker()
    private var userProfile: UserProfile
    
    init(user: UserProfile) {
        self.userProfile = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.setupViews()
        imagePicker.delegate = self
        imagePicker.viewController = self
    }
    
    private func setupViews() {
        layoutViews()
        usernameLabel.text = userProfile.username
        aboutUserLabel.text = userProfile.about
        updateProfileImage()
        let buttonGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(editButtonTapped))
        editButton.addGestureRecognizer(buttonGestureRecognizer)
    }
    
    @objc func editButtonTapped() {
        editProfilePhoto()
    }
    
    private func layoutViews() {
        profileImageContainer.addSubview(profileImageView)
        profileImageContainer.addSubview(editButton)
        
        containerView.addSubview(profileImageContainer)
        containerView.addSubview(usernameLabel)
        containerView.addSubview(saveButton)
        containerView.addSubview(aboutUserLabel)
        
        scrollView.addSubview(containerView)
        
        view.addSubview(scrollView)
        
        profileImageView.widthAnchor.constraint(equalTo: profileImageContainer.widthAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalTo: profileImageContainer.heightAnchor).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: profileImageContainer.centerXAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: profileImageContainer.centerYAnchor).isActive = true

        editButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        editButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        editButton.trailingAnchor.constraint(equalTo: profileImageContainer.trailingAnchor).isActive = true
        editButton.bottomAnchor.constraint(equalTo: profileImageContainer.bottomAnchor, constant: 14).isActive = true
        
        profileImageContainer.widthAnchor.constraint(equalToConstant: 240).isActive = true
        profileImageContainer.heightAnchor.constraint(equalToConstant: 240).isActive = true
        profileImageContainer.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 45).isActive = true
        profileImageContainer.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        usernameLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: profileImageContainer.bottomAnchor, constant: 32).isActive = true
        usernameLabel.widthAnchor.constraint(equalTo: profileImageContainer.widthAnchor).isActive = true
        
        aboutUserLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        aboutUserLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 32).isActive = true
        aboutUserLabel.widthAnchor.constraint(equalTo: profileImageContainer.widthAnchor).isActive = true
        aboutUserLabel.bottomAnchor.constraint(lessThanOrEqualTo: saveButton.topAnchor, constant: -32).isActive = true
        
        saveButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -56).isActive = true
        saveButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 56).isActive = true
        saveButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -30).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    
        containerView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        let height = containerView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        height.priority = UILayoutPriority.defaultLow
        height.isActive = true

        let width = containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        width.priority = UILayoutPriority(1000)
        width.isActive = true
    }

}

extension ProfileViewController {
    
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
        /*
            При вызове UIAlertController в консоль вылазит ошибка лейаута.
            Как написано на SO это давний баг https://stackoverflow.com/questions/55372093/uialertcontrollers-actionsheet-gives-constraint-error-on-ios-12-2-12-3
        */
        let ac = UIAlertController(title: "Изменить фото", message: nil, preferredStyle: .actionSheet)

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
