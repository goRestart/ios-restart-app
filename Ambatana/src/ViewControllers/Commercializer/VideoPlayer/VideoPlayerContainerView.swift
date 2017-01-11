//
//  VideoPlayerContainerView.swift
//  LetGo
//
//  Created by Dídac on 22/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit


protocol VideoPlayerContainerViewDelegate: class {
    func playerDidSwitchPlaying(_ isPlaying: Bool)
    func playerDidFinishPlaying()
    func playerDidReceiveTap()
    func playerDidPressFullscreen()
}

class VideoPlayerContainerView: UIView {

    @IBOutlet weak var playerFailedView: UIView!
    @IBOutlet weak var playerFailedLabel: UILabel!
    @IBOutlet weak var playerFailedButton: UIButton!

    
    weak var delegate: VideoPlayerContainerViewDelegate?

    private var videoPlayerVC: AVPlayerViewController
    private var player: AVPlayer
    private var audioButton: UIButton
    private var playButton: UIButton
    private var fullScreenButton: UIButton
    private var progressSlider: UISlider

    private var timeWhenInactive: Double = 0.0

    private var currentItemURL: URL? = nil

    private var playerObserverActive:Bool = false
    private var videoTimer: Timer?
    private var updateSliderFromVideoEnabled: Bool {
        return autoHideControlsEnabled
    }

    private var isFirstPlay: Bool = true

    private var isPlaying: Bool = true {
        didSet {
            delegate?.playerDidSwitchPlaying(isPlaying)
        }
    }
    var controlsVisibleWhenPaused: Bool = false
    var controlsAreVisible: Bool = false
    private var audioButtonIsVisible: Bool {
        return controlsAreVisible || isFirstPlay
    }
    var videoIsMuted: Bool = true {
        didSet {
            player.isMuted = videoIsMuted
            refreshUI()
        }
    }

    private var imageForAudioButton: UIImage {
        let imgName = videoIsMuted ? "ic_sound_off" : "ic_sound_on"
        return UIImage(named: imgName) ?? UIImage()
    }
    private var imageForPlayButton: UIImage {
        let imgName = isPlaying ? "ic_pause_video" : "ic_play_video"
        return UIImage(named: imgName) ?? UIImage()
    }
    private var autoHideControlsTimer: Timer?
    private var autoHideControlsEnabled: Bool = true

    
    // MARK: - Lifecycle

    static func instanceFromNib() -> VideoPlayerContainerView {
        guard let container = Bundle.main.loadNibNamed("VideoPlayerContainerView", owner: self, options: nil)?.first
            as? VideoPlayerContainerView else { return VideoPlayerContainerView() }
        return container
    }

