import UIKit
import RxSwift
import LGComponents

final class PostListingViewController: BaseViewController, PostListingViewModelDelegate {

    private static let retryButtonHeight: CGFloat = 50
    private static let retryButtonWidth: CGFloat = 100
    private static let loadingViewHeight: CGFloat = 100
    private static let loadingViewWidth: CGFloat = 100
    
    @IBOutlet weak var cameraGalleryContainer: UIView!
    
    @IBOutlet weak var otherStepsContainer: UIView!
    @IBOutlet weak var detailsScroll: UIScrollView!
    @IBOutlet weak var detailsContainer: UIView!
    @IBOutlet weak var detailsContainerBottomConstraint: NSLayoutConstraint!
    
    // contained in detailsContainer
    @IBOutlet weak var customLoadingView: LoadingIndicator!
    @IBOutlet weak var postedInfoLabel: UILabel!
    @IBOutlet weak var postErrorLabel: UILabel!
    @IBOutlet weak var retryButton: LetgoButton!
    @IBOutlet weak var uploadImageStackView: UIStackView!
    private var verticalLoadingView: LoadingIndicator?
    var messageLabelUploadingImage: UILabel = UILabel()
    var retryButtonUploadingImageRealEstate = LetgoButton(withStyle: .primary(fontSize: .medium))
    
    fileprivate let closeButton = UIButton()

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
    private var hiddeDoneButton: Bool {
        return !(viewModel.isBulkProducts && viewModel.bulkPostedListings?.count ?? 0 > 0)
    }
    fileprivate let keyboardHelper: KeyboardHelper
    fileprivate var isLoading: Bool = false
    private var viewDidAppear: Bool = false

    private var bulkPostingListingsView: BulkPostingListingsView?
    
    fileprivate static let detailTopMarginPrice: CGFloat = 100

    private let forcedInitialTab: Tab?
    private var initialTab: Tab {
        if let forcedInitialTab = forcedInitialTab {
            return forcedInitialTab
        }
        return Tab(rawValue: keyValueStorage.userPostListingLastTabSelected) ?? .gallery
    }
    private let socialSharer: SocialSharer

    private let disposeBag = DisposeBag()

    fileprivate var viewModel: PostListingViewModel
    private var shouldHideStatusBar = false
    private let onboardingView = MLPostingOnboardingView()
    private let keyValueStorage: KeyValueStorageable
    private let tracker: Tracker
    private let featureFlags: FeatureFlaggeable


    // MARK: - Lifecycle

    convenience init(viewModel: PostListingViewModel,
                     forcedInitialTab: Tab?) {
        self.init(viewModel: viewModel,
                  forcedInitialTab: forcedInitialTab,
                  keyboardHelper: KeyboardHelper(),
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  tracker: TrackerProxy.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance,
                  socialSharer: SocialSharer())
    }

    required init(viewModel: PostListingViewModel,
                  forcedInitialTab: Tab?,
                  keyboardHelper: KeyboardHelper,
                  keyValueStorage: KeyValueStorageable,
                  tracker: Tracker,
                  featureFlags: FeatureFlaggeable,
                  socialSharer: SocialSharer) {
        
        let tabPosition: LGViewPagerTabPosition = .hidden
        var postFooter: UIView & PostListingFooter
        if viewModel.shouldShowVideoFooter {
            postFooter = VPPostListingRedCamFooter(infoButtonIncluded: false)
        } else {
            postFooter = PostListingRedCamButtonFooter(infoButtonIncluded: false)
        }
        self.footer = postFooter
        self.footerView = postFooter

        let viewPagerConfig = LGViewPagerConfig(tabPosition: tabPosition, tabLayout: .fixed, tabHeight: 50)
        self.viewPager = LGViewPager(config: viewPagerConfig, frame: CGRect.zero)
        self.cameraView = PostListingCameraView(viewModel: viewModel.postListingCameraViewModel)
        self.keyboardHelper = keyboardHelper
        self.keyValueStorage = keyValueStorage
        self.tracker = tracker
        self.viewModel = viewModel
        self.forcedInitialTab = forcedInitialTab        
        self.galleryView = PostListingGalleryView(viewModel: viewModel.postListingGalleryViewModel)
        self.featureFlags = featureFlags
        self.socialSharer = socialSharer
        
        self.priceView = PostListingDetailPriceView(viewModel: viewModel.postDetailViewModel)
        self.categorySelectionView = PostCategorySelectionView(categoriesAvailables: viewModel.availablePostCategories, featureFlags: featureFlags)
        self.carDetailsView = PostCarDetailsView(initialValues: viewModel.carInfo(forDetail: .make).carInfoWrappers)

        super.init(viewModel: viewModel, nibName: "PostListingViewController",
                   statusBarStyle: UIApplication.shared.statusBarStyle)
        setupForModalWithNonOpaqueBackground()
        viewModel.delegate = self
        socialSharer.delegate = self
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
            bulkPostingListingsView?.alpha = CGFloat(initialTab.index)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraView.active = true
        galleryView.active = true
        hideStatusBarWithSoftAnimation()
    }
    
    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        navigationController?.setNavigationBarHidden(true, animated: false)
        if viewModel.state.value.isLoading {
            customLoadingView.startAnimating()
            verticalLoadingView?.startAnimating()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppear = true
    }

