import UIKit
import RxSwift
import RxCocoa
import LGComponents

protocol PostListingCameraViewDelegate: class {
    func productCameraCloseButton()
    func productCameraDidTakeImage(_ image: UIImage)
    func productCameraDidRecordVideo(video: RecordedVideo)
    func productCameraRequestsScrollLock(_ lock: Bool)
    func productCameraRequestHideTabs(_ hide: Bool)
    func productCameraLearnMoreButton()
}

class PostListingCameraView: BaseView, LGViewPagerPage {

    @IBOutlet var contentView: UIView!

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var videoPreview: VideoPreview!
    @IBOutlet weak var cornersContainer: UIView!

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var switchCamButton: UIButton!
    @IBOutlet weak var usePhotoButton: LetgoButton!

    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var infoTitle: UILabel!
    @IBOutlet weak var infoSubtitle: UILabel!
    @IBOutlet weak var infoButton: LetgoButton!
    @IBOutlet weak var verticalPromoLabel: UILabel!
    @IBOutlet weak var learnMoreButton: UIButton!
    @IBOutlet weak var learnMoreChevron: UIButton!
    
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var retryPhotoButton: UIButton!

    @IBOutlet weak var firstTimeAlertContainer: UIView!
    @IBOutlet weak var firstTimeAlert: UIView!
    @IBOutlet weak var firstTimeAlertTitle: UILabel!
    @IBOutlet weak var firstTimeAlertSubtitle: UILabel!

    private let headerStepView = BlockingPostingStepHeaderView()
    
    var visible: Bool {
        set {
            viewModel.visible.value = newValue
        }
        get {
            return viewModel.visible.value
        }
    }

    var usePhotoButtonText: String? {
        didSet {
            usePhotoButton?.setTitle(usePhotoButtonText, for: .normal)
        }
    }

    weak var delegate: PostListingCameraViewDelegate? {
        didSet {
            viewModel.cameraDelegate = delegate
        }
    }
    fileprivate var viewModel: PostListingCameraViewModel

    fileprivate let camera = LGCamera()
    private var headerShown = true

    let takePhotoEnabled = Variable<Bool>(true)
    let isRecordingVideo = Variable<Bool>(false)
    let recordingDuration = Variable<TimeInterval>(0)
    fileprivate let disposeBag = DisposeBag()
    private var recordingDurationTimer: Timer?
 

    // MARK: - View lifecycle

    convenience init(viewModel: PostListingCameraViewModel) {
        self.init(viewModel: viewModel, frame: CGRect.zero)
    }
    
