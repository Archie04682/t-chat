//
//  ThemesViewController.swift
//  t-chat
//
//  Created by Артур Гнедой on 03.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class ThemesViewController: UIViewController {
    private var themeManager: ThemeManager
    private lazy var selectedTheme = themeManager.currentTheme
    
    private lazy var themeViews: [ThemeView] = {
        var views: [ThemeView] = []
        for theme in Theme.allCases {
            let view = ThemeView(theme: theme)

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
    
    init(themeManager: ThemeManager) {
        self.themeManager = themeManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        
        themeManager.delegate = self
        
        view.backgroundColor = selectedTheme.conversationBackgroundColor
        themeViews.forEach {
            $0.checkIfButtonSelected(selectedTheme)
            container.addArrangedSubview($0)
        }
        
        view.addSubview(container)
        
        container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 38).isActive = true
        container.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -38).isActive = true
        container.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 38).isActive = true
        container.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -38).isActive = true
    }
    
    private func themeDidChange(theme: Theme) {
        themeManager.apply(theme: theme)
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

extension ThemesViewController: ThemeManagerDelegate {
    
    func didSelectTheme(theme: Theme) {
        themeManager.save(theme: theme) {[weak self] in
            DispatchQueue.main.async {
                self?.update(theme: theme)
            }
        }
    }
    
}
