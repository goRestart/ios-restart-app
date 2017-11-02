//
//  PostListingViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 11/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import RxSwift

class PostListingViewController: BaseViewController, PostListingViewModelDelegate {
    @IBOutlet weak var cameraGalleryContainer: UIView!
    
    @IBOutlet weak var otherStepsContainer: UIView!
    @IBOutlet weak var detailsScroll: UIScrollView!
    @IBOutlet weak var detailsContainer: UIView!
    @IBOutlet weak var detailsContainerBottomConstraint: NSLayoutConstraint!
    
    // contained in detailsContainer
    @IBOutlet weak var customLoadingView: LoadingIndicator!
    @IBOutlet weak var postedInfoLabel: UILabel!
    @IBOutlet weak var postErrorLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    
    fileprivate var closeButton: UIButton

    // contained in cameraGalleryContainer
    fileprivate var viewPager: LGViewPager
    fileprivate var cameraView: PostListingCameraView
    fileprivate var galleryView: PostListingGalleryView

    // contained in detailsContainer
    fileprivate let priceView: UIView
    fileprivate let categorySelectionView: PostCategorySelectionView
    fileprivate let carDetailsView: PostCarDetailsView
    
    fileprivate var footer: PostListingFooter
    fileprivate var footerView: UIView
    fileprivate let gradientLayer = CAGradientLayer.gradientWithColor(UIColor.black,
                                                                      alphas: [0, 0.6],
                                                                      locations: [0, 1])
    fileprivate let keyboardHelper: KeyboardHelper
    fileprivate var isLoading: Bool = false
    private var viewDidAppear: Bool = false

    fileprivate static let detailTopMarginPrice: CGFloat = 100

    private let forcedInitialTab: Tab?
    private var initialTab: Tab {
        if let forcedInitialTab = forcedInitialTab {
            return forcedInitialTab
        }
        return Tab(rawValue: KeyValueStorage.sharedInstance.userPostListingLastTabSelected) ?? .gallery
    }

    private let disposeBag = DisposeBag()

    // ViewModel
    fileprivate var viewModel: PostListingViewModel


    // MARK: - Lifecycle

    convenience init(viewModel: PostListingViewModel,
                     forcedInitialTab: Tab?) {
        self.init(viewModel: viewModel,
                  forcedInitialTab: forcedInitialTab,
                  keyboardHelper: KeyboardHelper())
    }

