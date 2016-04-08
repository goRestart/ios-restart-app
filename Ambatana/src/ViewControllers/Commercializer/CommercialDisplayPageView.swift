//
//  CommercialDisplayPageView.swift
//  LetGo
//
//  Created by Dídac on 24/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

public class CommercialDisplayPageView: UIView {


    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!

    var videoPlayer : VideoPlayerContainerView = VideoPlayerContainerView.instanceFromNib()

    
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
        videoPlayer.frame = playerView.bounds
    }

    public func setupVideoPlayerWithUrl(url: NSURL) {
        videoPlayer.frame = playerView.bounds
        videoPlayer.setupUI()
        playerView.addSubview(videoPlayer)

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

    public func playerDidReceiveTap() {
        
    }
}