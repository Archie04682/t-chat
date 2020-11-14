//
//  ConversationViewController.swift
//  t-chat
//
//  Created by Артур Гнедой on 27.09.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import CoreData
import UIKit
import Firebase

class ConversationViewController: UIViewController {
    
    private let profileService: ProfileService
    private var messageService: MessageService
    private let themeManager: ThemeManager
    
    private var toolbarBottomConstraint: NSLayoutConstraint?
    
    private var messages: [Message] = []
    
    private lazy var conversationTable: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = true
        tableView.keyboardDismissMode = .interactive
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        return tableView
    }()
    
    private lazy var noMessagesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.text = "No messages yet."
        label.textAlignment = .center
        label.textColor = themeManager.currentTheme.textColor
        return label
    }()
    
    private lazy var toolbar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        
        return view
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "up-arrow"), for: .normal)
        button.isEnabled = false
        return button
    }()
    
    private lazy var messageTextView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        view.textColor = themeManager.currentTheme.textColor
        view.isScrollEnabled = false
        view.delegate = self
        view.backgroundColor = themeManager.currentTheme.inputFieldBackgroundColor
        view.layer.borderColor = themeManager.currentTheme.inputFieldBorderBackgroundColor.cgColor
        view.layer.borderWidth = 1.5
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        
        return view
    }()
    
    private lazy var messageTextViewPlaceholder: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Message"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.sizeToFit()
        label.textColor = themeManager.currentTheme.textColor.withAlphaComponent(0.6)
        
        return label
    }()
    
    init(profileService: ProfileService, messageService: MessageService, themeManager: ThemeManager) {
        self.profileService = profileService
        self.messageService = messageService
        self.themeManager = themeManager
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        conversationTable.register(ConversationMessageTableViewCell.self, forCellReuseIdentifier: String(describing: type(of: ConversationMessageTableViewCell.self)))
        
        messageService.delegate = self
    }
    
    private func setupViews() {
        title = messageService.channel.name
        view.addSubview(noMessagesLabel)
        noMessagesLabel.translatesAutoresizingMaskIntoConstraints = false
        noMessagesLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        noMessagesLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        messageTextView.addSubview(messageTextViewPlaceholder)
        messageTextViewPlaceholder.leadingAnchor.constraint(equalTo: messageTextView.leadingAnchor, constant: 4).isActive = true
        messageTextViewPlaceholder.centerYAnchor.constraint(equalTo: messageTextView.centerYAnchor).isActive = true
        
        toolbar.addSubview(messageTextView)
        toolbar.addSubview(sendButton)
        
        sendButton.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor, constant: -8).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: toolbar.bottomAnchor, constant: -4).isActive = true

        messageTextView.topAnchor.constraint(equalTo: toolbar.topAnchor, constant: 2).isActive = true
        messageTextView.bottomAnchor.constraint(equalTo: toolbar.bottomAnchor, constant: -2).isActive = true
        messageTextView.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor, constant: 8).isActive = true
        messageTextView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8).isActive = true
        
        view.addSubview(conversationTable)
        view.addSubview(toolbar)
        
        conversationTable.translatesAutoresizingMaskIntoConstraints = false
        conversationTable.clipsToBounds = true
        conversationTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        conversationTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        conversationTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        conversationTable.bottomAnchor.constraint(equalTo: toolbar.topAnchor, constant: -8).isActive = true
        
        toolbar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        toolbar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        toolbarBottomConstraint = toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        toolbarBottomConstraint?.isActive = true
        
        conversationTable.separatorStyle = .none
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
    }
    
    @objc func sendMessage() {
        if let profile = profileService.profile {
            messageService.add(Message(content: messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines),
            created: Date(),
            senderId: UIDevice.current.identifierForVendor!.uuidString,
            senderName: profile.username)) {[weak self] error in
                guard error == nil else {
                    self?.showError(with: "Failed to send message")
                    
                    return
                }

                self?.messageTextView.text = String()
                // добавлено, чтобы стриггерить textViewDidChange
                self?.messageTextView.insertText(String())
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = LocalThemeManager.shared.currentTheme.conversationBackgroundColor
        conversationTable.backgroundColor = LocalThemeManager.shared.currentTheme.conversationBackgroundColor
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) {
            
            UIView.animate(withDuration: duration) { () -> Void in
                self.toolbarBottomConstraint?.isActive = false
                self.toolbarBottomConstraint? = self.toolbar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -(keyboardSize.height + 2))
                self.toolbarBottomConstraint?.isActive = true
                self.view.layoutIfNeeded()

            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) {
            UIView.animate(withDuration: duration) { () -> Void in
                self.toolbarBottomConstraint?.isActive = false
                self.toolbarBottomConstraint = self.toolbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
                self.toolbarBottomConstraint?.isActive = true
                self.view.layoutIfNeeded()
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

extension ConversationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: type(of: ConversationMessageTableViewCell.self))) as? ConversationMessageTableViewCell
            else { return UITableViewCell(style: .default, reuseIdentifier: "default") }
        
        configure(cell, with: messages[indexPath.row])
        
        return cell
    }
    
    private func configure(_ cell: ConversationMessageTableViewCell, with message: Message) {
        cell.configure(with: message)
        cell.backgroundColor = .clear
        cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
    }

}

extension ConversationViewController: UITableViewDelegate {
    
}

extension ConversationViewController: MessageServiceDelegate {
    
    func data(_ result: Result<[ObjectChanges<Message>], Error>) {
        switch result {
        case .success(let result):
            conversationTable.beginUpdates()
            if messages.isEmpty {
                messages.append(contentsOf: result.filter { $0.changeType == .insert }.map { $0.object })
            } else {
                for message in result.map({ $0.object }) {
                    messages.insert(message, at: 0)
                }
            }
            
            conversationTable.isHidden = messages.isEmpty
            noMessagesLabel.isHidden = !messages.isEmpty
            for change in result {
                switch change.changeType {
                case .insert:
                    if let index = messages.firstIndex(where: { $0.uid == change.object.uid}) {
                        conversationTable.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    }
                case .move:
                    if let index = messages.firstIndex(where: { $0.uid == change.object.uid}) {
                        messages.remove(at: index)
                        conversationTable.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    }
                    if let newIndex = change.newIndex {
                        messages.insert(change.object, at: newIndex)
                        conversationTable.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: .automatic)
                    }
                    
                case .update:
                    if let index = change.index {
                        messages[index] = change.object
                        guard let cell = conversationTable.cellForRow(at: IndexPath(row: index, section: 0)) as? ConversationMessageTableViewCell else { break }
                        configure(cell, with: change.object)
                    }
                    
                case .delete:
                    if let index = messages.firstIndex(where: { $0.uid == change.object.uid}) {
                        messages.remove(at: index)
                        conversationTable.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    }
                }
            }
            conversationTable.endUpdates()
        case .failure(let error):
            showError(with: error.localizedDescription)
        }
    }
}

extension ConversationViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        messageTextViewPlaceholder.isHidden = !textView.text.isEmpty
        sendButton.isEnabled = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
