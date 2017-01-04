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

class CommercialDisplayPageView: UIView {

    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!

    weak var delegate: CommercialDisplayPageViewDelegate?

    var videoPlayer : VideoPlayerContainerView = VideoPlayerContainerView.instanceFromNib()
    private var fullScreen = false

    
    // MARK: - Lifecycle

    open static func instanceFromNib() -> CommercialDisplayPageView {
        return Bundle.main.loadNibNamed("CommercialDisplayPageView", owner: self, options: nil)!.first as! CommercialDisplayPageView
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        videoPlayer.frame = bounds
    }

    open func setupVideoPlayerWithUrl(_ url: URL) {
        videoPlayer.frame = bounds
        videoPlayer.setupUI()
        addSubview(videoPlayer)

        videoPlayer.delegate = self
        videoPlayer.controlsAreVisible = true
        videoPlayer.controlsVisibleWhenPaused = true
        videoPlayer.videoIsMuted = false

        videoPlayer.updateVideoPlayerWithURL(url)
        videoPlayer.pausePlayer()
    }

    open func setupThumbnailWithUrl(_ thumbUrl: URL) {
        thumbnailImageView.lg_setImageWithURL(thumbUrl, placeholderImage: nil)
    }

    open func pauseVideo() {
        videoPlayer.pausePlayer()
    }

    open func playVideo() {
        videoPlayer.startPlayer()
    }

    func didBecomeActive() {
        videoPlayer.didBecomeActive()
    }

    func didBecomeInactive() {
        videoPlayer.didBecomeInactive()
    }
}

extension CommercialDisplayPageView: VideoPlayerContainerViewDelegate {

    public func playerDidSwitchPlaying(_ isPlaying: Bool) {
        videoPlayer.controlsAreVisible = true
    }

    public func playerDidReceiveTap() {}

    public func playerDidFinishPlaying() {
        if fullScreen { playerDidPressFullscreen() }
    }

    public func playerDidPressFullscreen() {

        let transform: CGAffineTransform
        if fullScreen {
            fullScreen = false
            delegate?.pageViewWillHideFullScreen()
            transform = CGAffineTransform.identity
        } else {
            fullScreen = true
            delegate?.pageViewWillShowFullScreen()
            transform = CGAffineTransform.commercializerVideoToFullScreenTransform(frame)
        }

        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.transform = transform
        }) 
    }
}
