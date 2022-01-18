//
//  PhotoEditAdjustView.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/7.
//

import UIKit

protocol PhotoEditAdjustViewDelegate: AnyObject {
    func adjustView(_ adjustView: PhotoEditAdjustView, didSelectAdjustMode: PhotoEditAdjustMode)
}

class PhotoEditAdjustView: UIView {
    
    var currentAdjustMode: PhotoEditAdjustMode? {
        if let indexPath = collectionView.indexPathsForSelectedItems?.first {
            return photoEditConfig.photoEditAdjustModes[indexPath.item]
        }
        return nil
    }
    
    weak var delegate: PhotoEditAdjustViewDelegate?
    
    var collectionView: UICollectionView!
    let photoEditConfig: PhotoEditConfig
    
    init(photoEditConfig: PhotoEditConfig) {
        self.photoEditConfig = photoEditConfig
        super.init(frame: .zero)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 28
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.register(PhotoEditAdjustCollectionViewCell.self)
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(24)
            make.right.equalTo(-24)
        }
        
        if photoEditConfig.photoEditAdjustModes.count > 0 {
            collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .left)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PhotoEditAdjustView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoEditConfig.photoEditAdjustModes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(PhotoEditAdjustCollectionViewCell.self, for: indexPath)
        cell.bind(photoEditConfig.photoEditAdjustModes[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        if indexPath == collectionView.indexPathsForSelectedItems?.first {
            return false
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.adjustView(self, didSelectAdjustMode: photoEditConfig.photoEditAdjustModes[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 28, height: collectionView.height)
    }
    
}
