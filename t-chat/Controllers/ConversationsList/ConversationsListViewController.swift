//
//  ConversationsListViewController.swift
//  t-chat
//
//  Created by Артур Гнедой on 24.09.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class ConversationsListViewController: UIViewController {
    
    private var sampleData: [(String, [ConversationCellModel])]
    private var myProfile = UserProfile(username: "Marina Dudarenko", about: "UX/UI designer, web-designer Moscow, Russia.")
    
    private var theme = ThemeManager.shared.currentTheme
    
    private lazy var conversationsTable: UITableView = {
        let tableView = UITableView.init(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        
        return tableView
    }()
    
    init() {
        let gen = DataGen().generateConversationsList(count: 30)
        sampleData = [
            ("Online", gen.filter { $0.isOnline }),
            ("History", gen.filter { !$0.message.isEmpty && !$0.isOnline })
        ]
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationItem.backBarButtonItem?.title = ""
        title = "Tinkoff Chat"
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
        
        let profileImageView = ProfileImageView(frame: CGRect.init(origin: CGPoint.zero, size: CGSize(width: 32, height: 32)))
        profileImageView.initials = "MD"
        profileImageView.backgroundColor = UIColor(red: 0.89, green: 0.91, blue: 0.17, alpha: 1.00)
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        let usernavigationItem = UIBarButtonItem(customView: profileImageView)
        navigationItem.rightBarButtonItem = usernavigationItem
        
        let profileTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.goToProfile))
        profileImageView.addGestureRecognizer(profileTapGestureRecognizer)
        
        let settingsNavigationItem = UIBarButtonItem(image: UIImage(named: "settings_light"), style: .plain, target: self, action: #selector(openSettings))
        navigationItem.leftBarButtonItem = settingsNavigationItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = ThemeManager.shared.currentTheme.backgroundColor
        conversationsTable.backgroundColor = ThemeManager.shared.currentTheme.backgroundColor
    }
    
    @objc func goToProfile() {
        let vc = ProfileViewController(user: myProfile)

        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeProfilePage))
        vc.title = "My profile"
        let nvc = UINavigationController(rootViewController: vc)
        
        present(nvc, animated: true, completion: nil)
    }
    
    @objc func openSettings() {
        navigationController?.pushViewController(ThemesViewController(), animated: true)
    }
    
    @objc func closeProfilePage() {
        self.dismiss(animated: true, completion: nil)
    }

}

extension ConversationsListViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = item
        
        if theme != ThemeManager.shared.currentTheme {
            // перезагружаем данные, чтобы таблица заново вызвала cellForRowAt. Если использовать метод делегата willDisplayCell при навигации назад с экрана выбора тем, уже видимые ячейки не поменяют тему и таблица обновит ячейки при скролле.
            conversationsTable.reloadData()
            theme = ThemeManager.shared.currentTheme
        }
    }
}

extension ConversationsListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sampleData.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sampleData[section].0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sampleData[section].1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: type(of: ConversationTableViewCell.self))) as? ConversationTableViewCell else { return UITableViewCell(style: .default, reuseIdentifier: "default") }
        
        cell.configure(with: sampleData[indexPath.section].1[indexPath.row])
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let firstMessage = sampleData[indexPath.section].1[indexPath.row].message
        let vc = ConversationViewController(username: sampleData[indexPath.section].1[indexPath.row].name, messages: firstMessage.isEmpty ? [] : DataGen().generateMessages(firstMessage: firstMessage))
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension ConversationsListViewController: UITableViewDelegate {
    
}
