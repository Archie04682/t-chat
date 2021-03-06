//
//  NetworkImagesViewController.swift
//  t-chat
//
//  Created by Артур Гнедой on 18.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit
import Network

class NetworkImagesViewController: UIViewController {
    private let themeManager: ThemeManager
    private let networkImageService: NetworkImageService
    
    weak var delegate: NetworkImagesViewDelegate?
    
    private var photos: [NetworkPhoto] = []
    
    private let contentInsets = UIEdgeInsets(top: 8.0,
                                             left: 8.0,
                                             bottom: 8.0,
                                             right: 8.0)
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.backgroundColor = self.themeManager.currentTheme.backgroundColor
        return view
    }()
    
    private lazy var backdropWithLoading: BackdropWithLoading = {
        let backdrop = BackdropWithLoading()
        backdrop.translatesAutoresizingMaskIntoConstraints = false
        
        return backdrop
    }()
    
    init(networkImageService: NetworkImageService, themeManager: ThemeManager) {
        self.themeManager = themeManager
        self.networkImageService = networkImageService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Choose image"
        view.backgroundColor = themeManager.currentTheme.backgroundColor
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: String(describing: type(of: PhotoCell.self)))
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        view.addSubview(backdropWithLoading)
        backdropWithLoading.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        backdropWithLoading.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        backdropWithLoading.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        backdropWithLoading.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        networkImageService.get(limit: 200, withTags: ["pug"]) {[weak self] result in
            switch result {
            case .success(let photos):
                self?.photos = photos
                DispatchQueue.main.async {
                    self?.collectionView.isHidden = false
                    self?.collectionView.reloadData()
                    self?.backdropWithLoading.isHidden = true
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    let errorVC = ErrorOccuredView(message: error.localizedDescription)
                    self?.present(errorVC, animated: true, completion: nil)
                }
            }
        }
    }
    
}

extension NetworkImagesViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return photos.count > 0 ? 1 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
      return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: type(of: PhotoCell.self)), for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
        
        cell.showActivityIndicator()
        
        networkImageService.downloadImage(fromURL: photos[indexPath.row].previewURL) { result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    cell.image = image
                }
            case .failure(let error):
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    cell.image = UIImage(named: "image-placeholder")
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        backdropWithLoading.isHidden = false
        networkImageService.downloadImage(fromURL: photos[indexPath.row].imageURL) { result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didSelect(image: image)
                    self?.backdropWithLoading.isHidden = true
                    self?.dismiss(animated: true, completion: nil)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    let ac = ErrorOccuredView(message: error.localizedDescription)
                    self.present(ac, animated: true, completion: nil)
                }
            }
        }
    }
}

extension NetworkImagesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = contentInsets.left * 4
        let availableWidth = view.frame.width - padding
        let itemWidth = availableWidth / 3
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
      return contentInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return contentInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return contentInsets.left
    }
}
