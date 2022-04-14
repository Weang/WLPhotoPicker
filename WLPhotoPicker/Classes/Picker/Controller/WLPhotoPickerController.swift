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
    func pickerController(_ pickerController: WLPhotoPickerController, didSelectResult results: [AssetPickerResult])
}

public extension WLPhotoPickerControllerDelegate {
    func pickerControllerDidCancel(_ pickerController: WLPhotoPickerController) { }
    func pickerController(_ pickerController: WLPhotoPickerController, didSelectResult results: [AssetPickerResult]) { }
}

public class WLPhotoPickerController: UINavigationController {
    
    public weak var pickerDelegate: WLPhotoPickerControllerDelegate?
    
    let config: WLPhotoConfig
    
    public init(config: WLPhotoConfig = .default) {
        self.config = config.checkCongfig()
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        navigationBar.barTintColor = WLPhotoUIConfig.default.color.navigationBarColor
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
        
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.shadowImage = UIImage.imageWithColor(.clear)
            appearance.backgroundImage = navigationBar.standardAppearance.backgroundImage
            appearance.titleTextAttributes = navigationBar.standardAppearance.titleTextAttributes
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.compactAppearance = appearance
        } else {
            navigationBar.shadowImage = UIImage.imageWithColor(.clear)
        }
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .statusBarStyle(style: WLPhotoUIConfig.default.color.userInterfaceStyle)
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
    
    func pickerController(_ pickerController: AssetPickerController, didSelectResult results: [AssetPickerResult]) {
        pickerDelegate?.pickerController(self, didSelectResult: results)
        
        if config.pickerConfig.dismissPickerAfterDone {
            let previewController = presentedViewController as? AssetPreviewViewController
            previewController?.transitioningDelegate = nil
            previewController?.modalPresentationStyle = .fullScreen
            presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
}
