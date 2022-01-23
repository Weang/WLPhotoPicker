//
//  AlbumListViewController.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/22.
//

import UIKit

protocol AlbumListViewControllerDelegate: AnyObject {
    func albumList(_ viewController: AlbumListViewController, didSelect album: AlbumModel)
    func albumListDidDismiss(_ viewController: AlbumListViewController)
}

class AlbumListViewController: UIViewController {
    
    weak var delegate: AlbumListViewControllerDelegate?
    
    let tableViewContentView = UIView()
    let tableView = UITableView(frame: .zero, style: .plain)
    
    let dismissTapGesture = UITapGestureRecognizer()
    
    private let albumsList: [AlbumModel]
    private let selectedAlbum: AlbumModel?
    
    init(albumsList: [AlbumModel], selectedAlbum: AlbumModel?) {
        self.albumsList = albumsList
        self.selectedAlbum = selectedAlbum
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
        modalPresentationCapturesStatusBarAppearance = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        if let index = albumsList.firstIndex(where: {
            $0.localIdentifier == self.selectedAlbum?.localIdentifier
        }) {
            tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: false)
        }
    }
    
    private func setupView() {
        view.backgroundColor = .clear
        
        tableViewContentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        tableViewContentView.layer.cornerRadius = 10
        tableViewContentView.layer.masksToBounds = true
        view.addSubview(tableViewContentView)
        tableViewContentView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(0)
        }
        
        tableView.register(AlbumListTableViewCell.self)
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.rowHeight = 54
        tableView.delegate = self
        tableView.dataSource = self
        tableViewContentView.addSubview(tableView)
        let height = min(view.height * 0.7, tableView.rowHeight * CGFloat(albumsList.count))
        tableView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(height)
        }
        view.layoutIfNeeded()
        
        dismissTapGesture.addTarget(self, action: #selector(handleTapGesture))
        dismissTapGesture.delegate = self
        view.addGestureRecognizer(dismissTapGesture)
    }
    
    @objc private func handleTapGesture() {
        dismiss(animated: true, completion: nil)
        delegate?.albumListDidDismiss(self)
    }
    
}

// MARK: UITableViewDelegate & UITableViewDataSource
extension AlbumListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(AlbumListTableViewCell.self)
        let model = albumsList[indexPath.row]
        cell.bind(model)
        cell.isSelectedAlbum = model.localIdentifier == selectedAlbum?.localIdentifier
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.albumList(self, didSelect: albumsList[indexPath.row])
        delegate?.albumListDidDismiss(self)
        dismiss(animated: true, completion: nil)
    }
    
}

extension AlbumListViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: self.view)
        return location.y > tableView.height || location.y < tableView.y
    }
    
}
