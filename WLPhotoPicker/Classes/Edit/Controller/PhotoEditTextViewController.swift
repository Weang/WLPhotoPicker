//
//  PhotoEditTextViewController.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/7.
//

import UIKit

protocol PhotoEditTextViewControllerDelegate: AnyObject {
    func textController(_ textController: PhotoEditTextViewController, didCancelImput maskLayer: PhotoEditTextMaskLayer?)
    func textController(_ textController: PhotoEditTextViewController, didFinishInput maskLayer: PhotoEditTextMaskLayer)
}

class PhotoEditTextViewController: UIViewController {
    
    weak var delegate: PhotoEditTextViewControllerDelegate?
    
    private let backgroundImageView = UIImageView()
    private let foregroundView = UIView()
    private let cancelButton = UIButton()
    private let doneButton = UIButton()
    private let inputTextView = UITextView()
    private let colorsView: PhotoEditTextColorsView
    private let textShapeLayer = CAShapeLayer()
    
    private var isTextWrap: Bool = false
    private var textColorIndex: Int = 0
    private var textLineRects: [CGRect] = []
    private let textWrapPadding: CGFloat = 16
    
    private let backgroundImage: UIImage?
    private var textMaskLayer: PhotoEditTextMaskLayer?
    private let photoEditConfig: PhotoEditConfig
    
    public override var prefersStatusBarHidden: Bool {
        true
    }
    
    init(backgroundImage: UIImage?, textMaskLayer: PhotoEditTextMaskLayer?, photoEditConfig: PhotoEditConfig) {
        self.backgroundImage = backgroundImage
        self.textMaskLayer = textMaskLayer
        self.photoEditConfig = photoEditConfig
        self.colorsView = PhotoEditTextColorsView(photoEditConfig: photoEditConfig)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalPresentationCapturesStatusBarAppearance = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        addNotifications()
        setupTextColor()
        setupCurrentText()
        inputTextView.becomeFirstResponder()
    }
    
