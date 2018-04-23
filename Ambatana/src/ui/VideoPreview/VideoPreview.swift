//
//  VideoPreview.swift
//  LetGo
//
//  Created by Álvaro Murillo del Puerto on 20/4/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit
import AVFoundation

final class VideoPreview: UIView {

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    var url: URL? {
        didSet {
            let playerItem: AVPlayerItem? = url != nil ? AVPlayerItem(url: url!) : nil
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

    var playerLayer: AVPlayerLayer {
        guard let layer = layer as? AVPlayerLayer else {
            fatalError("Expected `AVPlayerLayer` type for layer. Check VideoPreview.layerClass implementation.")
        }
        return layer
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func play() {
        player.play()

        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }

    func pause() {
        player.pause()
    }

    @objc func playerItemDidReachEnd(notification: Notification) {
        if let playerItem: AVPlayerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: kCMTimeZero, completionHandler: nil)
        }
    }
}
