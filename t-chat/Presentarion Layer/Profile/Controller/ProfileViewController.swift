//
//  ProfileViewController.swift
//  t-chat
//
//  Created by Артур Гнедой on 27.09.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class ProfileViewController: NavigationViewController {
    private lazy var backdrop: BackdropWithLoading = {
        let view = BackdropWithLoading()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.keyboardDismissMode = .interactive
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var profileImageContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var profileImageView: ProfileImageView = {
        let view = ProfileImageView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 240, height: 240)))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.89, green: 0.91, blue: 0.17, alpha: 1.00)
        return view
    }()
    
    private lazy var profileImageEditButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    private lazy var usernameLabel: StyledLabel = {
        let label = StyledLabel()
        label.configure(font: UIFont.systemFont(ofSize: 24, weight: .bold), theme: themeManager.currentTheme)
        return label
    }()
    
    private lazy var usernameTextField: UITextField = {
        let view = UITextField()
        view.borderStyle = .roundedRect
        view.translatesAutoresizingMaskIntoConstraints = false
        view.attributedPlaceholder = NSAttributedString(string: "Username",
                                                        attributes: [NSAttributedString.Key.foregroundColor:
                                                            themeManager.currentTheme.textColor.withAlphaComponent(0.7)])
        view.textColor = themeManager.currentTheme.textColor
        view.backgroundColor = themeManager.currentTheme.inputFieldBackgroundColor
        view.layer.borderColor = themeManager.currentTheme.inputFieldBorderBackgroundColor.cgColor
        view.layer.borderWidth = 1.5
        view.layer.cornerRadius = 4.0
        view.isHidden = true
        view.accessibilityLabel = "usernameTextField"
        return view
    }()
    
    private lazy var aboutUserLabel: StyledLabel = {
        let label = StyledLabel()
        label.configure(font: UIFont.systemFont(ofSize: 16, weight: .regular), theme: themeManager.currentTheme)
        label.isHidden = false
        return label
    }()
    
    private lazy var aboutUserTextView: TextViewWithPlaceholder = {
        let view = TextViewWithPlaceholder()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(placeholder: "About user", theme: themeManager.currentTheme)
        view.textDelegate = self
        view.isHidden = true
        view.accessibilityLabel = "aboutUserTextView"
        return view
    }()
    
    private lazy var editButton: ActionButton = {
        let button = ActionButton(type: .system)
        button.configure(with: "Edit", theme: themeManager.currentTheme)
        button.accessibilityLabel = "toggleEditModeButton"
        return button
    }()
    
    private lazy var saveButtonsContainer: UIStackView = {
        let button = UIStackView()
        button.axis = .horizontal
        button.translatesAutoresizingMaskIntoConstraints = false
        button.distribution = .fillEqually
        button.spacing = 16
        button.isHidden = true
        return button
    }()
    
    private lazy var saveWithGCDButton: ActionButton = {
        let button = ActionButton(type: .system)
        button.configure(with: "GCD", theme: themeManager.currentTheme)
        button.isEnabled = false
        
        return button
    }()
    
    private lazy var saveWithOperationButton: ActionButton = {
        let button = ActionButton(type: .system)
        button.configure(with: "Operation", theme: themeManager.currentTheme)
        button.isEnabled = false
        
        return button
    }()
    
    private lazy var cancelButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancel))
    }()
    
    private var imagePicker: ImagePicker
    private let themeManager: ThemeManager
    private var profileModel: ProfileModel?

    init(model: ProfileModel, imagePicker: ImagePicker, themeManager: ThemeManager) {
        self.profileModel = model
        self.imagePicker = imagePicker
        self.themeManager = themeManager
        
        super.init(nibName: nil, bundle: nil)
        
        self.imagePicker.delegate = self
        self.imagePicker.rootViewController = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Profile"
        imagePicker.delegate = self
        imagePicker.rootViewController = self
        profileModel?.delegate = self
        usernameTextField.delegate = self
        
        view.backgroundColor = themeManager.currentTheme.backgroundColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        layoutSubviews()
        editButton.addTarget(self, action: #selector(toggleMode), for: .touchUpInside)
        saveWithGCDButton.addTarget(self, action: #selector(saveChanges(_:)), for: .touchUpInside)
        saveWithOperationButton.addTarget(self, action: #selector(saveChanges(_:)), for: .touchUpInside)
        profileImageEditButton.addTarget(self, action: #selector(editProfilePhoto), for: .touchUpInside)
        usernameTextField.addTarget(self, action: #selector(usernameTextFieldDidChange(_:)), for: .editingChanged)

        updateProfile(username: profileModel?.username, about: profileModel?.about, photoData: profileModel?.photoData)
    }
    
    private func updateProfile(username: String?, about: String?, photoData: Data?) {
        usernameLabel.text = username
        aboutUserLabel.text = about
    
        if let photoData = photoData {
            profileImageView.image = UIImage(data: photoData)
        } else if let username = username {
            profileImageView.setInitials(username: username)
        }
    }
    
    private func animatePhotoEditButton() {
        let transitionBuilder = TransitionAnimationBuilder(duration: 0.3, repeatCount: .infinity)
        transitionBuilder.addRotation(withAngle: 18.0, reverseRotation: true)
        transitionBuilder.addPositionTransition(withIntent: 5, direction: .horizontal)
        transitionBuilder.addPositionTransition(withIntent: 5, direction: .vertical)
        profileImageEditButton.layer.add(transitionBuilder.build(), forKey: #keyPath(CALayer.transform))
    }
    
    @objc func toggleMode() {
        DispatchQueue.main.async {
            if self.profileImageEditButton.layer.animation(forKey: #keyPath(CALayer.transform)) != nil {
                self.profileImageEditButton.layer.removeAllAnimations()
            } else {
                self.animatePhotoEditButton()
            }
            
            UIView.transition(with: self.view, duration: 0.3, options: [.curveEaseInOut],
              animations: {
                [self.usernameLabel, self.usernameTextField, self.aboutUserLabel, self.aboutUserTextView,
                 self.profileImageEditButton, self.editButton, self.saveButtonsContainer].forEach {
                    $0.alpha = !$0.isHidden ? 0 : 1
                }
            }, completion: { _ in
                [self.usernameLabel, self.usernameTextField, self.aboutUserLabel, self.aboutUserTextView,
                 self.profileImageEditButton, self.editButton, self.saveButtonsContainer].forEach {
                    $0.isHidden = !$0.isHidden
                }
                self.usernameTextField.text = self.usernameLabel.text
                self.aboutUserTextView.text = self.aboutUserLabel.text
                
                self.navigationItem.rightBarButtonItem = !self.saveButtonsContainer.isHidden ? self.cancelButton : nil
            })
        }
    }
    
    @objc func cancel() {
        DispatchQueue.main.async {
            if self.profileModel?.changedData[.photoData] != nil {
                if let data = self.profileModel?.photoData {
                    self.profileImageView.image = UIImage(data: data)
                } else if let text = self.usernameLabel.text {
                    self.profileImageView.setInitials(username: text)
                }
            }
            
            self.profileModel?.changedData = [:]
            self.toggleMode()
            self.view.endEditing(true)
        }
    }

    @objc func saveChanges(_ button: UIButton) {
        backdrop.isHidden = false
        view.endEditing(true)
        guard let title = button.titleLabel?.text else {return}
        
        profileModel?.save(with: title == "GCD" ? .GCD : .operations)
    }
    
    @objc func usernameTextFieldDidChange(_ textField: UITextField) {
        if usernameLabel.text != textField.text {
            profileModel?.changedData[.username] = textField.text?.data(using: .utf8)
        } else {
            profileModel?.changedData.removeValue(forKey: .username)
        }

        if let text = textField.text, text.count > 0 {
            textField.layer.borderColor = themeManager.currentTheme.inputFieldBorderBackgroundColor.cgColor
        } else {
            textField.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo, let value = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue else { return }

        var contentInset: UIEdgeInsets = scrollView.contentInset
        contentInset.bottom = view.convert(value.cgRectValue, from: nil).size.height + 40
        scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets.zero
    }
    
    private func layoutSubviews() {
        profileImageContainer.addSubview(profileImageView)
        profileImageContainer.addSubview(profileImageEditButton)
        containerView.addSubview(profileImageContainer)
        containerView.addSubview(usernameLabel)
        containerView.addSubview(usernameTextField)
        containerView.addSubview(aboutUserLabel)
        containerView.addSubview(aboutUserTextView)
        saveButtonsContainer.addArrangedSubview(saveWithGCDButton)
        saveButtonsContainer.addArrangedSubview(saveWithOperationButton)
        containerView.addSubview(editButton)
        containerView.addSubview(saveButtonsContainer)
        scrollView.addSubview(containerView)
        
        view.addSubview(scrollView)
        view.addSubview(backdrop)
        
        profileImageView.widthAnchor.constraint(equalTo: profileImageContainer.widthAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalTo: profileImageContainer.heightAnchor).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: profileImageContainer.centerXAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: profileImageContainer.centerYAnchor).isActive = true
        profileImageEditButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageEditButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageEditButton.trailingAnchor.constraint(equalTo: profileImageContainer.trailingAnchor).isActive = true
        profileImageEditButton.bottomAnchor.constraint(equalTo: profileImageContainer.bottomAnchor, constant: 14).isActive = true
        profileImageContainer.widthAnchor.constraint(equalToConstant: 240).isActive = true
        profileImageContainer.heightAnchor.constraint(equalToConstant: 240).isActive = true
        profileImageContainer.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 45).isActive = true
        profileImageContainer.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        [usernameLabel, usernameTextField].forEach {
            $0.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: profileImageContainer.bottomAnchor, constant: 32).isActive = true
            $0.widthAnchor.constraint(equalTo: profileImageContainer.widthAnchor).isActive = true
        }
        
        [aboutUserLabel, aboutUserTextView].forEach {
            $0.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 32).isActive = true
            $0.widthAnchor.constraint(equalTo: profileImageContainer.widthAnchor).isActive = true
            $0.bottomAnchor.constraint(lessThanOrEqualTo: editButton.topAnchor, constant: -32).isActive = true
        }
        
        editButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -56).isActive = true
        editButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 56).isActive = true
        editButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -30).isActive = true
        editButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        saveButtonsContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        saveButtonsContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).isActive = true
        saveButtonsContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -30).isActive = true
        saveButtonsContainer.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
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
        
        backdrop.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backdrop.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backdrop.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backdrop.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}

