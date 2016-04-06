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


public protocol VideoPlayerContainerViewDelegate: class {
    func playerDidSwitchPlaying(isPlaying: Bool)
    func playerDidReceiveTap()
}

public class VideoPlayerContainerView: UIView {

    @IBOutlet weak var playerFailedView: UIView!
    @IBOutlet weak var playerFailedLabel: UILabel!
    @IBOutlet weak var playerFailedButton: UIButton!

    
    weak var delegate: VideoPlayerContainerViewDelegate?

    private var videoPlayerVC: AVPlayerViewController
    private var player: AVPlayer
    private var audioButton: UIButton
    private var playButton: UIButton
    private var progressSlider: UISlider

    private var currentItemURL: NSURL? = nil

    private var playerObserverActive:Bool = false
    private var videoTimer: NSTimer?
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
    var controlsAreVisible: Bool = false {
        didSet {
            if let timer = autoHideControlsTimer where !controlsAreVisible {
                timer.invalidate()
            }

            guard isPlaying || !controlsVisibleWhenPaused else { return }
            startAutoHidingControlsTimer()
            UIView.animateWithDuration(0.2) { [weak self] in
                if let strongSelf = self {
                    strongSelf.playButton.alpha = strongSelf.controlsAreVisible ? 1.0 : 0.0
                    strongSelf.audioButton.alpha = strongSelf.controlsAreVisible ? 1.0 : 0.0
                    strongSelf.progressSlider.alpha = strongSelf.controlsAreVisible ? 1.0 : 0.0
                }
            }
        }
    }
    private var audioButtonIsVisible: Bool {
        return controlsAreVisible || isFirstPlay
    }
    var videoIsMuted: Bool = true {
        didSet {
            player.muted = videoIsMuted
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
    private var autoHideControlsTimer: NSTimer?
    private var autoHideControlsEnabled: Bool = true

    
    // MARK: - Lifecycle

    public static func instanceFromNib() -> VideoPlayerContainerView {
        let view = NSBundle.mainBundle().loadNibNamed("VideoPlayerContainerView", owner: self, options: nil).first as! VideoPlayerContainerView
        return view
    }

    public override init(frame: CGRect) {
        self.videoPlayerVC = AVPlayerViewController()
        self.player = AVPlayer()
        self.audioButton = UIButton(type: .Custom)
        self.playButton = UIButton(type: .Custom)
        self.progressSlider = UISlider()
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        self.videoPlayerVC = AVPlayerViewController()
        self.player = AVPlayer()
        self.audioButton = UIButton(type: .Custom)
        self.playButton = UIButton(type: .Custom)
        self.progressSlider = UISlider()
        super.init(coder: aDecoder)
    }
    
    deinit {
        removePlayerStatusObserver()
    }


    // MARK: - Public methods

    @IBAction func onPlayerFailedButtonPressed(sender: AnyObject) {
        reloadSelectedTheme()
    }

    private func reloadSelectedTheme() {
        guard let currentURL = currentItemURL else { return }
        updateVideoPlayerWithURL(currentURL)
    }

    public func pausePlayer() {
        if isPlaying { switchPlaying() }
        invalidateTimer()
    }

    public func startPlayer() {
        if !isPlaying { switchPlaying() }
        controlsAreVisible = true
        startSliderUpdateTimer()
    }


    func didBecomeActive() {
        controlsAreVisible = !isFirstPlay
    }

    func didBecomeInactive() {
        if let timer = autoHideControlsTimer {
            timer.invalidate()
        }
    }


    public func setupUI() {
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

    public func onAudioButtonPressed() {
        switchAudio()
    }

    public func onPlayButtonPressed() {
        startSliderUpdateTimer()
        switchPlaying()
    }

    public func progressValueChanged() {
        guard let item = player.currentItem else { return }
        let duration = CMTimeGetSeconds(item.duration)
        let newTime = CMTimeMakeWithSeconds(Double(progressSlider.value)*duration, item.currentTime().timescale)
        player.seekToTime(newTime)
    }

    func disableUpdateVideoProgress() {
        disableAutoHideControls()
    }

    func enableUpdateVideoProgress() {
        enableAutoHideControls()
    }

    func updateSliderFromVideo() {
        guard let item = player.currentItem where updateSliderFromVideoEnabled else { return }
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
        videoTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self,
            selector: #selector(VideoPlayerContainerView.updateSliderFromVideo), userInfo: nil, repeats: true)
    }

    private func refreshUI() {
        audioButton.setImage(imageForAudioButton, forState: .Normal)
        playButton.setImage(imageForPlayButton, forState: .Normal)
        audioButton.alpha = audioButtonIsVisible ? 1.0 : 0.0
        playButton.alpha = controlsAreVisible ? 1.0 : 0.0
        progressSlider.alpha = controlsAreVisible ? 1.0 : 0.0
    }

    public func updateVideoPlayerWithURL(videoUrl: NSURL) {
        currentItemURL = videoUrl
        let playerItem = AVPlayerItem(URL: videoUrl)
        removePlayerStatusObserver()
        player = AVPlayer(playerItem: playerItem)

        startSliderUpdateTimer()

        player.muted = videoIsMuted
        videoPlayerVC.player = player

        player.addObserver(self, forKeyPath: "status", options: .New, context: nil)
        playerObserverActive = true
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: #selector(VideoPlayerContainerView.playerDidFinishPlaying(_:)),
            name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)

        videoPlayerVC.player?.play()
    }


    // MARK: - private & internal methods

    private func setupVideoPlayerViewController() {

        videoPlayerVC.showsPlaybackControls = false
        videoPlayerVC.view.userInteractionEnabled = true
        videoPlayerVC.view.frame = CGRect(x: 0, y: 0, width: self.frame.size.width,
            height: self.frame.size.height)
        self.addSubview(videoPlayerVC.view)

        setupVideoPlayerTouchFriendlyView()
        setupVideoPlayerAudioButton()
        setupVideoPlayerPlayPauseButton()
        setupVideoPlayerProgressSlider()

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

        let touchFriendlyViewTop = NSLayoutConstraint(item: touchFriendlyView, attribute: .Top, relatedBy: .Equal,
            toItem: videoPlayerVC.view, attribute: .Top, multiplier: 1, constant: 0)
        videoPlayerVC.view.addConstraint(touchFriendlyViewTop)
        let touchFriendlyViewBottom = NSLayoutConstraint(item: touchFriendlyView, attribute: .Bottom, relatedBy: .Equal,
            toItem: videoPlayerVC.view, attribute: .Bottom, multiplier: 1, constant: 0)
        videoPlayerVC.view.addConstraint(touchFriendlyViewBottom)
        let touchFriendlyViewLeft = NSLayoutConstraint(item: touchFriendlyView, attribute: .Left, relatedBy: .Equal,
            toItem: videoPlayerVC.view, attribute: .Left, multiplier: 1, constant: 0)
        videoPlayerVC.view.addConstraint(touchFriendlyViewLeft)
        let touchFriendlyViewRight = NSLayoutConstraint(item: touchFriendlyView, attribute: .Right, relatedBy: .Equal,
            toItem: videoPlayerVC.view, attribute: .Right, multiplier: 1, constant: 0)
        videoPlayerVC.view.addConstraint(touchFriendlyViewRight)
    }

    private func setupVideoPlayerAudioButton() {
        audioButton.addTarget(self, action: #selector(VideoPlayerContainerView.onAudioButtonPressed),
                              forControlEvents: .TouchUpInside)
        audioButton.translatesAutoresizingMaskIntoConstraints = false
        videoPlayerVC.view.addSubview(audioButton)

        let audioButtonWidth = NSLayoutConstraint(item: audioButton, attribute: .Width, relatedBy: .Equal, toItem: nil,
            attribute: .NotAnAttribute, multiplier: 1, constant: 30)
        audioButton.addConstraint(audioButtonWidth)
        let audioButtonHeight = NSLayoutConstraint(item: audioButton, attribute: .Height, relatedBy: .Equal, toItem: nil,
            attribute: .NotAnAttribute, multiplier: 1, constant: 30)
        audioButton.addConstraint(audioButtonHeight)

        let audioButtonTop = NSLayoutConstraint(item: audioButton, attribute: .Top, relatedBy: .Equal,
            toItem: videoPlayerVC.view, attribute: .Top, multiplier: 1, constant: 10)
        videoPlayerVC.view.addConstraint(audioButtonTop)
        let audioButtonRight = NSLayoutConstraint(item: audioButton, attribute: .Right, relatedBy: .Equal,
            toItem: videoPlayerVC.view, attribute: .Right, multiplier: 1, constant: -10)
        videoPlayerVC.view.addConstraint(audioButtonRight)
    }

    private func setupVideoPlayerPlayPauseButton() {
        playButton.addTarget(self, action: #selector(VideoPlayerContainerView.onPlayButtonPressed),
                             forControlEvents: .TouchUpInside)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        videoPlayerVC.view.addSubview(playButton)

        let playButtonWidth = NSLayoutConstraint(item: playButton, attribute: .Width, relatedBy: .Equal, toItem: nil,
            attribute: .NotAnAttribute, multiplier: 1, constant: 40)
        playButton.addConstraint(playButtonWidth)
        let playButtonHeight = NSLayoutConstraint(item: playButton, attribute: .Height, relatedBy: .Equal, toItem: nil,
            attribute: .NotAnAttribute, multiplier: 1, constant: 40)
        playButton.addConstraint(playButtonHeight)
        let playButtonXCenter = NSLayoutConstraint(item: playButton, attribute: .CenterX, relatedBy: .Equal,
            toItem: videoPlayerVC.view, attribute: .CenterX, multiplier: 1, constant: 0)
        videoPlayerVC.view.addConstraint(playButtonXCenter)
        let playButtonYCenter = NSLayoutConstraint(item: playButton, attribute: .CenterY, relatedBy: .Equal,
            toItem: videoPlayerVC.view, attribute: .CenterY, multiplier: 1, constant: 0)
        videoPlayerVC.view.addConstraint(playButtonYCenter)
    }

    private func setupVideoPlayerProgressSlider() {

        progressSlider.transform = CGAffineTransformMakeScale(0.8, 0.8);
        progressSlider.tintColor = StyleHelper.primaryColor
        progressSlider.addTarget(self, action: #selector(VideoPlayerContainerView.progressValueChanged),
                                 forControlEvents: .ValueChanged)
        progressSlider.addTarget(self, action: #selector(VideoPlayerContainerView.disableUpdateVideoProgress),
                                 forControlEvents: .TouchDown)
        progressSlider.addTarget(self, action: #selector(VideoPlayerContainerView.enableUpdateVideoProgress),
                                 forControlEvents: .TouchUpInside)
        progressSlider.translatesAutoresizingMaskIntoConstraints = false
        videoPlayerVC.view.addSubview(progressSlider)

        let sliderBottom = NSLayoutConstraint(item: progressSlider, attribute: .Bottom, relatedBy: .Equal,
            toItem: videoPlayerVC.view, attribute: .Bottom, multiplier: 1, constant: -10)
        videoPlayerVC.view.addConstraint(sliderBottom)
        let sliderLeft = NSLayoutConstraint(item: progressSlider, attribute: .Left, relatedBy: .Equal,
            toItem: videoPlayerVC.view, attribute: .Left, multiplier: 1, constant: 20)
        videoPlayerVC.view.addConstraint(sliderLeft)
        let sliderRight = NSLayoutConstraint(item: progressSlider, attribute: .Right, relatedBy: .Equal,
            toItem: videoPlayerVC.view, attribute: .Right, multiplier: 1, constant: -20)
        videoPlayerVC.view.addConstraint(sliderRight)
    }

    dynamic private func playerDidFinishPlaying(notification: NSNotification) {
        isPlaying = false
        player.seekToTime(kCMTimeZero)
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
        controlsAreVisible = !controlsAreVisible
    }

    dynamic func autoHideControls() {
        guard autoHideControlsEnabled else { return }
        switchControlsVisible()
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
        autoHideControlsTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self,
                        selector: #selector(VideoPlayerContainerView.autoHideControls), userInfo: nil, repeats: false)
        if let autoHideControlsTimer = autoHideControlsTimer where !controlsAreVisible || !autoHideControlsEnabled {
            autoHideControlsTimer.invalidate()
        }
    }


    // MARK: - Player observer for keypath

    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?,
        change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
            guard let keyPath = keyPath where keyPath == "status" && player == object as? AVPlayer else { return }
            if player.status == .Failed {
                playerFailedView.hidden = false
                videoPlayerVC.view.hidden = true
            } else if player.status == .ReadyToPlay {
                playerFailedView.hidden = true
                videoPlayerVC.view.hidden = false
            }
            removePlayerStatusObserver()
    }
}
