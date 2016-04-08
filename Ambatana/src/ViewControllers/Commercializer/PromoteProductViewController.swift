//
//  PromoteProductViewController.swift
//  LetGo
//
//  Created by Dídac on 01/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

protocol PromoteProductViewControllerDelegate: class {
    func promoteProductViewControllerDidFinishFromSource(promotionSource: PromotionSource)
    func promoteProductViewControllerDidCancelFromSource(promotionSource: PromotionSource)
}

public class PromoteProductViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var introOverlayView: UIView!
    @IBOutlet weak var introImageView: UIImageView!
    @IBOutlet weak var introLabel: UILabel!

    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var chooseThemeLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var promoteButton: UIButton!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var videoContainerView: VideoPlayerContainerView
    private var fullScreen = false
    var viewModel: PromoteProductViewModel
    weak var delegate: PromoteProductViewControllerDelegate?


    // MARK: Lifecycle

    public convenience init(viewModel: PromoteProductViewModel) {
        self.init(viewModel: viewModel, nibName: "PromoteProductViewController")
    }

    public required init(viewModel: PromoteProductViewModel, nibName nibNameOrNil: String?) {
        self.viewModel = viewModel
        self.videoContainerView = VideoPlayerContainerView.instanceFromNib()
        super.init(viewModel: viewModel, nibName: nibNameOrNil, statusBarStyle: .LightContent)
        viewModel.delegate = self
        self.videoContainerView.delegate = self
        modalTransitionStyle = .CrossDissolve
        modalPresentationStyle = .OverCurrentContext
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
        viewModel.viewDidLoad()
    }

    public override func viewDidFirstAppear(animated: Bool) {
        super.viewDidFirstAppear(animated)
        videoContainerView.frame = playerView.bounds
        videoContainerView.setupUI()
        playerView.addSubview(videoContainerView)
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // load video only if is not 1st time opening commercializer
        if viewModel.commercializerShownBefore {
            selectFirstAvailableTheme()
        } else {
            showIntro()
        }
    }

    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        videoContainerView.pausePlayer()
    }

    override func viewWillDisappearToBackground(toBackground: Bool) {
        super.viewWillDisappearToBackground(toBackground)
        videoContainerView.pausePlayer()
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // Adjust gradient layer
        if let layers = gradientView.layer.sublayers {
            layers.forEach { $0.frame = gradientView.bounds }
        }

        collectionView.reloadData()
    }


    // MARK: public methods

    @IBAction func onCloseButton(sender: AnyObject) {
        dismissViewControllerAnimated(true) { [weak self] _ in
            guard let source = self?.viewModel.promotionSource else { return }
            self?.delegate?.promoteProductViewControllerDidCancelFromSource(source)
        }
    }

    @IBAction func onFullScreenButtonTapped(sender: AnyObject) {
        switchFullscreen()
    }

    @IBAction func onIntroButtonPressed(sender: AnyObject) {
        hideIntro()
        selectFirstAvailableTheme()
    }

    @IBAction func onPromoteButtonPressed(sender: AnyObject) {
        videoContainerView.pausePlayer()
        viewModel.promoteProduct()
    }


    private func selectFirstAvailableTheme() {
        let numberOfItems = collectionView.numberOfItemsInSection(0)
        guard let firstAvailableVideoIndex = viewModel.firstAvailableVideoIndex else { return }
        guard 0..<numberOfItems ~= firstAvailableVideoIndex else { return }


        let indexPath = NSIndexPath(forItem: firstAvailableVideoIndex, inSection: 0)

        collectionView.selectItemAtIndexPath(indexPath, animated: true,
                                             scrollPosition: UICollectionViewScrollPosition.Top)
        viewModel.playFirstAvailableTheme()
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

            let index = indexPath.item
            let title = viewModel.titleForThemeAtIndex(index)
            let thumbnailURL = viewModel.imageUrlForThemeAtIndex(index)

            let playing = viewModel.playingThemeAtIndex(index)
            let available = viewModel.availableThemeAtIndex(index)

            cell.setupWithTitle(title, thumbnailURL: thumbnailURL, playing: playing, available: available,
                                indexPath: indexPath)
            return cell
    }

    public func collectionView(collectionView: UICollectionView,
                               shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return viewModel.availableThemeAtIndex(indexPath.item)
    }

    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        hideIntro()
        switchFullscreen()
        viewModel.playThemeAtIndex(indexPath.item)
        videoContainerView.videoIsMuted = false
        collectionView.reloadData()
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
        promoteButton.setPrimaryStyle()

        // Localization
        introLabel.text = LGLocalizedString.commercializerPromoteIntroLabel
        promoteButton.setTitle(LGLocalizedString.commercializerPromotePromoteButton, forState: .Normal)
        chooseThemeLabel.text = LGLocalizedString.commercializerPromoteChooseThemeLabel

        introImageView.sd_setImageWithURL(viewModel.imageUrlForThemeAtIndex(0))

        let themeCell = UINib(nibName: "ThemeCollectionCell", bundle: nil)
        collectionView.registerNib(themeCell, forCellWithReuseIdentifier: "ThemeCollectionCell")

        let gradient = CAGradientLayer.gradientWithColor(view.backgroundColor ?? UIColor.clearColor(),
            alphas:[0.0,1.0], locations: [0.0,1.0])
        gradient.frame = gradientView.bounds
        gradientView.layer.insertSublayer(gradient, atIndex: 0)

        refreshUI()
    }

    private func refreshUI() {
        fullScreenButton.hidden = !viewModel.fullScreenButtonEnabled
        collectionView.reloadData()
    }

    private func showIntro() {
        introOverlayView.hidden = false
        viewModel.commercializerIntroShown()
    }

    private func hideIntro() {
        guard !introOverlayView.hidden else { return }

        UIView.animateWithDuration(0.25, animations: { [weak self] in
            self?.introOverlayView.alpha = 0
        }) { [weak self] _ in
            self?.introOverlayView.hidden = true
        }
    }

    private func switchFullscreen() {
        viewModel.switchFullscreen()
    }
}

