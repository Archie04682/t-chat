//
//  ConversationTableViewCell.swift
//  t-chat
//
//  Created by Артур Гнедой on 24.09.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {
    
    private var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        
        return label
    }()
    
    private var lastMessageLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 0.24, green: 0.24, blue: 0.26, alpha: 0.60)
        label.numberOfLines = 2
        
        return label
    }()
    
    private var lastMessageLabelDate: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(red: 0.24, green: 0.24, blue: 0.26, alpha: 0.60)
        
        return label
    }()
    
    let parentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.spacing = 4
        
        return stackView
    }()
    
    let headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.spacing = 4

        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        headerStackView.addArrangedSubview(usernameLabel)
        headerStackView.addArrangedSubview(lastMessageLabelDate)
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
    
    typealias ConfigurationModel = ConversationCellModel
    
    func configure(with model: ConversationCellModel) {
        usernameLabel.text = model.name
        configureMessageLabel(with: model.message, hasUnreadMessages: model.hasUnreadMessages)
        if !model.message.isEmpty {
            configureMessageDateLabel(with: model.date)
        } else {
            lastMessageLabelDate.text = ""
        }
        
        backgroundColor = model.isOnline ? UIColor(red: 0.98, green: 0.99, blue: 0.67, alpha: 1.00) : .white
    }
    
    private func configureMessageLabel(with message: String, hasUnreadMessages: Bool) {
        if !message.isEmpty {
            lastMessageLabel.font = UIFont.systemFont(ofSize: 13, weight: hasUnreadMessages ? .bold :.regular)
            lastMessageLabel.text = message
            lastMessageLabel.numberOfLines = 2
        } else {
            lastMessageLabel.font = UIFont.italicSystemFont(ofSize: 13)
            lastMessageLabel.text = "No messages yet."
        }
    }
    
    private func configureMessageDateLabel(with date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Calendar.current.isDateInToday(date) ? "hh:mm" : "dd MMM"

        lastMessageLabelDate.text = dateFormatter.string(from: date)
    }
    
//    private func createUsernameLabel(with username: String) -> UILabel {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
//        label.text = username
//
//        return label
//    }
//
//    private func createLastMessageDateLabel(with date: Date) -> UILabel {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = Calendar.current.isDateInToday(date) ? "hh:mm" : "dd MMM"
//
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
//        label.textColor = UIColor(red: 0.24, green: 0.24, blue: 0.26, alpha: 0.60)
//        label.textAlignment = .right
//        label.text = dateFormatter.string(from: date)
//
//        return label
//    }
//
//    private func createLastMessageLabel(with message: String, hasUnreadMessages: Bool) -> UILabel {
//        let label = UILabel()
//        label.textColor = UIColor(red: 0.24, green: 0.24, blue: 0.26, alpha: 0.60)
//
//        if !message.isEmpty {
//            label.font = UIFont.systemFont(ofSize: 13, weight: hasUnreadMessages ? .bold :.regular)
//            label.text = message
//            label.numberOfLines = 2
//        } else {
//            label.font = UIFont.italicSystemFont(ofSize: 13)
//            label.text = "No messages yet."
//        }
//
//        return label
//    }
}
