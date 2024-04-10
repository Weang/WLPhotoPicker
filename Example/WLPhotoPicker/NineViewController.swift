//
//  NineViewController.swift
//  WLPhotoPicker_Example
//
//  Created by Mr.Wang on 2022/4/20.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import WLPhotoPicker

class NineViewController: UIViewController {

    var collectionView: UICollectionView!
    var results: [PhotoPickerResult] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor { traitCollection -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return .black
                } else {
                    return .white
                }
            }
        } else {
            view.backgroundColor = .white
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        let itemWidth = floor((UIScreen.main.bounds.size.width - layout.minimumLineSpacing * 2 - 10) / 3)
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.alwaysBounceVertical = true
        collectionView.register(NineCollectionViewCell.self, forCellWithReuseIdentifier: "NineCollectionViewCell")
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc func deleteButtonClick(_ button: UIButton) {
        results.remove(at: button.tag)
        collectionView.reloadData()
    }

}

extension NineViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(results.count + 1, 9)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NineCollectionViewCell", for: indexPath) as! NineCollectionViewCell
        if indexPath.item < results.count {
            cell.deleteButton.isHidden = false
            cell.imageView.image = results[indexPath.item].photo
        } else {
            cell.deleteButton.isHidden = true
            cell.imageView.image = UIImage.init(named: "add")
        }
        cell.deleteButton.tag = indexPath.item
        cell.deleteButton.addTarget(self, action: #selector(deleteButtonClick(_:)), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item == results.count else  {
            if let photo = results[indexPath.item].photo {
                let config = PhotoEditConfig()
                config.dismissWithAnimation = true
                let c = PhotoEditConfig()
                c.dismissWithAnimation = true
//                let editVC = PhotoEditViewController(photo: photo, photoEditConfig: c)
                let editVC = PhotoEditCropViewController(photo: photo, photoEditCropRatios: .ratio_1_1)
                if let cell = collectionView.cellForItem(at: indexPath) as? NineCollectionViewCell {
                    editVC.animationSourceImageView = cell.imageView
                }
                present(editVC, animated: true, completion: nil)
            }
            return
        }
        let config = WLPhotoConfig()
        config.pickerConfig.selectableType = [.photo]
        let vc = WLPhotoPickerController(config: config)
        vc.selectedIdentifiers = results.map{ $0.asset.localIdentifier }
        vc.pickerDelegate = self
        self.present(vc, animated: true)
    }
}

extension NineViewController: WLPhotoPickerControllerDelegate {
    
    func pickerController(_ pickerController: WLPhotoPickerController, didSelectResult results: [PhotoPickerResult]) {
        self.results = results
        collectionView.reloadData()
    }
    
}