    required init(viewModel: PostListingViewModel,
                  forcedInitialTab: Tab?,
                  keyboardHelper: KeyboardHelper) {
        
        let tabPosition: LGViewPagerTabPosition
        tabPosition = .hidden
        let postFooter = PostListingRedCamButtonFooter()
        self.footer = postFooter
        self.footerView = postFooter
        self.closeButton = UIButton()
        
        let viewPagerConfig = LGViewPagerConfig(tabPosition: tabPosition, tabLayout: .fixed, tabHeight: 50)
        self.viewPager = LGViewPager(config: viewPagerConfig, frame: CGRect.zero)
        self.cameraView = PostListingCameraView(viewModel: viewModel.postListingCameraViewModel)
        self.galleryView = PostListingGalleryView()
        self.keyboardHelper = keyboardHelper
        self.viewModel = viewModel
        self.forcedInitialTab = forcedInitialTab
        
        self.priceView = PostListingDetailPriceView(viewModel: viewModel.postDetailViewModel)
        self.categorySelectionView = PostCategorySelectionView(realEstateEnabled: viewModel.realEstateEnabled)
        self.carDetailsView = PostCarDetailsView(shouldShowSummaryAfter: viewModel.shouldShowSummaryAfter,
                                                 initialValues: viewModel.carInfo(forDetail: .make).carInfoWrappers)
        super.init(viewModel: viewModel, nibName: "PostListingViewController",
                   statusBarStyle: UIApplication.shared.statusBarStyle)
        modalPresentationStyle = .overCurrentContext
        viewModel.delegate = self

        self.closeButton.addTarget(self, action: #selector(onCloseButton),
                                   for: .touchUpInside)
        self.closeButton.setImage(UIImage(named: "ic_post_close"), for: .normal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setAccesibilityIds()
        view.layoutIfNeeded()
        setupRx()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !viewDidAppear {
            viewPager.delegate = self
            viewPager.selectTabAtIndex(initialTab.index)
            footer.update(scroll: CGFloat(initialTab.index))
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarHidden(true)
        cameraView.active = true
        galleryView.active = true
    }
    
    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        navigationController?.setNavigationBarHidden(true, animated: false)
        if viewModel.state.value.isLoading {
            customLoadingView.startAnimating()
        }
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
        carDetailsView.hideKeyboard()
        priceView.resignFirstResponder()
        viewModel.closeButtonPressed()
    }

    dynamic func galleryButtonPressed() {
        guard viewPager.scrollEnabled else { return }
        viewPager.selectTabAtIndex(Tab.gallery.index, animated: true)
    }
    
    dynamic func galleryPostButtonPressed() {
        galleryView.postButtonPressed()
    }

    dynamic func cameraButtonPressed() {
        if viewPager.currentPage == Tab.camera.index {
            cameraView.takePhoto()
        } else {
            viewPager.selectTabAtIndex(Tab.camera.index, animated: true)
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
        galleryView.collectionViewBottomInset = Metrics.margin + PostListingRedCamButtonFooter.cameraIconSide
        
        detailsContainerBottomConstraint.constant = 0
        
        setupViewPager()
        setupCategorySelectionView()
        setupPriceView()
        setupAddCarDetailsView()
        setupCloseButton()
        setupFooter()
    }
    
    private func setupCloseButton() {
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        closeButton.layout(with: view).left(by: Metrics.margin).top(by: Metrics.margin)
    }

    private func setupPriceView() {
        retryButton.setTitle(LGLocalizedString.commonErrorListRetryButton, for: .normal)
        retryButton.setStyle(.primary(fontSize: .medium))
        priceView.translatesAutoresizingMaskIntoConstraints = false
        detailsContainer.addSubview(priceView)
        priceView.layout(with: postedInfoLabel).below(by: Metrics.margin)
        priceView.layout(with: detailsContainer).bottom()
        priceView.layout(with: detailsContainer).fillHorizontal(by: Metrics.screenWidth/10)
    }
    
    private func setupCategorySelectionView() {
        categorySelectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(categorySelectionView)
        categorySelectionView.layout(with: view).fill()
    }
    
    private func setupAddCarDetailsView() {
        carDetailsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(carDetailsView)
        carDetailsView.layout(with: view)
            .left()
            .right()
            .top()
            .bottom()
        
        carDetailsView.updateProgress(withPercentage: viewModel.currentCarDetailsProgress)
        
        carDetailsView.navigationBackButton.rx.tap.asObservable().subscribeNext { [weak self] _ in
            self?.carDetailsNavigationBackButtonPressed()
        }.addDisposableTo(disposeBag)
        carDetailsView.navigationMakeButton.rx.tap.asObservable().subscribeNext { [weak self] _ in
            self?.carMakeButtonPressed()
        }.addDisposableTo(disposeBag)
        carDetailsView.navigationModelButton.rx.tap.asObservable().subscribeNext { [weak self] _ in
            self?.carModelButtonPressed()
        }.addDisposableTo(disposeBag)
        carDetailsView.navigationYearButton.rx.tap.asObservable().subscribeNext { [weak self] _ in
            self?.carYearButtonPressed()
        }.addDisposableTo(disposeBag)
        carDetailsView.makeRowView.button.rx.tap.asObservable().subscribeNext { [weak self] _ in
            self?.carMakeButtonPressed()
        }.addDisposableTo(disposeBag)
        carDetailsView.modelRowView.button.rx.tap.asObservable().subscribeNext { [weak self] _ in
            self?.carModelButtonPressed()
        }.addDisposableTo(disposeBag)
        carDetailsView.yearRowView.button.rx.tap.asObservable().subscribeNext { [weak self] _ in
            self?.carYearButtonPressed()
        }.addDisposableTo(disposeBag)
        
        carDetailsView.doneButton.rx.tap.asObservable().subscribeNext { [weak self] _ in
            self?.carDetailsDoneButtonPressed()
        }.addDisposableTo(disposeBag)
        
        carDetailsView.tableView.selectedDetail.asObservable().bindTo(viewModel.selectedDetail)
            .addDisposableTo(disposeBag)
        viewModel.selectedDetail.asObservable().subscribeNext { [weak self] (categoryDetailSelectedInfo) in
            guard let strongSelf = self else { return }
            guard let categoryDetail = categoryDetailSelectedInfo else { return }
            switch categoryDetail.type {
            case .make:
                strongSelf.carDetailsView.updateMake(withMake: categoryDetail.name)
                strongSelf.carDetailsView.updateModel(withModel: nil)
                strongSelf.showCarModels()
            case .model:
                strongSelf.carDetailsView.updateModel(withModel: categoryDetail.name)
                strongSelf.showCarYears()
            case .year:
                strongSelf.carDetailsView.updateYear(withYear: categoryDetail.name)
                delay(0.3) { _ in // requested by designers
                    strongSelf.didFinishEnteringDetails()
                }
            }
            strongSelf.carDetailsView.updateProgress(withPercentage: strongSelf.viewModel.currentCarDetailsProgress)
        }.addDisposableTo(disposeBag)
    }
    
    private func setupFooter() {
        footerView.translatesAutoresizingMaskIntoConstraints = false
        cameraGalleryContainer.addSubview(footerView)
        footerView.layout(with: cameraGalleryContainer)
            .leading()
            .trailing()
            .bottom()
        
        footer.galleryButton.rx.tap.asObservable().subscribeNext { [weak self] _ in
            self?.galleryButtonPressed()
        }.addDisposableTo(disposeBag)
        cameraView.takePhotoEnabled.asObservable().bindTo(footer.cameraButton.rx.isEnabled).addDisposableTo(disposeBag)
        cameraView.takePhotoEnabled.asObservable().bindTo(footer.galleryButton.rx.isEnabled).addDisposableTo(disposeBag)
        footer.cameraButton.rx.tap.asObservable().subscribeNext { [weak self] _ in
            self?.cameraButtonPressed()
        }.addDisposableTo(disposeBag)
    }

    private func setupRx() {
        viewModel.state.asObservable().bindNext { [weak self] state in
            self?.update(state: state)
        }.addDisposableTo(disposeBag)

        categorySelectionView.selectedCategory.asObservable()
            .bindTo(viewModel.category)
            .addDisposableTo(disposeBag)
        
        keyboardHelper.rx_keyboardOrigin.asObservable().bindNext { [weak self] origin in
            guard origin > 0 else { return }
            guard let strongSelf = self else { return }
            let nextKeyboardHeight = strongSelf.view.height - origin
            strongSelf.detailsContainerBottomConstraint.constant = -nextKeyboardHeight/2
            if strongSelf.carDetailsView.state == .selectDetail {
                strongSelf.carDetailsView.moveContentUpward(by: -nextKeyboardHeight)
            }
            UIView.animate(withDuration: Double(strongSelf.keyboardHelper.animationTime), animations: {
                strongSelf.view.layoutIfNeeded()
            })
            let willShowKeyboard = nextKeyboardHeight > 0
            strongSelf.loadingViewHidden(showingKeyboard: willShowKeyboard)
        }.addDisposableTo(disposeBag)
    }

    private func loadingViewHidden(showingKeyboard: Bool) {
        guard !DeviceFamily.current.isWiderOrEqualThan(.iPhone6) else { return }
        guard !priceView.isHidden else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak self] () -> Void in
            guard let strongSelf = self else { return }
            strongSelf.customLoadingView.alpha = showingKeyboard ? 0.0 : strongSelf.viewModel.state.value.customLoadingViewAlpha
        })
    }
}