extension ProfileViewController {
    func updateProfileImage(url: URL?) {
        guard let profileModel = profileModel else {return}
        if let url = url {
            do {
                let data = try Data(contentsOf: url)
                if !profileModel.photoIsSame(with: data) {
                    profileModel.changedData[.photoData] = data
                } else {
                    profileModel.changedData.removeValue(forKey: .photoData)
                }
                
                profileImageView.image = UIImage(data: data)
            } catch {
                let ac = UIAlertController(title: "Ошибка", message: "Произошла ошибка при загрузке изображения.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
                present(ac, animated: true) {
                    self.profileImageView.setInitials(username: self.usernameLabel.text ?? "")
                }
            }
        } else {
            if !profileModel.photoIsSame(with: nil) {
                profileModel.changedData.updateValue(nil, forKey: .photoData)
            } else {
                profileModel.changedData.removeValue(forKey: .photoData)
            }
            
            profileImageView.setInitials(username: usernameLabel.text ?? "")
        }
    }
    
    @objc func editProfilePhoto() {
        if profileImageEditButton.layer.animation(forKey: #keyPath(CALayer.transform)) != nil {
            profileImageEditButton.layer.removeAllAnimations()
        }
        
        let ac = UIAlertController(title: "Изменить фото", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Выбрать из галлереи", style: .default) { _ in
            self.imagePicker.pickImage(with: .photoLibrary)
            self.animatePhotoEditButton()
        })
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            ac.addAction(UIAlertAction(title: "Сделать фото", style: .default) { _ in
                self.imagePicker.pickImage(with: .camera)
                self.animatePhotoEditButton()
            })
        }
        
