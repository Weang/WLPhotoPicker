//
//  WLPhotoPickerController.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/10.
//

import UIKit
import SnapKit

public protocol WLPhotoPickerControllerDelegate: AnyObject {
    
    // 点击取消
    // 如果WLPhotoPickerUIConfig的autoDismiss为false，那么控制器不会自动关闭
    func pickerControllerDidCancel(_ pickerController: WLPhotoPickerController)
    
    // 点击完成按钮
    func pickerController(_ pickerController: WLPhotoPickerController, didSelectResult result: [AssetPickerResult])
    
    // 发生错误
    func pickerController(_ pickerController: WLPhotoPickerController, didOccurredError error: WLPhotoError)
}

public extension WLPhotoPickerControllerDelegate {
    func pickerControllerDidCancel(_ pickerController: WLPhotoPickerController) { }
    func pickerController(_ pickerController: WLPhotoPickerController, didSelectResult result: [AssetPickerResult]) { }
    func pickerController(_ pickerController: WLPhotoPickerController, didOccurredError error: WLPhotoError) { }
}

public class WLPhotoPickerController: UINavigationController {
    
    public weak var pickerDelegate: WLPhotoPickerControllerDelegate?
    
    let pickerConfig: WLPhotoConfig
    
    public init(pickerConfig: WLPhotoConfig = .default) {
        self.pickerConfig = pickerConfig.checkCongfig()
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        
        navigationBar.barTintColor = .white
        navigationBar.tintColor = .black
        let viewController = AssetPickerController(config: pickerConfig)
        viewController.delegate = self
        viewControllers = [viewController]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundImage = UIImage.imageWithColor(.white)
            appearance.shadowImage = UIImage.imageWithColor(.clear)
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        } else {
            navigationBar.setBackgroundImage(UIImage.imageWithColor(.white), for: .default)
            navigationBar.shadowImage = UIImage()
        }
        navigationBar.isTranslucent = true
    }
    
}

extension WLPhotoPickerController: AssetPickerControllerDelegate {
    
    func pickerControllerDidCancel(_ pickerController: AssetPickerController) {
        pickerDelegate?.pickerControllerDidCancel(self)
    }
    
    func pickerController(_ pickerController: AssetPickerController, didSelectResult result: [AssetPickerResult]) {
        pickerDelegate?.pickerController(self, didSelectResult: result)
        
        if pickerConfig.pickerConfig.autoDismissAfterDone {
            if let vc = self.presentedViewController as? AssetPreviewViewController {
                vc.transitioningDelegate = nil
                vc.modalPresentationStyle = .fullScreen
            }
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func pickerController(_ pickerController: AssetPickerController, didOccurredError error: WLPhotoError) {
        pickerDelegate?.pickerController(self, didOccurredError: error)
    }
    
}
