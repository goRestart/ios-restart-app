//
//  PostListingFooter.swift
//  LetGo
//
//  Created by Albert Hernández López on 08/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

protocol PostListingFooter {
    var galleryButton: UIButton { get }
    var cameraButton: UIButton { get }
    var infoButton: UIButton { get }
    var photoButton: UIButton { get }
    var videoButton: UIButton { get }
    var newBadgeLabel: UILabel { get }
    var isHidden: Bool { get set }
    func update(scroll: CGFloat)
    func updateToPhotoMode()
    func updateToVideoMode()
    func startRecording()
    func stopRecording()
    func updateVideoRecordingDurationProgress(progress: CGFloat, remainingTime: TimeInterval)
}
