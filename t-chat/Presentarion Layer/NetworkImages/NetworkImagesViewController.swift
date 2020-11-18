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
    private let apiKey = "19163487-f1fd170fca1ad072fa2f4a91c"
    private let themeManager: ThemeManager
    
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
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        return indicator
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
        
        view.addSubview(loadingIndicator)
        loadingIndicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        let queryParams = [URLQueryItem(name: "key", value: apiKey),
                           URLQueryItem(name: "q", value: "pug"),
                           URLQueryItem(name: "image_type", value: "photo"),
                           URLQueryItem(name: "per_page", value: "24")]
        
        var components = URLComponents(string: "https://pixabay.com/api/")
        components?.queryItems = queryParams
        let session = URLSession.shared
        if let url = components?.url {
            print(url.absoluteString)
            let task = session.dataTask(with: url) {[weak self] data, _, error in
                let parser = PixabayResponseParser()
                if let data = data {
                    let items = parser.parse(data: data)
                    if items.count > 0 {
                        self?.photos = items
                        DispatchQueue.main.async {
                            self?.collectionView.isHidden = false
                            self?.collectionView.reloadData()
                            self?.loadingIndicator.isHidden = true
                        }
                    }
                }
                
            }
            
            task.resume()
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
        
        URLSession.shared.dataTask(with: photos[indexPath.row].previewURL) { data, _, error in
            guard let data = data, let image = UIImage(data: data) else {
                return
            }
            
            DispatchQueue.main.async {
                cell.image = image
            }
        }.resume()
        
        cell.showActivityIndicator()
        
        return cell
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

class PixabayResponseParser {
    func parse(data: Data) -> [NetworkPhoto] {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                fatalError("Bad json for Pixabay API")
            }
            
            guard let images = json["hits"] as? [[String: Any]] else {
                fatalError("No images")
            }
            
            var photos: [NetworkPhoto] = []
            
            for image in images {
                if let preview = image["previewURL"] as? String, let photo = image["largeImageURL"] as? String {
                    guard let previewURL = URL(string: preview), let imageURL = URL(string: photo) else {
                        fatalError("No valid urls in response")
                    }
                    
                    photos.append(NetworkPhoto(previewURL: previewURL, imageURL: imageURL))
                }
            }
            
            return photos
            
        } catch {
            return []
        }
    }
}
