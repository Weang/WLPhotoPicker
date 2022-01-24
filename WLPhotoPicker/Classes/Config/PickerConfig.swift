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
    
    // 选择个数限制
    public var selectCountLimit: Int = 9
    
    // 可选择的最长视频时长, 0不做限制
    public var pickerMaximumVideoDuration: TimeInterval = 120
    
    // 是否可选择多个照片
    // 如果为false, 任何时候都不会选中照片，并且cell和预览页面不会显示选中按钮，selectCountLimit会失效
    public var allowSelectMultiPhoto: Bool = true
    
    // 是否可选择原图
    // 如果为false, 勾选原图按钮会隐藏
    public var allowSelectOriginal: Bool = true
    
    // 是否显示picker底部完成按钮
    public var showPickerDoneButton: Bool = true
    
    // 点击之后是否预览
    // 如果为false，点击cell之后会调用选中方法
    public var allowPreview: Bool = true
    
    // 在Limited权限时，是否显示添加更多照片
    public var canAddMoreAssetWhenLimited: Bool = true
    
    // 从LimitedLibraryPicker选择图片之后，是否自动选中选择的照片
    public var autoSelectAssetFromLimitedLibraryPicker: Bool = true
    
    // 图片是否可编辑
    // 如果为true，拍摄照片后会直接跳转到编辑页面
    public var allowEditPhoto: Bool = true
    
    // 视频是否可编辑
    // 如果为true，拍摄视频后会直接跳转到编辑页面
    // TODO: 视频编辑
    // public var allowEditVideo: Bool = true
    
    // 预览尺寸、非原图尺寸
    public var maximumPreviewSize: CGFloat = 900
    
    // jpg压缩质量
    public var jpgCompressionQuality: Double = 0.8
    
    // 选取照片时是否同时存储到本地
    // 如果为true，选择照片代理中AssetPickerResult的filePath会返回存储的路径
    public var saveImageToLocalWhenPick: Bool = false
    
    // 选取视频时是否导出到本地
    // 如果为true，选择照片代理中AssetPickerResult的filePath会返回存储的路径
    // 导出视频会使用视频压缩参数
    public var saveVideoToLocalWhenPick: Bool = false
    
    // 如果为false，不管是否勾选原图，导出的视频都是压缩后的视频
    // 如果为true，勾选原图后导出的视频是无压缩的视视频
    public var videoCanSaveOriginal: Bool = false
    
    // 导出视频尺寸
    // 如果videoCanSaveOriginal为true并且勾选原图，那么这个参数将被忽略
    public var videoExportCompressSize: AssetVideoCompressSize = ._960x540
    
    // 导出视频帧率
    // 如果videoCanSaveOriginal为true并且勾选原图，那么这个参数将被忽略
    public var videoExportFrameDuration: Float = 30
    
    // 视频导出格式
    public var videoExportFileType: AssetVideoExportFileType = .mp4
    
    // 点击确定是否自动关闭
    public var dismissPickerAfterDone: Bool = true
    
    // 点击选择照片后是否保存编辑后的照片
    public var saveEditedPhotoToAlbum: Bool = true
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
    
}