    override func viewDidFirstAppear(_ animated: Bool) {
        super.viewDidFirstAppear(animated)
        viewModel.mediaSourceDidChange(mediaSource: mediaSource)
        trackMediaSource(source: mediaSource, previousSource: .none)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        galleryView.active = false
        cameraView.active = false
    }
    
    override var prefersStatusBarHidden: Bool {
        return shouldHideStatusBar
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }

    // MARK: - Actions
    
    @IBAction func onCloseButton(_ sender: AnyObject) {
        carDetailsView.hideKeyboard()
        priceView.resignFirstResponder()
        viewModel.closeButtonPressed()
    }

    @objc func galleryButtonPressed() {
        guard viewPager.scrollEnabled else { return }
        viewPager.selectTabAtIndex(Tab.gallery.index, animated: true)
    }
    
    @objc func galleryPostButtonPressed() {
        galleryView.postButtonPressed()
    }

    @objc func cameraButtonTouchDown() {
        if viewPager.currentPage == Tab.camera.index {
            if viewModel.postListingCameraViewModel.cameraMode.value == .video {
                viewPager.scrollEnabled = false
                cameraView.recordVideo(maxDuration: SharedConstants.videoMaxRecordingDuration)
            } else {
                cameraView.takePhoto()
            }
        } else {
            viewPager.selectTabAtIndex(Tab.camera.index, animated: true)
        }
    }

    @objc func cameraButtonReleased() {
        if viewPager.currentPage == Tab.camera.index {
            guard self.viewModel.postListingCameraViewModel.cameraMode.value == .video else { return }
            cameraView.stopRecordingVideo()
            footer.stopRecording()
            viewPager.scrollEnabled = true
        } else {
            viewPager.selectTabAtIndex(Tab.camera.index, animated: true)
        }
    }

    @objc func photoButtonPressed() {
        let previousSource = mediaSource
        footer.updateToPhotoMode()
        viewModel.postListingCameraViewModel.cameraMode.value = .photo
        cameraView.setCameraModeToPhoto()
        cameraView.usePhotoButtonText = viewModel.usePhotoButtonText
        viewModel.mediaSourceDidChange(mediaSource: mediaSource)
        trackMediaSource(source: mediaSource, previousSource: previousSource)
    }

    @objc func videoButtonPressed() {
        let previousSource = mediaSource
        footer.updateToVideoMode()
        viewModel.postListingCameraViewModel.cameraMode.value = .video
        cameraView.setCameraModeToVideo()
        cameraView.usePhotoButtonText = viewModel.useVideoButtonText
        viewModel.mediaSourceDidChange(mediaSource: mediaSource)
        trackMediaSource(source: mediaSource, previousSource: previousSource)
    }

    @objc func doneButtonPressed() {
        viewModel.closeButtonPressed()
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
        setupBulkPostingView()
        setupLoadingStackView()
        setupMachineLearningOnboardingView()
    }
    