    init(viewModel: PostListingCameraViewModel, frame: CGRect) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, frame: frame)
        setupUI()
    }

    init?(viewModel: PostListingCameraViewModel, coder aDecoder: NSCoder) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, coder: aDecoder)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        updateCamera()
    }

    override func didBecomeInactive() {
        super.didBecomeInactive()
        updateCamera()
    }

    func showHeader(_ show: Bool) {
        guard headerShown != show else { return }
        headerShown = show
        let destinationAlpha: CGFloat = show ? 1.0 : 0.0
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.headerContainer.alpha = destinationAlpha
        }) 
    }

    func setCameraModeToVideo() {
        camera.cameraMode = .video
    }

    func setCameraModeToPhoto() {
        camera.cameraMode = .photo
    }

    func takePhoto() {
        hideFirstTimeAlert()
        guard takePhotoEnabled.value else { return }
        guard camera.isReady else { return }

        takePhotoEnabled.value = false
        camera.capturePhoto { [weak self] result in
            if let image = result.value {
                self?.viewModel.photoTaken(image)
            } else {
                self?.viewModel.retryPhotoButtonPressed()
            }
            self?.takePhotoEnabled.value = true
        }
    }

    func recordVideo(maxDuration: TimeInterval) {
        hideFirstTimeAlert()
        guard camera.isReady, !camera.isRecording, !isRecordingVideo.value else { return }
        isRecordingVideo.value = true
        startListeningVideoDuration()
        camera.startRecordingVideo(maxRecordingDuration: maxDuration) { [weak self] result in
            self?.stopListeningVideoDuration()
            if let recordedVideo = result.value {
                self?.viewModel.videoRecorded(video: recordedVideo)
            } else {
                self?.viewModel.videoRecordingFailed()
            }
            self?.isRecordingVideo.value = false
        }
    }

    func stopRecordingVideo() {
        camera.stopRecordingVideo()
    }
    
    // MARK: - Actions
    @IBAction func onCloseButton(_ sender: AnyObject) {
        hideFirstTimeAlert()
        viewModel.closeButtonPressed()
    }

    @IBAction func onToggleFlashButton(_ sender: AnyObject) {
        hideFirstTimeAlert()
        viewModel.flashButtonPressed()
    }

    @IBAction func onToggleCameraButton(_ sender: AnyObject) {
        hideFirstTimeAlert()
        viewModel.cameraButtonPressed()
    }

    @IBAction func onTakePhotoButton(_ sender: AnyObject) {
        takePhoto()
    }

    @IBAction func onRetryPhotoButton(_ sender: AnyObject) {
        hideFirstTimeAlert()
        viewModel.retryPhotoButtonPressed()
    }

    @IBAction func onUsePhotoButton(_ sender: AnyObject) {
        hideFirstTimeAlert()
        viewModel.usePhotoButtonPressed()
    }
    
    @IBAction func onLearnMoreButton(_ sender: AnyObject) {
        viewModel.learnMorePressed()
    }
    
    @IBAction func onLearnMoreChevron(_ sender: AnyObject) {
        viewModel.learnMorePressed()
    }


    // MARK: - Private methods

    private func setupUI() {

        Bundle.main.loadNibNamed("PostListingCameraView", owner: self, options: nil)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.backgroundColor = UIColor.black
        addSubview(contentView)

        //We're using same image for the 4 corners, so 3 of them must be rotated to the correct angle
        for (index, view) in cornersContainer.subviews.enumerated() {
            guard index > 0 else { continue }
            view.transform = CGAffineTransform(rotationAngle: CGFloat(Double(index) * Double.pi/2))
        }
        
        if viewModel.isBlockingPosting {
            addSubviewForAutoLayout(headerStepView)
            headerStepView.layout(with: self)
                .fillHorizontal()
                .top()
            headerStepView.layout().height(BlockingPostingStepHeaderView.height)
        }

        //i18n
        retryPhotoButton.setTitle(R.Strings.productPostRetake, for: .normal)
        usePhotoButton.setTitle(usePhotoButtonText, for: .normal)
        usePhotoButton.setStyle(.primary(fontSize: .medium))
        verticalPromoLabel.text = viewModel.verticalPromotionMessage

        setupInfoView()
        setupFirstTimeAlertView()
        setAccesibilityIds()
        setupLearnMore()
        setupRX()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideFirstTimeAlert))
        addGestureRecognizer(tapRecognizer)
        
    }
    
    private func setupLearnMore() {
        learnMoreButton.setAttributedTitle(viewModel.learnMoreMessage, for: .normal)
        learnMoreButton.isHidden = viewModel.learnMoreIsHidden
        learnMoreChevron.isHidden = viewModel.learnMoreIsHidden
    }

    private func setupRX() {
        let state = viewModel.cameraState.asObservable()
        state.subscribeNext{ [weak self] state in self?.updateCamera() }.disposed(by: disposeBag)
        let previewModeHidden = state.map{ !$0.previewMode }
        previewModeHidden.bind(to: retryPhotoButton.rx.isHidden).disposed(by: disposeBag)
        previewModeHidden.bind(to: usePhotoButton.rx.isHidden).disposed(by: disposeBag)

        let previewPhotoModeHidden = state.map{ !$0.previewPhotoMode }
        previewPhotoModeHidden.bind(to: imagePreview.rx.isHidden).disposed(by: disposeBag)

        let previewVideoModeHidden = state.map{ !$0.previewVideoMode }
        previewVideoModeHidden.bind(to: videoPreview.rx.isHidden).disposed(by: disposeBag)

        let captureModeHidden = state.map{ !$0.captureMode }

        let shouldHideTopButtons = Observable.combineLatest(captureModeHidden.asObservable(), 
                                                            isRecordingVideo.asObservable()) { $0 || $1 }
        shouldHideTopButtons
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] shouldShow in
                self?.cornersContainer.isHidden = shouldShow
                self?.switchCamButton.isHidden = shouldShow
                self?.flashButton.isHidden = shouldShow
            }).disposed(by: disposeBag)

        if viewModel.isBlockingPosting {
            state.map { $0.shouldShowCloseButtonBlockingPosting }.bind { [weak self] shouldShowClose in
                guard let strongSelf = self else { return }
                strongSelf.headerContainer.isHidden = !shouldShowClose
                strongSelf.headerStepView.isHidden = shouldShowClose
            }.disposed(by: disposeBag)
            
            let isCaptureMode = state.filter { s in
                s.captureMode }
            isCaptureMode.bind { [weak self] state in
                guard let strongSelf = self else { return }
                guard let headerStep = state.headerStep else { return }
                strongSelf.headerStepView.updateWith(stepNumber: headerStep.rawValue, title: headerStep.title)
            }.disposed(by: disposeBag)
            
            let isPreviewMode = state.filter { s in
                s.previewMode }
            isPreviewMode.bind { [weak self] state in
                guard let strongSelf = self else { return }
                guard let headerStep = state.headerStep else { return }
                strongSelf.headerStepView.updateWith(stepNumber: headerStep.rawValue, title: headerStep.title)
            }.disposed(by: disposeBag)
        }
    
        viewModel.imageSelected.asObservable().bind(to: imagePreview.rx.image).disposed(by: disposeBag)        
        viewModel.videoRecorded.asObservable().ignoreNil().subscribeNext { [weak self] videoRecorded in
            self?.videoPreview.url = videoRecorded.url
            self?.videoPreview.play()
        }.disposed(by: disposeBag)

        let flashMode = viewModel.cameraFlashState.asObservable()
        flashMode.subscribeNext{ [weak self] flashMode in
            guard let camera = self?.camera, camera.hasFlash else { return }
            camera.flashMode = flashMode
        }.disposed(by: disposeBag)
        flashMode.map{ $0.imageIcon }.bind(to: flashButton.rx.image(for: .normal)).disposed(by: disposeBag)

        viewModel.cameraSource.asObservable().subscribeNext{ [weak self] cameraSource in
            self?.camera.cameraPosition = cameraSource
        }.disposed(by: disposeBag)

        viewModel.shouldShowFirstTimeAlert.asObservable().map { !$0 }.bind(to: firstTimeAlertContainer.rx.isHidden).disposed(by: disposeBag)
        viewModel.shouldShowVerticalText.asObservable().bind { [weak self] visible in
            UIView.animate(withDuration: 0.3, animations: {
                self?.verticalPromoLabel.alpha = visible ? 1.0 : 0.0
                self?.learnMoreButton.alpha = visible ? 1.0 : 0.0
                self?.learnMoreChevron.alpha = visible ? 1.0 : 0.0
            })
        }.disposed(by: disposeBag)
    }

    @objc private dynamic func hideFirstTimeAlert() {
        viewModel.hideFirstTimeAlert()
    }
}


