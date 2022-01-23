//
//  PhotoEditTextColorsView.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/8.
//

import UIKit

protocol PhotoEditTextColorsViewDelegate: AnyObject {
    func textColorsView(_ textColorsView: PhotoEditTextColorsView, didClickWrapButton isWrap: Bool)
    func textColorsView(_ textColorsView: PhotoEditTextColorsView, didSelectColorIndex index: Int)
}

class PhotoEditTextColorsView: UIView {
    
    weak var delegate: PhotoEditTextColorsViewDelegate?
    
    private let photoEditConfig: PhotoEditConfig
    
    var collectionView: UICollectionView!
    let wrapButton = NormalStyleButton()
    
    init(photoEditConfig: PhotoEditConfig) {
        self.photoEditConfig = photoEditConfig
        super.init(frame: .zero)
        
        wrapButton.tintColor = .white
        wrapButton.addTarget(self, action: #selector(wrapButtonClick), for: .touchUpInside)
        wrapButton.setImage(BundleHelper.imageNamed("text_nowrap")?.withRenderingMode(.alwaysTemplate), for: .normal)
        wrapButton.setImage(BundleHelper.imageNamed("text_wrap")?.withRenderingMode(.alwaysTemplate), for: .selected)
        addSubview(wrapButton)
        wrapButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 26, height: 26)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.register(PhotoEditGraffitiColorCollectionViewCell.self)
        collectionView.isScrollEnabled = false
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.equalTo(wrapButton.snp.right).offset(20)
            make.right.equalToSuperview()
            make.height.equalTo(32)
            make.centerY.equalToSuperview()
        }
        
        collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .left)
    }
    
    @objc private func wrapButtonClick() {
        wrapButton.isSelected.toggle()
        delegate?.textColorsView(self, didClickWrapButton: wrapButton.isSelected)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PhotoEditTextColorsView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoEditConfig.photoEditTextColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(PhotoEditGraffitiColorCollectionViewCell.self, for: indexPath)
        cell.colorForegroundView.backgroundColor = photoEditConfig.photoEditTextColors[indexPath.item].tintColor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if collectionView.indexPathsForSelectedItems?.first == indexPath {
            return false
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.textColorsView(self, didSelectColorIndex: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let count = CGFloat(photoEditConfig.photoEditTextColors.count)
        let itemWidth = (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize.width ?? 0
        return CGFloat(floor((collectionView.width - count * itemWidth) / (count - 1)))
    }
}
