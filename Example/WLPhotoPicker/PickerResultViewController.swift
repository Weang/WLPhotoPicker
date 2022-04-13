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

    var result: [AssetPickerResult] = []
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "结果"
        
        view.backgroundColor = .white
        
        tableView.register(PickerResultTableViewCell.self, forCellReuseIdentifier: "PickerResultTableViewCell")
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.rowHeight = 120
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}

extension PickerResultViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return result.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PickerResultTableViewCell") as! PickerResultTableViewCell
        cell.bind(result[indexPath.section])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = result[indexPath.section]
        guard case .video(let video) = model.result else { return }
        
        if let fileURL = video.videoURL {
            let player = AVPlayer(url: fileURL)
            let controller = AVPlayerViewController()
            controller.player = player
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true) {
                player.play()
            }
        } else if let playerItem = video.playerItem.copy() as? AVPlayerItem {
            let player = AVPlayer(playerItem: playerItem)
            let controller = AVPlayerViewController()
            controller.player = player
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true) {
                player.play()
            }
        }
    }
}