extension PromoteProductViewController: ProcessingVideoDialogDismissDelegate {
    func processingVideoDidDismissOk() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func processingVideoDidDismissTryAgain() {
        viewModel.promoteProduct()
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

    public func viewModelDidSelectThemeAtIndex(index: Int) {
        guard let url = viewModel.videoUrlForThemeAtIndex(index) else { return }
        videoContainerView.updateVideoPlayerWithURL(url)
        refreshUI()
    }

    public func viewModelStartSendingVideoForProcessing() {
        showLoadingMessageAlert()
    }

    public func viewModelSentVideoForProcessing(processingViewModel: ProcessingVideoDialogViewModel,
        status: VideoProcessStatus) {
            dismissLoadingMessageAlert { [weak self] in

                guard let strongSelf = self else { return }
                let processingVideoVC = ProcessingVideoDialogViewController(viewModel: processingViewModel)
                processingVideoVC.delegate = strongSelf.delegate
                processingVideoVC.dismissDelegate = strongSelf
                strongSelf.presentViewController(processingVideoVC, animated: true, completion: nil)
            }
    }
    
    func viewModelWillRetrieveProductCommercials() {
        activityIndicator.startAnimating()
        view.userInteractionEnabled = false
        fullScreenButton.hidden = false
    }
    
    func viewModelDidRetrieveProductCommercialsSuccessfully() {
        activityIndicator.stopAnimating()
        collectionView.reloadData()
        view.userInteractionEnabled = true
        fullScreenButton.hidden = true
        selectFirstAvailableTheme()
    }
    
    func viewModelDidRetrieveProductCommercialsWithError() {
        activityIndicator.stopAnimating()
        view.userInteractionEnabled = true
        fullScreenButton.hidden = true
        showAutoFadingOutMessageAlert(LGLocalizedString.commonErrorConnectionFailed) { [weak self] in
            self?.onCloseButton("")
        }
    }
}


extension PromoteProductViewController: VideoPlayerContainerViewDelegate {

    public func playerDidSwitchPlaying(isPlaying: Bool) {
        guard !isPlaying && !viewModel.isFullscreen else { return }
        switchFullscreen()
    }

    public func playerDidReceiveTap() {
        // when tapping video player only get into fullscreen, not out
        if !viewModel.isFullscreen { switchFullscreen() }
    }

    public func playerDidFinishPlaying() {
        if viewModel.isFullscreen { switchFullscreen() }
        if fullScreen { playerDidPressFullscreen() }
    }

    public func playerDidPressFullscreen() {
        let transform: CGAffineTransform
        if fullScreen {
            fullScreen = false
            transform = CGAffineTransformIdentity
        } else {
            fullScreen = true
            transform = CGAffineTransform.commercializerVideoToFullScreenTransform(playerView.frame)
        }

        UIApplication.sharedApplication().setStatusBarHidden(fullScreen, withAnimation: .Fade)
        UIView.animateWithDuration(0.2) { [weak self] in
            self?.playerView.transform = transform
        }
    }
}
