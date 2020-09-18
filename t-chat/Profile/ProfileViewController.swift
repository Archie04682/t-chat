//
//  UserProfileViewController.swift
//  t-chat
//
//  Created by Артур Гнедой on 18.09.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    
    @IBOutlet weak var profileImageContainer: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    private var profileImageURL: URL?
    private let username = "Marina Dudarenko"
    
    required init?(coder: NSCoder) {
        /*
         Нельзя получить доступ к saveButton, т.к. при инициализации VC он еще не создан и saveButton == nil.
         Обернул в if let чтобы не возникало ошибки.
         */
        if let button = saveButton {
            print(button.frame)
        }
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(saveButton.frame)
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /*
        Значения Frame разные, потому что сначала вычисляются значения frame по констрейнтам. Это Update этап.
        
        Далее, идет этап Layout, который отвечает за размеров и позиций View и его Subviews на экране.
        
        Если выставить девайс в Storyboard IPhone 11 Pro, то разницы между выводимыми сообщениями не будет. Как я понял, это потому, что высота и ширина экрана будет одинаковой у девайса в Storyboard и эмулятора.
        */
        print(saveButton.frame)
    }
    
}

extension ProfileViewController {
    
    func setupViews() {
        profileImageContainer.layer.cornerRadius = profileImageContainer.frame.width / 2
        saveButton.layer.cornerRadius = 14
        usernameLabel.text = username
        setProfileImage()
    }
    
    func setProfileImage() {
        if profileImageURL == nil {
            createInitialsPlaceholder()
        } else {
    
        }
    }
    
    func createInitialsPlaceholder() {
        let initials = username.components(separatedBy: " ").map { word in
            if let firstLetter = word.first {
                return String(firstLetter)
            }
            
            return ""
        }.joined()
        
        let initialsLabel = UILabel()
        initialsLabel.text = initials
        initialsLabel.font = UIFont.systemFont(ofSize: 120)
        initialsLabel.textAlignment = .center
        
        profileImageContainer.addSubview(initialsLabel)
        initialsLabel.translatesAutoresizingMaskIntoConstraints = false
        initialsLabel.centerXAnchor.constraint(equalTo: profileImageContainer.centerXAnchor).isActive = true
        initialsLabel.centerYAnchor.constraint(equalTo: profileImageContainer.centerYAnchor).isActive = true
        initialsLabel.widthAnchor.constraint(equalTo: profileImageContainer.widthAnchor).isActive = true
    }
    
}
