//
//  ThemesViewController.swift
//  t-chat
//
//  Created by Артур Гнедой on 03.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class ThemesViewController: UIViewController {
    
    private var selectedTheme = ThemeManager.shared.currentTheme
    
    private lazy var themeViews: [ThemeView] = {
        var views: [ThemeView] = []
        for theme in Theme.allCases {
            let view = ThemeView()

            view.selected = {[weak self] theme in
                self?.themeDidChange(theme: theme)
            }
            view.configure(with: theme)
            views.append(view)
        }
        
        return views
    }()
    
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
        
        // И delegate и closure объявлены слабыми ссылками, т.к. ThemeManager синглтон и будет "жить" в приложении дольше нашего ThemesViewController. Retain cycle получаем, если объявляем и dalegate и closure сильными ссылками
        
         ThemeManager.shared.delegate = self
//        ThemeManager.shared.didPickTheme = {[weak self] theme in
//            self?.update(theme: theme)
//        }
        
        view.backgroundColor = selectedTheme.conversationBackgroundColor
        themeViews.forEach {
            $0.checkIfButtonSelected(selectedTheme)
            container.addArrangedSubview($0)
        }
        
        view.addSubview(container)
        
        container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 85).isActive = true
        container.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -85).isActive = true
        container.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 38).isActive = true
        container.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -38).isActive = true
    }
    
    private func themeDidChange(theme: Theme) {
        ThemeManager.shared.apply(theme: theme)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func update(theme: Theme) {
        self.selectedTheme = theme
        
        UIView.animate(withDuration: TimeInterval(0.7)) {
            self.view.backgroundColor = theme.conversationBackgroundColor
            self.navigationController?.navigationBar.barTintColor = theme.barTintColor
            self.navigationController?.navigationBar.backgroundColor = theme.backgroundColor
            self.navigationController?.navigationBar.titleTextAttributes = theme.navigationBarTitleTextAttributes
            self.navigationController?.navigationBar.barStyle = theme.statusBarStyle
        }
        
        themeViews.forEach {
            $0.checkIfButtonSelected(selectedTheme)
        }
    }

}

extension ThemesViewController: ThemePickerDelegate {
    
    func didSelectTheme(theme: Theme) {
        ThemeManager.shared.save(theme: theme) {[weak self] in
            DispatchQueue.main.async {
                self?.update(theme: theme)
            }
        }
    }
    
}
