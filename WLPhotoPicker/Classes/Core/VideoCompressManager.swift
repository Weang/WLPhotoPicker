//
//  VideoCompressManager.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/5.
//

import UIKit
import AVFoundation
import VideoToolbox

public class VideoCompressManager {
    
    // 视频压缩尺寸
    public var compressSize: AssetVideoCompressSize = ._960x540
    
    // 视频导出格式
    public var videoExportFileType: AssetVideoExportFileType = .mp4
    
    // 视频压缩帧率
    public var frameDuration: Float = 30 {
        didSet {
            updateComposition()
        }
    }
    
    // 是否压缩视频
    // 如果为false，所有视频压缩的相关参数将被忽略
    public var compressVideo: Bool = true {
        didSet {
            updateComposition()
        }
    }
    
    private var audioQueue = DispatchQueue(label: "com.WLPhotoPicker.DispatchQueue.VideoExportTool.Audio")
    private var videoQueue = DispatchQueue(label: "com.WLPhotoPicker.DispatchQueue.VideoExportTool.Video")
    
    private var assetVideoTrack: AVAssetTrack?
    private var assetAudioTrack: AVAssetTrack?
    private var renderSize: CGSize = .zero
    
    private let composition = AVMutableComposition()
    private let videoComposition = AVMutableVideoComposition()
    
    private let avAsset: AVAsset
    private let outputPath: String
    
    public init(avAsset: AVAsset, outputPath: String) {
        self.avAsset = avAsset
        self.outputPath = outputPath
        
        setupTracks()
        updateComposition()
    }
    
