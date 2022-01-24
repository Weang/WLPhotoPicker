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
    // 如果PickerConfig的dismissPickerAfterDone为false，那么控制器不会自动关闭
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
    
    let config: WLPhotoConfig
    
    public init(config: WLPhotoConfig = .default) {
        self.config = config.checkCongfig()
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        navigationBar.barTintColor = WLPhotoUIConfig.default.color.toolBarColor
        navigationBar.tintColor = WLPhotoUIConfig.default.color.textColor
        
        let viewController = AssetPickerController(config: config)
        viewController.delegate = self
        viewControllers = [viewController]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
//        if #available(iOS 15.0, *) {
//            let appearance = UINavigationBarAppearance()
//            appearance.configureWithTransparentBackground()
//            appearance.backgroundImage = UIImage.imageWithColor(WLPhotoUIConfig.default.color.pickerNavigationBar)
//            appearance.shadowImage = UIImage.imageWithColor(.clear)
//            navigationBar.standardAppearance = appearance
//            navigationBar.scrollEdgeAppearance = appearance
//        } else {
//            navigationBar.setBackgroundImage(UIImage.imageWithColor(WLPhotoUIConfig.default.color.pickerNavigationBar), for: .default)
//            navigationBar.shadowImage = UIImage()
//        }
    }
    
}

// MARK: AssetPickerControllerDelegate
extension WLPhotoPickerController: AssetPickerControllerDelegate {
    
    func pickerControllerDidCancel(_ pickerController: AssetPickerController) {
        pickerDelegate?.pickerControllerDidCancel(self)
        
        if config.pickerConfig.dismissPickerAfterDone {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func pickerController(_ pickerController: AssetPickerController, didSelectResult result: [AssetPickerResult]) {
        pickerDelegate?.pickerController(self, didSelectResult: result)
        
        if config.pickerConfig.dismissPickerAfterDone {
            let previewController = presentedViewController as? AssetPreviewViewController
            previewController?.transitioningDelegate = nil
            previewController?.modalPresentationStyle = .fullScreen
            presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func pickerController(_ pickerController: AssetPickerController, didOccurredError error: WLPhotoError) {
        pickerDelegate?.pickerController(self, didOccurredError: error)
    }
    
}
