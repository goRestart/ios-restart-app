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


    var videoContainerView: VideoPlayerContainerView
    var viewModel: PromoteProductViewModel
    weak var delegate: PromoteProductViewControllerDelegate?


    // MARK: Lifecycle

    public convenience init(viewModel: PromoteProductViewModel) {
        self.init(viewModel: viewModel, nibName: "PromoteProductViewController")
    }

    public required init(viewModel: PromoteProductViewModel, nibName nibNameOrNil: String?) {
        self.viewModel = viewModel
        self.videoContainerView = VideoPlayerContainerView.instanceFromNib()
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        viewModel.delegate = self
        self.videoContainerView.delegate = self
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

    public override func viewDidFirstAppear(animated: Bool) {
        super.viewDidFirstAppear(animated)
        videoContainerView.frame = playerView.bounds
        videoContainerView.setupUI()
        playerView.addSubview(videoContainerView)
    }

    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // view is hidden when the processing video dialog is prompted,
        // so the user don't see 2 screens dismissing when closing the top one
        guard !view.hidden else { return }

        // load video only if is not 1st time opening commercializer
        if viewModel.commercializerShownBefore {
            loadFirstOrSelectedVideo()
        } else {
            showIntro()
        }
    }

    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let statusBarStyle = viewModel.statusBarStyleAtDisappear
        UIApplication.sharedApplication().setStatusBarStyle(statusBarStyle, animated: true)
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
    }


    // MARK: public methods

    @IBAction func onCloseButton(sender: AnyObject) {
        dismissViewControllerAnimated(true) { [weak self] _ in
            guard let source = self?.viewModel.promotionSource else { return }
            self?.delegate?.promoteProductViewControllerDidFinishFromSource(source)
        }
    }

    @IBAction func onFullScreenButtonTapped(sender: AnyObject) {
        switchFullscreen()
    }

    @IBAction func onIntroButtonPressed(sender: AnyObject) {
        hideIntro()
        loadFirstOrSelectedVideo()
    }

    @IBAction func onPromoteButtonPressed(sender: AnyObject) {
        viewModel.promoteProduct()
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
        }
        hideIntro()
        switchFullscreen()
        viewModel.selectThemeAtIndex(indexPath.item)
        videoContainerView.videoIsMuted = false
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
    }

    private func loadFirstOrSelectedVideo() {
        let itemIndex = collectionView.indexPathsForSelectedItems()?.first ?? NSIndexPath(forItem: 0, inSection: 0)

        guard let cell = collectionView.cellForItemAtIndexPath(itemIndex) as? ThemeCollectionCell else { return }
        cell.selected = true
        viewModel.selectThemeAtIndex(itemIndex.item)
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

    public func viewModelDidSelectThemeWithURL(themeURL: NSURL) {
        videoContainerView.updateVideoPlayerWithURL(themeURL)
        refreshUI()
    }

    public func viewModelStartSendingVideoForProcessing() {
        showLoadingMessageAlert()
    }

    public func viewModelSentVideoForProcessing(processingViewModel: ProcessingVideoDialogViewModel,
        status: VideoProcessStatus) {
            dismissLoadingMessageAlert { [weak self] in

                guard let strongSelf = self else { return }

                var completion: (() -> ())?
                switch status {
                case .ProcessOK:
                    completion = { strongSelf.view.hidden = true }
                case .ProcessFail:
                    completion = nil
                }
                let processingVideoVC = ProcessingVideoDialogViewController(viewModel: processingViewModel)
                processingVideoVC.delegate = strongSelf.delegate
                processingVideoVC.dismissDelegate = strongSelf
                strongSelf.presentViewController(processingVideoVC, animated: true, completion: completion)
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
}