// MARK: - Car details

extension PostListingViewController {
    
    dynamic func carDetailsNavigationBackButtonPressed() {
        if let previousState = carDetailsView.previousState, previousState.isSummary {
            didFinishEnteringDetails()
        } else {
            if viewModel.shouldShowSummaryAfter {
                switch carDetailsView.state {
                    case .selectDetail, .selectDetailValue(forDetail: .make):
                    carDetailsView.hideKeyboard()
                    viewModel.revertToPreviousStep()
                    case .selectDetailValue(forDetail: .model):
                    showCarMakes()
                    case .selectDetailValue(forDetail: .year):
                    showCarModels()
                }
            } else {
                switch carDetailsView.state {
                case .selectDetail, .selectDetailValue(forDetail: .make):
                    didFinishEnteringDetails()
                case .selectDetailValue(forDetail: .model):
                    showCarMakes()
                case .selectDetailValue(forDetail: .year):
                    showCarModels()
                }
            }
        }
    }
    
    dynamic func carMakeButtonPressed() {
        showCarMakes()
    }
    
    dynamic func carModelButtonPressed() {
        showCarModels()
    }
    
    dynamic func carYearButtonPressed() {
        showCarYears()
    }
    
    dynamic func carDetailsDoneButtonPressed() {
        carDetailsView.hideKeyboard()
        viewModel.postCarDetailDone()
    }
    
