//
//  PickerResultViewController.swift
//  WLPhotoPicker_Example
//
//  Created by Mr.Wang on 2022/1/19.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import WLPhotoPicker
import AVFoundation
import AVKit

class PickerResultViewController: UIViewController {
    
    var results: [PhotoPickerResult] = []
    var collectionView: UICollectionView!
    
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
        
        let layout = WaterfallLayout()
        layout.delegate = self
        layout.sectionInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .clear
        collectionView.register(PickerResultCollectionViewCell.self, forCellWithReuseIdentifier: "PickerResultCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}

extension PickerResultViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PickerResultCollectionViewCell", for: indexPath) as! PickerResultCollectionViewCell
        cell.setResult(results[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let result = results[indexPath.item]
        switch result.result {
        case .photo(let photoResult):
            let vc = PhotoPreviewViewController()
            vc.imageView.image = photoResult.photo
            present(vc, animated: true)
        case .video(let videoResult):
            let playerItem: AVPlayerItem
            if let videoURL = videoResult.videoURL {
                playerItem = AVPlayerItem(asset: AVAsset(url: videoURL))
            } else {
                playerItem = AVPlayerItem(asset: videoResult.avasset)
            }
            let controller = AVPlayerViewController()
            controller.player = AVPlayer(playerItem: playerItem)
            present(controller, animated: true) {
                controller.player?.play()
            }
        case .livePhoto(let livePhotoResult):
            let vc = LivePhotoPreviewViewController()
            vc.videoURL = livePhotoResult.videoURL
            vc.livePhotoView.livePhoto = livePhotoResult.livePhoto
            present(vc, animated: true)
        }
    }
}

extension PickerResultViewController: WaterfallLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout: WaterfallLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let imageSize = results[indexPath.item].photo?.size {
            return imageSize
        }
        return WaterfallLayout.automaticSize
    }
    
    func collectionViewLayout(for section: Int) -> WaterfallLayout.Layout {
        return .waterfall(column: 2, distributionMethod: .balanced)
    }
    
}
