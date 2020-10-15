//
//  ConversationViewController.swift
//  t-chat
//
//  Created by Артур Гнедой on 27.09.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class ConversationViewController: UIViewController {
    
    private let username: String
    private let conversation: [MessageCellModel]
    
    private lazy var conversationTable: UITableView = {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        
        return tableView
    }()
    
    private lazy var noMessagesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.text = "No messages yet."
        label.textAlignment = .center
        label.textColor = ThemeManager.shared.currentTheme.textColor
        return label
    }()
    
    init(username: String, messages: [MessageCellModel]?) {
        self.username = username
        self.conversation = messages ?? []
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        conversationTable.register(ConversationMessageTableViewCell.self, forCellReuseIdentifier: String(describing: type(of: ConversationMessageTableViewCell.self)))
    }
    
    private func setupViews() {
        title = username
        if conversation.isEmpty {
            view.addSubview(noMessagesLabel)
            noMessagesLabel.translatesAutoresizingMaskIntoConstraints = false
            noMessagesLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            noMessagesLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        } else {
            view.addSubview(conversationTable)
            conversationTable.translatesAutoresizingMaskIntoConstraints = false
            conversationTable.clipsToBounds = true
            conversationTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            conversationTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            conversationTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            conversationTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            conversationTable.separatorStyle = .none
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = ThemeManager.shared.currentTheme.conversationBackgroundColor
        conversationTable.backgroundColor = ThemeManager.shared.currentTheme.conversationBackgroundColor
        
        if !conversation.isEmpty {
            // скроллим чат к последнему сообщению в чате
            DispatchQueue.main.async {
                self.conversationTable.scrollToRow(at: IndexPath(row: self.conversation.count - 1, section: 0), at: .bottom, animated: false)
            }
        }
    }

}

extension ConversationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: type(of: ConversationMessageTableViewCell.self))) as? ConversationMessageTableViewCell else { return UITableViewCell(style: .default, reuseIdentifier: "default") }
        
        cell.configure(with: conversation[indexPath.row])
        cell.backgroundColor = .clear
        return cell
    }

}

extension ConversationViewController: UITableViewDelegate {
    
}