//
//  AddNewChannelControllerViewController.swift
//  t-chat
//
//  Created by Артур Гнедой on 20.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class AddNewChannelViewController: UIAlertController {
    
    var nameEntered: ((String) -> Void)?
    
    private lazy var saveAction: UIAlertAction = {
        let action = UIAlertAction(title: "Create", style: .default) {[weak self] _ in
            self?.textFieldSubmitted()
        }
        
        action.isEnabled = false
        
        return action
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        addTextField { textField in
            textField.borderStyle = .roundedRect
            textField.attributedPlaceholder = NSAttributedString(string: "Channel name",
                                                                 attributes: [NSAttributedString.Key.foregroundColor:
                                                                    ThemeManager.shared.currentTheme.textColor.withAlphaComponent(0.7)])
            textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            textField.backgroundColor = ThemeManager.shared.currentTheme.inputFieldBackgroundColor
            textField.layer.borderColor = ThemeManager.shared.currentTheme.inputFieldBorderBackgroundColor.cgColor
            textField.layer.borderWidth = 1.5
            textField.layer.cornerRadius = 4.0
            textField.textColor = ThemeManager.shared.currentTheme.textColor
            textField.returnKeyType = .go
            textField.delegate = self
            textField.enablesReturnKeyAutomatically = true
            textField.addTarget(self, action: #selector(self.channelNameDidChanged(_:)), for: .editingChanged)
        }
        
        addAction(UIAlertAction(title: "Cancel", style: .cancel))
        addAction(saveAction)
    }
    
    @objc func channelNameDidChanged(_ textField: UITextField) {
        if let text = textField.text, text.count > 0 {
            saveAction.isEnabled = true
        } else {
            saveAction.isEnabled = false
        }
    }
    
    private func textFieldSubmitted() {
        if let textField = self.textFields?.first, let name = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), name.count > 0 {
            nameEntered?(name)
            dismiss(animated: true)
        }
    }

}

extension AddNewChannelViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldSubmitted()
        return true
    }
}
