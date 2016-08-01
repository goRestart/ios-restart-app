//
//  BannerCell.swift
//  LetGo
//
//  Created by Isaac Roldan on 7/7/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation


class BannerCell: UICollectionViewCell, ReusableCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var colorView: UIView!
    
    var videoURL: NSURL?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var playing: Bool = false
    
    override func awakeFromNib() {
        contentView.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        contentView.clipsToBounds = true
        if DeviceFamily.isWideScreen {
            title.font = UIFont.systemBoldFont(size: 17)
        } else {
            title.font = UIFont.systemBoldFont(size: 19)
        }
        
//        imageView.hidden = true
        title.hidden = true
        colorView.hidden = true
        
    }
    
    func configure() {
        stopVideo()
    }
    
    func playVideo() {
        guard !playing else { return }
        print("✳️ PLAYING!!!")
        playing = true
        let playerItem = AVPlayerItem(URL: videoURL!)
        player = AVPlayer(playerItem: playerItem)
        player?.volume = 0.0
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = bounds
        playerLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill;
        layer.addSublayer(playerLayer!)

        player?.play()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerDidReachEnd(_:)),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification, object:nil)
    }
    
    func playerDidReachEnd(notification: NSNotification) {
        guard playing else { return }
        player?.seekToTime(kCMTimeZero)
        player?.play()
    }

    func stopVideo() {
//        print("⛔️ Stopping!")
        playing = false
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        player?.seekToTime(kCMTimeZero)
    }
}