    private  func setupView() {
        view.backgroundColor = .black
        
        backgroundImageView.image = backgroundImage?.blurImage(blur: 8)
        view.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        foregroundView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.addSubview(foregroundView)
        foregroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        cancelButton.addTarget(self, action: #selector(cancelButtonClick), for: .touchUpInside)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.setTitle("取消", for: .normal)
        view.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.centerY.equalTo(keyWindowSafeAreaInsets.top + 30)
            make.left.equalTo(24)
        }
        
        doneButton.addTarget(self, action: #selector(doneButtonClick), for: .touchUpInside)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.setTitle("确定", for: .normal)
        view.addSubview(doneButton)
        doneButton.snp.makeConstraints { make in
            make.centerY.equalTo(cancelButton.snp.centerY)
            make.right.equalTo(-24)
        }
        
        colorsView.delegate = self
        view.addSubview(colorsView)
        colorsView.snp.makeConstraints { make in
            make.left.equalTo(24)
            make.right.equalTo(-24)
            make.height.equalTo(42)
            make.bottom.equalTo(0)
        }
        
        inputTextView.returnKeyType = .done
        inputTextView.enablesReturnKeyAutomatically = true
        inputTextView.showsVerticalScrollIndicator = false
        inputTextView.textContainer.lineBreakMode = .byCharWrapping
        inputTextView.textContainerInset = UIEdgeInsets(top: textWrapPadding,
                                                        left: textWrapPadding,
                                                        bottom: textWrapPadding,
                                                        right: textWrapPadding)
        inputTextView.textContainer.lineFragmentPadding = 0
        inputTextView.tintColor = WLPhotoUIConfig.default.color.primaryColor
        inputTextView.backgroundColor = .clear
        inputTextView.delegate = self
        inputTextView.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        inputTextView.layer.masksToBounds = true
        
        view.addSubview(inputTextView)
        inputTextView.snp.makeConstraints { make in
            make.top.equalTo(cancelButton.snp.bottom).offset(16)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.bottom.equalTo(colorsView.snp.top).offset(-16)
        }
        
        inputTextView.layer.insertSublayer(textShapeLayer, at: 0)
        
        view.layoutSubviews()
    }
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(kayboardChanged(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kayboardChanged(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupTextColor() {
        let textColor = photoEditConfig.photoEditTextColors[textColorIndex]
        inputTextView.textColor = isTextWrap ? textColor.textColor : textColor.tintColor
        textShapeLayer.fillColor = textColor.tintColor.cgColor
        textShapeLayer.removeAllAnimations()
    }
    
    private func setupCurrentText() {
        guard let textMaskLayer = self.textMaskLayer else {
            return
        }
        inputTextView.text = textMaskLayer.text
        isTextWrap = textMaskLayer.isWrap
        textColorIndex = textMaskLayer.colorIndex
        colorsView.wrapButton.isSelected = isTextWrap
        colorsView.collectionView.selectItem(at: IndexPath(item: textColorIndex, section: 0), animated: false, scrollPosition: .left)
        setupTextColor()
        updateAttributeText()
    }
    
    @objc private func cancelButtonClick() {
        delegate?.textController(self, didCancelImput: textMaskLayer)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func doneButtonClick() {
        if textLineRects.count == 0 {
            delegate?.textController(self, didCancelImput: textMaskLayer)
            dismiss(animated: true, completion: nil)
            return
        }
        guard let image = drawTextImage() else {
            return
        }
        var textMask: PhotoEditTextMaskLayer
        if let editedtextMask = self.textMaskLayer {
            textMask = editedtextMask
            textMask.text = inputTextView.text
            textMask.isWrap = isTextWrap
            textMask.colorIndex = textColorIndex
            textMask.maskImage = image
        } else {
            textMask = PhotoEditTextMaskLayer(text: inputTextView.text,
                                              isWrap: isTextWrap,
                                              colorIndex: textColorIndex,
                                              maskImage: image)
        }
        delegate?.textController(self, didFinishInput: textMask)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func kayboardChanged(_ notification: Notification) {
        guard let keyboardRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        colorsView.snp.updateConstraints { make in
            make.bottom.equalTo(keyboardRect.origin.y - UIScreen.height - 16)
        }
        view.layoutSubviews()
    }
    
    private func updateAttributeText() {
        let attributedText = NSMutableAttributedString(attributedString: inputTextView.attributedText)
        let paragraphStye = NSMutableParagraphStyle()
        paragraphStye.alignment = .left
        paragraphStye.lineBreakMode = .byCharWrapping
        let range = NSMakeRange(0, attributedText.length)
        attributedText.addAttribute(.paragraphStyle, value: paragraphStye, range: range)
        inputTextView.attributedText = attributedText
        textLineRects = CoreTextHelper.getLineRectsFrom(attributedText, containerWidth: inputTextView.width - textWrapPadding * 2)
        drawLineLayers()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: Draw
extension PhotoEditTextViewController {
    
    private func drawLineLayers() {
        textShapeLayer.path = drawTextWrapPath()?.cgPath
    }
    
    private func drawTextImage() -> UIImage? {
        let textWidth = textLineRects.map{ $0.width }.max() ?? 0
        let textHeight = textLineRects.map{ $0.height }.reduce(0, +)
        let width = textWidth + textWrapPadding * 2
        let height = textHeight + textWrapPadding * 2
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        let path = drawTextWrapPath()
        let attributeText = NSMutableAttributedString(attributedString: inputTextView.attributedText)
        if path == nil {
            let shadow = NSShadow()
            shadow.shadowBlurRadius = 10
            shadow.shadowColor = UIColor(white: 0, alpha: 0.4)
            attributeText.addAttribute(.shadow, value: shadow, range: NSRange(location: 0, length: attributeText.length))
        }
        attributeText.draw(in: CGRect(x: textWrapPadding,
                                      y: textWrapPadding,
                                      width: textWidth,
                                      height: textHeight))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    @discardableResult
    private func drawTextWrapPath() -> UIBezierPath? {
        guard isTextWrap, textLineRects.count > 0 else {
            return nil
        }
        let width = textLineRects.map{ $0.width }.max() ?? 0
        let height = textLineRects.map{ $0.height }.reduce(0, +)
        
        let path = UIBezierPath()
        
        // top-left
        path.move(to: CGPoint(x: textWrapPadding, y: 0))
        path.addArc(withCenter: CGPoint(x: textWrapPadding, y: textWrapPadding), radius: textWrapPadding, startAngle: CGFloat.pi * 1.5, endAngle: CGFloat.pi, clockwise: false)
        
        // left-bottom
        path.addLine(to: CGPoint(x: 0, y: height + textWrapPadding))
        path.addArc(withCenter: CGPoint(x: textWrapPadding, y: height + textWrapPadding), radius: textWrapPadding, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 0.5, clockwise: false)
        
        // 最后一行比较短
        if textLineRects.count > 1, textLineRects[textLineRects.count - 2].width - textLineRects[textLineRects.count - 1].width > textWrapPadding * 2 {
            let lastWidth = textLineRects[textLineRects.count - 1].width
            let lastHeight = textLineRects[textLineRects.count - 1].height
            
            path.addLine(to: CGPoint(x: lastWidth + textWrapPadding, y: height + textWrapPadding * 2))
            path.addArc(withCenter: CGPoint(x: lastWidth + textWrapPadding, y: height + textWrapPadding), radius: textWrapPadding, startAngle: CGFloat.pi * 0.5, endAngle: 0, clockwise: false)
            
            path.addLine(to: CGPoint(x: lastWidth + textWrapPadding * 2, y: height - lastHeight + textWrapPadding * 3))
            path.addArc(withCenter: CGPoint(x: lastWidth + textWrapPadding * 3, y: height - lastHeight + textWrapPadding * 3), radius: textWrapPadding, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 1.5, clockwise: true)
            
            path.addLine(to: CGPoint(x: width + textWrapPadding, y: height - lastHeight + textWrapPadding * 2))
            path.addArc(withCenter: CGPoint(x: width + textWrapPadding, y: height - lastHeight + textWrapPadding), radius: textWrapPadding, startAngle: CGFloat.pi * 0.5, endAngle: 0, clockwise: false)
        } else {
            // bottom-right
            path.addLine(to: CGPoint(x: width + textWrapPadding, y: height + textWrapPadding * 2))
            path.addArc(withCenter: CGPoint(x: width + textWrapPadding, y: height + textWrapPadding), radius: textWrapPadding, startAngle: CGFloat.pi * 0.5, endAngle: 0, clockwise: false)
        }
        
        // right-top
        path.addLine(to: CGPoint(x: width + textWrapPadding * 2, y: textWrapPadding))
        path.addArc(withCenter: CGPoint(x: width + textWrapPadding, y: textWrapPadding), radius: textWrapPadding, startAngle: 0, endAngle: CGFloat.pi * 1.5, clockwise: false)
        photoEditConfig.photoEditTextColors[textColorIndex].tintColor
            .withAlphaComponent(photoEditConfig.photoEditTextBackgroundAlpha).setFill()
        path.fill()
        return path
    }
    
}

// MARK: UITextViewDelegate
extension PhotoEditTextViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        updateAttributeText()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            doneButtonClick()
            return false
        }
        return true
    }
}

// MARK: TextColorsViewDelegate
extension PhotoEditTextViewController: PhotoEditTextColorsViewDelegate {
    
    func textColorsView(_ textColorsView: PhotoEditTextColorsView, didClickWrapButton isWrap: Bool) {
        isTextWrap = isWrap
        setupTextColor()
        drawLineLayers()
    }
    
    func textColorsView(_ textColorsView: PhotoEditTextColorsView, didSelectColorIndex index: Int) {
        textColorIndex = index
        setupTextColor()
        drawLineLayers()
    }
    
}