    private func setupMachineLearningOnboardingView() {
        guard viewModel.machineLearningSupported, !keyValueStorage[.machineLearningOnboardingShown] else { return }
        onboardingView.buttonBlock = { [weak self] in
            self?.onboardingView.backgroundColor = .clear
            UIView.animate(withDuration: 0.2, animations: {
                self?.onboardingView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                self?.onboardingView.center = self?.cameraView.machineLearningButtonCenter ?? CGPoint.zero
            }, completion: { _ in
                self?.onboardingView.removeFromSuperview()
            })
        }
        view.addSubviewForAutoLayout(onboardingView)
        onboardingView.layout(with: view).fill()
        keyValueStorage[.machineLearningOnboardingShown] = true
    }
    
    private func setupLoadingStackView() {
        guard viewModel.isRealEstate || viewModel.isService else { return }
        verticalLoadingView = LoadingIndicator(frame: CGRect(x: 0, y: 0, width: PostListingViewController.loadingViewWidth, height: PostListingViewController.loadingViewHeight))
        verticalLoadingView?.layout().height(PostListingViewController.loadingViewHeight).width(PostListingViewController.loadingViewWidth)
        if let loadingView = verticalLoadingView {
            uploadImageStackView.addArrangedSubview(loadingView)
        }
        messageLabelUploadingImage.textColor = UIColor.white
        messageLabelUploadingImage.font = UIFont.postingFlowBody
        messageLabelUploadingImage.numberOfLines = 0
        retryButtonUploadingImageRealEstate.layout()
            .height(PostListingViewController.retryButtonHeight)
            .width(PostListingViewController.retryButtonWidth, relatedBy: .greaterThanOrEqual)
        retryButtonUploadingImageRealEstate.setTitle(R.Strings.commonErrorListRetryButton, for: .normal)
        retryButtonUploadingImageRealEstate.addTarget(self, action: #selector(PostListingViewController.onRetryButton), for: .touchUpInside)
        uploadImageStackView.addArrangedSubview(messageLabelUploadingImage)
        uploadImageStackView.addArrangedSubview(retryButtonUploadingImageRealEstate)
        messageLabelUploadingImage.isHidden = true
        retryButtonUploadingImageRealEstate.isHidden = true
    }
    
    fileprivate func addMessageToStackView(textMessage: String?, success: Bool) {
        messageLabelUploadingImage.text = textMessage
        messageLabelUploadingImage.isHidden = false
        if !success {
            retryButtonUploadingImageRealEstate.isHidden = false
        }
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.uploadImageStackView.layoutIfNeeded()
        })
    }
    
    private func setupCloseButton() {
        guard !viewModel.isBlockingPosting else { return }
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        if #available(iOS 11.0, *) {
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                             constant:Metrics.margin).isActive = true
        } else {
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant:Metrics.margin).isActive = true
        }
        closeButton.layout(with: view).left(by: Metrics.margin)

        closeButton.addTarget(self, action: #selector(onCloseButton), for: .touchUpInside)
        closeButton.setImage(R.Asset.IconsButtons.icPostClose.image, for: .normal)
    }

    private func setupPriceView() {
        retryButton.setTitle(R.Strings.commonErrorListRetryButton, for: .normal)
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
        if #available(iOS 11, *) {
            categorySelectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            categorySelectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        }
        categorySelectionView.layout(with: view).fillHorizontal().bottom()
    }
    
    private func setupAddCarDetailsView() {
        carDetailsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(carDetailsView)
        carDetailsView.layout(with: view)
            .left()
            .right()
            .bottom()
        if #available(iOS 11.0, *) {
            carDetailsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            carDetailsView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        }
        
        carDetailsView.updateProgress(withPercentage: viewModel.currentCarDetailsProgress)
        
        carDetailsView.navigationBackButton.rx.tap.asObservable().subscribeNext { [weak self] in
            self?.carDetailsNavigationBackButtonPressed()
        }.disposed(by: disposeBag)
        carDetailsView.navigationMakeButton.rx.tap.asObservable().subscribeNext { [weak self] in
            self?.carMakeButtonPressed()
        }.disposed(by: disposeBag)
        carDetailsView.navigationModelButton.rx.tap.asObservable().subscribeNext { [weak self] in
            self?.carModelButtonPressed()
        }.disposed(by: disposeBag)
        carDetailsView.navigationYearButton.rx.tap.asObservable().subscribeNext { [weak self] in
            self?.carYearButtonPressed()
        }.disposed(by: disposeBag)
        carDetailsView.makeRowView.button.rx.tap.asObservable().subscribeNext { [weak self] in
            self?.carMakeButtonPressed()
        }.disposed(by: disposeBag)
        carDetailsView.modelRowView.button.rx.tap.asObservable().subscribeNext { [weak self] in
            self?.carModelButtonPressed()
        }.disposed(by: disposeBag)
        carDetailsView.yearRowView.button.rx.tap.asObservable().subscribeNext { [weak self] in
            self?.carYearButtonPressed()
        }.disposed(by: disposeBag)
        
        carDetailsView.doneButton.rx.tap.asObservable().subscribeNext { [weak self] in
            self?.carDetailsDoneButtonPressed()
        }.disposed(by: disposeBag)
        
        carDetailsView.tableView.selectedDetail.asObservable().bind(to: viewModel.selectedDetail)
            .disposed(by: disposeBag)
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
                delay(0.3) {  // requested by designers
                    strongSelf.didFinishEnteringDetails()
                }
            case .distance, .body, .transmission, .fuel, .drivetrain, .seat:
                break
            }
            strongSelf.carDetailsView.updateProgress(withPercentage: strongSelf.viewModel.currentCarDetailsProgress)
        }.disposed(by: disposeBag)
    }
    
    private func setupFooter() {
        cameraGalleryContainer.addSubviewForAutoLayout(footerView)
        footerView.bottomAnchor.constraint(equalTo: safeBottomAnchor).isActive = true
        footerView.layout(with: cameraGalleryContainer).fillHorizontal()
        
        footer.galleryButton.rx.controlEvent(.touchUpInside).asDriver().drive(onNext: { [weak self] (_) in
            self?.galleryButtonPressed()
        }).disposed(by: disposeBag)
        
        footer.cameraButton.rx.controlEvent(.touchUpInside).asDriver().drive(onNext: { [weak self] (_) in
            self?.cameraButtonReleased()
        }).disposed(by: disposeBag)

        footer.cameraButton.rx.controlEvent(.touchUpOutside).asDriver().drive(onNext: { [weak self] (_) in
            self?.cameraButtonReleased()
        }).disposed(by: disposeBag)

        footer.cameraButton.rx.controlEvent(.touchDown).asDriver().drive(onNext: { [weak self] (_) in
            self?.cameraButtonTouchDown()
        }).disposed(by: disposeBag)

        footer.photoButton.rx.controlEvent(.touchUpInside).asDriver().drive(onNext: { [weak self] (_) in
            self?.photoButtonPressed()
        }).disposed(by: disposeBag)
        
        footer.videoButton.rx.controlEvent(.touchUpInside).asDriver().drive(onNext: { [weak self] (_) in
            self?.videoButtonPressed()
        }).disposed(by: disposeBag)

        footer.doneButton.rx.controlEvent(.touchUpInside).asDriver().drive(onNext: { [weak self] (_) in
            self?.doneButtonPressed()
        }).disposed(by: disposeBag)

        footer.doneButton.isHidden = hiddeDoneButton
        
        cameraView.takePhotoEnabled.asObservable().bind(to: footer.cameraButton.rx.isEnabled).disposed(by: disposeBag)
        cameraView.takePhotoEnabled.asObservable().bind(to: footer.galleryButton.rx.isEnabled).disposed(by: disposeBag)
        cameraView.recordingDuration.asObservable().subscribeNext { [weak self] (duration) in
            let progress = CGFloat(duration/SharedConstants.videoMaxRecordingDuration)
            self?.footer.updateVideoRecordingDurationProgress(progress: progress, recordingDuration: duration)
        }.disposed(by: disposeBag)

        cameraView.isRecordingVideo.asDriver().drive(onNext: { [weak self] isRecordingVideo in
            self?.footer.photoButton.isHidden = isRecordingVideo
            self?.footer.videoButton.isHidden = isRecordingVideo
            self?.footer.newBadgeLabel.isHidden = isRecordingVideo
            self?.footer.galleryButton.isHidden = isRecordingVideo
            self?.footer.doneButton.isHidden = isRecordingVideo || self?.hiddeDoneButton ?? true
            isRecordingVideo ? self?.footer.startRecording() : self?.footer.stopRecording()
        }).disposed(by: disposeBag)
    }

    private func setupBulkPostingView() {
        if let bulkPostedListings = viewModel.bulkPostedListings {
            let bulkPostingListingsViewModel = BulkPostingListingsViewModel(listings: bulkPostedListings)
            let bulkPostingListingsView = BulkPostingListingsView(viewModel: bulkPostingListingsViewModel)
            self.bulkPostingListingsView = bulkPostingListingsView

            cameraGalleryContainer.addSubviewForAutoLayout(bulkPostingListingsView)
            cameraGalleryContainer.bringSubview(toFront: footerView)
            NSLayoutConstraint.activate([
                bulkPostingListingsView.leadingAnchor.constraint(equalTo: cameraGalleryContainer.leadingAnchor, constant: Metrics.margin),
                bulkPostingListingsView.trailingAnchor.constraint(equalTo: cameraGalleryContainer.trailingAnchor, constant: Metrics.margin),
                bulkPostingListingsView.bottomAnchor.constraint(equalTo: footerView.topAnchor, constant: -Metrics.margin)
            ])
        }
    }

    private func setupRx() {
        viewModel.state.asDriver().drive(onNext: { [weak self] state in
            print("🙈 State: \(state.step)")
            self?.update(state: state)
        }).disposed(by: disposeBag)

        categorySelectionView.selectedCategory.asObservable().bind { [weak self] category in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.category.value = category
            strongSelf.trackSelectCategory(source: strongSelf.viewModel.postingSource, category: category)
        }.disposed(by: disposeBag)

        keyboardHelper.rx_keyboardOrigin.asObservable().bind { [weak self] origin in
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
        }.disposed(by: disposeBag)
    }

    private func loadingViewHidden(showingKeyboard: Bool) {
        guard !DeviceFamily.current.isWiderOrEqualThan(.iPhone6) else { return }
        guard !priceView.isHidden else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak self] () -> Void in
            guard let strongSelf = self else { return }
            strongSelf.customLoadingView.alpha = showingKeyboard ? 0.0 : strongSelf.viewModel.state.value.customLoadingViewAlpha
        })
    }
    
    private func hideStatusBarWithSoftAnimation() {
        shouldHideStatusBar = true
        let animationDuration = Double(UINavigationControllerHideShowBarDuration)
        UIView.animate(withDuration: animationDuration) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

    // MARK: - PostListingViewModelDelegate

    func shareOnFacebook(socialMessage: SocialMessage) {
        socialSharer.share(socialMessage, shareType: .facebook, viewController: self)
    }

    func showCameraTab() {
        viewPager.selectTabAtIndex(Tab.camera.index)
    }
}


