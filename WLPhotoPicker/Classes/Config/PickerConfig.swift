//
//  PickerConfig.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/10.
//

import UIKit

// Config for picker.
public class PickerConfig {
    
    public init() { }
    public static let `default` = PickerConfig()
   
    // MARK: Picker UI
    
    // 一行的列数
    public var columnsOfPhotos: Int = 4
    
    // 行间距
    public var pickerRowSpace: CGFloat = 2
    
    // 列间距
    public var pickerColumnSpace: CGFloat = 2
    
    // 列间距
    public var pickerSectionInset: UIEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    
    // MARK: Fetch config
    
    // 可选择资源类型
    public var selectableType: PhotoPickerSelectionType = .all
    
    // 排序方式
    public var sortType: AssetSortType = .asc
    
    // MARK: Picker config
    
    // 选择个数限制
    public var selectCountLimit: Int = 9
    
    // 图片是否可编辑
    // 如果为true，拍摄照片后会直接跳转到编辑页面
    public var allowEditPhoto: Bool = true
    
    // 在Limited权限时，是否显示添加更多照片
    public var canAddMoreAssetWhenLimited: Bool = true
    
    // 从LimitedLibraryPicker选择图片之后，是否自动选中选择的照片
    public var autoSelectAssetFromLimitedLibraryPicker: Bool = true
    
    // 可选择的最长视频时长, 0不做限制
    public var pickerMaximumVideoDuration: TimeInterval = 120
    
    // 是否可选择原图
    public var allowSelectOriginal: Bool = true
    
    // 预览尺寸、非原图尺寸
    public var maximumPreviewSize: CGFloat = 900
    
    // jpg压缩质量
    public var jpgCompressionQuality: Double = 0.8
    
    // 选取照片时是否同时存储到本地
    // 如果为true，选择照片代理中AssetPickerResult的filePath会返回存储的路径
    public var saveImageToLocalWhenPick: Bool = false
    
    // 选取视频时是否导出到本地
    public var exportVideoToLocalWhenPick: Bool = false
    
    // 导出视频尺寸
    // 如果videoExportCanExpoetOriginal为true，那么这个参数将被忽略
    public var videoExportCompressSize: VideoCompressSize = ._960x540
    
    // 导出视频帧率
    // 如果videoExportCanExpoetOriginal为true，那么这个参数将被忽略
    public var videoExportFrameDuration: Float = 30
    
    // 视频导出格式
    public var videoExportFileType: VideoExportFileType = .mp4
    
    // 如果为false，不管是否勾选原图，导出的视频都是压缩后的视频
    // 如果为true，勾选原图后导出的视频是无压缩的视视频
    public var videoExportOriginal: Bool = false
    
    // 点击确定是否自动关闭
    public var autoDismissAfterDone: Bool = true
    
    // 点击选择照片后是否保存编辑后的照片
    public var saveEditedPhotoToAlbum: Bool = true
    
}

extension PickerConfig {
    
    // Cell显示大小
    var photoCollectionViewItemSize: CGSize {
        let screenWidth = UIScreen.main.bounds.size.width
        let columnsOfPhotos = CGFloat(columnsOfPhotos)
        let pickerSectionAround = pickerSectionInset.left + pickerSectionInset.right
        var itemWidth = (screenWidth - (columnsOfPhotos - 1) * pickerColumnSpace - pickerSectionAround) / columnsOfPhotos
        itemWidth = floor(itemWidth)
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
}