    fileprivate func didFinishEnteringDetails() {
        carDetailsView.hideKeyboard()
        
        switch carDetailsView.state {
        case .selectDetail:
            viewModel.revertToPreviousStep()
        case .selectDetailValue:
            carDetailsView.showSelectDetail()
        }
    }
    
    fileprivate func showCarMakes() {
        let (values, selectedIndex) = viewModel.carInfo(forDetail: .make)
        showSelectCarDetailValue(forDetail: .make, values: values, selectedValueIndex: selectedIndex)
    }
    
    fileprivate func showCarModels() {
        let (values, selectedIndex) = viewModel.carInfo(forDetail: .model)
        showSelectCarDetailValue(forDetail: .model, values: values, selectedValueIndex: selectedIndex)
    }
    
    fileprivate func showCarYears() {
        let (values, selectedIndex) = viewModel.carInfo(forDetail: .year)
        showSelectCarDetailValue(forDetail: .year, values: values, selectedValueIndex: selectedIndex)
    }
    
    private func showSelectCarDetailValue(forDetail detail: CarDetailType, values: [CarInfoWrapper], selectedValueIndex: Int?) {
        carDetailsView.hideKeyboard()
        delay(0.3) { [weak self] in // requested by designers
            self?.carDetailsView.showSelectDetailValue(forDetail: detail, values: values, selectedValueIndex: selectedValueIndex)
        }
    }
}


// MARK: - State selection

fileprivate extension PostListingState {
    var closeButtonAlpha: CGFloat {
        switch step {
        case .carDetailsSelection:
            return 0
        case .imageSelection, .uploadingImage, .errorUpload, .detailsSelection, .categorySelection, .finished, .uploadSuccess, .addingDetails:
            return 1
        }
    }
    
    var isOtherStepsContainerAlpha: CGFloat {
        switch step {
        case .imageSelection:
            return 0
        case .uploadingImage, .errorUpload, .detailsSelection, .categorySelection, .carDetailsSelection, .finished, .uploadSuccess, .addingDetails:
            return 1
        }
    }
    
    var customLoadingViewAlpha: CGFloat {
        switch step {
        case .imageSelection, .categorySelection, .carDetailsSelection, .finished, .addingDetails:
            return 0
        case .uploadingImage, .errorUpload, .detailsSelection, .uploadSuccess:
            return 1
        }
    }
    
    var postedInfoLabelAlpha: CGFloat {
        switch step {
        case .imageSelection, .categorySelection, .uploadingImage, .errorUpload, .carDetailsSelection, .finished, .addingDetails:
            return 0
        case .detailsSelection, .uploadSuccess:
            return 1
        }
    }
    
    func postedInfoLabelText(confirmationText: String?) -> String? {
        return isError ? LGLocalizedString.commonErrorTitle.capitalized : confirmationText
    }
    
    var postErrorLabelAlpha: CGFloat {
        return isError ? 1 : 0
    }
    
    var postErrorLabelText: String? {
        switch step {
        case .imageSelection, .detailsSelection, .categorySelection, .uploadingImage, .carDetailsSelection, .finished, .uploadSuccess, .addingDetails:
            return nil
        case let .errorUpload(message):
            return message
        }
    }
    
    var retryButtonAlpha: CGFloat {
        return isError ? 1 : 0
    }
    
    var priceViewAlpha: CGFloat {
        switch step {
        case .imageSelection, .categorySelection, .carDetailsSelection, .uploadingImage, .errorUpload, .finished, .uploadSuccess, .addingDetails:
            return 0
        case .detailsSelection:
            return 1
        }
    }
    
    var categorySelectionViewAlpha: CGFloat {
        switch step {
        case .imageSelection, .carDetailsSelection, .uploadingImage, .errorUpload, .detailsSelection, .finished, .uploadSuccess, .addingDetails:
            return 0
        case .categorySelection:
            return 1
        }
    }
    
    var carDetailsViewAlpha: CGFloat {
        switch step {
        case .imageSelection, .categorySelection, .uploadingImage, .errorUpload, .detailsSelection, .finished, .uploadSuccess, .addingDetails:
            return 0
        case .carDetailsSelection:
            return 1
        }
    }
    
    func priceViewShouldBecomeFirstResponder() -> Bool {
        switch step {
        case .imageSelection, .categorySelection, .uploadingImage, .errorUpload, .carDetailsSelection, .finished, .uploadSuccess, .addingDetails:
            return false
        case .detailsSelection:
            return true
        }
    }
    
    func priceViewShouldResignFirstResponder() -> Bool {
        return isError
    }
    
    var isError: Bool {
        switch step {
        case .imageSelection, .detailsSelection, .categorySelection, .uploadingImage, .carDetailsSelection, .finished, .uploadSuccess, .addingDetails:
            return false
        case .errorUpload:
            return true
        }
    }
    
    var isLoading: Bool {
        switch step {
        case .imageSelection, .detailsSelection, .categorySelection, .errorUpload, .carDetailsSelection, .finished, .uploadSuccess, .addingDetails:
            return false
        case .uploadingImage:
            return true
        }
    }
}

