//
//  ConversationsListViewController.swift
//  t-chat
//
//  Created by Артур Гнедой on 24.09.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import CoreData
import UIKit
import Firebase

class ConversationsListViewController: UIViewController {
    
    private var themeManager: ThemeManager
    private var channelsService: ChannelService
    private var profileService: ProfileService
    private var rootNavigator: RootNavigator
    private var theme: Theme
    private var isVisible = true
    
    private var channels: [Int: Channel] = [:]
    
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
    
    init(themeManager: ThemeManager, channelsService: ChannelService, profileService: ProfileService, navigator: RootNavigator) {
        self.themeManager = themeManager
        self.channelsService = channelsService
        self.theme = themeManager.currentTheme
        self.profileService = profileService
        self.rootNavigator = navigator
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
        
        view.backgroundColor = LocalThemeManager.shared.currentTheme.backgroundColor
        conversationsTable.backgroundColor = .clear
        conversationsTable.separatorColor = LocalThemeManager.shared.currentTheme.tableViewSeparatorColor
        
        channelsService.delegate = self
        isVisible = true
        
        profileService.delegate = self
        profileService.load()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        isVisible = false
    }
    
    @objc func showAddNewChannelPopup() {
        let ac = AddNewChannelViewController(title: "Start new channel", message: nil, preferredStyle: UIAlertController.Style.alert)
        ac.nameEntered = {[weak self] name in
            self?.saveNewChannel(name: name)
        }

        present(ac, animated: true)
    }
    
    @objc func goToProfile() {
//        let vc = ProfileViewController(model: profileModel)
//
//        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeProfilePage))
//        vc.title = "My profile"
//        let nvc = UINavigationController(rootViewController: vc)
//
//        present(nvc, animated: true, completion: nil)
    }
    
    @objc func openSettings() {
        navigationController?.pushViewController(ThemesViewController(), animated: true)
    }
    
    @objc func closeProfilePage() {
//        self.dismiss(animated: true) {[weak self] in
//            DispatchQueue.main.async {
//                if let imageData = self?.profileModel.photoData {
//                    self?.profileImageView.image = UIImage(data: imageData)
//                } else if let username = self?.profileModel.username {
//                    self?.profileImageView.setInitials(username: username)
//                }
//            }
//        }
    }
    
    func saveNewChannel(name: String) {
        channelsService.add(withName: name) {[weak self] error in
            if let error = error {
                self?.showError(with: error.localizedDescription)
            }
        }
    }
    
    func showError(with message: String) {
        DispatchQueue.main.async {
            if self.presentedViewController == nil {
                let ac = ErrorOccuredView(message: message)
                self.present(ac, animated: true)
            }
        }
    }
}

extension ConversationsListViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = item
        
        if theme != LocalThemeManager.shared.currentTheme {
            conversationsTable.reloadData()
            theme = LocalThemeManager.shared.currentTheme
        }
        
        profileService.delegate = self
    }
}

extension ConversationsListViewController: ProfileServiceDelegate {
    func profile(updated: Result<UserProfile, Error>) {
        switch updated {
        case .success(let profile):
            DispatchQueue.main.async { [weak self] in
                if let imageData = profile.photoData {
                    self?.profileImageView.image = UIImage(data: imageData)
                } else {
                    self?.profileImageView.setInitials(username: profile.username)
                }
            }
        case .failure(let error):
            showError(with: error.localizedDescription)
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

        if let channel = channels[indexPath.row] {
            configure(cell: cell, with: channel)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let channel = channels[indexPath.row] else {
            return
        }
        
        rootNavigator.navigate(to: .conversation(channel: channel))
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, let channel = channels[indexPath.row] {
            channelsService.delete(withUID: channel.identifier) {[weak self] error in
                if error != nil {
                    self?.showError(with: "Failed to remove channel. Try again")
                }
            }
        }
    }

    private func configure(cell: ConversationTableViewCell, with channel: Channel) {
        cell.configure(with: channel)
        cell.accessoryType = .disclosureIndicator
        cell.tintColor = .white
    }

}

extension ConversationsListViewController: UITableViewDelegate {
    
}

extension ConversationsListViewController: ChannelServiceDelegate {
    
    func data(_ result: Result<[ObjectChanges<Channel>], Error>) {
        switch result {
        case .success(let result):
            if !isVisible {
                return
            }
            
            conversationsTable.beginUpdates()
            
            result.filter { $0.changeType == .insert }.forEach { channel in
                if let newIndex = channel.newIndex {
                    channels[newIndex] = channel.object
                }
            }
            for change in result {
                switch change.changeType {
                case .insert:
                    if let index = change.newIndex {
                        conversationsTable.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)

                    }
                case .move:
                    if let index = change.index {
                        if channels.removeValue(forKey: index) != nil {
                            conversationsTable.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                        }
                    }
                    if let newIndex = change.newIndex {
                        channels[newIndex] = change.object
                        conversationsTable.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: .automatic)
                    }
                    
                case .update:
                    if let index = change.index {
                        channels[index] = change.object
                        guard let cell = conversationsTable.cellForRow(at: IndexPath(row: index, section: 0)) as? ConversationTableViewCell else { break }
                        configure(cell: cell, with: change.object)
                    }
                    
                case .delete:
                    if let index = change.index {
                        if channels.removeValue(forKey: index) != nil {
                            conversationsTable.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                        }
                    }
                }
            }
            conversationsTable.endUpdates()
            return
        case .failure(let error):
            showError(with: error.localizedDescription)
        }
    }
}
