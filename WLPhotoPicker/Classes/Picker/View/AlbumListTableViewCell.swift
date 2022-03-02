//
//  AlbumListTableViewCell.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/11.
//

import UIKit

class AlbumListTableViewCell: UITableViewCell {
    
    private let albumCover = UIImageView()
    private let albumNameLabel = UILabel()
    private let photoCountLabel = UILabel()
    private let checkedIconView = UIImageView()
    
    private var request: AssetFetchRequest?
    
    public var isSelectedAlbum: Bool = false {
        didSet {
            checkedIconView.isHidden = !isSelectedAlbum
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        
        albumCover.clipsToBounds = true
        albumCover.contentMode = .scaleAspectFill
        contentView.addSubview(albumCover)
        albumCover.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(albumCover.snp.height)
        }
        
        albumNameLabel.textColor = WLPhotoUIConfig.default.color.textColor
        contentView.addSubview(albumNameLabel)
        albumNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(albumCover.snp.right).offset(12)
        }
        
        photoCountLabel.textColor = WLPhotoUIConfig.default.color.textColor.withAlphaComponent(0.7)
        contentView.addSubview(photoCountLabel)
        photoCountLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(albumNameLabel.snp.right).offset(10)
        }
        
        checkedIconView.image = BundleHelper.imageNamed("checked")?.withRenderingMode(.alwaysTemplate)
        checkedIconView.tintColor = WLPhotoUIConfig.default.color.primaryColor
        checkedIconView.contentMode = .scaleAspectFit
        contentView.addSubview(checkedIconView)
        checkedIconView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-16)
            make.height.width.equalTo(18)
        }
        
    }
    
    func bind(_ model: AlbumModel) {
        cancelLastRequest()
        
        albumNameLabel.text = model.localizedTitle
        photoCountLabel.text = "（\(model.count)）"
        
        if let coverAsset = model.coverAsset {
            let options = AssetFetchOptions()
            options.sizeOption = .specify(54 * UIScreen.main.scale)
            request = AssetFetchTool.requestPhoto(for: coverAsset.asset, options: options) { [weak self] result, _ in
                switch result {
                case .success(let response):
                    self?.albumCover.image = response.image
                case .failure:
                    self?.albumCover.image = nil
                }
            }
        }
    }
    
    private func cancelLastRequest() {
        request?.cancel()
        request = nil
        albumCover.image = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancelLastRequest()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
