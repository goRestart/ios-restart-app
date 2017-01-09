//
//  PromoteProductViewController.swift
//  LetGo
//
//  Created by Dídac on 01/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

protocol PromoteProductViewControllerDelegate: class {
    func promoteProductViewControllerDidFinishFromSource(_ promotionSource: PromotionSource)
    func promoteProductViewControllerDidCancelFromSource(_ promotionSource: PromotionSource)
}

class PromoteProductViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var introOverlayView: UIView!
    @IBOutlet weak var introContainer: UIView!
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var introButton: UIButton!

    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var chooseThemeLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var promoteButton: UIButton!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var navigationBar: UINavigationBar!

    var videoContainerView: VideoPlayerContainerView
    fileprivate var fullScreen = false
    var viewModel: PromoteProductViewModel
    weak var delegate: PromoteProductViewControllerDelegate?


    // MARK: Lifecycle

    convenience init(viewModel: PromoteProductViewModel) {
        self.init(viewModel: viewModel, nibName: "PromoteProductViewController")
    }

    required init(viewModel: PromoteProductViewModel, nibName nibNameOrNil: String?) {
        self.viewModel = viewModel
        self.videoContainerView = VideoPlayerContainerView.instanceFromNib()
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        viewModel.delegate = self
        self.videoContainerView.delegate = self
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.viewDidLoad()
    }

    override func viewDidFirstAppear(_ animated: Bool) {
        super.viewDidFirstAppear(animated)
        videoContainerView.frame = playerView.bounds
        videoContainerView.setupUI()
        playerView.addSubview(videoContainerView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if viewModel.shouldShowOnboarding {
            showIntro()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !viewModel.shouldShowOnboarding {
            selectFirstAvailableTheme()
        }
    }

    override func viewWillDisappearToBackground(_ toBackground: Bool) {
        super.viewWillDisappearToBackground(toBackground)
        videoContainerView.pausePlayer()
        videoContainerView.didBecomeInactive()
    }

    override func viewWillAppearFromBackground(_ toBackground: Bool) {
        super.viewWillAppearFromBackground(toBackground)
        videoContainerView.didBecomeActive()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // Adjust gradient layer
        if let layers = gradientView.layer.sublayers {
            layers.forEach { $0.frame = gradientView.bounds }
        }

        collectionView.reloadData()
    }


    // MARK: public methods

    @IBAction func onCloseButton(_ sender: Any) {
        dismiss(animated: true) { [weak self] _ in
            guard let source = self?.viewModel.promotionSource else { return }
            self?.delegate?.promoteProductViewControllerDidCancelFromSource(source)
        }
    }

    @IBAction func onFullScreenButtonTapped(_ sender: AnyObject) {
        switchFullscreen()
    }

    @IBAction func onIntroButtonPressed(_ sender: AnyObject) {
        hideIntro()
        selectFirstAvailableTheme()
    }

    @IBAction func onPromoteButtonPressed(_ sender: AnyObject) {
        videoContainerView.pausePlayer()
        viewModel.promoteProduct()
    }


    fileprivate func selectFirstAvailableTheme() {
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        guard let firstAvailableVideoIndex = viewModel.firstAvailableVideoIndex else { return }
        guard 0..<numberOfItems ~= firstAvailableVideoIndex else { return }


        let indexPath = IndexPath(item: firstAvailableVideoIndex, section: 0)

        collectionView.selectItem(at: indexPath, animated: true,
                                             scrollPosition: UICollectionViewScrollPosition.top)
        viewModel.playFirstAvailableTheme()
    }

    // MARK: - UICollectionView Delegate & DataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.themesCount ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThemeCollectionCell",
                for: indexPath) as? ThemeCollectionCell else { return UICollectionViewCell() }

            cell.tag = (indexPath as NSIndexPath).hash // used for cell reuse

            let index = indexPath.item
            let title = viewModel.titleForThemeAtIndex(index)
            let thumbnailURL = viewModel.imageUrlForThemeAtIndex(index)

            let playing = viewModel.playingThemeAtIndex(index)
            let available = viewModel.availableThemeAtIndex(index)

            cell.setupWithTitle(title, thumbnailURL: thumbnailURL, playing: playing, available: available,
                                indexPath: indexPath)
            return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                               shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return viewModel.availableThemeAtIndex(indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        hideIntro()
        switchFullscreen()
        viewModel.playThemeAtIndex(indexPath.item)
        videoContainerView.videoIsMuted = false
        collectionView.reloadData()
    }


    // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width-30)/2
        guard cellWidth > 0 else { return CGSize.zero }
        return CGSize(width: cellWidth, height: cellWidth*9/16)
    }


    // MARK: private methods

    private func setupUI() {
        promoteButton.setStyle(.primary(fontSize: .medium))
        introButton.setStyle(.primary(fontSize: .medium))
        introContainer.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius

        // Localization
        introLabel.text = LGLocalizedString.commercializerPromoteIntroLabel
        introButton.setTitle(LGLocalizedString.commercializerPromoteIntroButton, for: UIControlState())
        promoteButton.setTitle(LGLocalizedString.commercializerPromotePromoteButton, for: UIControlState())
        chooseThemeLabel.text = LGLocalizedString.commercializerPromoteChooseThemeLabel

        let themeCell = UINib(nibName: "ThemeCollectionCell", bundle: nil)
        collectionView.register(themeCell, forCellWithReuseIdentifier: "ThemeCollectionCell")

        let gradient = CAGradientLayer.gradientWithColor(view.backgroundColor ?? UIColor.clear,
            alphas:[0.0,1.0], locations: [0.0,1.0])
        gradient.frame = gradientView.bounds
        gradientView.layer.insertSublayer(gradient, at: 0)

        navigationBar.topItem?.title = LGLocalizedString.commercializerPromoteNavigationTitle
        let backIconImage = UIImage(named: "navbar_close")
        let backButton = UIBarButtonItem(image: backIconImage, style: UIBarButtonItemStyle.plain,
                                         target: self, action: #selector(onCloseButton))
        navigationBar.topItem?.leftBarButtonItem = backButton
        refreshUI()
    }

    fileprivate func refreshUI() {
        fullScreenButton.isHidden = !viewModel.fullScreenButtonEnabled
        collectionView.reloadData()
    }

    fileprivate func showIntro() {
        introOverlayView.isHidden = false
        viewModel.commercializerIntroShown()
    }

    fileprivate func hideIntro() {
        guard !introOverlayView.isHidden else { return }

        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.introOverlayView.alpha = 0
        }, completion: { [weak self] _ in
            self?.introOverlayView.isHidden = true
        }) 
    }

    fileprivate func switchFullscreen() {
        viewModel.switchFullscreen()
    }
}


