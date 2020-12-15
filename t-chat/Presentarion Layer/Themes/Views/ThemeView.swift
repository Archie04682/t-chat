//
//  ThemeView.swift
//  t-chat
//
//  Created by Артур Гнедой on 03.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class ThemeView: UIView {
    
    var selected: ((Theme) -> Void)?
    
    private let theme: Theme
    
    private lazy var selectionButton: ThemeSelectionButton = {
        let button = ThemeSelectionButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 0x97 / 0xFF, green: 0x97 / 0xFF, blue: 0x97 / 0xFF, alpha: 1.0).cgColor
        button.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var dialogSampleView: UIStackView = {
        let view = UIStackView(frame: CGRect(x: 0, y: 0, width: self.selectionButton.frame.width, height: 100))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .fill
        view.distribution = .fill
        view.axis = .vertical
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var themeNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        label.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        label.addGestureRecognizer(tapGestureRecognizer)
        return label
    }()
    
    private lazy var incommingMessageView: MessageView = {
        let view = MessageView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.width))
        view.translatesAutoresizingMaskIntoConstraints = false
    
        return view
    }()
    
    private lazy var outcommingMessageView: MessageView = {
        let view = MessageView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.width))
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    init(theme: Theme) {
        self.theme = theme
        super.init(frame: CGRect())
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        dialogSampleView.addArrangedSubview(incommingMessageView)
        dialogSampleView.addArrangedSubview(outcommingMessageView)
        
        selectionButton.addSubview(dialogSampleView)

        dialogSampleView.topAnchor.constraint(equalTo: selectionButton.topAnchor, constant: 5).isActive = true
        dialogSampleView.bottomAnchor.constraint(equalTo: selectionButton.bottomAnchor, constant: -5).isActive = true
        dialogSampleView.leadingAnchor.constraint(equalTo: selectionButton.leadingAnchor, constant: 5).isActive = true
        dialogSampleView.trailingAnchor.constraint(equalTo: selectionButton.trailingAnchor, constant: -5).isActive = true
        
        self.addSubview(selectionButton)
        self.addSubview(themeNameLabel)
        
        selectionButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        selectionButton.bottomAnchor.constraint(equalTo: themeNameLabel.topAnchor, constant: -10).isActive = true
        selectionButton.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        selectionButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        themeNameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        themeNameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
    }
    
    @objc func tap(_ sender: UIView) {
        if let closure = selected {
            closure(theme)
            return
        }
    }

    func checkIfButtonSelected(_ selectedTheme: Theme) {
        selectionButton.isSelected = selectedTheme == theme
        themeNameLabel.textColor = selectedTheme.textColor
    }
}

extension ThemeView: ConfigurableView {
    func configure(with model: Theme, theme: Theme? = nil) {
        themeNameLabel.text = model.themeName
        
        incommingMessageView.configure(with: Message(content: "Hello! How r u?",
                                                     created: Date(),
                                                     senderId: "sender",
                                                     senderName: ""), theme: model)
        outcommingMessageView.configure(with: Message(content: "Hi! Fine!",
                                                      created: Date(),
                                                      senderId: UIDevice.current.identifierForVendor!.uuidString,
                                                      senderName: ""), theme: model)
        
        incommingMessageView.setBackgroundColor(model.incommingMessageBackgroundColor)
        incommingMessageView.setTextColor(model.incommingMessageTextColor)
        selectionButton.backgroundColor = model.conversationBackgroundColor
        
        outcommingMessageView.setBackgroundColor(model.outcommingMessageBackgroundColor)
        outcommingMessageView.setTextColor(model.outcommingMessageTextColor)
        selectionButton.backgroundColor = model.conversationBackgroundColor
    }
}