    private func setupTracks() {
        guard let assetVideoTrack = avAsset.tracks(withMediaType: .video).first,
              let assetAudioTrack = avAsset.tracks(withMediaType: .audio).first else {
                  return
              }
        self.assetVideoTrack = assetVideoTrack
        self.assetAudioTrack = assetAudioTrack
        
        let id = kCMPersistentTrackID_Invalid
        guard let videoCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: id),
              let audioCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: id) else {
                  return
              }
        
        let assetDuration = avAsset.duration
        let timeRange = CMTimeRange(start: .zero, duration: assetDuration)
        renderSize = assetVideoTrack.naturalSize.applying(assetVideoTrack.preferredTransform)
        renderSize = CGSize(width: abs(renderSize.width), height: abs(renderSize.height))
        let preferredTransform = fixedTransformFrom(transForm: assetVideoTrack.preferredTransform,
                                                    natureSize: assetVideoTrack.naturalSize)
        
        videoCompositionTrack.preferredTransform = avAsset.preferredTransform
        try? videoCompositionTrack.insertTimeRange(timeRange, of: assetVideoTrack, at: .zero)
        try? audioCompositionTrack.insertTimeRange(timeRange, of: assetAudioTrack, at: .zero)
        
        let videolayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)
        videolayerInstruction.setTransform(preferredTransform, at: .zero)
        
        let videoCompositionInstrution = AVMutableVideoCompositionInstruction()
        videoCompositionInstrution.timeRange = timeRange
        videoCompositionInstrution.layerInstructions = [videolayerInstruction]
        
        videoComposition.renderSize = renderSize
        videoComposition.instructions = [videoCompositionInstrution]
    }
    
    private func updateComposition() {
        guard let assetVideoTrack = self.assetVideoTrack else {
            return
        }
        let timescale: CMTimeScale
        if compressVideo {
            timescale = CMTimeScale(min(frameDuration, assetVideoTrack.nominalFrameRate))
        } else {
            timescale = CMTimeScale(assetVideoTrack.nominalFrameRate)
        }
        videoComposition.frameDuration = CMTime(value: 1, timescale: timescale)
    }
    
    public func exportVideo(progress: ((Double) -> Void)? = nil, completion: @escaping ((URL) -> Void)) {
        guard let assetReader = try? AVAssetReader(asset: composition),
              let assetWriter = try? AVAssetWriter(outputURL: URL(fileURLWithPath: outputPath), fileType: videoExportFileType.avFileType) else {
                  return
              }
        
        let readerVideoOutput = AVAssetReaderVideoCompositionOutput(videoTracks: composition.tracks(withMediaType: .video), videoSettings: nil)
        readerVideoOutput.videoComposition = videoComposition
        readerVideoOutput.alwaysCopiesSampleData = false
        if assetReader.canAdd(readerVideoOutput) {
            assetReader.add(readerVideoOutput)
        }
        
        let readerAudioOutput = AVAssetReaderAudioMixOutput(audioTracks: composition.tracks(withMediaType: .audio), audioSettings: nil)
        readerAudioOutput.alwaysCopiesSampleData = false
        if assetReader.canAdd(readerAudioOutput) {
            assetReader.add(readerAudioOutput)
        }
        
        let assetWriterVideoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoWriterConfig())
        assetWriterVideoInput.expectsMediaDataInRealTime = true
        if assetWriter.canAdd(assetWriterVideoInput) {
            assetWriter.add(assetWriterVideoInput)
        }
        
        let assetWriterAudioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioWriterConfig())
        assetWriterAudioInput.expectsMediaDataInRealTime = true
        if assetWriter.canAdd(assetWriterAudioInput) {
            assetWriter.add(assetWriterAudioInput)
        }
        
        assetReader.startReading()
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: .zero)
        
        let dispatchGroup = DispatchGroup()
        
        let totalSeconds = avAsset.duration.seconds
        
        dispatchGroup.enter()
        assetWriterVideoInput.requestMediaDataWhenReady(on: videoQueue) {
            while assetWriterVideoInput.isReadyForMoreMediaData {
                guard let sampleBuffer = readerVideoOutput.copyNextSampleBuffer() else {
                    assetWriterVideoInput.markAsFinished()
                    dispatchGroup.leave()
                    break
                }
                let timeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                progress?(timeStamp.seconds / totalSeconds)
                assetWriterVideoInput.append(sampleBuffer)
            }
        }
        
        dispatchGroup.enter()
        assetWriterAudioInput.requestMediaDataWhenReady(on: audioQueue) {
            while assetWriterAudioInput.isReadyForMoreMediaData {
                guard let sampleBuffer = readerAudioOutput.copyNextSampleBuffer() else {
                    assetWriterAudioInput.markAsFinished()
                    dispatchGroup.leave()
                    break
                }
                assetWriterAudioInput.append(sampleBuffer)
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            assetReader.cancelReading()
            assetWriter.finishWriting {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {
                        return
                    }
                    completion(URL(fileURLWithPath: self.outputPath))
                }
            }
        }
    }
    
    private func videoWriterConfig() -> [String: Any]? {
        let videoExportSize = computeVideoExportSize()
        
        let supportHEVC = VTIsHardwareDecodeSupported(kCMVideoCodecType_HEVC)
        var bitRate = Float(0.1 * videoExportSize.height * videoExportSize.width) * Float(videoComposition.frameDuration.timescale)
        if !compressVideo, let assetVideoTrack = self.assetVideoTrack {
            bitRate = assetVideoTrack.estimatedDataRate
        }
        let codec = supportHEVC ? AVVideoCodecType.hevc : .h264
        let profileLevel = supportHEVC ? kVTProfileLevel_HEVC_Main_AutoLevel as String : AVVideoProfileLevelH264MainAutoLevel
        
        return [
            AVVideoCodecKey: codec,
            AVVideoWidthKey: videoExportSize.width,
            AVVideoHeightKey: videoExportSize.height,
            AVVideoCompressionPropertiesKey: [
                AVVideoProfileLevelKey: profileLevel,
                AVVideoAverageBitRateKey: bitRate
            ]
        ]
    }
    
    private func audioWriterConfig() -> [String: Any]? {
        return [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVEncoderBitRatePerChannelKey: 64000,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2]
    }
    
    private func computeVideoExportSize() -> CGSize {
        if compressVideo {
            let videoShortSide = min(renderSize.width, renderSize.height)
            let videoLongSide = max(renderSize.width, renderSize.height)
            let videoRatio = videoShortSide / videoLongSide
            
            let exportSize = compressSize.size
            let exportShortSide = min(exportSize.width, exportSize.height)
            let exportLongSide = max(exportSize.width, exportSize.height)
            let exportRatio = exportShortSide / exportLongSide
            
            let shortSide: CGFloat
            let longSide: CGFloat
            if videoRatio > exportRatio {
                shortSide = min(videoShortSide, exportShortSide)
                longSide = shortSide / videoRatio
            } else {
                longSide = min(videoLongSide, exportLongSide)
                shortSide = longSide * videoRatio
            }
            if renderSize.width > renderSize.height {
                return CGSize(width: longSide, height: shortSide)
            } else {
                return CGSize(width: shortSide, height: longSide)
            }
        } else {
            return renderSize
        }
    }
    
    private func fixedTransformFrom(transForm: CGAffineTransform, natureSize: CGSize) -> CGAffineTransform {
        switch (transForm.a, transForm.b, transForm.c, transForm.d) {
        case (0, 1, -1, 0):
            return CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: natureSize.height, ty: 0)
        case (0, -1, 1, 0):
            return CGAffineTransform(a: 0, b: -1, c: 1, d: 0, tx: 0, ty: natureSize.width)
        case (0, 1, 1, 0):
            return CGAffineTransform(a: 0, b: -1, c: 1, d: 0, tx: -natureSize.height, ty: 2 * natureSize.width)
        case (-1, 0, 0, -1):
            return CGAffineTransform(a: -1, b: 0, c: 0, d: -1, tx: natureSize.width, ty: natureSize.height)
        default:
            return .identity
        }
    }
    
}
