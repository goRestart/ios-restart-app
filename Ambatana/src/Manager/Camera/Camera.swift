//
//  Camera.swift
//  LetGo
//
//  Created by Álvaro Murillo del Puerto on 6/3/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import AVFoundation
import Result

typealias CameraPhotoResult = Result<UIImage, NSError>
typealias CameraRecordingVideoResult = Result<URL, NSError>

typealias CameraPhotoCompletion = (CameraPhotoResult) -> Void
typealias CameraRecordingVideoCompletion = (CameraRecordingVideoResult) -> Void

enum CameraFlashState {
    case auto, on, off
}

enum CameraSource {
    case front, rear
}

protocol Camera {

    var flashMode: CameraFlashState { get set }
    var cameraSource: CameraSource { get set }
    var isReady: Bool { get }
    var hasFlash: Bool { get }
    var hasFrontCamera: Bool { get }
    var isAttached: Bool { get }
    var shouldForwardPixelBuffersToDelegate: Bool { get set }
    var pixelsBuffersToForwardPerSecond: CMTime { get set }
    weak var videoOutputDelegate: CameraVideoCaptureDelegate? { get set }

    func addPreviewLayerTo(view: UIView) -> Bool
    func capturePhoto(completion: @escaping CameraPhotoCompletion)
    func startRecordingVideo()
    func stopRecordingVideo(completion: @escaping CameraRecordingVideoCompletion)
    func pause()
    func resume()
}

protocol CameraVideoCaptureDelegate: class {

    func didCaptureVideoFrame(pixelBuffer: CVPixelBuffer?, timestamp: CMTime)
}

