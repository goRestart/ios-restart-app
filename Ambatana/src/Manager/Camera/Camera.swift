//
//  Camera.swift
//  LetGo
//
//  Created by Álvaro Murillo del Puerto on 6/3/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import AVFoundation
import Result

public enum CameraError: Error {
    case internalError(message: String)
    case frameworkError(error: Error)
}

typealias CameraPhotoResult = Result<UIImage, CameraError>
typealias CameraPhotoCompletion = (CameraPhotoResult) -> Void

typealias CameraRecordingVideoResult = Result<RecordedVideo, CameraError>
typealias CameraRecordingVideoCompletion = (CameraRecordingVideoResult) -> Void

enum CameraFlashState {
    case auto, on, off
}

enum CameraSource {
    case front, rear
}

enum CameraMode {
    case photo
    case video
}

protocol Camera {

    var flashMode: CameraFlashState? { get set }
    var cameraPosition: CameraSource? { get set }
    var cameraMode: CameraMode { get set }
    var isReady: Bool { get }
    var hasFlash: Bool { get }
    var hasFrontCamera: Bool { get }
    var isAttached: Bool { get }
    var isRecording: Bool { get }
    var recordingDuration: TimeInterval { get }

    func pause()
    func resume()
    func addPreviewLayerTo(view: UIView)
    func capturePhoto(completion: @escaping CameraPhotoCompletion)
    func startRecordingVideo(maxRecordingDuration: TimeInterval, completion: @escaping CameraRecordingVideoCompletion)
    func stopRecordingVideo()
    func startForwardingPixelBuffers(to delegate: VideoOutputDelegate, pixelsBuffersToForwardPerSecond: Int)
    func stopForwardingPixelBuffers()
}

protocol VideoOutputDelegate: class {
    func didCaptureVideoFrame(pixelBuffer: CVPixelBuffer?, timestamp: CMTime)
}
