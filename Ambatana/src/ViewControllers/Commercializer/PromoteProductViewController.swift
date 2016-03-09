//
//  PromoteProductViewController.swift
//  LetGo
//
//  Created by Dídac on 01/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

protocol PromoteProductViewControllerDelegate: class {
    func promoteProductViewControllerDidFinishFromSource(promotionSource: PromotionSource)
}

public class PromoteProductViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var promoteTitleLabel: UILabel!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var chooseThemeLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var promoteButton: UIButton!
    @IBOutlet weak var fullScreenButton: UIButton!

    var viewModel: PromoteProductViewModel
    weak var delegate: PromoteProductViewControllerDelegate?

    var videoPlayerVC: AVPlayerViewController
    var player: AVPlayer
    var audioButton: UIButton
    var playButton: UIButton
    var progressSlider: UISlider

    var playerObserverActive:Bool = false
    var videoTimer: NSTimer?
    var updateSliderFromVideoEnabled: Bool {
        return viewModel.autoHideControlsEnabled
    }


    // MARK: Lifecycle

    public convenience init(viewModel: PromoteProductViewModel) {
        self.init(viewModel: viewModel, nibName: "PromoteProductViewController")
    }

    public required init(viewModel: PromoteProductViewModel, nibName nibNameOrNil: String?) {
        self.videoPlayerVC = AVPlayerViewController()
        self.player = AVPlayer()
        self.audioButton = UIButton(type: .Custom)
        self.playButton = UIButton(type: .Custom)
        self.progressSlider = UISlider()
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        viewModel.delegate = self
        modalPresentationStyle = .OverCurrentContext
        modalTransitionStyle = .CrossDissolve
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        setupUI()
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        guard !view.hidden else { return }
        // load video only if is not 1st time opening commercializer
        if viewModel.commercializerShownBefore {
            loadFirstOrSelectedVideo()
        } else {
            presentCommercializerIntro()
        }
    }

    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let statusBarStyle = viewModel.statusVarStyleAtDisappear
        UIApplication.sharedApplication().setStatusBarStyle(statusBarStyle, animated: true)
    }

    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if let videoTimer = videoTimer {
            videoTimer.invalidate()
        }
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // Adjust gradient layer
        if let layers = gradientView.layer.sublayers {
            layers.forEach { $0.frame = gradientView.bounds }
        }
    }


    // MARK: public methods

    @IBAction func onCloseButton(sender: AnyObject) {
        removePlayerStatusObserver()
        dismissViewControllerAnimated(true) { [weak self] _ in
            guard let source = self?.viewModel.promotionSource else { return }
            self?.delegate?.promoteProductViewControllerDidFinishFromSource(source)
        }
    }

    @IBAction func onFullScreenButtonTapped(sender: AnyObject) {
        switchFullscreen()
    }

    @IBAction func onPromoteButtonPressed(sender: AnyObject) {
        removePlayerStatusObserver()
        viewModel.promoteVideo()
    }

    func videoPlayerTapped() {
        switchControlsVisible()

        // when tapping video player only get into fullscreen, not out
        if !viewModel.isFullscreen { switchFullscreen() }

        if viewModel.isFirstPlay {
            viewModel.isFirstPlay = false
            viewModel.videoIsMuted = false
        }
    }

    public func onAudioButtonPressed() {
        switchAudio()
    }

    public func onPlayButtonPressed() {
        switchPlaying()
    }

    public func progressValueChanged() {
        guard let item = player.currentItem else { return }
        let duration = CMTimeGetSeconds(item.duration)
        let newTime = CMTimeMakeWithSeconds(Double(progressSlider.value)*duration, item.currentTime().timescale)
        player.seekToTime(newTime)
    }

    func disableUpdateVideoProgress() {
        viewModel.disableAutoHideControls()
    }

    func enableUpdateVideoProgress() {
        viewModel.enableAutoHideControls()
    }

    func updateSliderFromVideo() {
        guard let item = player.currentItem where updateSliderFromVideoEnabled else { return }
        let currentTime = CMTimeGetSeconds(item.currentTime())
        let duration = CMTimeGetSeconds(item.duration)
        progressSlider.value = Float(currentTime/duration)
    }

    func switchAudio() {
        viewModel.switchAudio()
    }

    func switchFullscreen() {
        viewModel.switchFullscreen()
    }

    func switchControlsVisible() {
        viewModel.switchControlsVisible()
    }

    func switchPlaying() {
        viewModel.switchIsPlaying()
    }


    // MARK: - UICollectionView Delegate & DataSource

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.themesCount ?? 0
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath)
        -> UICollectionViewCell {

            guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ThemeCollectionCell",
                forIndexPath: indexPath) as? ThemeCollectionCell else { return UICollectionViewCell() }

            cell.tag = indexPath.hash // used for cell reuse

            cell.setupWithTitle(viewModel.titleForThemeAtIndex(indexPath.item),
                thumbnailURL: viewModel.imageUrlForThemeAtIndex(indexPath.item), indexPath: indexPath)

            return cell
    }

    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let firstIndex = NSIndexPath(forItem: 0, inSection: 0)

        guard let firstCell = collectionView.cellForItemAtIndexPath(firstIndex) as? ThemeCollectionCell else { return }
        if firstCell.selected && indexPath.item != firstIndex.item {
            firstCell.selected = false
//            firstCell.selectionChanged()
        }

        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ThemeCollectionCell else { return }
