import UIKit
import RxSwift
import RxCocoa
import LGCoreKit
import LGComponents

protocol MLPostListingCameraViewDelegate: class {
    func productCameraCloseButton()
    func productCameraDidTakeImage(_ image: UIImage, predictionData: MLPredictionDetailsViewData?)
    func productCameraRequestsScrollLock(_ lock: Bool)
    func productCameraRequestHideTabs(_ hide: Bool)
    
    func productCameraRequestCategory()
}

class MLPostListingCameraView: BaseView, LGViewPagerPage, MLPredictionDetailsViewDelegate {

    @IBOutlet var contentView: UIView!

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var cornersContainer: UIView!

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var switchCamButton: UIButton!
    @IBOutlet weak var usePhotoButton: LetgoButton!

    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var infoTitle: UILabel!
    @IBOutlet weak var infoSubtitle: UILabel!
    @IBOutlet weak var infoButton: LetgoButton!
    @IBOutlet weak var verticalPromoLabel: UILabel!
    @IBOutlet weak var bottomControlsContainer: UIView!
    @IBOutlet weak var bottomControlsContainerBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var retryPhotoButton: UIButton!
    let machineLeaningButton = UIButton(type: .custom)

    @IBOutlet weak var firstTimeAlertContainer: UIView!
    @IBOutlet weak var firstTimeAlert: UIView!
    @IBOutlet weak var firstTimeAlertTitle: UILabel!
    @IBOutlet weak var firstTimeAlertSubtitle: UILabel!
    
    private var machineLearningEnabled: Bool {
        return viewModel.machineLearning.isLiveStatsEnabled
    }
    private let predictionLabel = UILabel()
    private let predictionDetailsView = MLPredictionDetailsView()
    private var predictionDetailsViewBottomConstraint = NSLayoutConstraint()

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

    weak var delegate: MLPostListingCameraViewDelegate? {
        didSet {
            viewModel.cameraDelegate = delegate
        }
    }
    fileprivate var viewModel: MLPostListingCameraViewModel

    fileprivate let cameraWrapper = CameraWrapper()
    private var headerShown = true

    let takePhotoEnabled = Variable<Bool>(true)
    fileprivate let disposeBag = DisposeBag()
 

    // MARK: - View lifecycle

    convenience init(viewModel: MLPostListingCameraViewModel) {
        self.init(viewModel: viewModel, frame: CGRect.zero)
    }
    
