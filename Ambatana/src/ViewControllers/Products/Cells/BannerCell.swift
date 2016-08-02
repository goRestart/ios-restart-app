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
import FLAnimatedImage
import FastttCamera

class BannerCell: UICollectionViewCell, ReusableCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var colorView: UIView!
    
    var videoURL: NSURL?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var playing: Bool = false
    var animatedImageView: FLAnimatedImageView?
    
    var activateVideo = false
    var fastCamera: FastttCamera?
    
    override func awakeFromNib() {
        contentView.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        contentView.clipsToBounds = true
        if DeviceFamily.isWideScreen {
            title.font = UIFont.systemBoldFont(size: 17)
        } else {
            title.font = UIFont.systemBoldFont(size: 19)
        }
        
        imageView.hidden = true
        title.hidden = true
        colorView.hidden = true
        
        if !activateVideo {
            animatedImageView = FLAnimatedImageView()
            animatedImageView?.frame = bounds
            animatedImageView?.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
            animatedImageView?.contentMode = .ScaleToFill
//            addSubview(animatedImageView!)
        }
        configureCamera()
    }
    
    func configureCamera() {
        fastCamera = FastttCamera()
        guard let fastCamera = fastCamera else { return }
        
        fastCamera.scalesImage = false
        fastCamera.normalizesImageOrientations = true
        fastCamera.interfaceRotatesWithOrientation = false
//        fastCamera.delegate = self
        fastCamera.cameraFlashMode = .Off
        fastCamera.cameraDevice = .Front
        
        fastCamera.beginAppearanceTransition(true, animated: false)
        contentView.addSubview(fastCamera.view)
        fastCamera.endAppearanceTransition()
        fastCamera.view.frame = bounds
    }
    
    func playVideo() {
        guard activateVideo else { return }
        guard !playing else { return }
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
        playing = false
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        player?.seekToTime(kCMTimeZero)
    }
}
//
//FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://upload.wikimedia.org/wikipedia/commons/2/2c/Rotating_earth_%28large%29.gif"]]];
//FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
//imageView.animatedImage = image;
//imageView.frame = CGRectMake(0.0, 0.0, 100.0, 100.0);
//[self.view addSubview:imageView];