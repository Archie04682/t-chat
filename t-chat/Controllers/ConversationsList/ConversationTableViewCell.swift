//
//  ConversationTableViewCell.swift
//  t-chat
//
//  Created by Артур Гнедой on 24.09.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {
    
    private lazy var channelName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)

        return label
    }()
    
    private lazy var lastMessageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        
        return label
    }()
    
    private lazy var lastActivityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = ThemeManager.shared.currentTheme.subtitleColor
        
        return label
    }()
    
    private lazy var parentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.spacing = 4
        
        return stackView
    }()
    
    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.spacing = 4

        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        headerStackView.addArrangedSubview(channelName)
        headerStackView.addArrangedSubview(lastActivityLabel)
        parentStackView.addArrangedSubview(headerStackView)
        parentStackView.addArrangedSubview(lastMessageLabel)
        contentView.addSubview(parentStackView)
        
        parentStackView.translatesAutoresizingMaskIntoConstraints = false
        parentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.0).isActive = true
        parentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.0).isActive = true
        parentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0).isActive = true
        parentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ConversationTableViewCell: ConfigurableView {
    
    typealias ConfigurationModel = Channel
    
    func configure(with model: Channel) {
        channelName.text = model.name
        channelName.textColor = ThemeManager.shared.currentTheme.textColor
        lastMessageLabel.textColor = ThemeManager.shared.currentTheme.subtitleColor
        lastActivityLabel.textColor = ThemeManager.shared.currentTheme.subtitleColor
        
        configureMessageLabel(with: model.lastMessage)
        configureMessageDateLabel(with: model.lastActivity)
        
        backgroundColor = .clear
    }
    
    private func configureMessageLabel(with message: String?) {
        if let message = message, message.count > 0 {
            lastMessageLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            lastMessageLabel.text = message
            lastMessageLabel.numberOfLines = 2
        } else {
            lastMessageLabel.font = UIFont.italicSystemFont(ofSize: 13)
            lastMessageLabel.text = "No messages yet."
        }
    }
    
    private func configureMessageDateLabel(with date: Date?) {
        if let date = date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = Calendar.current.isDateInToday(date) ? "hh:mm" : "dd MMM"

            lastActivityLabel.text = dateFormatter.string(from: date)
        } else {
            lastActivityLabel.text = ""
        }
    }
}
