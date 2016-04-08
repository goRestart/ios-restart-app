//
//  CommercialDisplayPageView.swift
//  LetGo
//
//  Created by Dídac on 24/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

protocol CommercialDisplayPageViewDelegate: class {
    func pageViewWillShowFullScreen()
    func pageViewWillHideFullScreen()
}

public class CommercialDisplayPageView: UIView {

    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!

    weak var delegate: CommercialDisplayPageViewDelegate?

    var videoPlayer : VideoPlayerContainerView = VideoPlayerContainerView.instanceFromNib()
    private var fullScreen = false

    
    // MARK: - Lifecycle

    public static func instanceFromNib() -> CommercialDisplayPageView {
        let view = NSBundle.mainBundle().loadNibNamed("CommercialDisplayPageView", owner: self, options: nil).first as! CommercialDisplayPageView
        return view
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        videoPlayer.frame = bounds
    }

    public func setupVideoPlayerWithUrl(url: NSURL) {
        videoPlayer.frame = bounds
        videoPlayer.setupUI()
        addSubview(videoPlayer)

        videoPlayer.delegate = self
        videoPlayer.controlsAreVisible = true
        videoPlayer.controlsVisibleWhenPaused = true

        videoPlayer.updateVideoPlayerWithURL(url)
        videoPlayer.pausePlayer()
    }

    public func setupThumbnailWithUrl(thumbUrl: NSURL) {
        thumbnailImageView.sd_setImageWithURL(thumbUrl, placeholderImage: nil)
    }

    public func pauseVideo() {
        videoPlayer.pausePlayer()
    }

    public func playVideo() {
        videoPlayer.startPlayer()
    }
}

extension CommercialDisplayPageView: VideoPlayerContainerViewDelegate {

    public func playerDidSwitchPlaying(isPlaying: Bool) {
        videoPlayer.controlsAreVisible = true
    }

    public func playerDidReceiveTap() {}

    public func playerDidPressFullscreen() {

        let transform: CGAffineTransform
        if fullScreen {
            fullScreen = false
            delegate?.pageViewWillHideFullScreen()
            transform = CGAffineTransformIdentity
        } else {
            fullScreen = true
            delegate?.pageViewWillShowFullScreen()
            transform = CGAffineTransform.toFullScreenTransform(frame)
        }

        UIView.animateWithDuration(0.2) { [weak self] in
            self?.transform = transform
        }
    }
}