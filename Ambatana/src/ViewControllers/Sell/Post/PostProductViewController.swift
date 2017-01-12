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
    fileprivate var productDetailView: UIView

    fileprivate var viewPager: LGViewPager
    fileprivate var cameraView: PostProductCameraView
    fileprivate var galleryView: PostProductGalleryView
    fileprivate let keyboardHelper: KeyboardHelper
    private var viewDidAppear: Bool = false

    fileprivate static let detailTopMarginPrice: CGFloat = 100
    fileprivate let rightMarginCameraIcon:CGFloat = 15.0

    private let forceCamera: Bool
    private var initialTab: Int {
        if forceCamera { return 1 }
        return KeyValueStorage.sharedInstance.userPostProductLastTabSelected
    }

    private let disposeBag = DisposeBag()


    // ViewModel
    fileprivate var viewModel: PostProductViewModel


    // MARK: - Lifecycle

    convenience init(viewModel: PostProductViewModel, forceCamera: Bool) {
        self.init(viewModel: viewModel, forceCamera: forceCamera, keyboardHelper: KeyboardHelper.sharedInstance)
    }

    required init(viewModel: PostProductViewModel, forceCamera: Bool, keyboardHelper: KeyboardHelper) {
        let viewPagerConfig = LGViewPagerConfig(tabPosition: .hidden, tabLayout: .fixed, tabHeight: 54)
        self.viewPager = LGViewPager(config: viewPagerConfig, frame: CGRect.zero)
        self.cameraView = PostProductCameraView(viewModel: viewModel.postProductCameraViewModel)
        self.galleryView = PostProductGalleryView(multiSelectionEnabled: viewModel.galleryMultiSelectionEnabled)
        self.keyboardHelper = keyboardHelper
        self.viewModel = viewModel
        self.forceCamera = forceCamera
        self.productDetailView = PostProductDetailPriceView(viewModel: viewModel.postDetailViewModel)
        super.init(viewModel: viewModel, nibName: "PostProductViewController",
                   statusBarStyle: UIApplication.shared.statusBarStyle)
        modalPresentationStyle = .overCurrentContext
        self.viewModel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarHidden(true)
        cameraView.active = true
        galleryView.active = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppear = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setStatusBarHidden(false)
        galleryView.active = false
        cameraView.active = false
    }


    // MARK: - Actions
    
    @IBAction func onCloseButton(_ sender: AnyObject) {
        productDetailView.resignFirstResponder()
        viewModel.closeButtonPressed()
    }

    @IBAction func galleryButtonPressed(_ sender: AnyObject) {
        guard viewPager.scrollEnabled else { return }
        viewPager.selectTabAtIndex(0, animated: true)
    }

    @IBAction func photoButtonPressed(_ sender: AnyObject) {
        if viewPager.currentPage == 1 {
            cameraView.takePhoto()
        } else {
            viewPager.selectTabAtIndex(1, animated: true)
        }
    }

    @IBAction func onRetryButton(_ sender: AnyObject) {
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
        retryButton.setTitle(LGLocalizedString.commonErrorListRetryButton, for: UIControlState())
        retryButton.setStyle(.primary(fontSize: .medium))

        productDetailView.translatesAutoresizingMaskIntoConstraints = false
        detailsContainer.addSubview(productDetailView)
        productDetailView.alpha = 0

        let top = NSLayoutConstraint(item: productDetailView, attribute: .top, relatedBy: .equal,
                                     toItem: postedInfoLabel, attribute: .bottom, multiplier: 1.0, constant: 15)
        let left = NSLayoutConstraint(item: productDetailView, attribute: .left, relatedBy: .equal,
                                      toItem: detailsContainer, attribute: .left, multiplier: 1.0, constant: 0)
        let right = NSLayoutConstraint(item: productDetailView, attribute: .right, relatedBy: .equal,
                                       toItem: detailsContainer, attribute: .right, multiplier: 1.0, constant: 0)
        let bottom = NSLayoutConstraint(item: productDetailView, attribute: .bottom, relatedBy: .equal,
                                        toItem: detailsContainer, attribute: .bottom, multiplier: 1.0, constant: 0)
        detailsContainer.addConstraints([top, left, right, bottom])
    }

    private func setupRx() {
        viewModel.state.asObservable().bindNext { [weak self] state in
            switch state {
            case .imageSelection:
                self?.setSelectImageState()
            case .uploadingImage:
                self?.setSelectPriceState(loading: true, error: nil)
            case .errorUpload(let message):
                self?.setSelectPriceState(loading: false, error: message)
            case .detailsSelection:
               self?.setSelectPriceState(loading: false, error: nil)
            }
        }.addDisposableTo(disposeBag)

        keyboardHelper.rx_keyboardOrigin.asObservable().bindNext { [weak self] origin in
            guard origin > 0 else { return }
            guard let scrollView = self?.detailsScroll, let viewHeight = self?.view.height,
            let detailsRect = self?.productDetailView.frame else { return }
            scrollView.contentInset.bottom = viewHeight - origin
            let showingKeyboard = (viewHeight - origin) > 0
            self?.loadingViewHidden(hide: showingKeyboard)
            scrollView.scrollRectToVisible(detailsRect, animated: false)
            
        }.addDisposableTo(disposeBag)
    }

    fileprivate func updateButtonsForPagerScroll(_ scroll: CGFloat) {
        galleryButton.alpha = scroll
        let rightOffset = photoButton.frame.width/2 + rightMarginCameraIcon
        let movement = view.width/2 - rightOffset
        photoButtonCenterX.constant = movement * (1.0 - scroll)
    }
    
    private func loadingViewHidden(hide: Bool) {
        guard !DeviceFamily.current.isWiderOrEqualThan(.iPhone6) else { return }
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.customLoadingView.alpha = hide ? 0.0 : 1.0
        })
    }
}


