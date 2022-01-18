//
//  AssetFetchTool+ExportVideo.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/5.
//

import UIKit
import AVFoundation

public typealias VideoExportCompletion = (Result<VideoExportResponse, AssetFetchError>) -> Void

extension AssetFetchTool {
    
//    public static func videoSessionExport(for videoAsset: AVAsset, videoOutputPath: String, options: AssetFetchOptions, completion: @escaping VideoExportCompletion) {
//        guard let videoAsset = videoAsset as? AVURLAsset else {
//            completion(.failure(.fetchFailed))
//            return
//        }
//        guard let videoOutputPath = options.videoOutputPath else {
//            completion(.failure(.invalidVideoUrl))
//            return
//        }
//        VideoExportTool.exportVideo(avAsset: videoAsset, outputPath: videoOutputPath, config: pickerConfig, isOriginal: isOrigin) { progress in
//            options.progressHandler?(progress)
//        } completion: { result in
//            
//        }
//    }
    
}
