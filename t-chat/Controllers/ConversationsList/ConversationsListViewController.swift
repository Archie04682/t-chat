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
    private var coreDataStack: CoreDataStack
    private let profileModel = ProfileModel()
    
    private lazy var channels: [Channel] = []
    
    private lazy var conversationsTable: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
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
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
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
        
        listener = firestoreProvider.getChannels {[weak self] channels, error in
            guard let channels = channels, error == nil else {
                return
            }

            self?.channels = channels
            self?.conversationsTable.reloadData()
            
            self?.coreDataStack.save { context in
                channels.forEach { ChannelEntity(with: $0, in: context) }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = ThemeManager.shared.currentTheme.backgroundColor
        conversationsTable.backgroundColor = .clear
        conversationsTable.separatorColor = ThemeManager.shared.currentTheme.tableViewSeparatorColor
    }
    
    @objc func showAddNewChannelPopup() {
        let ac = AddNewChannelViewController(title: "Start new channel", message: nil, preferredStyle: UIAlertController.Style.alert)
        ac.nameEntered = {[weak self] name in
            self?.saveNewChannel(name: name)
        }

        present(ac, animated: true)
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
    
    func saveNewChannel(name: String) {
        firestoreProvider.createChannel(withName: name) {[weak self] error in
            if let error = error {
                let ac = UIAlertController(title: "Error occured", message: error.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
                self?.present(ac, animated: true)
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
        let vc = ConversationViewController(channel: channels[indexPath.row],
                                            profile: profileModel,
                                            firestoreProvider: firestoreProvider,
                                            channelRepository: ChannelRepository(coreDataStack: coreDataStack))
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension ConversationsListViewController: UITableViewDelegate {
    
}
