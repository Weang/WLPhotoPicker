//
//  PhotoEditPasterCollectionViewCell.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/6.
//

import UIKit

class PhotoEditPasterCollectionViewCell: UICollectionViewCell {

    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func bind(_ paster: PhotoEditPasterProvider) {
        switch paster {
        case .imageName(let name):
            imageView.image = UIImage(named: name)
        case .imagePath(let path):
            imageView.image = UIImage(contentsOfFile: path)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
