//
//  PostProductCameraView.swift
//  LetGo
//
//  Created by Eli Kohen on 03/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import FastttCamera
import RxSwift
import RxCocoa

protocol PostProductCameraViewDelegate: class {
    func productCameraCloseButton()
    func productCameraDidTakeImage(_ image: UIImage)
    func productCameraRequestsScrollLock(_ lock: Bool)
    func productCameraRequestHideTabs(_ hide: Bool)
}

class PostProductCameraView: BaseView, LGViewPagerPage {

    @IBOutlet var contentView: UIView!

    @IBOutlet weak var cameraContainerView: UIView!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var cornersContainer: UIView!

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var switchCamButton: UIButton!
    @IBOutlet weak var usePhotoButton: UIButton!

    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var infoTitle: UILabel!
    @IBOutlet weak var infoSubtitle: UILabel!
    @IBOutlet weak var infoButton: UIButton!

    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var retryPhotoButton: UIButton!

    @IBOutlet weak var firstTimeAlertContainer: UIView!
    @IBOutlet weak var firstTimeAlert: UIView!
    @IBOutlet weak var firstTimeAlertTitle: UILabel!
    @IBOutlet weak var firstTimeAlertSubtitle: UILabel!

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
            usePhotoButton?.setTitle(usePhotoButtonText, for: UIControlState())
        }
    }

    weak var delegate: PostProductCameraViewDelegate? {
        didSet {
            viewModel.cameraDelegate = delegate
        }
    }
    fileprivate var viewModel: PostProductCameraViewModel

    fileprivate var fastCamera: FastttCamera?
    private var headerShown = true

    fileprivate let disposeBag = DisposeBag()
 

    // MARK: - View lifecycle

    convenience init(viewModel: PostProductCameraViewModel) {
        self.init(viewModel: viewModel, frame: CGRect.zero)
    }
    
    init(viewModel: PostProductCameraViewModel, frame: CGRect) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, frame: frame)
        setupUI()
    }

    init?(viewModel: PostProductCameraViewModel, coder aDecoder: NSCoder) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, coder: aDecoder)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        
        super.layoutSubviews()

        adaptLayoutsToScreenSize()
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
        guard let fastCamera = fastCamera else { return }

        viewModel.takePhotoButtonPressed()
        fastCamera.takePicture()
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
        hideFirstTimeAlert()
        guard let fastCamera = fastCamera else { return }

        fastCamera.takePicture()
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

        Bundle.main.loadNibNamed("PostProductCameraView", owner: self, options: nil)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.backgroundColor = UIColor.black
        addSubview(contentView)

        //We're using same image for the 4 corners, so 3 of them must be rotated to the correct angle
        for (index, view) in cornersContainer.subviews.enumerated() {
            guard index > 0 else { continue }
            view.transform = CGAffineTransform(rotationAngle: CGFloat(Double(index) * M_PI_2))
        }

        //i18n
        retryPhotoButton.setTitle(LGLocalizedString.productPostRetake, for: UIControlState())
        usePhotoButton.setTitle(usePhotoButtonText, for: UIControlState())
        usePhotoButton.setStyle(.primary(fontSize: .medium))

        setupInfoView()
        setupFirstTimeAlertView()
        setAccesibilityIds()
        setupRX()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideFirstTimeAlert))
        addGestureRecognizer(tapRecognizer)
    }

    private func adaptLayoutsToScreenSize() {
        if let fastCamera = fastCamera {
            fastCamera.view.frame = cameraContainerView.frame
        }
    }

    private func setupRX() {
        let state = viewModel.cameraState.asObservable()
        state.subscribeNext{ [weak self] state in self?.updateCamera() }.addDisposableTo(disposeBag)
        let previewModeHidden = state.map{ !$0.previewMode }
        previewModeHidden.bindTo(imagePreview.rx_hidden).addDisposableTo(disposeBag)
        previewModeHidden.bindTo(retryPhotoButton.rx_hidden).addDisposableTo(disposeBag)
        previewModeHidden.bindTo(usePhotoButton.rx_hidden).addDisposableTo(disposeBag)
        let captureModeHidden = state.map{ !$0.captureMode }
        captureModeHidden.bindTo(cornersContainer.rx_hidden).addDisposableTo(disposeBag)
        captureModeHidden.bindTo(switchCamButton.rx_hidden).addDisposableTo(disposeBag)
        captureModeHidden.bindTo(flashButton.rx_hidden).addDisposableTo(disposeBag)
        
        viewModel.imageSelected.asObservable().bindTo(imagePreview.rx_image).addDisposableTo(disposeBag)

        let flashMode = viewModel.cameraFlashMode.asObservable()
        flashMode.map{ $0.fastttCameraFlash }.subscribeNext{ [weak self] flashMode in
            guard let fastCamera = self?.fastCamera, fastCamera.isFlashAvailableForCurrentDevice() else { return }
            fastCamera.cameraFlashMode = flashMode
        }.addDisposableTo(disposeBag)
        flashMode.map{ $0.imageIcon }.bindTo(flashButton.rx_image).addDisposableTo(disposeBag)

        viewModel.cameraSourceMode.asObservable().map{ $0.fastttCameraDevice }.subscribeNext{ [weak self] deviceMode in
            self?.fastCamera?.cameraDevice = deviceMode
        }.addDisposableTo(disposeBag)

        viewModel.shouldShowFirstTimeAlert.asObservable().map { !$0 }.bindTo(firstTimeAlertContainer.rx_hidden).addDisposableTo(disposeBag)
    }

    private dynamic func hideFirstTimeAlert() {
        viewModel.hideFirstTimeAlert()
    }
}


