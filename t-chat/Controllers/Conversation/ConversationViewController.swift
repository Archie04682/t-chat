//
//  ConversationViewController.swift
//  t-chat
//
//  Created by Артур Гнедой on 27.09.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit
import Firebase

class ConversationViewController: UIViewController {
    
    private let channel: Channel
    private let profile: ProfileModel
    
    private var conversation: [Message] = []
    private var listener: ListenerRegistration?
    private var toolbarBottomConstraint: NSLayoutConstraint?
    private let firestoreProvider: FirestoreProvider
    
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
        label.textColor = ThemeManager.shared.currentTheme.textColor
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
        view.textColor = ThemeManager.shared.currentTheme.textColor
        view.isScrollEnabled = false
        view.delegate = self
        view.backgroundColor = ThemeManager.shared.currentTheme.inputFieldBackgroundColor
        view.layer.borderColor = ThemeManager.shared.currentTheme.inputFieldBorderBackgroundColor.cgColor
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
        label.textColor = ThemeManager.shared.currentTheme.textColor.withAlphaComponent(0.6)
        
        return label
    }()
    
    init(channel: Channel, profile: ProfileModel, firestoreProvider: FirestoreProvider) {
        self.channel = channel
        self.profile = profile
        self.firestoreProvider = firestoreProvider
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
        title = channel.name
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
        firestoreProvider.sendMessage(toChannel: channel.identifier,
                                     message: Message(content: messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines),
                                                      created: Date(),
                                                      senderId: profile.identifier,
                                                      senderName: profile.username)) {[weak self] error in
            guard error == nil else {
                return
            }

            self?.messageTextView.text = String()
            // добавлено, чтобы стриггерить textViewDidChange
            self?.messageTextView.insertText(String())
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = ThemeManager.shared.currentTheme.conversationBackgroundColor
        conversationTable.backgroundColor = ThemeManager.shared.currentTheme.conversationBackgroundColor
        
        listener = firestoreProvider.getMessages(forChannel: channel.identifier) {[weak self] messages, error in
            guard error == nil, let messages = messages else {return}
            self?.conversation = messages
            
            if !messages.isEmpty {
                DispatchQueue.main.async {[weak self] in
                    self?.conversationTable.isHidden = false
                    self?.noMessagesLabel.isHidden = true
                    self?.conversationTable.reloadData()
                }
            } else {
                self?.conversationTable.isHidden = true
                self?.noMessagesLabel.isHidden = false
            }
        }
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
    
    deinit {
        listener?.remove()
    }

}

extension ConversationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: type(of: ConversationMessageTableViewCell.self))) as? ConversationMessageTableViewCell
            else { return UITableViewCell(style: .default, reuseIdentifier: "default") }
        
        cell.configure(with: conversation[indexPath.row])
        cell.backgroundColor = .clear
        cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        return cell
    }

}

extension ConversationViewController: UITableViewDelegate {
    
}

extension ConversationViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        messageTextViewPlaceholder.isHidden = !textView.text.isEmpty
        sendButton.isEnabled = !textView.text.isEmpty
    }
}
