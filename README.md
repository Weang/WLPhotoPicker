# WLPhotoPicker

iOS图片、视频选择工具。支持图片视频多选。支持导出实况照片、未压缩的视频。支持视频压缩，视频转实况。

[![Version](https://img.shields.io/cocoapods/v/WLPhotoPicker.svg?style=flat)](https://cocoapods.org/pods/WLPhotoPicker)
[![License](https://img.shields.io/cocoapods/l/WLPhotoPicker.svg?style=flat)](https://cocoapods.org/pods/WLPhotoPicker)
[![Platform](https://img.shields.io/cocoapods/p/WLPhotoPicker.svg?style=flat)](https://cocoapods.org/pods/WLPhotoPicker)
![Language](https://img.shields.io/badge/Language-%20Swift%20-E57141.svg)

## 截图
![image](https://github.com/Weang/Resources/blob/main/WLPhotoPicker/demo.png)

## 已实现功能
- [x] 支持选择照片，动图，视频，实况照片。
- [x] 支持选择原图和原视频.
- [x] 自定义主体颜色和提示文字.
- [x] 适配暗黑模式.
- [x] 图片，视频和实况预览.
- [x] 图片编辑(涂鸦，贴图，马赛克，裁剪，滤镜).
- [x] 视频压缩，视频水印，视频替换音轨.
- [x] 自定义相机.
- [x] 视频和实况照片互转.
- [x] 多语言(简体中文，繁体中文，英文).
- [x] 相册实时更新.

## TODO
- [ ] 自定义相机添加滤镜.
- [ ] 视频编辑.

## 系统要求
 * iOS 11.0
 * Swift 5.x
 * Xcode 12.x

## 使用方法
```ruby
pod 'WLPhotoPicker'
```

## 如何使用

```swift
class ViewController: UIViewController {
    
    @objc func openPicker() {

        // 选择照片
        let config = WLPhotoConfig()
        let vc = WLPhotoPickerController(config: config)
        vc.pickerDelegate = self
        self.present(vc, animated: true, completion: nil)

        // 视频压缩，水印
        let videoUrl = URL(string: "/demo.video")
        let outputPath = ""
        let manager = VideoCompressManager(avAsset: AVAsset(url: videoUrl), outputPath: outputPath)
        manager.frameDuration = 24
        manager.compressSize = ._960x540
        manager.addWaterMark(image: UIImage.init(named: "bilibili")) { size in
            return CGRect(x: 100, y: 100, width: 100, height: 40)
        }
        manager.exportVideo { videoUrl in
            print(videoUrl)
        }

        // 自定义相机
        let vc = CaptureViewController(captureConfig: CaptureConfig())
        vc.delegate = self
        present(vc, animated: true)

        // 视频转实况
        LivePhotoGenerator.createLivePhotoFrom(videoURL) { progress in
            print(progress)
        } completion: { result in
            print(result.livePhoto)
        }
    }
}
```
