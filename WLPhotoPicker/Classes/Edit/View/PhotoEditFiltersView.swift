//
//  PhotoEditFiltersView.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/6.
//

import UIKit

protocol PhotoEditFiltersViewDelegate: AnyObject {
    func filtersView(_ filtersView: PhotoEditFiltersView, didSelectFilter filter: PhotoEditFilterProvider, index: Int)
}

class PhotoEditFiltersView: UIView {
    
    weak var delegate: PhotoEditFiltersViewDelegate?
    
    private var collectionView: UICollectionView!
    
    private let photo: UIImage?
    private let selectedFilterIndex: Int
    private let photoEditConfig: PhotoEditConfig
    
    private var photoEditFilters: [PhotoEditFilterProvider] = []
    private var filterPhotos: [UIImage?] = []
    
    private let filterQueue = DispatchQueue(label: "com.WLPhotoPicker.DispatchQueue.Filter")
    
    init(photo: UIImage?, selectedFilterIndex: Int, photoEditConfig: PhotoEditConfig) {
        self.photo = photo
        self.selectedFilterIndex = selectedFilterIndex
        self.photoEditConfig = photoEditConfig
        super.init(frame: .zero)
        
        setupView()
        setupPhotos()
    }
    
    func setupView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(PhotoEditFilterCollectionViewCell.self)
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(16)
            make.right.equalTo(-16)
        }
    }
    
    func setupPhotos() {
        let photo = self.photo?.thumbnailWith(60)
        
        photoEditFilters = photoEditConfig.photoEditFilters
        photoEditFilters.insert(PhotoEditOriginalFilter(), at: 0)
        filterPhotos = [UIImage?].init(repeating: nil, count: photoEditFilters.count)
        
        for (index, filter) in self.photoEditFilters.enumerated() {
            filterQueue.async { [weak self] in
                let filterPhoto = filter.filter?(photo) ?? photo
                self?.filterPhotos[index] = filterPhoto
                DispatchQueue.main.sync {
                    guard let self = self else { return }
                    self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                    if index == self.selectedFilterIndex {
                        let indexPath = IndexPath(item: self.selectedFilterIndex, section: 0)
                        self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
                    }
                }
            }
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PhotoEditFiltersView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(PhotoEditFilterCollectionViewCell.self, for: indexPath)
        cell.imageView.image = filterPhotos[indexPath.item]
        cell.nameLabel.text = photoEditFilters[indexPath.item].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if indexPath == collectionView.indexPathsForSelectedItems?.first {
            return false
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.filtersView(self, didSelectFilter: photoEditFilters[indexPath.item], index: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: collectionView.height)
    }
    
}
