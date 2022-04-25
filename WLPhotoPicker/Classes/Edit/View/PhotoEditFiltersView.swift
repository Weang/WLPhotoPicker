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
    private let photoEditConfig: PhotoEditConfig
    private var filterPhotos: [UIImage?] = []
    
    var selectedFilterIndex: Int = 0 {
        didSet {
            if filterPhotos.count > selectedFilterIndex {
                collectionView.selectItem(at: IndexPath(item: selectedFilterIndex, section: 0), animated: false, scrollPosition: .left)
            }
        }
    }
    
    init(photo: UIImage?, photoEditConfig: PhotoEditConfig) {
        self.photo = photo
        self.photoEditConfig = photoEditConfig
        super.init(frame: .zero)
        
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
        
        DispatchQueue.global().async { [weak self] in
            for filter in photoEditConfig.photoEditFilters {
                let filterPhoto = filter.filter?(photo) ?? photo
                self?.filterPhotos.append(filterPhoto)
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.collectionView.reloadData()
                if self.filterPhotos.count > self.selectedFilterIndex {
                    let indexPath = IndexPath(item: self.selectedFilterIndex, section: 0)
                    self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
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
        cell.nameLabel.text = photoEditConfig.photoEditFilters[indexPath.item].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if indexPath == collectionView.indexPathsForSelectedItems?.first {
            return false
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.filtersView(self, didSelectFilter: photoEditConfig.photoEditFilters[indexPath.item], index: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: collectionView.height)
    }
    
}
