//
//  PhotoEditPasterViewController.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/6.
//

import UIKit

protocol PhotoEditPasterViewControllerDelegate: AnyObject {
    
    func pasterController(_ pasterController: PhotoEditPasterViewController, didSelectPasterImage image: UIImage)
    
}

class PhotoEditPasterViewController: UIViewController {

    weak var delegate: PhotoEditPasterViewControllerDelegate?
    
    let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    let cancelButton = UIButton()
    var collectionView: UICollectionView!
    
    var backgroundViewHeight: CGFloat {
        400 + keyWindowSafeAreaInsets.bottom
    }
    
    let photoEditConfig: PhotoEditConfig
    
    init(photoEditConfig: PhotoEditConfig) {
        self.photoEditConfig = photoEditConfig
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView() {
        view.backgroundColor = .clear
        
        let dismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(cancelButtonClick))
        dismissTapGesture.delegate = self
        view.addGestureRecognizer(dismissTapGesture)
        
        backgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        backgroundView.layer.cornerRadius = 10
        backgroundView.layer.masksToBounds = true
        backgroundView.contentView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.5)
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(backgroundViewHeight)
            make.bottom.equalTo(backgroundViewHeight)
        }
        
        cancelButton.setImage(BundleHelper.imageNamed("paster_back"), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonClick), for: .touchUpInside)
        backgroundView.contentView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.centerX.equalToSuperview()
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 14
        layout.minimumInteritemSpacing = 14
        layout.sectionInset = UIEdgeInsets(top: 0, left: 14, bottom: 10, right: 14)
        let itemWidth = CGFloat(floor((UIScreen.width - 70) / 4))
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(PhotoEditPasterCollectionViewCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        backgroundView.contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(cancelButton.snp.bottom).offset(16)
        }
        
        view.layoutIfNeeded()
    }
    
    @objc func cancelButtonClick() {
        dismiss(animated: true, completion: nil)
    }
    
}

extension PhotoEditPasterViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoEditConfig.photoEditPasters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(PhotoEditPasterCollectionViewCell.self, for: indexPath)
        cell.bind(photoEditConfig.photoEditPasters[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var image: UIImage?
        switch photoEditConfig.photoEditPasters[indexPath.item] {
        case .imageName(let name):
            image = UIImage(named: name)
        case .imagePath(let path):
            image = UIImage(contentsOfFile: path)
        }
        guard let image = image else { return }
        delegate?.pasterController(self, didSelectPasterImage: image)
        dismiss(animated: true, completion: nil)
    }
}

extension PhotoEditPasterViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: self.view)
        return !backgroundView.frame.contains(location)
    }
    
}
