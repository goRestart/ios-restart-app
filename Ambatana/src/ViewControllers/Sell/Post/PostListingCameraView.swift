//
//  PostListingCameraView.swift
//  LetGo
//
//  Created by Eli Kohen on 03/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol PostListingCameraViewDelegate: class {
    func productCameraCloseButton()
    func productCameraDidTakeImage(_ image: UIImage)
    func productCameraRequestsScrollLock(_ lock: Bool)
    func productCameraRequestHideTabs(_ hide: Bool)
}

class PostListingCameraView: BaseView, LGViewPagerPage {

    @IBOutlet var contentView: UIView!

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var cornersContainer: UIView!

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var switchCamButton: UIButton!
    @IBOutlet weak var usePhotoButton: UIButton!

    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var infoTitle: UILabel!
    @IBOutlet weak var infoSubtitle: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var verticalPromoLabel: UILabel!

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

    fileprivate let cameraWrapper = CameraWrapper()
    private var headerShown = true

    let takePhotoEnabled = Variable<Bool>(true)
    fileprivate let disposeBag = DisposeBag()
 

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

    override func layoutSubviews() {
        super.layoutSubviews()
        cameraWrapper.addPreviewLayerTo(view: cameraView)
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
        retryPhotoButton.setTitle(LGLocalizedString.productPostRetake, for: .normal)
        usePhotoButton.setTitle(usePhotoButtonText, for: .normal)
        usePhotoButton.setStyle(.primary(fontSize: .medium))
        
        verticalPromoLabel.text = viewModel.verticalPromotionMessage

        setupInfoView()
        setupFirstTimeAlertView()
        setAccesibilityIds()
        setupRX()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideFirstTimeAlert))
        addGestureRecognizer(tapRecognizer)
        
    }

    private func setupRX() {
        let state = viewModel.cameraState.asObservable()
        state.subscribeNext{ [weak self] state in self?.updateCamera() }.disposed(by: disposeBag)
        let previewModeHidden = state.map{ !$0.previewMode }
        previewModeHidden.bind(to: imagePreview.rx.isHidden).disposed(by: disposeBag)
        previewModeHidden.bind(to: retryPhotoButton.rx.isHidden).disposed(by: disposeBag)
        previewModeHidden.bind(to: usePhotoButton.rx.isHidden).disposed(by: disposeBag)
        let captureModeHidden = state.map{ !$0.captureMode }
        captureModeHidden.bind(to: cornersContainer.rx.isHidden).disposed(by: disposeBag)
        captureModeHidden.bind(to: switchCamButton.rx.isHidden).disposed(by: disposeBag)
        captureModeHidden.bind(to: flashButton.rx.isHidden).disposed(by: disposeBag)
        
        
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
        viewModel.shouldShowVerticalText.asObservable().bind { visible in
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.verticalPromoLabel.alpha = visible ? 1.0 : 0.0
            })
        }.disposed(by: disposeBag)
    }

    @objc private dynamic func hideFirstTimeAlert() {
        viewModel.hideFirstTimeAlert()
    }
}


// MARK: - Camera related

extension PostListingCameraView {
    
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
