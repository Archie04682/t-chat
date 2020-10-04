//
//  ThemesViewController.swift
//  t-chat
//
//  Created by Артур Гнедой on 03.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class ThemesViewController: UIViewController {
    
    private lazy var container: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .fill
        view.distribution = .equalSpacing
        view.axis = .vertical
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        
        view.backgroundColor = .white
        
        let classicThemeView = ThemeView()
        classicThemeView.configure(with: Theme.classic)
        let dayThemeView = ThemeView()
        dayThemeView.configure(with: Theme.day)
        let nightThemeView = ThemeView()
        nightThemeView.configure(with: Theme.night)
        container.addArrangedSubview(classicThemeView)
        container.addArrangedSubview(dayThemeView)
        container.addArrangedSubview(nightThemeView)
        
        view.addSubview(container)
        
        container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 85).isActive = true
        container.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -85).isActive = true
        container.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 38).isActive = true
        container.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -38).isActive = true
    }

}