//        cell.selectionChanged()
        viewModel.isFirstPlay = false
        viewModel.videoIsMuted = false
        switchFullscreen()
        viewModel.selectThemeAtIndex(indexPath.item)
    }

    public func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ThemeCollectionCell else { return }
//        cell.selectionChanged()
    }


    // MARK: UICollectionViewDelegateFlowLayout

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
            return 10
    }

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
            return 10
    }

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let cellWidth = (collectionView.frame.width-30)/2
            return CGSize(width: cellWidth, height: cellWidth*9/16)
    }


    // MARK: private methods

    private func setupUI() {
        promoteTitleLabel.text = LGLocalizedString.commercializerPromoteTitleLabel
        chooseThemeLabel.text = LGLocalizedString.commercializerPromoteChooseThemeLabel
        promoteButton.setTitle(LGLocalizedString.commercializerPromotePromoteButton, forState: .Normal)
        promoteButton.setPrimaryStyle()

        let themeCell = UINib(nibName: "ThemeCollectionCell", bundle: nil)
        collectionView.registerNib(themeCell, forCellWithReuseIdentifier: "ThemeCollectionCell")

        let gradient = CAGradientLayer.gradientWithColor(backgroundView.backgroundColor ?? UIColor.clearColor(),
            alphas:[0.0,1.0], locations: [0.0,1.0])
        gradient.frame = gradientView.bounds
        gradientView.layer.insertSublayer(gradient, atIndex: 0)

        setupVideoPlayerViewController()

        refreshUI()
    }

    private func refreshUI() {
        audioButton.setImage(viewModel.imageForAudioButton, forState: .Normal)
        playButton.setImage(viewModel.imageForPlayButton, forState: .Normal)

        audioButton.hidden = !viewModel.audioButtonIsVisible
        playButton.hidden = !viewModel.controlsAreVisible
        fullScreenButton.hidden = !viewModel.fullScreenButtonEnabled
        progressSlider.hidden = !viewModel.controlsAreVisible
    }

    private func loadFirstOrSelectedVideo() {
        let itemIndex = collectionView.indexPathsForSelectedItems()?.first ?? NSIndexPath(forItem: 0, inSection: 0)

        guard let cell = collectionView.cellForItemAtIndexPath(itemIndex) as? ThemeCollectionCell else { return }
        cell.selected = true
//        cell.selectionChanged()
        viewModel.selectThemeAtIndex(itemIndex.item)
    }

    private func updateVideoPlayerWithURL(videoUrl: NSURL) {
        let playerItem = AVPlayerItem(URL: videoUrl)
        removePlayerStatusObserver()
        player = AVPlayer(playerItem: playerItem)

        if let videoTimer = videoTimer {
            videoTimer.invalidate()
        }
        videoTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "updateSliderFromVideo",
            userInfo: nil, repeats: true)

        player.muted = viewModel.videoIsMuted
        videoPlayerVC.player = player

        player.addObserver(self, forKeyPath: "status", options: .New, context: nil)
        playerObserverActive = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidFinishPlaying:",
            name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)

        videoPlayerVC.player?.play()
    }

    private func setupVideoPlayerViewController() {

        addChildViewController(videoPlayerVC)
        videoPlayerVC.showsPlaybackControls = false
        videoPlayerVC.view.userInteractionEnabled = true
        videoPlayerVC.view.frame = CGRect(x: 0, y: 0, width: videoContainerView.frame.size.width,
            height: videoContainerView.frame.size.height)
        videoContainerView.addSubview(videoPlayerVC.view)

        setupVideoPlayerTouchFriendlyView()
        setupVideoPlayerAudioButton()
        setupVideoPlayerPlayPauseButton()
        setupVideoPlayerProgressSlider()

        videoPlayerVC.view.layoutIfNeeded()
    }

    private func setupVideoPlayerTouchFriendlyView() {
        let touchFriendlyView = UIView()
        touchFriendlyView.translatesAutoresizingMaskIntoConstraints = false

        let videoPlayerTapRecognizer = UITapGestureRecognizer(target: self, action: "videoPlayerTapped")
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
        audioButton.addTarget(self, action: "onAudioButtonPressed", forControlEvents: .TouchUpInside)
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
        playButton.addTarget(self, action: "onPlayButtonPressed", forControlEvents: .TouchUpInside)
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
        // TODO: remove comments after design check
        //        progressSlider.setThumbImage(UIImage?, forState: UIControlState)
        //http://stackoverflow.com/questions/13196263/custom-uislider-increase-hot-spot-size

        progressSlider.tintColor = StyleHelper.primaryColor
        progressSlider.addTarget(self, action: "progressValueChanged", forControlEvents: .ValueChanged)
        progressSlider.addTarget(self, action: "disableUpdateVideoProgress", forControlEvents: .TouchDown)
        progressSlider.addTarget(self, action: "enableUpdateVideoProgress", forControlEvents: .TouchUpInside)
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
        viewModel.isFullscreen = false
        player.seekToTime(kCMTimeZero)
    }

    private func removePlayerStatusObserver() {
        if playerObserverActive {
            player.removeObserver(self, forKeyPath: "status")
            playerObserverActive = false
        }
    }

    private func presentCommercializerIntro() {
        let introVC = CommercializerIntroViewController()
        introVC.delegate = self

        presentViewController(introVC, animated: true) { [weak self] in
            self?.viewModel.commercializerIntroShown()
        }
    }

    // MARK: Player observer for keypath

    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?,
        change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
            if let keyPath = keyPath where keyPath == "status" && player == object as? AVPlayer {
                if player.status == .Failed {
                    // TODO: setup the view for player fail...
                } else if player.status == .ReadyToPlay {
                    // TODO: to check if status changed, this case might be ignored in the end
                }
                removePlayerStatusObserver()
            }
    }
}


