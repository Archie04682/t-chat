//
//  MessageView.swift
//  t-chat
//
//  Created by Артур Гнедой on 03.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class MessageView: UIView {
    
    private var trailingConstraint: NSLayoutConstraint?
    private var leadingConstraint: NSLayoutConstraint?
    
    private lazy var container: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 4
        
        return view
    }()
    
    private lazy var senderNameLabel: UILabel = {
        let label = UILabel()
        label.text = "username"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var createdLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.italicSystemFont(ofSize: 12)
        label.textAlignment = .right
        label.text = "00:00"
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.text = "message"
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    private func setupView() {
        
        stackView.addArrangedSubview(senderNameLabel)
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(createdLabel)
        
        container.addSubview(stackView)
        self.addSubview(container)

        container.topAnchor.constraint(equalTo: self.topAnchor, constant: 4.0).isActive = true
        container.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4.0).isActive = true
        
        stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 8.0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8.0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8.0).isActive = true
        stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8.0).isActive = true
        
        container.layer.cornerRadius = 16
    }
    
    func setBackgroundColor(_ color: UIColor) {
        container.backgroundColor = color
    }
    
    func setTextColor(_ color: UIColor) {
        senderNameLabel.textColor = color
        messageLabel.textColor = color
        createdLabel.textColor = color
    }

}

extension MessageView: ConfigurableView {
    
    typealias ConfigurationModel = Message
    
    func configure(with model: Message) {
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        let isIncomming = deviceId != model.senderId
        
        let largePadding = UIScreen.main.bounds.width * 0.25
        
        container.backgroundColor = isIncomming ? LocalThemeManager.shared.currentTheme.incommingMessageBackgroundColor
            : LocalThemeManager.shared.currentTheme.outcommingMessageBackgroundColor
        messageLabel.textColor = isIncomming ? LocalThemeManager.shared.currentTheme.incommingMessageTextColor : LocalThemeManager.shared.currentTheme.outcommingMessageTextColor
        
        trailingConstraint?.isActive = false
        trailingConstraint = isIncomming ? container.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -largePadding)
            : container.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)
        trailingConstraint?.isActive = true

        leadingConstraint?.isActive = false
        leadingConstraint = isIncomming ? container.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10)
            : container.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: largePadding)
        leadingConstraint?.isActive = true
        
        container.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, isIncomming ? .layerMaxXMaxYCorner : .layerMinXMaxYCorner]
        messageLabel.text = model.content
        
        senderNameLabel.isHidden = !isIncomming
        senderNameLabel.text = model.senderName

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Calendar.current.isDateInToday(model.created) ? "HH:mm" : "dd MMM HH:mm"
        
        createdLabel.text = dateFormatter.string(from: model.created)
    }
    
}
