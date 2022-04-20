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
    func pickerController(_ pickerController: WLPhotoPickerController, didSelectResult results: [PhotoPickerResult])
}

public extension WLPhotoPickerControllerDelegate {
    func pickerControllerDidCancel(_ pickerController: WLPhotoPickerController) { }
    func pickerController(_ pickerController: WLPhotoPickerController, didSelectResult results: [PhotoPickerResult]) { }
}

public class WLPhotoPickerController: UINavigationController {
    
    public weak var pickerDelegate: WLPhotoPickerControllerDelegate?
    
    // 传入已选中的localIdentifier，默认选中已选择的资源
    public var selectedIdentifiers: [String]? {
        didSet {
            if let viewController = viewControllers.first as? AssetPickerController {
                viewController.selectedIdentifiers = selectedIdentifiers
            }
        }
    }
    
    private let config: WLPhotoConfig
    
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
        
        if #unavailable(iOS 15.0) {
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
    
    func pickerController(_ pickerController: AssetPickerController, didSelectResult results: [PhotoPickerResult]) {
        pickerDelegate?.pickerController(self, didSelectResult: results)
        
        if config.pickerConfig.dismissPickerAfterDone {
            let previewController = presentedViewController as? AssetPreviewViewController
            previewController?.transitioningDelegate = nil
            previewController?.modalPresentationStyle = .fullScreen
            presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
}
