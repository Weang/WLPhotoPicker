//
//  PhotoEditConfig.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/11.
//

import UIKit

public class PhotoEditConfig {

    public init() { }
    
    // 照片编辑菜单类型
    public var photoEditItemTypes: [PhotoEditItemType] = PhotoEditItemType.all
    
    // 照片编辑涂鸦颜色
    public var photoEditGraffitiColors: [UIColor] = [#colorLiteral(red: 0.9752930999, green: 0.3147607744, blue: 0.3190720677, alpha: 1), #colorLiteral(red: 0.9450979829, green: 0.9450982213, blue: 0.9494037032, alpha: 1), #colorLiteral(red: 0.1638098657, green: 0.1687904298, blue: 0.168703407, alpha: 1), #colorLiteral(red: 0.9968875051, green: 0.7632474303, blue: 0, alpha: 1), #colorLiteral(red: 0.02922653779, green: 0.7524088621, blue: 0.375612855, alpha: 1), #colorLiteral(red: 0.05218506604, green: 0.6807786822, blue: 0.9946766496, alpha: 1), #colorLiteral(red: 0.3903390169, green: 0.4003461599, blue: 0.9338593483, alpha: 1)]
    
    // 照片编辑涂鸦线条宽度
    public var photoEditGraffitiLineWidth: CGFloat = 5
    
    // 照片贴图
    public var photoEditPasters: [PhotoEditPasterProvider] = []
    
    // 照片编辑文字颜色
    public var photoEditTextColors: [PhotoEditTextColor] = PhotoEditTextColor.default
    
    // 照片编辑文字背景颜色透明度
    public var photoEditTextBackgroundAlpha: CGFloat = 1
    
    // 照片马赛克路径宽度
    public var photoEditMosaicLineWidth: CGFloat = 20
    
    // 照片马赛克像素大小
    public var photoEditMosaicWidth: CGFloat = 30
    
    // 照片裁剪比例
    // TODO: public var photoEditCropRatios: PhotoEditCropRatio = .freedom
    
    // 照片裁剪是否裁剪圆形，如果为true，那么photoEditCropRatios不会生效，只会默认圆形
    // TODO: public var photoEditCropCircle: Bool = false
    
    // 滤镜选项
    public var photoEditFilters: [PhotoEditFilterProvider] = PhotoEditDefaultFilter.all
    
    // 照片调整功能选项
    public var photoEditAdjustModes: [PhotoEditAdjustMode] = [.brightness, .contrast, .saturability]
    
}
