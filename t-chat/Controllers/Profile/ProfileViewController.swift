////
////  UpdatedProfileViewController.swift
////  t-chat
////
////  Created by Артур Гнедой on 27.09.2020.
////  Copyright © 2020 Артур Гнедой. All rights reserved.
////

import UIKit

class ProfileViewController: UIViewController {
    
    private lazy var backdrop: Backdrop = {
        let view = Backdrop()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = .red
        view.startAnimating()
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
        let view = ProfileImageView(frame: CGRect.init(origin: CGPoint.zero, size: CGSize(width: 240, height: 240)))
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
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ThemeManager.shared.currentTheme.textColor
        
        return label
    }()
    
    private lazy var usernameTextField: UITextField = {
        let view = UITextField()
        view.borderStyle = .roundedRect
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Username"
        view.backgroundColor = ThemeManager.shared.currentTheme.inputFieldBackgroundColor
        view.layer.borderColor = ThemeManager.shared.currentTheme.inputFieldBorderBackgroundColor.cgColor
        view.layer.borderWidth = 1.5
        view.layer.cornerRadius = 4.0
        view.textColor = ThemeManager.shared.currentTheme.textColor
        view.isHidden = true
        
        return view
    }()
    
    private lazy var aboutUserLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ThemeManager.shared.currentTheme.textColor
        