// MARK: - Car details

extension PostListingViewController {
    
    @objc func carDetailsNavigationBackButtonPressed() {
        if let previousState = carDetailsView.previousState, previousState.isSummary {
            didFinishEnteringDetails()
        } else {
            switch carDetailsView.state {
            case .selectDetail, .selectDetailValue(forDetail: .make):
                didFinishEnteringDetails()
            case .selectDetailValue(forDetail: .model):
                showCarMakes()
            case .selectDetailValue(forDetail: .year):
                showCarModels()
            case .selectDetailValue(.distance),
                 .selectDetailValue(.body),
                 .selectDetailValue(.transmission),
                 .selectDetailValue(.fuel),
                 .selectDetailValue(.drivetrain),
                 .selectDetailValue(.seat):
                break
            }
        }
    }
    
    @objc func carMakeButtonPressed() {
        showCarMakes()
    }
    
    @objc func carModelButtonPressed() {
        showCarModels()
    }
    
    @objc func carYearButtonPressed() {
        showCarYears()
    }
    
    @objc func carDetailsDoneButtonPressed() {
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

private extension PostListingState {
    var closeButtonAlpha: CGFloat {
        switch step {
        case .carDetailsSelection, .postingListing:
            return 0
        case .imageSelection, .uploadingImage, .errorUpload, .uploadingVideo, .errorVideoUpload, .detailsSelection,
             .categorySelection, .finished, .uploadSuccess, .addingDetails,
             .postingError:
            return 1
        }
    }
    
    var isOtherStepsContainerAlpha: CGFloat {
        switch step {
        case .imageSelection:
            return 0
        case .uploadingImage, .errorUpload, .uploadingVideo, .errorVideoUpload, .detailsSelection, .categorySelection,
             .carDetailsSelection, .finished, .uploadSuccess, .addingDetails, .postingListing, .postingError:
            return 1
        }
    }
    
    var customLoadingViewAlpha: CGFloat {
        guard !isRealEstate && !isService else { return 0 }
        switch step {
        case .imageSelection, .categorySelection, .carDetailsSelection, .finished, .addingDetails:
            return 0
        case .uploadingImage, .errorUpload, .uploadingVideo, .errorVideoUpload, .detailsSelection, .uploadSuccess,
             .postingListing, .postingError:
            return 1
        }
    }
    
    var stackViewLoadingAlpha: CGFloat {
        switch step {
        case .imageSelection, .categorySelection, .carDetailsSelection, .finished, .addingDetails:
            return 0
        case .uploadingImage, .errorUpload, .uploadingVideo, .errorVideoUpload, .detailsSelection, .uploadSuccess,
             .postingListing, .postingError:
            return 1
        }
    }
    
    var postedInfoLabelAlpha: CGFloat {
        guard !isRealEstate && !isService else { return 0 }
        switch step {
        case .imageSelection, .categorySelection, .uploadingImage, .errorUpload, .uploadingVideo, .errorVideoUpload,
             .carDetailsSelection, .finished, .addingDetails, .postingListing, .postingError:
            return 0
        case .detailsSelection, .uploadSuccess:
            return 1
        }
    }
    
    func postedInfoLabelText(confirmationText: String?) -> String? {
        return isError ? R.Strings.commonErrorTitle.localizedCapitalized : confirmationText
    }
    
    func messageForLoadedImage(confirmationText: String?) -> String? {
        return isError ? R.Strings.commonErrorPostingLoadedImage : confirmationText
    }
    
    var postErrorLabelAlpha: CGFloat {
        guard let category = category, (category == .realEstate || category == .services)  else { return isError ? 1 : 0 }
        return 0
    }
    
    var postErrorLabelText: String? {
        switch step {
        case .imageSelection, .detailsSelection, .categorySelection, .uploadingImage, .uploadingVideo,
             .carDetailsSelection, .finished, .uploadSuccess, .addingDetails, .postingListing:
            return nil
        case let .errorUpload(message), let .errorVideoUpload(message), let .postingError(message):
            return message
        }
    }
    
    var retryButtonAlpha: CGFloat {
        guard isRealEstate || isService else { return isError ? 1 : 0 }
        return 0
    }
    
    var priceViewAlpha: CGFloat {
        switch step {
        case .imageSelection, .categorySelection, .carDetailsSelection, .uploadingImage, .errorUpload, .uploadingVideo,
             .errorVideoUpload, .finished, .uploadSuccess, .addingDetails, .postingListing,
             .postingError:
            return 0
        case .detailsSelection:
            return 1
        }
    }
    
    var categorySelectionViewAlpha: CGFloat {
        switch step {
        case .imageSelection, .carDetailsSelection, .uploadingImage, .errorUpload, .uploadingVideo, .errorVideoUpload,
             .detailsSelection, .finished, .uploadSuccess, .addingDetails, .postingListing,
             .postingError:
            return 0
        case .categorySelection:
            return 1
        }
    }
    
    var carDetailsViewAlpha: CGFloat {
        switch step {
        case .imageSelection, .categorySelection, .uploadingImage, .errorUpload, .uploadingVideo, .errorVideoUpload,
             .detailsSelection, .finished, .uploadSuccess, .addingDetails, .postingListing,
             .postingError:
            return 0
        case .carDetailsSelection:
            return 1
        }
    }
    
    func priceViewShouldBecomeFirstResponder() -> Bool {
        switch step {
        case .imageSelection, .categorySelection, .uploadingImage, .errorUpload, .uploadingVideo, .errorVideoUpload,
             .carDetailsSelection, .finished, .uploadSuccess, .addingDetails, .postingListing,
             .postingError:
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
        case .imageSelection, .detailsSelection, .categorySelection, .uploadingImage, .uploadingVideo,
             .carDetailsSelection, .finished, .uploadSuccess, .addingDetails, .postingListing:
            return false
        case .errorUpload, .errorVideoUpload, .postingError:
            return true
        }
    }
    
    var isLoading: Bool {
        switch step {
        case .imageSelection, .detailsSelection, .categorySelection, .errorUpload, .errorVideoUpload,
             .carDetailsSelection, .finished, .uploadSuccess, .addingDetails, .postingError:
            return false
        case .uploadingImage, .uploadingVideo, .postingListing:
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
            strongSelf.uploadImageStackView.alpha = state.stackViewLoadingAlpha
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
            verticalLoadingView?.startAnimating()
            isLoading = true
        } else if isLoading {
            stopAnimationLoaders(text: state.messageForLoadedImage(confirmationText: viewModel.confirmationOkText), isError: state.isError, action: updateVisibility)
            isLoading = false
        } else {
            updateVisibility()
        }
        if state.priceViewShouldBecomeFirstResponder() {
            priceView.becomeFirstResponder()
            stopAnimationLoaders(text: state.messageForLoadedImage(confirmationText: viewModel.confirmationOkText),isError: state.isError, action: updateVisibility)
        } else if state.priceViewShouldResignFirstResponder() {
            priceView.resignFirstResponder()
        }
    }
    
    private func stopAnimationLoaders(text: String?, isError: Bool, action: @escaping ()->()) {
        guard viewModel.isRealEstate || viewModel.isService else {
            customLoadingView.stopAnimating(correctState: !isError, completion: action)
            return
        }
        verticalLoadingView?.stopAnimating(correctState: !isError, completion: action)
        
        if isError || viewModel.isRealEstate {
            addMessageToStackView(textMessage:text , success: !isError)
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
        case .imageSelection, .uploadingImage, .errorUpload, .uploadingVideo, .errorVideoUpload, .finished,
             .uploadSuccess, .addingDetails, .postingListing, .postingError:
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

    func productCameraDidTakeImage(_ image: UIImage, predictionData: MLPredictionDetailsViewData?) {
        if let navigationController = navigationController as? SellNavigationController {
            navigationController.updateBackground(image: cameraGalleryContainer.takeSnapshot())
        }
        viewModel.imagesSelected([image], source: .camera, predictionData: predictionData)
    }

    func productCameraDidRecordVideo(video: RecordedVideo) {
        if let navigationController = navigationController as? SellNavigationController {
            navigationController.updateBackground(image: cameraGalleryContainer.takeSnapshot())
        }
        viewModel.videoRecorded(video: video)
    }

    func productCameraRequestHideTabs(_ hide: Bool) {
        footer.isHidden = hide
    }

    func productCameraRequestsScrollLock(_ lock: Bool) {
        viewPager.scrollEnabled = !lock
    }

    func productCameraRequestCategory() {
        let alert = UIAlertController(title: R.Strings.sellChooseCategoryDialogTitle, message: nil,
                                      preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = cameraView
        alert.popoverPresentationController?.sourceRect = cameraView.frame

        viewModel.categories.enumerated().forEach { [weak self] (index, category) in
            guard let strongSelf = self else { return }
            alert.addAction(UIAlertAction(title: strongSelf.viewModel.categoryNameAtIndex(index),
                                          style: .default,
                                          handler: { (categoryAction) -> Void in
                                            strongSelf.cameraView.listingCategorySelected(category: strongSelf.viewModel.categoryAtIndex(index))
            }))
        }

        alert.addAction(UIAlertAction(title: R.Strings.sellChooseCategoryDialogCancelButton,
                                      style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func productCameraShowRecordingErrorMessage(message: String) {
        showAutoFadingOutMessageAlert(message: message, time: 1)
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
        // As we don't have a preview for the gallery, we send the event once the user try to post the selected images
        trackMediaCapture(source: .gallery, fileCount: images.count)
        viewModel.imagesSelected(images, source: .gallery, predictionData: nil)
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
        viewPager.tabsBackgroundColor = .clear
        viewPager.tabsSeparatorColor = .clear
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
        keyValueStorage.userPostListingLastTabSelected = index
        let mediaSource: EventParameterMediaSource
        let previousSource: EventParameterMediaSource
        if index == Tab.gallery.index {
            mediaSource = .gallery
            previousSource = viewModel.postListingCameraViewModel.cameraMode.value.eventMediaSource
        } else {
            mediaSource = viewModel.postListingCameraViewModel.cameraMode.value.eventMediaSource
            previousSource = .gallery

        }
        trackMediaSource(source: mediaSource , previousSource: previousSource)
        viewModel.mediaSourceDidChange(mediaSource: mediaSource)

    }

    func viewPager(_ viewPager: LGViewPager, didEndDisplayingView view: UIView, atIndex index: Int) {}

    func viewPager(_ viewPager: LGViewPager, didScrollToPagePosition pagePosition: CGFloat) {
        cameraView.showHeader(pagePosition == 1.0)
        galleryView.showHeader(pagePosition == 0.0)

        footer.update(scroll: pagePosition)
        bulkPostingListingsView?.alpha = pagePosition
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
            icon = R.Asset.IconsButtons.icPostTabGallery.image
            text = R.Strings.productPostGalleryTab
        } else {
            icon = R.Asset.IconsButtons.icPostTabCamera.image
            text = R.Strings.productPostCameraTabV2
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
    
    private func tabTitleTextAttributes()-> [NSAttributedStringKey : Any] {
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.black.withAlphaComponent(0.5)
        shadow.shadowBlurRadius = 2
        shadow.shadowOffset = CGSize(width: 0, height: 0)
        
        var titleAttributes = [NSAttributedStringKey : Any]()
        titleAttributes[NSAttributedStringKey.shadow] = shadow
        titleAttributes[NSAttributedStringKey.foregroundColor] = UIColor.white
        titleAttributes[NSAttributedStringKey.font] = UIFont.activeTabFont
        return titleAttributes
    }
}

extension PostListingViewController: SocialSharerDelegate {
    func shareStartedIn(_ shareType: ShareType) {
        
    }

    func shareFinishedIn(_ shareType: ShareType, withState state: SocialShareState) {
        viewModel.shareFinishedIn(shareType, withState: state)
    }
}

// MARK: - Tracking

extension PostListingViewController {
    var mediaSource: EventParameterMediaSource {
        if viewPager.currentPage == Tab.gallery.index {
            return .gallery
        } else {
            return viewModel.postListingCameraViewModel.cameraMode.value.eventMediaSource
        }
    }

    private func trackMediaSource(source: EventParameterMediaSource,
                                  previousSource: EventParameterMediaSource?) {
        tracker.trackEvent(TrackerEvent.listingSellMediaSource(source: source,
                                                               previousSource: previousSource,
                                                               predictiveFlow: viewModel.machineLearningSupported))
    }

    private func trackMediaCapture(source: EventParameterMediaSource, fileCount: Int) {
        let predictiveFlow = EventParameterBoolean(bool: viewModel.machineLearningSupported)
        tracker.trackEvent(TrackerEvent.listingSellMediaCapture(source: source,
                                                                fileCount: fileCount,
                                                                predictiveFlow: predictiveFlow))
    }

    private func trackSelectCategory(source: PostingSource, category: PostCategory) {
        tracker.trackEvent(TrackerEvent.listingSellCategorySelect(typePage: source.typePage,
                                                                  postingType: EventParameterPostingType(category: category),
                                                                  category: category.listingCategory))
    }
}

extension CameraMode {
    var eventMediaSource: EventParameterMediaSource {
        switch self {
        case .photo:
            return .camera
        case .video:
            return .videoCamera
        }
    }
}


// MARK: - Accesibility

extension PostListingViewController {
    func setAccesibilityIds() {
        closeButton.set(accessibilityId: .postingCloseButton)
        customLoadingView.set(accessibilityId: .postingLoading)
        retryButton.set(accessibilityId: .postingRetryButton)
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