        ac.addAction(UIAlertAction(title: "Загрузить из сети", style: .default) { _ in
            self.navigate?(self, .networkImages, true)
            self.animatePhotoEditButton()
        })

        if profileImageView.image != nil {
            ac.addAction(UIAlertAction(title: "Удалить изображение", style: .destructive) { _ in
                self.animatePhotoEditButton()
                self.updateProfileImage(url: nil)
            })
        }
        
        ac.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: { _ in
            self.animatePhotoEditButton()
        }))
        
        present(ac, animated: true)
    }
    
    @objc func dismissAlertController() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController: NetworkImagesViewDelegate {
    
    func didSelect(image: UIImage) {
        profileImageView.image = image
        profileModel?.changedData[.photoData] = image.pngData()
    }
    
}

extension ProfileViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text != aboutUserLabel.text {
            profileModel?.changedData[.about] = textView.text?.data(using: .utf8)
        } else {
            profileModel?.changedData.removeValue(forKey: .about)
        }
    }
}

extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
}

extension ProfileViewController: ImagePickerDelegate {
    func didSelectImage(url: URL?) {
        updateProfileImage(url: url)
    }
}

extension ProfileViewController: ProfileModelDelegate {
    func didUpdate(provider: ManagerType, userProfile: UserProfile, failToUpdateProperties: [UserProfile.Keys: Error]?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.updateProfile(username: userProfile.username, about: userProfile.about, photoData: userProfile.photoData)
            if let props = failToUpdateProperties, !props.isEmpty {
                var message = "Cannot update some properties:\n"
                props.forEach { message = message + "\($0.key)" }
                let repeatAC = RepeatableAlert(title: "Error", message: message, preferredStyle: .alert)
                repeatAC.okHandler = {
                    self?.backdrop.isHidden = true
                }
                repeatAC.repeatHandler = {
                    self?.profileModel?.save(with: provider)
                }
                    
                self?.present(repeatAC, animated: true, completion: nil)
            } else {
                let ac = UIAlertController(title: "Saved with \(provider)", message: "Profile data updated successfully", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
                    ac.dismiss(animated: true, completion: nil)
                })
                    
                self?.present(ac, animated: true, completion: nil)
                self?.toggleMode()
                self?.backdrop.isHidden = true
            }
        }
    }
    
    func didFailUpdate(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.view.endEditing(true)
            self?.backdrop.isHidden = true
            let errorAC = ErrorOccuredView(message: "Failed to save your data")
            self?.present(errorAC, animated: true, completion: nil)
        }
    }
    
    func isDirty(_ value: Bool) {
        DispatchQueue.main.async {[weak self] in
            self?.saveWithGCDButton.isEnabled = value
            self?.saveWithOperationButton.isEnabled = value
        }
    }
}
