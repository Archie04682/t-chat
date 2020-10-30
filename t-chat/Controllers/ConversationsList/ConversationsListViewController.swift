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
    private var theme = ThemeManager.shared.currentTheme
    private var channelRepository: ChannelRepository
    private let profileModel = ProfileModel()
    private var isVisible = true
    private lazy var fetchedResultsController: NSFetchedResultsController<ChannelEntity> = {
        let request: NSFetchRequest<ChannelEntity> = ChannelEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "lastActivity", ascending: false)]
        request.fetchBatchSize = 20
        let controller = NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: channelRepository.viewContext,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: "ChannelsCache")
        controller.delegate = self
        
        return controller
    }()
    
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
    
    init(channelRepository: ChannelRepository) {
        self.channelRepository = channelRepository
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
        
        if listener == nil {
            listener = firestoreProvider.getChannels {[weak self] channels, error in
                guard let channels = channels, error == nil else {
                    return
                }

                self?.channelRepository.add(channels: channels)
            }
        }
        
        try? fetchedResultsController.performFetch()
        
        isVisible = true
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
        guard let sections = fetchedResultsController.sections else {
            return 0
        }

        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }

        return sections[section].numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: type(of: ConversationTableViewCell.self))) as? ConversationTableViewCell
            else { return UITableViewCell(style: .default, reuseIdentifier: "default") }

        configure(cell: cell, with: Channel(from: fetchedResultsController.object(at: indexPath)))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ConversationViewController(profile: profileModel,
                                            firestoreProvider: firestoreProvider,
                                            channelRepository: channelRepository,
                                            channel: fetchedResultsController.object(at: indexPath))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let object = fetchedResultsController.object(at: indexPath)
            firestoreProvider.deleteChannel(atPath: object.uid)
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

extension ConversationsListViewController: NSFetchedResultsControllerDelegate {
    // isVisible добавлено из-за появления ошибки
    // [TableView] Warning once only: UITableView was told to layout its visible cells and other contents without
    // being in the view hierarchy (the table view or one of its superviews has not been added to a window).
    // This may cause bugs by forcing views inside the table view to load and perform layout without accurate information
    // (e.g. table view bounds, trait collection, layout margins, safe area insets, etc),
    // and will also cause unnecessary performance overhead due to extra layout passes.
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if !isVisible { return }
        conversationsTable.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        if !isVisible { return }
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                conversationsTable.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                conversationsTable.deleteRows(at: [indexPath], with: .automatic)
            }
        case .move:
            if let indexPath = indexPath {
                conversationsTable.deleteRows(at: [indexPath], with: .automatic)
            }

            if let newIndexPath = newIndexPath {
                conversationsTable.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                guard let cell = conversationsTable.cellForRow(at: indexPath) as? ConversationTableViewCell else { break }
                configure(cell: cell, with: Channel(from: fetchedResultsController.object(at: indexPath)))
            }
        @unknown default:
            fatalError("Unknown ResultsChangeType")
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if !isVisible { return }
        conversationsTable.endUpdates()
    }
}
