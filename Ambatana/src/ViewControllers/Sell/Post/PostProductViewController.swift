//
//  PostProductViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 11/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import FastttCamera
import RxSwift

class PostProductViewController: BaseViewController {

    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var cameraGalleryContainer: UIView!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var photoButtonCenterX: NSLayoutConstraint!

    @IBOutlet weak var selectPriceContainer: UIView!
    @IBOutlet weak var customLoadingView: LoadingIndicator!
    @IBOutlet weak var postedInfoLabel: UILabel!
    @IBOutlet weak var detailsScroll: UIScrollView!
    @IBOutlet weak var detailsContainer: UIView!
    @IBOutlet weak var postErrorLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    private var productDetailView: UIView

    private var viewPager: LGViewPager
    private var cameraView: PostProductCameraView
    private var galleryView: PostProductGalleryView
    private let keyboardHelper: KeyboardHelper
    private var viewDidAppear: Bool = false

    private static let detailTopMarginPrice: CGFloat = 100

    private let forceCamera: Bool
    private var initialTab: Int {
        if forceCamera { return 1 }
        return KeyValueStorage.sharedInstance.userPostProductLastTabSelected
    }

    private let disposeBag = DisposeBag()


    // ViewModel
    private var viewModel: PostProductViewModel


    // MARK: - Lifecycle

    convenience init(forceCamera: Bool) {
        self.init(viewModel: PostProductViewModel(source: .SellButton), forceCamera: forceCamera)
    }

    convenience init(viewModel: PostProductViewModel, forceCamera: Bool) {
        self.init(viewModel: viewModel, forceCamera: forceCamera, keyboardHelper: KeyboardHelper.sharedInstance)
    }

