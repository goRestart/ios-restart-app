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
    fileprivate var fullScreen = false

    
    // MARK: - Lifecycle

    static func instanceFromNib() -> CommercialDisplayPageView {
        return Bundle.main.loadNibNamed("CommercialDisplayPageView", owner: self, options: nil)!.first as! CommercialDisplayPageView
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        videoPlayer.frame = bounds
    }

    func setupVideoPlayerWithUrl(_ url: URL) {
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

    func setupThumbnailWithUrl(_ thumbUrl: URL) {
        thumbnailImageView.lg_setImageWithURL(thumbUrl, placeholderImage: nil)
    }

    func pauseVideo() {
        videoPlayer.pausePlayer()
    }

    func playVideo() {
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

    func playerDidSwitchPlaying(_ isPlaying: Bool) {
        videoPlayer.controlsAreVisible = true
    }

    func playerDidReceiveTap() {}

    func playerDidFinishPlaying() {
        if fullScreen { playerDidPressFullscreen() }
    }

    func playerDidPressFullscreen() {

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
