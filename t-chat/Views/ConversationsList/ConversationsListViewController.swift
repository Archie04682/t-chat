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
    
    private lazy var conversationsTable: UITableView = {
        let tableView = UITableView.init(frame: .zero, style: .grouped)
        tableView.backgroundColor = .white
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
        view.backgroundColor = .white
        title = "Tinkoff Chat"
        setupViews()
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
    }

}

extension ConversationsListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ConversationViewController(username: sampleData[indexPath.section].1[indexPath.row].name, messages: DataGen().generateMessages(count: !sampleData[indexPath.section].1[indexPath.row].message.isEmpty ? Int.random(in: 10..<15) : 0))
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension ConversationsListViewController: UITableViewDelegate {
    
}
