//
//  ConversationsListViewController.swift
//  t-chat
//
//  Created by Артур Гнедой on 24.09.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit
import Firebase

class ConversationsListViewController: UIViewController {
    private var theme = ThemeManager.shared.currentTheme
    
    private let profileModel = ProfileModel()
    
    private lazy var channels: [Channel] = []
    
    private lazy var conversationsTable: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        
        return tableView
    }()
    
    private lazy var profileImageView: ProfileImageView = {
        let profileImageView = ProfileImageView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 32, height: 32)))
        profileImageView.backgroundColor = UIColor(red: 0.89, green: 0.91, blue: 0.17, alpha: 1.00)
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        return profileImageView
    }()
    
    private let firestoreProvider = FirestoreProvider()
    private var listener: ListenerRegistration?
    private var alert: UIAlertController?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationItem.backBarButtonItem?.title = ""
        title = "Channels"
        setupViews()
        navigationController?.delegate = self
        conversationsTable.register(ConversationTableViewCell.self, forCellReuseIdentifier: String(describing: type(of: ConversationTableViewCell.self)))
    }
    
    private func setupViews() {
        view.addSubview(conversationsTable)
        conversationsTable.translatesAutoresizingMaskIntoConstraints = false
        conversationsTable.clipsToBounds = true
        conversationsTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        conversationsTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        conversationsTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        conversationsTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        let userNavigationItem = UIBarButtonItem(customView: profileImageView)
        let addNewChannelItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(self.showAddNewChannelPopup))
        navigationItem.rightBarButtonItems = [userNavigationItem, addNewChannelItem]
        
        let profileTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.goToProfile))
        profileImageView.addGestureRecognizer(profileTapGestureRecognizer)
        
        let settingsNavigationItem = UIBarButtonItem(image: UIImage(named: "settings_light"), style: .plain, target: self, action: #selector(openSettings))
        navigationItem.leftBarButtonItem = settingsNavigationItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = ThemeManager.shared.currentTheme.backgroundColor
        conversationsTable.backgroundColor = .clear
        conversationsTable.separatorColor = ThemeManager.shared.currentTheme.tableViewSeparatorColor
        
        listener = firestoreProvider.getChannels {[weak self] channels, error in
            guard let channels = channels, error == nil else {
                return
            }
            
            self?.channels = channels
            self?.conversationsTable.reloadData()
        }
    }
    
    @objc func showAddNewChannelPopup() {
        let ac = UIAlertController(title: "Start new channel", message: nil, preferredStyle: UIAlertController.Style.alert)
        ac.addTextField { textField in
            textField.borderStyle = .roundedRect
            textField.attributedPlaceholder = NSAttributedString(string: "Channel name",
                                                                 attributes: [NSAttributedString.Key.foregroundColor:
                                                                    ThemeManager.shared.currentTheme.textColor.withAlphaComponent(0.7)])
            textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            textField.backgroundColor = ThemeManager.shared.currentTheme.inputFieldBackgroundColor
            textField.layer.borderColor = ThemeManager.shared.currentTheme.inputFieldBorderBackgroundColor.cgColor
            textField.layer.borderWidth = 1.5
            textField.layer.cornerRadius = 4.0
            textField.textColor = ThemeManager.shared.currentTheme.textColor
            textField.returnKeyType = .go
            textField.enablesReturnKeyAutomatically = true
            textField.addTarget(self, action: #selector(self.saveNewChannel(textField:)), for: .primaryActionTriggered)
        }
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true) {[weak self] in
            self?.alert = ac
        }
    }
    
    @objc func goToProfile() {
        let vc = ProfileViewController(model: profileModel)

        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeProfilePage))
        vc.title = "My profile"
        let nvc = UINavigationController(rootViewController: vc)
        
        present(nvc, animated: true, completion: nil)
    }
    
    @objc func openSettings() {
        navigationController?.pushViewController(ThemesViewController(), animated: true)
    }
    
    @objc func closeProfilePage() {
        self.dismiss(animated: true) {[weak self] in
            DispatchQueue.main.async {
                if let imageData = self?.profileModel.photoData {
                    self?.profileImageView.image = UIImage(data: imageData)
                } else if let username = self?.profileModel.username {
                    self?.profileImageView.setInitials(username: username)
                }
            }
        }
    }
    
    @objc func saveNewChannel(textField: UITextField) {
        if let text = textField.text {
            firestoreProvider.createChannel(withName: text) {[weak self] error in
                guard error == nil else { return }
                
                self?.alert?.dismiss(animated: true)
                self?.alert = nil
            }
        }
    }
    
    deinit {
        listener?.remove()
    }
}

extension ConversationsListViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = item
        
        if theme != ThemeManager.shared.currentTheme {
            conversationsTable.reloadData()
            theme = ThemeManager.shared.currentTheme
        }
        
        profileModel.load {[weak self] profile, _ in
            if let profile = profile {
                DispatchQueue.main.async {
                    if let imageData = profile.photoData {
                        self?.profileImageView.image = UIImage(data: imageData)
                    } else {
                        self?.profileImageView.setInitials(username: profile.username)
                    }
                }
            }
        }
    }
}

extension ConversationsListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: type(of: ConversationTableViewCell.self))) as? ConversationTableViewCell
            else { return UITableViewCell(style: .default, reuseIdentifier: "default") }
        
        cell.configure(with: channels[indexPath.row])
        cell.accessoryType = .disclosureIndicator
        cell.tintColor = .white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ConversationViewController(channelId: channels[indexPath.row].identifier, channelName: channels[indexPath.row].name)
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension ConversationsListViewController: UITableViewDelegate {
    
}
