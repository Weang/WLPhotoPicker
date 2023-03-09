//
//  PickerConfig.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/10.
//

import UIKit
import MobileCoreServices

// Config for picker.
public class PickerConfig {
    
    public init() { }
   
    // 一行的列数
    public var columnsOfPhotos: Int = 4
    
    // 行间距
    public var pickerRowSpace: CGFloat = 2
    
    // 列间距
    public var pickerColumnSpace: CGFloat = 2
    
    // SectionInset
    public var pickerSectionInset: UIEdgeInsets = .zero
    
    // 排序方式
    public var sortType: PickerSortType = .asc
    
    // 可选择资源类型
    public var selectableType: PickerSelectionType = .all
    
    // 是否显示隐藏相册
    // iOS16.1之后，显示隐藏相册和最近删除相册功能被限制
    public var showHiddenAlbum: Bool = false
    
    // 是否显示最近删除的相册
    public var showRecentlyDeletedAlbum: Bool = false
    
    // 选择个数限制
    public var selectCountLimit: Int = 9
    
    // 可选择的最长视频时长，单位为秒, 0不做限制
    public var pickerMaximumVideoDuration: TimeInterval = 0
    
    // 是否可选择多个照片和视频
    // 如果为false, 任何时候都不会选中照片，并且cell和预览页面不会显示选中按钮，selectCountLimit会失效
    public var allowsMultipleSelection: Bool = true
    
    // 是否可以同时选择图片和视频
    public var allowsSelectBothPhotoAndVideo: Bool = true
    
    // 是否可选择原图
    // 如果为false, 勾选原图按钮会隐藏
    public var allowSelectOriginal: Bool = true
    
    // 如果为false，不管是否勾选原图，导出的视频都是压缩后的视频
    // 如果为true，勾选原图后导出的视频是无压缩的视视频
    public var allowVideoSelectOriginal: Bool = false
    
    // 是否显示picker底部完成按钮
    public var showPickerDoneButton: Bool = true
    
    // 点击之后是否预览
    // 如果为false，点击cell之后会调用选中方法
    public var allowPreview: Bool = true
    
    // 在Limited权限时，是否显示添加更多照片
    // 如果开启此配置，建议在info.plist中添加"Prevent limited photos access alert"来关闭提示弹框
    public var canAddMoreAssetWhenLimited: Bool = true
    
    // 从LimitedLibraryPicker选择图片之后，是否自动选中选择的照片
    public var autoSelectAssetFromLimitedLibraryPicker: Bool = true
    
    // Limietd权限时，底部是否显示提示框
    public var showLimitedTip: Bool = true
    
    // 图片是否可编辑
    // 如果为true，拍摄照片后会直接跳转到编辑页面
    public var allowEditPhoto: Bool = true
    
    // 视频是否可编辑
    // 如果为true，拍摄视频后会直接跳转到编辑页面
    // TODO: 视频编辑
    // public var allowEditVideo: Bool = true
    
    // 图片预览尺寸
    // 未选择“原图”时导出的图片短边尺寸
    public var maximumPreviewSize: CGFloat = 900
    
    // 导出图片保存到本地时的jpg压缩参数
    public var jpgCompressionQuality: Double = 0.8
    
    // 点击确定是否自动关闭
    // 如果置为false，需要在picker回调中手动dismiss
    public var dismissPickerAfterDone: Bool = true
    
    // 点击选择照片后是否保存编辑后的照片
    public var saveEditedPhotoToAlbum: Bool = true
    
    // 选取照片时是否同时存储到本地
    // 如果为true，选择照片代理中AssetPickerResult的filePath会返回存储的路径
    public var exportImageURLWhenPick: Bool = false
    
    // 选取视频时是否返回视频路径，如果为true，选择照片代理中AssetPickerResult的filePath会返回存储的路径
    // 如果不导出视频地址，视频压缩参数则会失效
    // 如果为true，选择的是原视频并且视频在本地相册中存在原视频的地址，则会返回原视频的地址，不会额外保存到沙盒中
    public var exportVideoURLWhenPick: Bool = false
    
    // 导出视频尺寸
    // 如果allowVideoSelectOriginal为true并且勾选原图，那么这个参数将被忽略
    public var videoExportCompressSize: PickerVideoCompressSize = ._960x540
    
    // 导出视频帧率
    // 如果allowVideoSelectOriginal为true并且勾选原图，那么这个参数将被忽略
    public var videoExportFrameDuration: Float = 30
    
    // 视频导出格式
    public var videoExportFileType: PickerVideoExportFileType = .mp4
    
    // 是否允许拍摄照片
    public var allowTakingPhoto: Bool = true
    
    // 是否允许拍摄视频
    public var allowTakingVideo: Bool = true
    
    // 是否使用系统UIImagePickerController拍摄
    // 如果使用系统相机进行拍摄，拍摄视频的参数将会失效
    public var useSystemImagePickerController: Bool = false
    
    // 是否注册图片更新的通知，如果注册，会实时更新相册的图片
    public var registerPhotoLibraryChangeObserver: Bool = true
    
}

extension PickerConfig {
    
    // Cell显示大小
    var photoCollectionViewItemSize: CGSize {
        let screenWidth = UIScreen.width
        let columnsOfPhotos = CGFloat(columnsOfPhotos)
        let pickerSectionAround = pickerSectionInset.left + pickerSectionInset.right
        var itemWidth = (screenWidth - (columnsOfPhotos - 1) * pickerColumnSpace - pickerSectionAround) / columnsOfPhotos
        itemWidth = floor(itemWidth)
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    var showsCameraItem: Bool {
        allowTakingPhoto || allowTakingVideo
    }
    
    var imagePickerControllerMediaTypes: [String] {
        var mediaTypes: [String] = []
        if allowTakingPhoto {
            mediaTypes.append(kUTTypeImage as String)
        }
        if allowTakingVideo {
            mediaTypes.append(kUTTypeMovie as String)
        }
        return mediaTypes
    }
}
