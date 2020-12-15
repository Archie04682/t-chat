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

class ConversationsListViewController: NavigationViewController {
    
    private var themeManager: ThemeManager
    private var channelsService: ChannelService
    private var profileService: ProfileService
    
    private var theme: Theme
    private var isVisible = true
    
    private var channels: [Channel] = []
    
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
    
    init(themeManager: ThemeManager, channelsService: ChannelService, profileService: ProfileService) {
        self.themeManager = themeManager
        self.channelsService = channelsService
        self.theme = themeManager.currentTheme
        self.profileService = profileService
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
        channelsService.delegate = self
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
        
        view.backgroundColor = themeManager.currentTheme.backgroundColor
        conversationsTable.backgroundColor = .clear
        conversationsTable.separatorColor = themeManager.currentTheme.tableViewSeparatorColor
        
        isVisible = true
        
        if let imageData = profileService.profile?.photoData {
            self.profileImageView.image = UIImage(data: imageData)
        } else {
            if let username = profileService.profile?.username {
                self.profileImageView.setInitials(username: username)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        isVisible = false
    }
    
    @objc func showAddNewChannelPopup() {
        let ac = AddNewChannelViewController(title: "New Channel", message: nil, preferredStyle: .alert)
        ac.configure(with: "", theme: themeManager.currentTheme)
        ac.nameEntered = {[weak self] name in
            self?.saveNewChannel(name: name)
        }

        present(ac, animated: true)
    }
    
    @objc func goToProfile() {
        self.navigate?(self, .profile, true)
    }
    
    @objc func openSettings() {
        self.navigate?(self, .settings, false)
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
        
        if theme != themeManager.currentTheme {
            conversationsTable.reloadData()
            theme = themeManager.currentTheme
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

        configure(cell: cell, with: channels[indexPath.row])
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigate?(self, .conversation(channel: channels[indexPath.row]), false)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            channelsService.delete(withUID: channels[indexPath.row].identifier) {[weak self] error in
                if error != nil {
                    self?.showError(with: "Failed to remove channel. Try again")
                }
            }
        }
    }

    private func configure(cell: ConversationTableViewCell, with channel: Channel) {
        cell.configure(with: channel, theme: themeManager.currentTheme)
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
            
            conversationsTable.beginUpdates()
            channels.append(contentsOf: result.filter { $0.changeType == .insert }.map { $0.object })
            for change in result {
                switch change.changeType {
                case .insert:
                    if let index = channels.firstIndex(where: { $0.identifier == change.object.identifier }) {
                        conversationsTable.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    }
                case .move:
                    if let index = channels.firstIndex(where: { $0.identifier == change.object.identifier }) {
                        channels.remove(at: index)
                        conversationsTable.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    }
                    if let newIndex = change.newIndex {
                        channels.insert(change.object, at: newIndex)
                        conversationsTable.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: .automatic)
                    }
                    
                case .update:
                    if let index = channels.firstIndex(where: { $0.identifier == change.object.identifier }) {
                        channels[index] = change.object
                        guard let cell = conversationsTable.cellForRow(at: IndexPath(row: index, section: 0)) as? ConversationTableViewCell else { break }
                        configure(cell: cell, with: change.object)
                    }
                    
                case .delete:
                    if let index = change.index {
                        channels.remove(at: index)
                        conversationsTable.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
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
