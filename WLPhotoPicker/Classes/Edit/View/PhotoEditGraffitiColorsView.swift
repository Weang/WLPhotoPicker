//
//  PhotoEditGraffitiColorsView.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/6.
//

import UIKit

protocol PhotoEditGraffitiColorsViewDelegate: AnyObject {
    func graffitiColorsViewDidClickUndoButton(_ graffitiColorsView: PhotoEditGraffitiColorsView)
    func graffitiColorsView(_ graffitiColorsView: PhotoEditGraffitiColorsView, didSelectColor color: UIColor)
}

class PhotoEditGraffitiColorsView: UIView {
    
    weak var delegate: PhotoEditGraffitiColorsViewDelegate?
    
    var currentColor: UIColor? {
        if let indexPath = graffitiCollectionView.indexPathsForSelectedItems?.first {
            return photoEditConfig.photoEditGraffitiColors[indexPath.item]
        }
        return nil
    }
    
    let photoEditConfig: PhotoEditConfig
    
    var graffitiCollectionView: UICollectionView!
    let undoButton = UIButton()
    
    init(photoEditConfig: PhotoEditConfig) {
        self.photoEditConfig = photoEditConfig
        super.init(frame: .zero)
        
        undoButton.tintColor = .white
        undoButton.addTarget(self, action: #selector(undoButtonClick), for: .touchUpInside)
        undoButton.setImage(BundleHelper.imageNamed("undo")?.withRenderingMode(.alwaysTemplate), for: .normal)
        addSubview(undoButton)
        undoButton.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalToSuperview()
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 26, height: 26)
        
        graffitiCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        graffitiCollectionView.delegate = self
        graffitiCollectionView.dataSource = self
        graffitiCollectionView.backgroundColor = .clear
        graffitiCollectionView.register(PhotoEditGraffitiColorCollectionViewCell.self)
        graffitiCollectionView.isScrollEnabled = false
        addSubview(graffitiCollectionView)
        graffitiCollectionView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(undoButton.snp.left).offset(-20)
            make.height.equalTo(32)
            make.centerY.equalToSuperview()
        }
        
        if photoEditConfig.photoEditGraffitiColors.count > 0 {
            graffitiCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .left)
        }
        
    }
    
    @objc func undoButtonClick() {
        delegate?.graffitiColorsViewDidClickUndoButton(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PhotoEditGraffitiColorsView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoEditConfig.photoEditGraffitiColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(PhotoEditGraffitiColorCollectionViewCell.self, for: indexPath)
        cell.colorForegroundView.backgroundColor = photoEditConfig.photoEditGraffitiColors[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.graffitiColorsView(self, didSelectColor: photoEditConfig.photoEditGraffitiColors[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let count = CGFloat(photoEditConfig.photoEditGraffitiColors.count)
        let itemWidth = (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize.width ?? 0
        return CGFloat(floor((collectionView.width - count * itemWidth) / (count - 1)))
    }
}