    required init(viewModel: PostProductViewModel, forceCamera: Bool, keyboardHelper: KeyboardHelper) {
        let viewPagerConfig = LGViewPagerConfig(tabPosition: .Hidden, tabLayout: .Fixed, tabHeight: 54)
        self.viewPager = LGViewPager(config: viewPagerConfig, frame: CGRect.zero)
        self.cameraView = PostProductCameraView()
        self.galleryView = PostProductGalleryView()
        self.keyboardHelper = keyboardHelper
        self.viewModel = viewModel
        self.forceCamera = forceCamera
        switch FeatureFlags.postingDetailsMode {
        case .Old:
            self.productDetailView = PostProductDetailPriceView(viewModel: viewModel.postDetailViewModel)
        case .Steps:
            self.productDetailView = PostProductDetailStepsView(viewModel: viewModel.postDetailViewModel)
        case .AllInOne:
            self.productDetailView = PostProductDetailFullView(viewModel: viewModel.postDetailViewModel)
        }
        super.init(viewModel: viewModel, nibName: "PostProductViewController",
                   statusBarStyle: UIApplication.sharedApplication().statusBarStyle)
        modalPresentationStyle = .OverCurrentContext
        self.viewModel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.onViewLoaded()
        setupView()
        setAccesibilityIds()
        setupRx()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !viewDidAppear {
            viewPager.delegate = self
            viewPager.selectTabAtIndex(initialTab)
            updateButtonsForPagerScroll(CGFloat(initialTab))
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarHidden(true)
        cameraView.active = true
        galleryView.active = true
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppear = true
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        setStatusBarHidden(false)
        galleryView.active = false
        cameraView.active = false
    }


    // MARK: - Actions
    
    @IBAction func onCloseButton(sender: AnyObject) {
        productDetailView.resignFirstResponder()
        viewModel.closeButtonPressed()
    }

    @IBAction func galleryButtonPressed(sender: AnyObject) {
        guard viewPager.scrollEnabled else { return }
        viewPager.selectTabAtIndex(0, animated: true)
    }

    @IBAction func photoButtonPressed(sender: AnyObject) {
        if viewPager.currentPage == 1 {
            cameraView.takePhoto()
        } else {
            viewPager.selectTabAtIndex(1, animated: true)
        }
    }

    @IBAction func onRetryButton(sender: AnyObject) {
        viewModel.retryButtonPressed()
    }


    // MARK: - Private methods

    private func setupView() {
        
        cameraView.delegate = self
        cameraView.usePhotoButtonText = viewModel.usePhotoButtonText

        galleryView.delegate = self
        galleryView.usePhotoButtonText = viewModel.usePhotoButtonText

        setupViewPager()

        setupDetailView()

        setSelectImageState()
    }

    private func setupDetailView() {
        retryButton.setTitle(LGLocalizedString.commonErrorListRetryButton, forState: UIControlState.Normal)
        retryButton.setStyle(.Primary(fontSize: .Medium))

        productDetailView.translatesAutoresizingMaskIntoConstraints = false
        detailsContainer.addSubview(productDetailView)
        productDetailView.alpha = 0

        let top = NSLayoutConstraint(item: productDetailView, attribute: .Top, relatedBy: .Equal,
                                     toItem: postedInfoLabel, attribute: .Bottom, multiplier: 1.0, constant: 15)
        let left = NSLayoutConstraint(item: productDetailView, attribute: .Left, relatedBy: .Equal,
                                      toItem: detailsContainer, attribute: .Left, multiplier: 1.0, constant: 0)
        let right = NSLayoutConstraint(item: productDetailView, attribute: .Right, relatedBy: .Equal,
                                       toItem: detailsContainer, attribute: .Right, multiplier: 1.0, constant: 0)
        let bottom = NSLayoutConstraint(item: productDetailView, attribute: .Bottom, relatedBy: .Equal,
                                        toItem: detailsContainer, attribute: .Bottom, multiplier: 1.0, constant: 0)
        detailsContainer.addConstraints([top, left, right, bottom])
    }

    private func setupRx() {
        viewModel.state.asObservable().bindNext { [weak self] state in
            switch state {
            case .ImageSelection:
                self?.setSelectImageState()
            case .UploadingImage:
                self?.setSelectPriceState(loading: true, error: nil)
            case .ErrorUpload(let message):
                self?.setSelectPriceState(loading: false, error: message)
            case .DetailsSelection:
                self?.setSelectPriceState(loading: false, error: nil)
            }
        }.addDisposableTo(disposeBag)

        keyboardHelper.rx_keyboardOrigin.asObservable().bindNext { [weak self] origin in
            guard origin > 0 else { return }
            guard let scrollView = self?.detailsScroll, viewHeight = self?.view.height,
            let detailsRect = self?.productDetailView.frame else { return }
            scrollView.contentInset.bottom = viewHeight - origin
            scrollView.scrollRectToVisible(detailsRect, animated: false)
        }.addDisposableTo(disposeBag)
    }

    private func updateButtonsForPagerScroll(scroll: CGFloat) {
        galleryButton.alpha = scroll

        let movement = (view.width/2) * (1.0 - scroll)
        photoButtonCenterX.constant = movement
    }
}


// MARK: - State selection

extension PostProductViewController {
    private func setSelectImageState() {
        selectPriceContainer.hidden = true
    }

    private func setSelectPriceState(loading loading: Bool, error: String?) {
        detailsScroll.contentInset.top = (view.height / 3) - customLoadingView.height

        selectPriceContainer.hidden = false
        let hasError = error != nil

        if(loading) {
            customLoadingView.startAnimating()
            setSelectPriceItems(loading, error: error)
        }
        else {
            customLoadingView.stopAnimating(!hasError) { [weak self] in
                self?.setSelectPriceItems(loading, error: error)
            }
        }
    }