// MARK: - ProcessingVideoDialogDismissDelegate

extension PromoteProductViewController: ProcessingVideoDialogDismissDelegate {
    func processingVideoDidDismissOk() {
        self.dismiss(animated: true, completion: nil)
    }

    func processingVideoDidDismissTryAgain() {
        viewModel.promoteProduct()
    }
}


// MARK: - PromoteProductViewModelDelegate

extension PromoteProductViewController : PromoteProductViewModelDelegate {

    func viewModelDidRetrieveThemesListSuccessfully() {
        collectionView.reloadData()
    }

    func viewModelDidRetrieveThemesListWithError(_ errorMessage: String) {
        collectionView.reloadData()
    }

    func viewModelVideoDidSwitchFullscreen(_ isFullscreen: Bool) {
        fullScreenButton.isHidden = !isFullscreen
    }

    func viewModelDidSelectThemeAtIndex(_ index: Int) {
        guard let url = viewModel.videoUrlForThemeAtIndex(index) else { return }
        videoContainerView.updateVideoPlayerWithURL(url)
        refreshUI()
    }

    func viewModelStartSendingVideoForProcessing() {
        showLoadingMessageAlert()
    }

    func viewModelSentVideoForProcessing(_ processingViewModel: ProcessingVideoDialogViewModel,
        status: VideoProcessStatus) {
            dismissLoadingMessageAlert { [weak self] in

                guard let strongSelf = self else { return }
                let processingVideoVC = ProcessingVideoDialogViewController(viewModel: processingViewModel)
                processingVideoVC.delegate = strongSelf.delegate
                processingVideoVC.dismissDelegate = strongSelf
                strongSelf.present(processingVideoVC, animated: true, completion: nil)
            }
    }
    
    func viewModelWillRetrieveProductCommercials() {
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        fullScreenButton.isHidden = false
    }
    
    func viewModelDidRetrieveProductCommercialsSuccessfully() {
        activityIndicator.stopAnimating()
        collectionView.reloadData()
        view.isUserInteractionEnabled = true
        fullScreenButton.isHidden = true
        selectFirstAvailableTheme()
    }
    
    func viewModelDidRetrieveProductCommercialsWithError() {
        activityIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
        fullScreenButton.isHidden = true
        showAutoFadingOutMessageAlert(LGLocalizedString.commonErrorConnectionFailed) { [weak self] in
            self?.onCloseButton("")
        }
    }
}


extension PromoteProductViewController: VideoPlayerContainerViewDelegate {

    func playerDidSwitchPlaying(_ isPlaying: Bool) {
        guard !isPlaying && !viewModel.isFullscreen else { return }
        switchFullscreen()
    }

    func playerDidReceiveTap() {
        // when tapping video player only get into fullscreen, not out
        if !viewModel.isFullscreen { switchFullscreen() }
    }

    func playerDidFinishPlaying() {
        if viewModel.isFullscreen { switchFullscreen() }
        if fullScreen { playerDidPressFullscreen() }
    }

    func playerDidPressFullscreen() {
        let transform: CGAffineTransform
        if fullScreen {
            fullScreen = false
            transform = CGAffineTransform.identity
        } else {
            fullScreen = true
            transform = CGAffineTransform.commercializerVideoToFullScreenTransform(playerView.frame)
        }

        UIApplication.shared.setStatusBarHidden(fullScreen, with: .fade)
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.playerView.transform = transform
        }) 
    }
}
