# WLPhotoPicker

WLPhotoPicker is a image picker with multifunction.Support select photos, videos, gif and livePhoto.Also support photo edit and video compress with custom config.

[![Version](https://img.shields.io/cocoapods/v/WLPhotoPicker.svg?style=flat)](https://cocoapods.org/pods/WLPhotoPicker)
[![License](https://img.shields.io/cocoapods/l/WLPhotoPicker.svg?style=flat)](https://cocoapods.org/pods/WLPhotoPicker)
[![Platform](https://img.shields.io/cocoapods/p/WLPhotoPicker.svg?style=flat)](https://cocoapods.org/pods/WLPhotoPicker)
![Language](https://img.shields.io/badge/Language-%20Swift%20-E57141.svg)

## Features
- [x] Photo,Gif,LivePhoto,Video.
- [x] Support original photos and videos.
- [x] Custom UI.
- [x] Light mode, dark mode and auto mode support.
- [x] Preview selection.
- [x] Image editor(Drawing/Emoji/Input text/Mosaic/Fliter).
- [x] Video Compression(Custom video size and video frame).
- [x] Custom camera(Custom video size, video frame and stabilization mode).
- [ ] Photo cropping.
- [ ] Internationalization support.

## Requirements
 * iOS 11.0
 * Swift 5.x
 * Xcode 12.x

## Installation

WLPhotoPicker is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'WLPhotoPicker'
```

## Usage
```swift
class ViewController: UIViewController {
    
    @objc func openPicker() {
        let config = WLPhotoConfig()
        let vc = WLPhotoPickerController(config: config)
        vc.pickerDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
}

extension ViewController: WLPhotoPickerControllerDelegate {

    func pickerController(_ pickerController: WLPhotoPickerController, didSelectResult results: [AssetPickerResult]) {
        
    }
    
    func pickerControllerDidCancel(_ pickerController: WLPhotoPickerController) {
        
    }
    
    func pickerController(_ pickerController: WLPhotoPickerController, didOccurredError error: WLPhotoError) {
        
    }

}
```

## Screenshots
![image](https://github.com/Weang/Resources/blob/main/WLPhotoPicker/demo.png)