extension PromoteProductViewController: CommercializerIntroViewControllerDelegate {
    func commercializerIntroIsDismissed() {
        loadFirstOrSelectedVideo()
    }
}

extension PromoteProductViewController: ProcessingVideoDialogDismissDelegate {
    func processingVideoDidDismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension PromoteProductViewController : PromoteProductViewModelDelegate {

    public func viewModelDidRetrieveThemesListSuccessfully() {
        collectionView.reloadData()
    }

    public func viewModelDidRetrieveThemesListWithError(errorMessage: String) {
        collectionView.reloadData()
    }

    public func viewModelVideoDidSwitchFullscreen(isFullscreen: Bool) {
        fullScreenButton.hidden = !isFullscreen
    }

    public func viewModelVideoDidSwitchControlsVisible(controlsAreVisible: Bool) {

        UIView.animateWithDuration(0.5) { [weak self] in
            self?.playButton.hidden = !controlsAreVisible
            self?.audioButton.hidden = !controlsAreVisible
            self?.progressSlider.hidden = !controlsAreVisible
        }
    }

    public func viewModelVideoDidSwitchPlaying(isPlaying: Bool) {
        isPlaying ? player.play() : player.pause()
        refreshUI()
    }

    public func viewModelVideoDidSwitchAudio(videoIsMuted: Bool) {
        player.muted = videoIsMuted
        refreshUI()
    }

    public func viewModelDidSelectThemeWithURL(themeURL: NSURL) {
        updateVideoPlayerWithURL(themeURL)
        refreshUI()
    }

    public func viewModelStartSendingVideoForProcessing() {
        showLoadingMessageAlert()
    }

    public func viewModelSentVideoForProcessingSuccessfully(processingViewModel: ProcessingVideoDialogViewModel) {
        dismissLoadingMessageAlert { [weak self] in
            if let strongSelf = self {
                let processingVideoVC = ProcessingVideoDialogViewController(viewModel: processingViewModel)
                processingVideoVC.delegate = strongSelf.delegate
                processingVideoVC.dismissDelegate = strongSelf
                strongSelf.presentViewController(processingVideoVC, animated: true, completion: {
                    strongSelf.view.hidden = true
                })
            }
        }
    }
    
    public func viewModelSentVideoForProcessingFailedWithMessage(message: String) {
        dismissLoadingMessageAlert { [weak self] in
            self?.showAutoFadingOutMessageAlert(message)
        }
    }
}