    init(viewModel: MLPostListingCameraViewModel, frame: CGRect) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, frame: frame)
        setupUI()
    }

    init?(viewModel: MLPostListingCameraViewModel, coder aDecoder: NSCoder) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, coder: aDecoder)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        cameraWrapper.addPreviewLayerTo(view: cameraView)
        contentView.bringSubview(toFront: predictionDetailsView)
        contentView.bringSubview(toFront: bottomControlsContainer)
        usePhotoButton.layer.cornerRadius = usePhotoButton.height / 2
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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

    func takePhoto() {
        hideFirstTimeAlert()
        guard takePhotoEnabled.value else { return }
        guard cameraWrapper.isReady else { return }
        
        viewModel.machineLearning.isLiveStatsEnabled = false
        if viewModel.isLiveStatsEnabledBackup,
            let predictionDetailsData = viewModel.predictionDetailsData() {
            predictionDetailsView.set(data: predictionDetailsData)
            viewModel.trackPredictedData(predictedData: predictionDetailsData)
        }
        
        takePhotoEnabled.value = false
        cameraWrapper.capturePhoto { [weak self] result in
            if let image = result.value {
                self?.viewModel.photoTaken(image)
            } else {
                self?.viewModel.retryPhotoButtonPressed()
            }
            self?.takePhotoEnabled.value = true
        }
    }
    
    // MARK: - Actions
    @IBAction func onCloseButton(_ sender: AnyObject) {
        endEditing(true)
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
        endEditing(true)
        takePhoto()
    }

    @IBAction func onRetryPhotoButton(_ sender: AnyObject) {
        endEditing(true)
        hideFirstTimeAlert()
        viewModel.retryPhotoButtonPressed()
        viewModel.machineLearning.isLiveStatsEnabled = viewModel.isLiveStatsEnabledBackup
    }

    @IBAction func onUsePhotoButton(_ sender: AnyObject) {
        endEditing(true)
        hideFirstTimeAlert()
        viewModel.usePhotoButtonPressed(predictionData: predictionDetailsView.data)
    }


    // MARK: - Private methods

    private func setupUI() {

        Bundle.main.loadNibNamed("MLPostListingCameraView", owner: self, options: nil)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.backgroundColor = UIColor.black
        addSubview(contentView)

        //We're using same image for the 4 corners, so 3 of them must be rotated to the correct angle
        for (index, view) in cornersContainer.subviews.enumerated() {
            guard index > 0 else { continue }
            view.transform = CGAffineTransform(rotationAngle: CGFloat(Double(index) * Double.pi/2))
        }

        //i18n
        retryPhotoButton.setTitle(R.Strings.productPostRetake, for: .normal)
        usePhotoButton.setTitle(usePhotoButtonText, for: .normal)
        usePhotoButton.setStyle(.primary(fontSize: .medium))
        
        verticalPromoLabel.text = viewModel.verticalPromotionMessage

        setupInfoView()
        setupFirstTimeAlertView()
        setAccesibilityIds()
        setupRX()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideFirstTimeAlert))
        tapRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(tapRecognizer)
        
        cornersContainer.isHidden = true
        setupMachineLearningVideoOutput()
        setupMachineLearningButton()
        setupMachineLearning(enabled: machineLearningEnabled)
        setupPredictionLabel()
        setupPredictionDetailsView()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    private func setupPredictionDetailsView() {
        contentView.addSubviewForAutoLayout(predictionDetailsView)
        predictionDetailsView.layout(with: contentView)
            .right()
            .left()
            .top(by: -44)
            .bottom { [weak self] constraint in
                self?.predictionDetailsViewBottomConstraint = constraint
        }
        predictionDetailsView.isHidden = true
        predictionDetailsView.delegate = self
    }
    
    func listingCategorySelected(category: ListingCategory?) {
        predictionDetailsView.set(category: category)
    }
    
    private func setupPredictionLabel() {
        predictionLabel.textColor = .white
        predictionLabel.font = UIFont.systemBoldFont(size: 27)
        predictionLabel.textAlignment = .left
        predictionLabel.numberOfLines = 0
        predictionLabel.layer.shadowColor = UIColor.black.cgColor
        predictionLabel.layer.shadowRadius = 1.0
        predictionLabel.layer.shadowOpacity = 1.0
        predictionLabel.layer.shadowOffset = CGSize.zero
        predictionLabel.layer.masksToBounds = false
        contentView.addSubviewForAutoLayout(predictionLabel)
        predictionLabel.layout(with: contentView)
            .left(by: Metrics.margin)
            .right(by: -Metrics.margin)
        predictionLabel.layout(with: closeButton)
            .top(to: .bottom, by: 20)
    }
    
    private func setupMachineLearningVideoOutput() {
        cameraWrapper.setupVideoOutput()
    }
    
    @objc func machineLearningSwitch() {
        viewModel.machineLearningButtonPressed()
        setupMachineLearning(enabled: machineLearningEnabled)
    }
    
    private func setupMachineLearningButton() {
        headerContainer.addSubviewForAutoLayout(machineLeaningButton)
        machineLeaningButton.layout(with: headerContainer).top()
        machineLeaningButton.layout(with: switchCamButton).right(to: .left, by: -12).centerY()
        machineLeaningButton.addTarget(self, action: #selector(machineLearningSwitch), for: .touchUpInside)
    }
    
    private func setupMachineLearning(enabled: Bool) {
        if enabled {
            machineLeaningButton.setImage(R.Asset.Machinelearning.mlIconOn.image, for: .normal)
            cameraWrapper.enableVideoOutput(withDelegate: viewModel.machineLearning)
            predictionLabel.animateTo(alpha: 1)
        } else {
            machineLeaningButton.setImage(R.Asset.Machinelearning.mlIconOff.image, for: .normal)
            cameraWrapper.disableVideoOutput()
            predictionLabel.animateTo(alpha: 0)
        }
    }

    private func setupRX() {
        let state = viewModel.cameraState.asObservable()
        state.subscribeNext{ [weak self] state in self?.updateCamera() }.disposed(by: disposeBag)
        let previewModeHidden = state.map{ !$0.previewMode }
        previewModeHidden.bind(to: imagePreview.rx.isHidden).disposed(by: disposeBag)
        previewModeHidden.bind(to: retryPhotoButton.rx.isHidden).disposed(by: disposeBag)
        previewModeHidden.bind(to: usePhotoButton.rx.isHidden).disposed(by: disposeBag)
        previewModeHidden.bind { [weak self] isHidden in
            guard let strongSelf = self else { return }
            if strongSelf.viewModel.isLiveStatsEnabledBackup && strongSelf.viewModel.predictionDetailsData() != nil {
                strongSelf.predictionDetailsView.isHidden = isHidden
            }
            }.disposed(by: disposeBag)
        
        let captureModeHidden = state.map{ !$0.captureMode }
        captureModeHidden.bind(to: switchCamButton.rx.isHidden).disposed(by: disposeBag)
        captureModeHidden.bind(to: flashButton.rx.isHidden).disposed(by: disposeBag)
        captureModeHidden.bind(to: machineLeaningButton.rx.isHidden).disposed(by: disposeBag)
        captureModeHidden.bind(to: predictionLabel.rx.isHidden).disposed(by: disposeBag)

        viewModel.imageSelected.asObservable().bind(to: imagePreview.rx.image).disposed(by: disposeBag)

        let flashMode = viewModel.cameraFlashState.asObservable()
        flashMode.subscribeNext{ [weak self] flashMode in
            guard let cameraWrapper = self?.cameraWrapper, cameraWrapper.hasFlash else { return }
            cameraWrapper.flashMode = flashMode
        }.disposed(by: disposeBag)
        flashMode.map{ $0.imageIcon }.bind(to: flashButton.rx.image(for: .normal)).disposed(by: disposeBag)

        viewModel.cameraSource.asObservable().subscribeNext{ [weak self] cameraSource in
            self?.cameraWrapper.cameraSource = cameraSource
        }.disposed(by: disposeBag)

        viewModel.shouldShowFirstTimeAlert.asObservable().map { !$0 }.bind(to: firstTimeAlertContainer.rx.isHidden).disposed(by: disposeBag)
        viewModel.shouldShowVerticalText.asObservable().bind { [weak self] visible in
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.verticalPromoLabel.alpha = visible ? 1.0 : 0.0
            })
        }.disposed(by: disposeBag)
        
        viewModel.liveStatsText.asObservable().bind { [weak self] statsText in
            self?.predictionLabel.text = statsText
        }.disposed(by: disposeBag)
    }

    @objc private dynamic func hideFirstTimeAlert() {
        viewModel.hideFirstTimeAlert()
    }
    
    // MARK: - Keyboard
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo,
            let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let animationDuration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
            bottomControlsContainerBottomConstraint.constant = keyboardSize.height
            predictionDetailsViewBottomConstraint.constant = -keyboardSize.height
            UIView.animate(withDuration: animationDuration) { [weak self] in
                self?.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let userInfo = notification.userInfo,
            let animationDuration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
            bottomControlsContainerBottomConstraint.constant = 0
            predictionDetailsViewBottomConstraint.constant = 0
            UIView.animate(withDuration: animationDuration) { [weak self] in
                self?.layoutIfNeeded()
            }
        }
    }
    
    //MARK: - MLPredictionDetailsViewDelegate
    
    func didRequestCategorySelection() {
        delegate?.productCameraRequestCategory()
    }
}


// MARK: - Camera related

extension MLPostListingCameraView {
    
    fileprivate func updateCamera() {
        if viewModel.active && viewModel.cameraState.value.captureMode {
            if cameraWrapper.isAttached {
                cameraWrapper.resume()
            } else {
                cameraWrapper.addPreviewLayerTo(view: cameraView)
            }
            cameraView.isHidden = false
        } else {
            cameraWrapper.pause()
            cameraView.isHidden = true
        }
    }
}


// MARK: - Info screen

extension MLPostListingCameraView {

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

extension MLPostListingCameraView {
    func setupFirstTimeAlertView() {
        firstTimeAlert.cornerRadius = LGUIKitConstants.bigCornerRadius
        firstTimeAlertTitle.text = viewModel.firstTimeTitle
        firstTimeAlertSubtitle.text = viewModel.firstTimeSubtitle
    }
}


// MARK: - Accesibility

extension MLPostListingCameraView {
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