    override init(frame: CGRect) {
        self.videoPlayerVC = AVPlayerViewController()
        self.player = AVPlayer()
        self.audioButton = UIButton(type: .custom)
        self.playButton = UIButton(type: .custom)
        self.progressSlider = UISlider()
        self.fullScreenButton = UIButton(type: .custom)
        super.init(frame: frame)

        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(VideoPlayerContainerView.playerDidFinishPlaying(_:)),
                                                         name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        self.videoPlayerVC = AVPlayerViewController()
        self.player = AVPlayer()
        self.audioButton = UIButton(type: .custom)
        self.playButton = UIButton(type: .custom)
        self.progressSlider = UISlider()
        self.fullScreenButton = UIButton(type: .custom)
        super.init(coder: aDecoder)

        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(VideoPlayerContainerView.playerDidFinishPlaying(_:)),
                                                         name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    deinit {
        removePlayerStatusObserver()
        NotificationCenter.default.removeObserver(self)
    }


    // MARK: - Public methods

    @IBAction func onPlayerFailedButtonPressed(_ sender: AnyObject) {
        reloadSelectedTheme()
    }

    private func reloadSelectedTheme() {
        guard let currentURL = currentItemURL else { return }
        updateVideoPlayerWithURL(currentURL)
    }

    func pausePlayer() {
        if isPlaying { switchPlaying() }
        invalidateTimer()
    }

    func startPlayer() {
        if !isPlaying { switchPlaying() }
        setControlsVisible(true)
        startSliderUpdateTimer()
    }


    func didBecomeActive() {
        guard timeWhenInactive > 0.0  else { return }
        guard let item = player.currentItem else { return }
        let duration = CMTimeGetSeconds(item.duration)
        progressSlider.value = Float(timeWhenInactive/duration)

        let newTime = CMTimeMakeWithSeconds(Double(progressSlider.value)*duration, item.currentTime().timescale)
        player.seek(to: newTime)
    }

    func didBecomeInactive() {
        guard let item = player.currentItem else { return }
        timeWhenInactive = item.currentTime().seconds
    }


    func setupUI() {
        playerFailedLabel.text = LGLocalizedString.commercializerLoadVideoFailedErrorMessage
        setupVideoPlayerViewController()
        refreshUI()
    }

    func videoPlayerTapped() {
        delegate?.playerDidReceiveTap()
        switchControlsVisible()

        if isFirstPlay {
            isFirstPlay = false
            videoIsMuted = false
        }
    }

    func onAudioButtonPressed() {
        switchAudio()
    }

    func onPlayButtonPressed() {
        startSliderUpdateTimer()
        switchPlaying()
    }

    func onFullScreenButtonPressed() {
        delegate?.playerDidPressFullscreen()
    }

    func progressValueChanged() {
        guard let item = player.currentItem else { return }
        let duration = CMTimeGetSeconds(item.duration)
        let newTime = CMTimeMakeWithSeconds(Double(progressSlider.value)*duration, item.currentTime().timescale)
        player.seek(to: newTime)
    }

    func disableUpdateVideoProgress() {
        disableAutoHideControls()
    }

    func enableUpdateVideoProgress() {
        enableAutoHideControls()
    }

    func updateSliderFromVideo() {
        guard let item = player.currentItem, updateSliderFromVideoEnabled else { return }
        let currentTime = CMTimeGetSeconds(item.currentTime())
        let duration = CMTimeGetSeconds(item.duration)
        progressSlider.value = Float(currentTime/duration)
    }
    
    private func invalidateTimer() {
        if let videoTimer = videoTimer {
            videoTimer.invalidate()
        }
    }

    private func startSliderUpdateTimer() {
        if let videoTimer = videoTimer {
            videoTimer.invalidate()
        }
        videoTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self,
            selector: #selector(VideoPlayerContainerView.updateSliderFromVideo), userInfo: nil, repeats: true)
    }

    private func refreshUI() {
        audioButton.setImage(imageForAudioButton, for: UIControlState())
        playButton.setImage(imageForPlayButton, for: UIControlState())
        audioButton.alpha = audioButtonIsVisible ? 1.0 : 0.0
        fullScreenButton.alpha = audioButtonIsVisible ? 1.0 : 0.0
        playButton.alpha = controlsAreVisible ? 1.0 : 0.0
        progressSlider.alpha = controlsAreVisible ? 1.0 : 0.0
    }

    func updateVideoPlayerWithURL(_ videoUrl: URL) {
        currentItemURL = videoUrl
        let playerItem = AVPlayerItem(url: videoUrl)
        removePlayerStatusObserver()
        player = AVPlayer(playerItem: playerItem)

        startSliderUpdateTimer()

        player.isMuted = videoIsMuted
        videoPlayerVC.player = player

        player.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        playerObserverActive = true

        isPlaying = true
        videoPlayerVC.player?.play()
        refreshUI()
    }


    // MARK: - private & internal methods

    private func setupVideoPlayerViewController() {

        videoPlayerVC.showsPlaybackControls = false
        videoPlayerVC.view.isUserInteractionEnabled = true
        videoPlayerVC.view.frame = CGRect(x: 0, y: 0, width: self.frame.size.width,
            height: self.frame.size.height)
        self.addSubview(videoPlayerVC.view)

        setupVideoPlayerTouchFriendlyView()
        setupVideoPlayerAudioButton()
        setupVideoPlayerPlayPauseButton()
        setupVideoPlayerProgressSlider()
        setupVideoPlayerFullscreenButton()

        videoPlayerVC.view.layoutIfNeeded()
    }

    private func setupVideoPlayerTouchFriendlyView() {
        let touchFriendlyView = UIView()
        touchFriendlyView.translatesAutoresizingMaskIntoConstraints = false

        let videoPlayerTapRecognizer = UITapGestureRecognizer(target: self,
                action: #selector(VideoPlayerContainerView.videoPlayerTapped))
        videoPlayerTapRecognizer.numberOfTapsRequired = 1
        touchFriendlyView.addGestureRecognizer(videoPlayerTapRecognizer)

        videoPlayerVC.view.addSubview(touchFriendlyView)

        let touchFriendlyViewTop = NSLayoutConstraint(item: touchFriendlyView, attribute: .top, relatedBy: .equal,
            toItem: videoPlayerVC.view, attribute: .top, multiplier: 1, constant: 0)
        videoPlayerVC.view.addConstraint(touchFriendlyViewTop)
        let touchFriendlyViewBottom = NSLayoutConstraint(item: touchFriendlyView, attribute: .bottom, relatedBy: .equal,
            toItem: videoPlayerVC.view, attribute: .bottom, multiplier: 1, constant: 0)
        videoPlayerVC.view.addConstraint(touchFriendlyViewBottom)
        let touchFriendlyViewLeft = NSLayoutConstraint(item: touchFriendlyView, attribute: .left, relatedBy: .equal,
            toItem: videoPlayerVC.view, attribute: .left, multiplier: 1, constant: 0)
        videoPlayerVC.view.addConstraint(touchFriendlyViewLeft)
        let touchFriendlyViewRight = NSLayoutConstraint(item: touchFriendlyView, attribute: .right, relatedBy: .equal,
            toItem: videoPlayerVC.view, attribute: .right, multiplier: 1, constant: 0)
        videoPlayerVC.view.addConstraint(touchFriendlyViewRight)
    }

    private func setupVideoPlayerAudioButton() {
        audioButton.addTarget(self, action: #selector(VideoPlayerContainerView.onAudioButtonPressed),
                              for: .touchUpInside)
        audioButton.translatesAutoresizingMaskIntoConstraints = false
        videoPlayerVC.view.addSubview(audioButton)

        let audioButtonWidth = NSLayoutConstraint(item: audioButton, attribute: .width, relatedBy: .equal, toItem: nil,
            attribute: .notAnAttribute, multiplier: 1, constant: 30)
        audioButton.addConstraint(audioButtonWidth)
        let audioButtonHeight = NSLayoutConstraint(item: audioButton, attribute: .height, relatedBy: .equal, toItem: nil,
            attribute: .notAnAttribute, multiplier: 1, constant: 30)
        audioButton.addConstraint(audioButtonHeight)

        let audioButtonTop = NSLayoutConstraint(item: audioButton, attribute: .top, relatedBy: .equal,
            toItem: videoPlayerVC.view, attribute: .top, multiplier: 1, constant: 10)
        videoPlayerVC.view.addConstraint(audioButtonTop)
        let audioButtonRight = NSLayoutConstraint(item: audioButton, attribute: .right, relatedBy: .equal,
            toItem: videoPlayerVC.view, attribute: .right, multiplier: 1, constant: -10)
        videoPlayerVC.view.addConstraint(audioButtonRight)
    }

    private func setupVideoPlayerPlayPauseButton() {
        playButton.addTarget(self, action: #selector(VideoPlayerContainerView.onPlayButtonPressed),
                             for: .touchUpInside)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        videoPlayerVC.view.addSubview(playButton)

        let playButtonWidth = NSLayoutConstraint(item: playButton, attribute: .width, relatedBy: .equal, toItem: nil,
            attribute: .notAnAttribute, multiplier: 1, constant: 40)
        playButton.addConstraint(playButtonWidth)
        let playButtonHeight = NSLayoutConstraint(item: playButton, attribute: .height, relatedBy: .equal, toItem: nil,
            attribute: .notAnAttribute, multiplier: 1, constant: 40)
        playButton.addConstraint(playButtonHeight)
        let playButtonXCenter = NSLayoutConstraint(item: playButton, attribute: .centerX, relatedBy: .equal,
            toItem: videoPlayerVC.view, attribute: .centerX, multiplier: 1, constant: 0)
        videoPlayerVC.view.addConstraint(playButtonXCenter)
        let playButtonYCenter = NSLayoutConstraint(item: playButton, attribute: .centerY, relatedBy: .equal,
            toItem: videoPlayerVC.view, attribute: .centerY, multiplier: 1, constant: 0)
        videoPlayerVC.view.addConstraint(playButtonYCenter)
    }

    private func setupVideoPlayerProgressSlider() {
        progressSlider.transform = CGAffineTransform(scaleX: 0.8, y: 0.8);
        progressSlider.tintColor = UIColor.primaryColor
        progressSlider.addTarget(self, action: #selector(VideoPlayerContainerView.progressValueChanged),
                                 for: .valueChanged)
        progressSlider.addTarget(self, action: #selector(VideoPlayerContainerView.disableUpdateVideoProgress),
                                 for: .touchDown)
        progressSlider.addTarget(self, action: #selector(VideoPlayerContainerView.enableUpdateVideoProgress),
                                 for: .touchUpInside)
        progressSlider.translatesAutoresizingMaskIntoConstraints = false
        videoPlayerVC.view.addSubview(progressSlider)

        let sliderBottom = NSLayoutConstraint(item: progressSlider, attribute: .bottom, relatedBy: .equal,
            toItem: videoPlayerVC.view, attribute: .bottom, multiplier: 1, constant: -10)
        videoPlayerVC.view.addConstraint(sliderBottom)
        let sliderLeft = NSLayoutConstraint(item: progressSlider, attribute: .left, relatedBy: .equal,
            toItem: videoPlayerVC.view, attribute: .left, multiplier: 1, constant: 20)
        videoPlayerVC.view.addConstraint(sliderLeft)
        let sliderRight = NSLayoutConstraint(item: progressSlider, attribute: .right, relatedBy: .equal,
            toItem: videoPlayerVC.view, attribute: .right, multiplier: 1, constant: -20)
        videoPlayerVC.view.addConstraint(sliderRight)
    }

    private func setupVideoPlayerFullscreenButton() {
        fullScreenButton.addTarget(self, action: #selector(VideoPlayerContainerView.onFullScreenButtonPressed),
                             for: .touchUpInside)
        fullScreenButton.setImage(UIImage(named: "ic_video_fullscreen"), for: UIControlState())
        fullScreenButton.translatesAutoresizingMaskIntoConstraints = false
        videoPlayerVC.view.addSubview(fullScreenButton)

        fullScreenButton.addConstraint(NSLayoutConstraint(item: fullScreenButton, attribute: .width, relatedBy: .equal, toItem: nil,
                                                 attribute: .notAnAttribute, multiplier: 1, constant: 25))
        fullScreenButton.addConstraint(NSLayoutConstraint(item: fullScreenButton, attribute: .height, relatedBy: .equal, toItem: nil,
                                                  attribute: .notAnAttribute, multiplier: 1, constant: 22))

        videoPlayerVC.view.addConstraint(NSLayoutConstraint(item: fullScreenButton, attribute: .right, relatedBy: .equal,
                                                   toItem: videoPlayerVC.view, attribute: .right, multiplier: 1, constant: -12))
        videoPlayerVC.view.addConstraint(NSLayoutConstraint(item: fullScreenButton, attribute: .bottom, relatedBy: .equal,
                                                   toItem: videoPlayerVC.view, attribute: .bottom, multiplier: 1, constant: -12))
    }

    dynamic private func playerDidFinishPlaying(_ notification: Notification) {
        isPlaying = false
        player.seek(to: kCMTimeZero)
        setControlsVisible(true, force: true)
        refreshUI()
        delegate?.playerDidFinishPlaying()
    }

    private func removePlayerStatusObserver() {
        guard playerObserverActive else { return }
        player.removeObserver(self, forKeyPath: "status")
        playerObserverActive = false
    }

    private func switchPlaying() {
        isPlaying ? player.pause() : player.play()
        isPlaying = !isPlaying
        refreshUI()
    }

    func switchControlsVisible() {
        setControlsVisible(!controlsAreVisible)
    }

    dynamic func autoHideControls() {
        guard autoHideControlsEnabled else { return }
        setControlsVisible(false)
    }

    func disableAutoHideControls() {
        autoHideControlsEnabled = false
    }

    func enableAutoHideControls() {
        autoHideControlsEnabled = true
        startAutoHidingControlsTimer()
    }
    
    func switchAudio() {
        videoIsMuted = !videoIsMuted
    }

    private func startAutoHidingControlsTimer() {
        autoHideControlsTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self,
                        selector: #selector(VideoPlayerContainerView.autoHideControls), userInfo: nil, repeats: false)
        if let autoHideControlsTimer = autoHideControlsTimer, !controlsAreVisible || !autoHideControlsEnabled {
            autoHideControlsTimer.invalidate()
        }
    }

    private func setControlsVisible(_ visible: Bool, force: Bool = false) {

        if let timer = autoHideControlsTimer, !controlsAreVisible {
            timer.invalidate()
        }

        guard force || isPlaying || !controlsVisibleWhenPaused else { return }
        controlsAreVisible = visible
        if visible {
            startAutoHidingControlsTimer()
        }
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            if let strongSelf = self {
                strongSelf.playButton.alpha = strongSelf.controlsAreVisible ? 1.0 : 0.0
                strongSelf.audioButton.alpha = strongSelf.controlsAreVisible ? 1.0 : 0.0
                strongSelf.fullScreenButton.alpha = strongSelf.controlsAreVisible ? 1.0 : 0.0
                strongSelf.progressSlider.alpha = strongSelf.controlsAreVisible ? 1.0 : 0.0
            }
        }) 
    }


    // MARK: - Player observer for keypath

    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
        change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            guard let keyPath = keyPath, keyPath == "status" && player == object as? AVPlayer else { return }
            if player.status == .failed {
                playerFailedView.isHidden = false
                videoPlayerVC.view.isHidden = true
            } else if player.status == .readyToPlay {
                playerFailedView.isHidden = true
                videoPlayerVC.view.isHidden = false
            }
            removePlayerStatusObserver()
    }
}