extension PostListingViewController {
    fileprivate func update(state: PostListingState) {

        if let view = viewToAdjustDetailsScrollContentInset(state: state) {
            adjustDetailsScrollContentInset(to: view)
        }
        let updateVisibility: () -> () = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.closeButton.alpha = state.closeButtonAlpha
            strongSelf.otherStepsContainer.alpha = state.isOtherStepsContainerAlpha
            strongSelf.customLoadingView.alpha = state.customLoadingViewAlpha
            strongSelf.postedInfoLabel.alpha = state.postedInfoLabelAlpha
            strongSelf.postedInfoLabel.text = state.postedInfoLabelText(confirmationText: strongSelf.viewModel.confirmationOkText)
            strongSelf.postErrorLabel.alpha = state.postErrorLabelAlpha
            strongSelf.postErrorLabel.text = state.postErrorLabelText
            strongSelf.retryButton.alpha = state.retryButtonAlpha
            strongSelf.priceView.alpha = state.priceViewAlpha
            strongSelf.categorySelectionView.alpha = state.categorySelectionViewAlpha
            strongSelf.carDetailsView.alpha = state.carDetailsViewAlpha
        }
        
        if state.isLoading {
            UIView.animate(withDuration: 0.2,
                           delay: 0.8,
                           options: [],
                           animations: { () -> Void in
                                updateVisibility()
                           },
                           completion: { (_) -> Void in
                                updateVisibility()
                           })
            customLoadingView.startAnimating()
            isLoading = true
        } else if isLoading {
            customLoadingView.stopAnimating(!state.isError, completion: updateVisibility)
            isLoading = false
        } else {
            updateVisibility()
        }
        if state.priceViewShouldBecomeFirstResponder() {
            priceView.becomeFirstResponder()
            customLoadingView.stopAnimating(!state.isError, completion: nil)
        } else if state.priceViewShouldResignFirstResponder() {
            priceView.resignFirstResponder()
        }
    }
    
    private func viewToAdjustDetailsScrollContentInset(state: PostListingState) -> UIView? {
        switch state.step {
        case .detailsSelection:
            return customLoadingView
        case .categorySelection:
            return categorySelectionView
        case .carDetailsSelection:
            return carDetailsView
        case .imageSelection, .uploadingImage, .errorUpload, .finished, .uploadSuccess, .addingDetails:
            return nil
        }
    }
    
    private func adjustDetailsScrollContentInset(to view: UIView) {
        detailsScroll.contentInset.top = (view.height / 3)
    }
}


// MARK: - PostListingCameraViewDelegate

extension PostListingViewController: PostListingCameraViewDelegate {
    func productCameraCloseButton() {
        onCloseButton(cameraView)
    }

    func productCameraDidTakeImage(_ image: UIImage) {
        if let navigationController = navigationController as? SellNavigationController {
            navigationController.updateBackground(image: cameraGalleryContainer.takeSnapshot())
        }
        viewModel.imagesSelected([image], source: .camera)
    }

    func productCameraRequestHideTabs(_ hide: Bool) {
        footer.isHidden = hide
    }

    func productCameraRequestsScrollLock(_ lock: Bool) {
        viewPager.scrollEnabled = !lock
    }
}


// MARK: - PostListingGalleryViewDelegate

extension PostListingViewController: PostListingGalleryViewDelegate {
    func listingGalleryCloseButton() {
        onCloseButton(galleryView)
    }

    func listingGalleryDidSelectImages(_ images: [UIImage]) {
        if let navigationController = navigationController as? SellNavigationController {
            navigationController.updateBackground(image: cameraGalleryContainer.takeSnapshot())
        }
        viewModel.imagesSelected(images, source: .gallery)
    }

    func listingGalleryRequestsScrollLock(_ lock: Bool) {
        viewPager.scrollEnabled = !lock
    }