        return label
    }()
    
    private lazy var aboutUserTextView: UITextView = {
        let view = UITextView()
        view.layer.borderColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1).cgColor
        view.layer.borderWidth = 1.5
        view.layer.cornerRadius = 4.0
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        view.isScrollEnabled = false
        view.isHidden = true
        view.delegate = self
        view.backgroundColor = ThemeManager.shared.currentTheme.inputFieldBackgroundColor
        view.layer.borderColor = ThemeManager.shared.currentTheme.inputFieldBorderBackgroundColor.cgColor
        view.textColor = ThemeManager.shared.currentTheme.textColor
        return view
    }()
    
    private lazy var editButton: UIButton = {
        let view = UIButton(type: .system)
        view.setTitle("Edit", for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 14
        view.backgroundColor = ThemeManager.shared.currentTheme.filledButtonColor
        return view
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
    
    private lazy var saveWithGCDButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("GCD", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.backgroundColor = ThemeManager.shared.currentTheme.filledButtonColor
        return button
    }()
    
    private lazy var saveWithOperationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Operation", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.backgroundColor = ThemeManager.shared.currentTheme.filledButtonColor
        
        return button
    }()
    
    private lazy var aboutTextViewPlaceholder: UILabel = {
        let label = UILabel()
        label.text = "About user info"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.sizeToFit()
        label.textColor = .gray
        label.frame.origin = CGPoint(x: 5, y: (self.aboutUserTextView.font?.pointSize)! / 2)
        label.isHidden = true
        return label
    }()
    
    private lazy var cancelButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancel))
    }()
    
    private let imagePicker = ImagePicker()
    private var profileModel: ProfileModel?
    
    init(model: ProfileModel) {
        self.profileModel = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.viewController = self
        profileModel?.delegate = self
        usernameTextField.delegate = self
        
        view.backgroundColor = .white
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        view.backgroundColor = ThemeManager.shared.currentTheme.backgroundColor
    }
    
    private func updateProfile(username: String?, about: String?, photoData: Data?) {
        usernameLabel.text = username
        aboutUserLabel.text = about
        if let photoData = photoData {
            profileImageView.image = UIImage.init(data: photoData)
        } else if let username = username {
            profileImageView.setInitials(username: username)
        }
    }
    
    private func updateProfileData(profile: UserProfile) {
        usernameLabel.text = profile.username
        aboutUserLabel.text = profile.about
        if let photoData = profile.photoData {
            profileImageView.image = UIImage.init(data: photoData)
        } else {
            profileImageView.setInitials(username: profile.username)
        }
    }
    
    @objc func toggleMode() {
        DispatchQueue.main.async {
            UIView.transition(with: self.view,
              duration: 0.3,
              options: [.curveEaseInOut],
              animations: {
                self.usernameLabel.alpha = !self.usernameLabel.isHidden ? 0 : 1
                self.usernameTextField.alpha = !self.usernameTextField.isHidden ? 0 : 1
                
                self.aboutUserLabel.alpha = !self.aboutUserLabel.isHidden ? 0 : 1
                self.aboutUserTextView.alpha = !self.aboutUserTextView.isHidden ? 0 : 1
                
                self.profileImageEditButton.alpha = !self.profileImageEditButton.isHidden ? 0 : 1
                
                self.editButton.alpha = !self.editButton.isHidden ? 0 : 1
                self.saveButtonsContainer.alpha = !self.saveButtonsContainer.isHidden ? 0 : 1
            }) { _ in
                self.usernameLabel.isHidden = !self.usernameLabel.isHidden
                self.usernameTextField.isHidden = !self.usernameTextField.isHidden
                self.usernameTextField.text = self.usernameLabel.text
                
                self.aboutUserLabel.isHidden = !self.aboutUserLabel.isHidden
                self.aboutUserTextView.isHidden = !self.aboutUserTextView.isHidden
                self.aboutUserTextView.text = self.aboutUserLabel.text
                
                self.editButton.isHidden = !self.editButton.isHidden
                self.saveButtonsContainer.isHidden = !self.saveButtonsContainer.isHidden
                
                self.profileImageEditButton.isHidden = !self.profileImageEditButton.isHidden
                self.navigationItem.rightBarButtonItem = !self.saveButtonsContainer.isHidden ? self.cancelButton : nil
            }
        }
    }
    
    @objc func cancel() {
        DispatchQueue.main.async {[weak self] in
            if let self = self {
                if let _ = self.profileModel?.changedData[.photoData] {
                    if let data = self.profileModel?.photoData {
                        self.profileImageView.image = UIImage(data: data)
                    } else if let text = self.usernameLabel.text {
                        self.profileImageView.setInitials(username: text)
                    }
                }
            }
        }
        profileModel?.changedData = [:]
        toggleMode()
        view.endEditing(true)
    }

    @objc func saveChanges(_ button: UIButton) {
        backdrop.isHidden = false
        view.endEditing(true)
        guard let title = button.titleLabel?.text else {
            return
        }
        
        profileModel?.save(with: title == "GCD" ? .GCD : .operations)
    }
    
    @objc func usernameTextFieldDidChange(_ textField: UITextField) {
        if (usernameLabel.text != textField.text) {
            profileModel?.changedData[.username] = textField.text?.data(using: .utf8)
        } else {
            profileModel?.changedData.removeValue(forKey: .username)
        }

        if let text = textField.text, text.count > 0 {
            textField.layer.borderColor = ThemeManager.shared.currentTheme.inputFieldBorderBackgroundColor.cgColor
        } else {
            textField.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 40
        scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
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
        
        backdrop.addSubview(activityIndicator)
        
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
        
        usernameLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: profileImageContainer.bottomAnchor, constant: 32).isActive = true
        usernameLabel.widthAnchor.constraint(equalTo: profileImageContainer.widthAnchor).isActive = true
        
        usernameTextField.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        usernameTextField.topAnchor.constraint(equalTo: profileImageContainer.bottomAnchor, constant: 32).isActive = true
        usernameTextField.widthAnchor.constraint(equalTo: profileImageContainer.widthAnchor).isActive = true
        
        aboutUserLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        aboutUserLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 32).isActive = true
        aboutUserLabel.widthAnchor.constraint(equalTo: profileImageContainer.widthAnchor).isActive = true
        aboutUserLabel.bottomAnchor.constraint(lessThanOrEqualTo: editButton.topAnchor, constant: -32).isActive = true
        
        aboutUserTextView.addSubview(aboutTextViewPlaceholder)
        aboutUserTextView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        aboutUserTextView.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 32).isActive = true
        aboutUserTextView.widthAnchor.constraint(equalTo: profileImageContainer.widthAnchor).isActive = true
        aboutUserTextView.bottomAnchor.constraint(lessThanOrEqualTo: editButton.topAnchor, constant: -32).isActive = true
        
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
        
        activityIndicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
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
                if (!profileModel.photoIsSame(with: data)) {
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
            if (!profileModel.photoIsSame(with: nil)) {
                profileModel.changedData.updateValue(nil, forKey: .photoData)
            } else {
                profileModel.changedData.removeValue(forKey: .photoData)
            }
            
            profileImageView.setInitials(username: usernameLabel.text ?? "")
        }
    }
    
    @objc func editProfilePhoto() {
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

        if profileImageView.image != nil {
            ac.addAction(UIAlertAction(title: "Удалить изображение", style: .destructive) { _ in
                self.updateProfileImage(url: nil)
            })
        }
        
        ac.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        present(ac, animated: true)
    }
    
    @objc func dismissAlertController() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension ProfileViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        aboutTextViewPlaceholder.isHidden = !textView.text.isEmpty
        
        if (textView.text != aboutUserLabel.text) {
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
    
    func didUpdate(provider: ManagerType, userProfile: UserProfile, failToUpdateProperties: [UserProfile.Keys:Error]?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            print(userProfile)
            self?.updateProfile(username: userProfile.username, about: userProfile.about, photoData: userProfile.photoData)
            if let props = failToUpdateProperties, !props.isEmpty {
                var message = "Cannot update some properties:\n"
                props.forEach { message = message + "\($0.key)" }
                let ac = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                
                ac.addAction(UIAlertAction(title: "Ok", style: .default){ _ in
                    ac.dismiss(animated: true, completion: nil)
                    self?.backdrop.isHidden = true
                })
                
                ac.addAction(UIAlertAction(title: "Repeat", style: .default){ _ in
                    self?.profileModel?.save(with: provider)
                    ac.dismiss(animated: true, completion: nil)
                })
                    
                self?.present(ac, animated: true, completion: nil)
            } else {
                let ac = UIAlertController(title: "Saved with \(provider)", message: "Profile data updated successfully", preferredStyle: .alert)
                
                ac.addAction(UIAlertAction(title: "Ok", style: .default){ _ in
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
            let ac = UIAlertController(title: "Error happend", message: "Failed to save your data", preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "Ok", style: .default){ _ in
                ac.dismiss(animated: true, completion: nil)
            })
            
            self?.present(ac, animated: true, completion: nil)
            
            print(error)
        }
    }
    
    func isDirty(_ value: Bool) {
        DispatchQueue.main.async {[weak self] in
            self?.saveWithGCDButton.isEnabled = value
            self?.saveWithOperationButton.isEnabled = value
        }
    }
    
}
