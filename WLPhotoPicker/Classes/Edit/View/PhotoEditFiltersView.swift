//
//  PhotoEditFiltersView.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/6.
//

import UIKit

protocol PhotoEditFiltersViewDelegate: AnyObject {
    func filtersView(_ filtersView: PhotoEditFiltersView, didSelectFilter filter: PhotoEditFilterProvider)
}

class PhotoEditFiltersView: UIView {
    
    weak var delegate: PhotoEditFiltersViewDelegate?
    
    private var collectionView: UICollectionView!
    
    private let photo: UIImage?
    private let photoEditConfig: PhotoEditConfig
    
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
        if photoEditConfig.photoEditFilters.count > 0 {
            collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .left)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PhotoEditFiltersView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoEditConfig.photoEditFilters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(PhotoEditFilterCollectionViewCell.self, for: indexPath)
        let filter = photoEditConfig.photoEditFilters[indexPath.item]
        cell.bind(filter)
        cell.imageView.image = filter.filterImage(photo?.thumbnailWith(60))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if indexPath == collectionView.indexPathsForSelectedItems?.first {
            return false
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.filtersView(self, didSelectFilter: photoEditConfig.photoEditFilters[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: collectionView.height)
    }
    
}
