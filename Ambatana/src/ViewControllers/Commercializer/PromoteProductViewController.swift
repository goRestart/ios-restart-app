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

public class PromoteProductViewController: BaseViewController, PromoteProductViewModelDelegate, UICollectionViewDataSource,
UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CommercializerIntroViewControllerDelegate {


    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var promoteTitleLabel: UILabel!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var chooseThemeLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var promoteButton: UIButton!
    @IBOutlet weak var fullScreenButton: UIButton!

    var viewModel: PromoteProductViewModel?

    var videoPlayerVC: AVPlayerViewController
    var player: AVPlayer
    var audioButton: UIButton
    var playButton: UIButton
    var progressSlider: UISlider


    // MARK: Lifecycle

    public convenience init() {
        self.init(viewModel: PromoteProductViewModel(), nibName: "PromoteProductViewController")
    }

    public convenience init(viewModel: PromoteProductViewModel) {
        self.init(viewModel: viewModel, nibName: "PromoteProductViewController")
    }

    public required init(viewModel: PromoteProductViewModel, nibName nibNameOrNil: String?) {
        self.videoPlayerVC = AVPlayerViewController()
        self.player = AVPlayer()
        self.audioButton = UIButton(type: .Custom)
        self.playButton = UIButton(type: .Custom)
        self.progressSlider = UISlider()
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        self.viewModel = viewModel
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
        setupUI()

    }

    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // load video only if is not 1st time opening commercializer
        guard let viewModel = viewModel where viewModel.commercializerShownBefore else {
            let introVC = CommercializerIntroViewController()
            introVC.delegate = self
            introVC.modalPresentationStyle = .OverCurrentContext
            introVC.modalTransitionStyle = .CrossDissolve

            presentViewController(introVC, animated: true) {
                print("intro shown...")
                // TODO: uncomment when working ok, this line saves commercializer shown in user defaults
//                viewModel.commercializerIntroShown()
            }

            return
        }

        loadFirstOrSelectedVideo()
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
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onFullScreenButtonTapped(sender: AnyObject) {
        switchFullscreen()
    }

    func videoPlayerTapped() {
        if let viewModel = viewModel {

            switchControlsVisible()

            // when tapping video player only get into of fullscreen, not out
            if !viewModel.isFullscreen { switchFullscreen() }

            if viewModel.isFirstPlay {
                viewModel.isFirstPlay = false
                viewModel.videoIsMuted = false
            }
        }
    }

    public func onAudioButtonPressed() {
        switchAudio()
    }

    public func onPlayButtonPressed() {
        switchPlaying()
    }

    public func progressValueChanged() {

        print("SLIDER VALUE CHANGED TO \(progressSlider.value)")

        guard let item = player.currentItem else { return }
        let duration = CMTimeGetSeconds(item.duration)
        let newTime = CMTimeMakeWithSeconds(Double(progressSlider.value)*duration, item.currentTime().timescale)
        player.seekToTime(newTime)
    }

//    func updateSliderFromVideo() {
//
//        guard let item = player.currentItem else { return }
//
//        let currentTime = CMTimeGetSeconds(item.currentTime())
//        let duration = CMTimeGetSeconds(item.duration)
//        progressSlider.value = Float(currentTime/duration)
//
//
////        currentTime = CMTimeGetSeconds(playerItem.currentTime);
////        duration = CMTimeGetSeconds(playerItem.duration);
////        [self.audioSliderBar setValue:(currentTime/duration)];
////        float minutes = floor(currentTime/60);
////        seconds =currentTime - (minutes * 60);
////        float duration_minutes = floor(duration/60);
////        duration_seconds = duration - (duration_minutes * 60);
////        NSString *timeInfoString = [[NSString alloc] initWithFormat:@"%0.0f:%0.0f", minutes, seconds ];
////        self.audioCurrentTimeLabel.text = timeInfoString;
//    }

    func switchAudio() {
        viewModel?.switchAudio()
    }

    func switchFullscreen() {
        viewModel?.switchFullscreen()
    }

    func switchControlsVisible() {
        viewModel?.switchControlsVisible()
    }

    func switchPlaying() {
        viewModel?.switchIsPlaying()
    }


    // MARK: CommercializerIntroViewControllerDelegate

    func commercializerIntroIsDismissed() {
        loadFirstOrSelectedVideo()
    }


    // MARK: UICollectionView Delegate & DataSource

    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.themesCount ?? 0
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ThemeCollectionCell", forIndexPath: indexPath) as? ThemeCollectionCell else { return UICollectionViewCell() }

        cell.tag = indexPath.hash // used for cell reuse

        cell.setupWithTitle(viewModel?.titleForThemeAtIndex(indexPath.item), thumbnailURL: viewModel?.imageUrlForThemeAtIndex(indexPath.item), indexPath: indexPath)

        return cell
    }

    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let firstIndex = NSIndexPath(forItem: 0, inSection: 0)

        guard let firstCell = collectionView.cellForItemAtIndexPath(firstIndex) as? ThemeCollectionCell else { return }
        if firstCell.selected && indexPath.item != firstIndex.item {
            firstCell.selected = false
            firstCell.selectionChanged()
        }

        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ThemeCollectionCell else { return }
        cell.selectionChanged()
        viewModel?.isFirstPlay = false
        viewModel?.videoIsMuted = false
        switchFullscreen()
        viewModel?.selectThemeAtIndex(indexPath.item)
    }

    public func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ThemeCollectionCell else { return }
        cell.selectionChanged()
    }

    // MARK: UICollectionViewDelegateFlowLayout

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }


    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width-30)/2

        return CGSize(width: cellWidth, height: cellWidth*9/16)
    }


    // MARK: PromoteProductViewModelDelegate


    func viewModelVideoDidSwitchFullscreen(isFullscreen: Bool) {
        fullScreenButton.hidden = !isFullscreen
    }

    func viewModelVideoDidSwitchControlsVisible(controlsAreVisible: Bool) {

        UIView.animateWithDuration(0.5) {
            self.playButton.hidden = !controlsAreVisible
            self.audioButton.hidden = !controlsAreVisible
            self.progressSlider.hidden = !controlsAreVisible
        }
    }

    func viewModelVideoDidSwitchPlaying(isPlaying: Bool) {
        if isPlaying {
            player.play()
        } else {
            player.pause()
        }

        refreshUI()
    }

    func viewModelVideoDidSwitchAudio(videoIsMuted: Bool) {
        player.muted = videoIsMuted
        refreshUI()
    }

    public func viewModelDidSelectThemeWithURL(themeURL: NSURL) {
        updateVideoPlayerWithURL(themeURL)
        refreshUI()
    }


    // MARK: private methods

    private func setupUI() {

        promoteTitleLabel.text = "_Promote your product"
        chooseThemeLabel.text = "_Choose one theme"
        promoteButton.setPrimaryStyle()

        let themeCell = UINib(nibName: "ThemeCollectionCell", bundle: nil)
        collectionView.registerNib(themeCell, forCellWithReuseIdentifier: "ThemeCollectionCell")

        let gradient = CAGradientLayer.gradientWithColor(backgroundView.backgroundColor ?? UIColor.clearColor(), alphas:[0.0,1.0], locations: [0.0,1.0])
        gradient.frame = gradientView.bounds
        gradientView.layer.insertSublayer(gradient, atIndex: 0)

        setupVideoPlayerViewController()

        refreshUI()
    }

    private func refreshUI() {

        guard let viewModel = viewModel else { return }

        audioButton.setImage(viewModel.imageForAudioButton, forState: .Normal)
        playButton.setImage(viewModel.imageForPlayButton, forState: .Normal)

        fullScreenButton.hidden = !viewModel.fullScreenButtonEnabled

        playButton.hidden = !viewModel.controlsAreVisible
        audioButton.hidden = !viewModel.controlsAreVisible && !viewModel.isFirstPlay
        progressSlider.hidden = !viewModel.controlsAreVisible

    }

    private func loadFirstOrSelectedVideo() {
        guard let itemIndex = collectionView.indexPathsForSelectedItems()?.first else {
            // select 1st item
            let firstIndex = NSIndexPath(forItem: 0, inSection: 0)
            guard let cell = collectionView.cellForItemAtIndexPath(firstIndex) as? ThemeCollectionCell else { return }
            cell.selected = true
            cell.selectionChanged()
            viewModel?.selectThemeAtIndex(firstIndex.item)
            return
        }

        guard let cell = collectionView.cellForItemAtIndexPath(itemIndex) as? ThemeCollectionCell else { return }
        cell.selected = true
        cell.selectionChanged()
        viewModel?.selectThemeAtIndex(itemIndex.item)
    }

        


    private func updateVideoPlayerWithURL(videoUrl: NSURL) {

        // add video player:  Or maybe just thumbnail????

        let playerItem = AVPlayerItem(URL: videoUrl)

        player = AVPlayer(playerItem: playerItem)

        player.addObserver(self, forKeyPath: "status", options: .New, context: nil)

        // TODO: Make video move the slider!!!!
        // http://stackoverflow.com/questions/11732620/how-to-add-uislider-to-avplayer

//        let duration = CMTimeGetSeconds(playerItem.asset.duration)
//        let interval = CMTimeMake(Int64(duration), 1);
//
//        let _ = player.addPeriodicTimeObserverForInterval(interval, queue: nil) { cmTime in
//
//            let endTime:CMTime = CMTimeConvertScale (playerItem.duration, playerItem.currentTime().timescale, .RoundHalfAwayFromZero);
//
//            print("-_-_______-_________-")
//            print(playerItem.currentTime().timescale)
//            print(playerItem.currentTime().value)
//            print(endTime.value)
//            print(playerItem.currentTime().value/endTime.value)
//            print(Float(playerItem.currentTime().value/endTime.value))
//
//            if (CMTimeCompare(endTime, kCMTimeZero) != 0) {
//                let normalizedTime = Float(playerItem.currentTime().value/endTime.value)
//                self.progressSlider.value = normalizedTime
//            }
//        }

        player.muted = viewModel?.videoIsMuted ?? true
        videoPlayerVC.player = player

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidFinishPlaying:", name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)

        videoPlayerVC.player?.play()
    }

    private func setupVideoPlayerViewController() {

        addChildViewController(videoPlayerVC)
        videoPlayerVC.showsPlaybackControls = false
        videoPlayerVC.view.userInteractionEnabled = true
        videoPlayerVC.view.frame = CGRect(x: 0, y: 0, width: videoContainerView.frame.size.width, height: videoContainerView.frame.size.height)
        videoContainerView.addSubview(videoPlayerVC.view)

        // Touch Friendly View

        let touchFriendlyView = UIView()
        touchFriendlyView.translatesAutoresizingMaskIntoConstraints = false

        let videoPlayerTapRecognizer = UITapGestureRecognizer(target: self, action: "videoPlayerTapped")
        videoPlayerTapRecognizer.numberOfTapsRequired = 1
        touchFriendlyView.addGestureRecognizer(videoPlayerTapRecognizer)

        videoPlayerVC.view.addSubview(touchFriendlyView)

        let touchFriendlyViewTop = NSLayoutConstraint(item: touchFriendlyView, attribute: .Top, relatedBy: .Equal, toItem: videoPlayerVC.view, attribute: .Top, multiplier: 1, constant: 0)
        videoPlayerVC.view.addConstraint(touchFriendlyViewTop)
        let touchFriendlyViewBottom = NSLayoutConstraint(item: touchFriendlyView, attribute: .Bottom, relatedBy: .Equal, toItem: videoPlayerVC.view, attribute: .Bottom, multiplier: 1, constant: 0)
        videoPlayerVC.view.addConstraint(touchFriendlyViewBottom)
        let touchFriendlyViewLeft = NSLayoutConstraint(item: touchFriendlyView, attribute: .Left, relatedBy: .Equal, toItem: videoPlayerVC.view, attribute: .Left, multiplier: 1, constant: 0)
        videoPlayerVC.view.addConstraint(touchFriendlyViewLeft)
        let touchFriendlyViewRight = NSLayoutConstraint(item: touchFriendlyView, attribute: .Right, relatedBy: .Equal, toItem: videoPlayerVC.view, attribute: .Right, multiplier: 1, constant: 0)
        videoPlayerVC.view.addConstraint(touchFriendlyViewRight)

        // Audio Button
        audioButton.addTarget(self, action: "onAudioButtonPressed", forControlEvents: .TouchUpInside)
        audioButton.translatesAutoresizingMaskIntoConstraints = false
        videoPlayerVC.view.addSubview(audioButton)

        let audioButtonWidth = NSLayoutConstraint(item: audioButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 30)
        audioButton.addConstraint(audioButtonWidth)
        let audioButtonHeight = NSLayoutConstraint(item: audioButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 30)
        audioButton.addConstraint(audioButtonHeight)

        let audioButtonTop = NSLayoutConstraint(item: audioButton, attribute: .Top, relatedBy: .Equal,
            toItem: videoPlayerVC.view, attribute: .Top, multiplier: 1, constant: 10)
        videoPlayerVC.view.addConstraint(audioButtonTop)
        let audioButtonRight = NSLayoutConstraint(item: audioButton, attribute: .Right, relatedBy: .Equal,
            toItem: videoPlayerVC.view, attribute: .Right, multiplier: 1, constant: -10)
        videoPlayerVC.view.addConstraint(audioButtonRight)

        // Play Button
        playButton.addTarget(self, action: "onPlayButtonPressed", forControlEvents: .TouchUpInside)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        videoPlayerVC.view.addSubview(playButton)

        let playButtonWidth = NSLayoutConstraint(item: playButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 40)
        playButton.addConstraint(playButtonWidth)
        let playButtonHeight = NSLayoutConstraint(item: playButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 40)
        playButton.addConstraint(playButtonHeight)
        let playButtonXCenter = NSLayoutConstraint(item: playButton, attribute: .CenterX, relatedBy: .Equal, toItem: videoPlayerVC.view, attribute: .CenterX, multiplier: 1, constant: 0)
        videoPlayerVC.view.addConstraint(playButtonXCenter)
        let playButtonYCenter = NSLayoutConstraint(item: playButton, attribute: .CenterY, relatedBy: .Equal, toItem: videoPlayerVC.view, attribute: .CenterY, multiplier: 1, constant: 0)
        videoPlayerVC.view.addConstraint(playButtonYCenter)

        // Slider
        // http://stackoverflow.com/questions/32283044/objective-c-uislider-in-avplayer-not-working-fine-after-scrubber

        progressSlider.transform = CGAffineTransformMakeScale(0.8, 0.8);
//        progressSlider.setThumbImage(UIImage?, forState: UIControlState)
        //http://stackoverflow.com/questions/13196263/custom-uislider-increase-hot-spot-size

        progressSlider.tintColor = StyleHelper.primaryColor
        progressSlider.addTarget(self, action: "progressValueChanged", forControlEvents: .ValueChanged)
        progressSlider.translatesAutoresizingMaskIntoConstraints = false
        videoPlayerVC.view.addSubview(progressSlider)

        let sliderBottom = NSLayoutConstraint(item: progressSlider, attribute: .Bottom, relatedBy: .Equal, toItem: videoPlayerVC.view, attribute: .Bottom, multiplier: 1, constant: -10)
        videoPlayerVC.view.addConstraint(sliderBottom)
        let sliderLeft = NSLayoutConstraint(item: progressSlider, attribute: .Left, relatedBy: .Equal, toItem: videoPlayerVC.view, attribute: .Left, multiplier: 1, constant: 20)
        videoPlayerVC.view.addConstraint(sliderLeft)
        let sliderRight = NSLayoutConstraint(item: progressSlider, attribute: .Right, relatedBy: .Equal, toItem: videoPlayerVC.view, attribute: .Right, multiplier: 1, constant: -20)
        videoPlayerVC.view.addConstraint(sliderRight)

        videoPlayerVC.view.layoutIfNeeded()

    }

    func playerDidFinishPlaying(note: NSNotification) {
        viewModel?.isFullscreen = false
        player.seekToTime(kCMTimeZero)
    }

    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let keyPath = keyPath where keyPath == "status" && player == object as? AVPlayer {
            if player.status == .Failed {
                // TODO: setup the view for player fail...
                print("PLAYER FAILED!!!")
            } else if player.status == .ReadyToPlay {
                print("\n\nPLAYER READY TO PLAY!!!\n\n")
            }
            player.removeObserver(self, forKeyPath: "status")
        }
    }
}
