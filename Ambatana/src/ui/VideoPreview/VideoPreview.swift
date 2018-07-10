//
//  VideoPreview.swift
//  LetGo
//
//  Created by Álvaro Murillo del Puerto on 20/4/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit
import AVFoundation
import RxSwift

final class VideoPreview: UIView {

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    var url: URL? {
        didSet {
            if let playerItem = player.currentItem {
                NotificationCenter.default.removeObserver(self,
                                                          name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                                          object: playerItem)
            }
            var playerItem: AVPlayerItem?
            if let url = url { playerItem = AVPlayerItem(url: url) }
            player.replaceCurrentItem(with: playerItem)
        }
    }

    lazy private var player: AVPlayer = {
        let player = AVPlayer(playerItem: nil)
        player.actionAtItemEnd = .none
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        return player
    }()

    private var playerLayer: AVPlayerLayer {
        guard let layer = layer as? AVPlayerLayer else {
            fatalError("Expected `AVPlayerLayer` type for layer. Check VideoPreview.layerClass implementation.")
        }
        return layer
    }

    var duration: TimeInterval {
        guard let duration = player.currentItem?.duration else { return 0}
        return CMTimeGetSeconds(duration)
    }

    var currentTime: TimeInterval {
        guard let currentTime = player.currentItem?.currentTime() else { return 0}
        return CMTimeGetSeconds(currentTime)
    }

    var progress: Float {
        return Float(currentTime / duration)
    }

    var rx_progress = Variable<Float>(0.0)

    private var periodicTimeObserver: Any?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func play() {
        player.play()
        let time = CMTimeMake(1, 20)
        periodicTimeObserver = player.addPeriodicTimeObserver(forInterval: time,
                                                              queue: DispatchQueue.main) { [weak self] (time) in
            guard let strongSelf = self else { return }
            strongSelf.rx_progress.value = strongSelf.progress
        }

        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)
    }

    func pause() {
        player.pause()
        if let periodicTimeObserver = periodicTimeObserver {
            player.removeTimeObserver(periodicTimeObserver)
        }
    }

    @objc func playerItemDidReachEnd(notification: Notification) {
        if let playerItem: AVPlayerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: kCMTimeZero, completionHandler: nil)
        }
    }
}