    private func setSelectPriceItems(loading: Bool, error: String?) {

        postedInfoLabel.alpha = 0
        postedInfoLabel.text = error != nil ?
            LGLocalizedString.commonErrorTitle.capitalizedString : viewModel.confirmationOkText
        postErrorLabel.text = error

        if (loading) {
            setSelectPriceBottomItems(loading, error: error)
        } else {
            UIView.animateWithDuration(0.2,
                                       animations: { [weak self] in
                                        self?.postedInfoLabel.alpha = 1
                },
                                       completion: { [weak self] completed in
                                        self?.postedInfoLabel.alpha = 1
                                        self?.setSelectPriceBottomItems(loading, error: error)
                }
            )
        }
    }

    private func setSelectPriceBottomItems(loading: Bool, error: String?) {
        productDetailView.alpha = 0
        postErrorLabel.alpha = 0
        retryButton.alpha = 0

        guard !loading else { return }

        let okItemsAlpha: CGFloat = error != nil ? 0 : 1
        let wrongItemsAlpha: CGFloat = error == nil ? 0 : 1
        let loadingItemAlpha: CGFloat = error == nil ? PostProductViewController.detailsLoadingOkAlpha : 1
        let finalAlphaBlock = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.productDetailView.alpha = okItemsAlpha
            strongSelf.postErrorLabel.alpha = wrongItemsAlpha
            strongSelf.retryButton.alpha = wrongItemsAlpha
            strongSelf.customLoadingView.alpha = loadingItemAlpha
            strongSelf.postedInfoLabel.alpha = loadingItemAlpha
            strongSelf.detailsScroll.contentInset.top = PostProductViewController.detailsContentTopInset
        }
        UIView.animateWithDuration(0.2, delay: 0.8, options: UIViewAnimationOptions(),
                                   animations: { () -> Void in
                                    finalAlphaBlock()
            }, completion: { [weak self] (completed: Bool) -> Void in
                finalAlphaBlock()

                if okItemsAlpha == 1 {
                    self?.productDetailView.becomeFirstResponder()
                } else {
                    self?.productDetailView.resignFirstResponder()
                }
            }
        )
    }

    private static var detailsLoadingOkAlpha: CGFloat {
        switch FeatureFlags.postingDetailsMode {
        case .AllInOne:
            return 0
        case .Steps, .Old:
            return 1
        }
    }

    private static var detailsContentTopInset: CGFloat {
        switch FeatureFlags.postingDetailsMode {
        case .Old:
            return detailTopMarginPrice
        case .Steps, .AllInOne:
            return 0
        }
    }
}


// MARK: - PostProductViewModelDelegate

extension PostProductViewController: PostProductViewModelDelegate {
    func postProductviewModel(viewModel: PostProductViewModel, shouldAskLoginWithCompletion completion: () -> Void) {
        ifLoggedInThen(.Sell, loginStyle: .Popup(LGLocalizedString.productPostLoginMessage),
                       preDismissAction: { [weak self] in
                        self?.view.hidden = true
            },
                       loggedInAction: completion,
                       elsePresentSignUpWithSuccessAction: completion)
    }
}


// MARK: - PostProductCameraViewDelegate

extension PostProductViewController: PostProductCameraViewDelegate {
    func productCameraCloseButton() {
        onCloseButton(cameraView)
    }

    func productCameraDidTakeImage(image: UIImage) {
        viewModel.imageSelected(image, source: .Camera)
    }

    func productCameraRequestHideTabs(hide: Bool) {
        galleryButton.hidden = hide
        photoButton.hidden = hide
    }

    func productCameraRequestsScrollLock(lock: Bool) {
        viewPager.scrollEnabled = !lock
    }
}


// MARK: - PostProductGalleryViewDelegate

extension PostProductViewController: PostProductGalleryViewDelegate {
    func productGalleryCloseButton() {
        onCloseButton(galleryView)
    }

    func productGalleryDidSelectImage(image: UIImage) {
        viewModel.imageSelected(image, source: .Gallery)
    }

    func productGalleryRequestsScrollLock(lock: Bool) {
        viewPager.scrollEnabled = !lock
    }

    func productGalleryDidPressTakePhoto() {
        viewPager.selectTabAtIndex(1)
    }