// MARK: - Camera related

extension PostListingCameraView {
    
    private func updateCamera() {
        if viewModel.active && viewModel.cameraState.value.captureMode {
            if !camera.isAttached {
                camera.addPreviewLayerTo(view: cameraView)
            }
            camera.resume()
            cameraView.isHidden = false
        } else {
            camera.pause()
            cameraView.isHidden = true
        }
    }

    private func startListeningVideoDuration() {
        recordingDurationTimer?.invalidate()
        recordingDurationTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(PostListingCameraView.updateRecordingDuration), userInfo: nil, repeats: true)
    }

    private func stopListeningVideoDuration() {
        recordingDurationTimer?.invalidate()
    }

    @objc private func updateRecordingDuration() {
        recordingDuration.value = camera.recordingDuration
    }
}


// MARK: - Info screen

extension PostListingCameraView {

    fileprivate func setupInfoView() {
        infoButton.setStyle(.primary(fontSize: .medium))

        viewModel.infoShown.asObservable().map{ !$0 }.bind(to: infoContainer.rx.isHidden).disposed(by: disposeBag)
        viewModel.infoTitle.asObservable().bind(to: infoTitle.rx.text).disposed(by: disposeBag)
        viewModel.infoSubtitle.asObservable().bind(to: infoSubtitle.rx.text).disposed(by: disposeBag)
        viewModel.infoButton.asObservable().bind(to: infoButton.rx.title(for: .normal)).disposed(by: disposeBag)
    }

    @IBAction func onInfoButtonPressed(_ sender: AnyObject) {
        viewModel.infoButtonPressed()
    }
}


// MARK: - First time alert view

extension PostListingCameraView{
    func setupFirstTimeAlertView() {
        firstTimeAlert.cornerRadius = LGUIKitConstants.bigCornerRadius
        firstTimeAlertTitle.text = viewModel.firstTimeTitle
        firstTimeAlertSubtitle.text = viewModel.firstTimeSubtitle
    }
}


// MARK: - Flash state extension

extension CameraFlashState {
    var imageIcon: UIImage? {
        switch self {
        case .auto:
            return UIImage(named: "ic_post_flash_auto")
        case .on:
            return UIImage(named: "ic_post_flash")
        case .off:
            return UIImage(named: "ic_post_flash_innactive")
        }
    }
}


// MARK: - Accesibility

extension PostListingCameraView {
    func setAccesibilityIds() {
        closeButton.set(accessibilityId: .postingCameraCloseButton)
        imagePreview.set(accessibilityId: .postingCameraImagePreview)
        switchCamButton.set(accessibilityId: .postingCameraSwitchCamButton)
        usePhotoButton.set(accessibilityId: .postingCameraUsePhotoButton)
        infoButton.set(accessibilityId: .postingCameraInfoScreenButton)
        flashButton.set(accessibilityId: .postingCameraFlashButton)
        retryPhotoButton.set(accessibilityId: .postingCameraRetryPhotoButton)
        firstTimeAlert.set(accessibilityId: .postingCameraFirstTimeAlert)
    }
}