// MARK: - State selection

extension PostProductViewController {
    fileprivate func setSelectImageState() {
        selectPriceContainer.isHidden = true
    }

    fileprivate func setSelectPriceState(loading: Bool, error: String?) {
        detailsScroll.contentInset.top = (view.height / 3) - customLoadingView.height

        selectPriceContainer.isHidden = false
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

    fileprivate func setSelectPriceItems(_ loading: Bool, error: String?) {

        postedInfoLabel.alpha = 0
        postedInfoLabel.text = error != nil ?
            LGLocalizedString.commonErrorTitle.capitalized : viewModel.confirmationOkText
        postErrorLabel.text = error

        if (loading) {
            setSelectPriceBottomItems(loading, error: error)
        } else {
            UIView.animate(withDuration: 0.2,
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

    fileprivate func setSelectPriceBottomItems(_ loading: Bool, error: String?) {
        productDetailView.alpha = 0
        postErrorLabel.alpha = 0
        retryButton.alpha = 0

        guard !loading else { return }

        let okItemsAlpha: CGFloat = error != nil ? 0 : 1
        let wrongItemsAlpha: CGFloat = error == nil ? 0 : 1
        let loadingItemAlpha: CGFloat = 1
        let finalAlphaBlock = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.productDetailView.alpha = okItemsAlpha
            strongSelf.postErrorLabel.alpha = wrongItemsAlpha
            strongSelf.retryButton.alpha = wrongItemsAlpha
            strongSelf.customLoadingView.alpha = loadingItemAlpha
            strongSelf.postedInfoLabel.alpha = loadingItemAlpha
            strongSelf.detailsScroll.contentInset.top = PostProductViewController.detailTopMarginPrice
        }
        UIView.animate(withDuration: 0.2, delay: 0.8, options: UIViewAnimationOptions(),
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
}


// MARK: - PostProductViewModelDelegate

extension PostProductViewController: PostProductViewModelDelegate {
    func postProductviewModel(_ viewModel: PostProductViewModel, shouldAskLoginWithCompletion completion: @escaping () -> Void) {
        ifLoggedInThen(.sell, loginStyle: .popup(LGLocalizedString.productPostLoginMessage),
                       preDismissAction: { [weak self] in
                        self?.view.isHidden = true
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

    func productCameraDidTakeImage(_ image: UIImage) {
        viewModel.imagesSelected([image], source: .camera)
    }

    func productCameraRequestHideTabs(_ hide: Bool) {
        galleryButton.isHidden = hide
        photoButton.isHidden = hide
    }

    func productCameraRequestsScrollLock(_ lock: Bool) {
        viewPager.scrollEnabled = !lock
    }
}


// MARK: - PostProductGalleryViewDelegate

extension PostProductViewController: PostProductGalleryViewDelegate {
    func productGalleryCloseButton() {
        onCloseButton(galleryView)
    }

    func productGalleryDidSelectImages(_ images: [UIImage]) {
        viewModel.imagesSelected(images, source: .gallery)
    }

    func productGalleryRequestsScrollLock(_ lock: Bool) {
        viewPager.scrollEnabled = !lock
    }

    func productGalleryDidPressTakePhoto() {
        viewPager.selectTabAtIndex(1)
    }

    func productGalleryShowActionSheet(_ cancelAction: UIAction, actions: [UIAction]) {
        showActionSheet(cancelAction, actions: actions, sourceView: galleryView.albumButton,
                        sourceRect: galleryView.albumButton.frame, completion: nil)
    }

    func productGallerySelectionFull(_ selectionFull: Bool) {
        photoButton.isHidden = selectionFull
    }
}


// MARK: - LGViewPager

extension PostProductViewController: LGViewPagerDataSource, LGViewPagerDelegate, LGViewPagerScrollDelegate {

    func setupViewPager() {
        viewPager.dataSource = self
        viewPager.scrollDelegate = self
        viewPager.indicatorSelectedColor = UIColor.primaryColor
        viewPager.tabsBackgroundColor = UIColor.black
        viewPager.tabsSeparatorColor = UIColor.clear
        viewPager.translatesAutoresizingMaskIntoConstraints = false
        cameraGalleryContainer.insertSubview(viewPager, at: 0)
        setupViewPagerConstraints()

        viewPager.reloadData()
    }

    private func setupViewPagerConstraints() {
        let views = ["viewPager": viewPager]
        cameraGalleryContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[viewPager]|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        cameraGalleryContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[viewPager]|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
    }

    func viewPager(_ viewPager: LGViewPager, willDisplayView view: UIView, atIndex index: Int) {
        KeyValueStorage.sharedInstance.userPostProductLastTabSelected = index
    }

    func viewPager(_ viewPager: LGViewPager, didEndDisplayingView view: UIView, atIndex index: Int) {}

    func viewPager(_ viewPager: LGViewPager, didScrollToPagePosition pagePosition: CGFloat) {
        cameraView.showHeader(pagePosition == 1.0)
        galleryView.showHeader(pagePosition == 0.0)

        updateButtonsForPagerScroll(pagePosition)
    }

    func viewPagerNumberOfTabs(_ viewPager: LGViewPager) -> Int {
        return 2
    }

    func viewPager(_ viewPager: LGViewPager, viewForTabAtIndex index: Int) -> UIView {
        if index == 0 {
            return galleryView
        }
        else {
            return cameraView
        }
    }

    func viewPager(_ viewPager: LGViewPager, showInfoBadgeAtIndex index: Int) -> Bool {
        return false
    }

    func viewPager(_ viewPager: LGViewPager, titleForUnselectedTabAtIndex index: Int) -> NSAttributedString {
        if index == 0 {
            return NSAttributedString(string: LGLocalizedString.productPostGalleryTab, attributes: tabTextAttributes(false))
        } else {
            return NSAttributedString(string: LGLocalizedString.productPostCameraTab, attributes: tabTextAttributes(false))
        }
    }

    func viewPager(_ viewPager: LGViewPager, titleForSelectedTabAtIndex index: Int) -> NSAttributedString {
        if index == 0 {
            return NSAttributedString(string: LGLocalizedString.productPostGalleryTab, attributes: tabTextAttributes(true))
        } else {
            return NSAttributedString(string: LGLocalizedString.productPostCameraTab, attributes: tabTextAttributes(true))
        }
    }
    
    func viewPager(_ viewPager: LGViewPager, accessibilityIdentifierAtIndex index: Int) -> AccessibilityId? { return nil }

    private func tabTextAttributes(_ selected: Bool)-> [String : Any] {
        var titleAttributes = [String : Any]()
        titleAttributes[NSForegroundColorAttributeName] = selected ? UIColor.primaryColor : UIColor.white
        titleAttributes[NSFontAttributeName] = selected ? UIFont.activeTabFont : UIFont.inactiveTabFont
        return titleAttributes
    }
}


// MARK: - Accesibility

extension PostProductViewController {
    func setAccesibilityIds() {
        closeButton.accessibilityId = .postingCloseButton
        galleryButton.accessibilityId = .postingGalleryButton
        photoButton.accessibilityId = .postingPhotoButton
        customLoadingView.accessibilityId = .postingLoading
        retryButton.accessibilityId = .postingRetryButton
    }
}