    func productGalleryShowActionSheet(cancelAction: UIAction, actions: [UIAction]) {
        showActionSheet(cancelAction, actions: actions, sourceView: galleryView.albumButton,
                        sourceRect: galleryView.albumButton.frame, completion: nil)
    }
}


// MARK: - LGViewPager

extension PostProductViewController: LGViewPagerDataSource, LGViewPagerDelegate, LGViewPagerScrollDelegate {

    func setupViewPager() {
        viewPager.dataSource = self
        viewPager.scrollDelegate = self
        viewPager.indicatorSelectedColor = UIColor.primaryColor
        viewPager.tabsBackgroundColor = UIColor.black
        viewPager.tabsSeparatorColor = UIColor.clearColor()
        viewPager.translatesAutoresizingMaskIntoConstraints = false
        cameraGalleryContainer.insertSubview(viewPager, atIndex: 0)
        setupViewPagerConstraints()

        viewPager.reloadData()
    }

    private func setupViewPagerConstraints() {
        let views = ["viewPager": viewPager]
        cameraGalleryContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[viewPager]|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        cameraGalleryContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[viewPager]|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
    }

    func viewPager(viewPager: LGViewPager, willDisplayView view: UIView, atIndex index: Int) {
        KeyValueStorage.sharedInstance.userPostProductLastTabSelected = index
    }

    func viewPager(viewPager: LGViewPager, didEndDisplayingView view: UIView, atIndex index: Int) {}

    func viewPager(viewPager: LGViewPager, didScrollToPagePosition pagePosition: CGFloat) {
        cameraView.showHeader(pagePosition == 1.0)
        galleryView.showHeader(pagePosition == 0.0)

        updateButtonsForPagerScroll(pagePosition)
    }

    func viewPagerNumberOfTabs(viewPager: LGViewPager) -> Int {
        return 2
    }

    func viewPager(viewPager: LGViewPager, viewForTabAtIndex index: Int) -> UIView {
        if index == 0 {
            return galleryView
        }
        else {
            return cameraView
        }
    }

    func viewPager(viewPager: LGViewPager, showInfoBadgeAtIndex index: Int) -> Bool {
        return false
    }

    func viewPager(viewPager: LGViewPager, titleForUnselectedTabAtIndex index: Int) -> NSAttributedString {
        if index == 0 {
            return NSAttributedString(string: LGLocalizedString.productPostGalleryTab, attributes: tabTextAttributes(false))
        } else {
            return NSAttributedString(string: LGLocalizedString.productPostCameraTab, attributes: tabTextAttributes(false))
        }
    }

    func viewPager(viewPager: LGViewPager, titleForSelectedTabAtIndex index: Int) -> NSAttributedString {
        if index == 0 {
            return NSAttributedString(string: LGLocalizedString.productPostGalleryTab, attributes: tabTextAttributes(true))
        } else {
            return NSAttributedString(string: LGLocalizedString.productPostCameraTab, attributes: tabTextAttributes(true))
        }
    }
    
    func viewPager(viewPager: LGViewPager, accessibilityIdentifierAtIndex index: Int) -> AccessibilityId? { return nil }

    private func tabTextAttributes(selected: Bool)-> [String : AnyObject] {
        var titleAttributes = [String : AnyObject]()
        titleAttributes[NSForegroundColorAttributeName] = selected ? UIColor.primaryColor : UIColor.white
        titleAttributes[NSFontAttributeName] = selected ? UIFont.activeTabFont : UIFont.inactiveTabFont
        return titleAttributes
    }
}


// MARK: - Accesibility

extension PostProductViewController {
    func setAccesibilityIds() {
        closeButton.accessibilityId = .PostingCloseButton
        galleryButton.accessibilityId = .PostingGalleryButton
        photoButton.accessibilityId = .PostingPhotoButton
        customLoadingView.accessibilityId = .PostingLoading
        retryButton.accessibilityId = .PostingRetryButton
    }
}