// MARK: - Camera related

extension PostProductCameraView {
    
    fileprivate func updateCamera() {
        if viewModel.active && viewModel.cameraState.value.captureMode {
            setupCamera()
        } else {
            removeCamera()
        }
    }

    fileprivate func setupCamera() {
        guard fastCamera == nil else { return }

        fastCamera = FastttCamera()
        guard let fastCamera = fastCamera else { return }

        fastCamera.scalesImage = false
        fastCamera.normalizesImageOrientations = true
        fastCamera.interfaceRotatesWithOrientation = false
        fastCamera.delegate = self
        fastCamera.cameraFlashMode = viewModel.cameraFlashMode.value.fastttCameraFlash
        fastCamera.cameraDevice = viewModel.cameraSourceMode.value.fastttCameraDevice

        fastCamera.beginAppearanceTransition(true, animated: false)
        cameraContainerView.insertSubview(fastCamera.view, at: 0)
        fastCamera.endAppearanceTransition()
        fastCamera.view.frame = cameraContainerView.frame
    }

    fileprivate func removeCamera() {
        guard let fastCamera = fastCamera else { return }
        fastCamera.willMove(toParentViewController: nil)
        fastCamera.beginAppearanceTransition(false, animated: false)
        fastCamera.view.removeFromSuperview()
        fastCamera.removeFromParentViewController()
        fastCamera.endAppearanceTransition()
        self.fastCamera = nil
    }
}


// MARK: - Info screen

extension PostProductCameraView {

    fileprivate func setupInfoView() {
        infoButton.setStyle(.primary(fontSize: .medium))

        viewModel.infoShown.asObservable().map{ !$0 }.bindTo(infoContainer.rx_hidden).addDisposableTo(disposeBag)
        viewModel.infoTitle.asObservable().bindTo(infoTitle.rx_text).addDisposableTo(disposeBag)
        viewModel.infoSubtitle.asObservable().bindTo(infoSubtitle.rx_text).addDisposableTo(disposeBag)
        viewModel.infoButton.asObservable().bindTo(infoButton.rx_title).addDisposableTo(disposeBag)
    }

    @IBAction func onInfoButtonPressed(_ sender: AnyObject) {
        viewModel.infoButtonPressed()
    }
}


// MARK: - First time alert view

extension PostProductCameraView{
    func setupFirstTimeAlertView() {
        firstTimeAlert.layer.cornerRadius = LGUIKitConstants.alertCornerRadius
        firstTimeAlertTitle.text = viewModel.firstTimeTitle
        firstTimeAlertSubtitle.text = viewModel.firstTimeSubtitle
    }
}


// MARK: - FastttCameraDelegate

extension PostProductCameraView: FastttCameraDelegate {
    func cameraController(_ cameraController: FastttCameraInterface!,
                          didFinishNormalizing capturedImage: FastttCapturedImage!) {
        viewModel.photoTaken(capturedImage.fullImage)
    }
}

extension CameraFlashMode {
    var fastttCameraFlash: FastttCameraFlashMode {
        switch self {
        case .auto:
            return .auto
        case .on:
            return .on
        case .off:
            return .off
        }
    }

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

extension CameraSourceMode {
    var fastttCameraDevice: FastttCameraDevice {
        switch self {
        case .front:
            return .front
        case .rear:
            return .rear
        }
    }
}


// MARK: - Accesibility

extension PostProductCameraView {
    func setAccesibilityIds() {
        closeButton.accessibilityId = .postingCameraCloseButton
        imagePreview.accessibilityId = .postingCameraImagePreview
        switchCamButton.accessibilityId = .postingCameraSwitchCamButton
        usePhotoButton.accessibilityId = .postingCameraUsePhotoButton
        infoButton.accessibilityId = .postingCameraInfoScreenButton
        flashButton.accessibilityId = .postingCameraFlashButton
        retryPhotoButton.accessibilityId = .postingCameraRetryPhotoButton
        firstTimeAlert.accessibilityId = .postingCameraFirstTimeAlert
    }
}