    func listingGalleryDidPressTakePhoto() {
        viewPager.selectTabAtIndex(Tab.camera.index)
    }

    func listingGalleryShowActionSheet(_ cancelAction: UIAction, actions: [UIAction]) {
        showActionSheet(cancelAction, actions: actions, sourceView: galleryView.albumButton,
                        sourceRect: galleryView.albumButton.frame, completion: nil)
    }

    func listingGallerySelection(selection: ImageSelection) {
        footer.cameraButton.isHidden = false
    }
    
    func listingGallerySwitchToCamera() {
        viewPager.selectTabAtIndex(Tab.camera.index, animated: true)
    }
}


// MARK: - LGViewPager

extension PostListingViewController: LGViewPagerDataSource, LGViewPagerDelegate, LGViewPagerScrollDelegate {
    func setupViewPager() {
        viewPager.dataSource = self
        viewPager.scrollDelegate = self
        viewPager.indicatorSelectedColor = UIColor.white
        viewPager.tabsBackgroundColor = UIColor.clear
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
        KeyValueStorage.sharedInstance.userPostListingLastTabSelected = index
    }

    func viewPager(_ viewPager: LGViewPager, didEndDisplayingView view: UIView, atIndex index: Int) {}

    func viewPager(_ viewPager: LGViewPager, didScrollToPagePosition pagePosition: CGFloat) {
        cameraView.showHeader(pagePosition == 1.0)
        galleryView.showHeader(pagePosition == 0.0)

        footer.update(scroll: pagePosition)
    }

    func viewPagerNumberOfTabs(_ viewPager: LGViewPager) -> Int {
        return Tab.allValues.count
    }

    func viewPager(_ viewPager: LGViewPager, viewForTabAtIndex index: Int) -> UIView {
        if index == Tab.gallery.index {
            return galleryView
        } else {
            return cameraView
        }
    }

    func viewPager(_ viewPager: LGViewPager, showInfoBadgeAtIndex index: Int) -> Bool {
        return false
    }

    func viewPager(_ viewPager: LGViewPager, titleForUnselectedTabAtIndex index: Int) -> NSAttributedString {
        return titleForTabAt(index: index)
    }

    func viewPager(_ viewPager: LGViewPager, titleForSelectedTabAtIndex index: Int) -> NSAttributedString {
        return titleForTabAt(index: index)
    }
    
    func viewPager(_ viewPager: LGViewPager, accessibilityIdentifierAtIndex index: Int) -> AccessibilityId? {
        return nil
    }

    private func titleForTabAt(index: Int) -> NSAttributedString {
        let text: String
        let icon: UIImage?
        let attributes = tabTitleTextAttributes()
        if index == Tab.gallery.index {
            icon = #imageLiteral(resourceName: "ic_post_tab_gallery")
            text = LGLocalizedString.productPostGalleryTab
        } else {
            icon = #imageLiteral(resourceName: "ic_post_tab_camera")
            text = LGLocalizedString.productPostCameraTabV2
        }
        let attachment = NSTextAttachment()
        attachment.image = icon
        attachment.bounds = CGRect(x: 0, y: UIFont.activeTabFont.descender + 1,
                                   width: icon?.size.width ?? 0,
                                   height: icon?.size.height ?? 0)
        let title = NSMutableAttributedString()
        title.append(NSAttributedString(attachment: attachment))
        title.append(NSAttributedString(string: "  "))
        title.append(NSMutableAttributedString(string: text, attributes: attributes))
        return title
    }
    
    private func tabTitleTextAttributes()-> [String : Any] {
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.black.withAlphaComponent(0.5)
        shadow.shadowBlurRadius = 2
        shadow.shadowOffset = CGSize(width: 0, height: 0)
        
        var titleAttributes = [String : Any]()
        titleAttributes[NSShadowAttributeName] = shadow
        titleAttributes[NSForegroundColorAttributeName] = UIColor.white
        titleAttributes[NSFontAttributeName] = UIFont.activeTabFont
        return titleAttributes
    }
}


// MARK: - Accesibility

extension PostListingViewController {
    func setAccesibilityIds() {
        closeButton.accessibilityId = .postingCloseButton
        customLoadingView.accessibilityId = .postingLoading
        retryButton.accessibilityId = .postingRetryButton
    }
}


// MARK: - Tab

extension PostListingViewController {
    enum Tab: Int {
        case gallery, camera
        
        static var allValues: [Tab] = [.gallery, .camera]
        
        var index: Int {
            return rawValue
        }
    }
}
