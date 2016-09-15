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
    func productCameraDidTakeImage(image: UIImage)
    func productCameraRequestsScrollLock(lock: Bool)
    func productCameraRequestHideTabs(hide: Bool)
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
            usePhotoButton?.setTitle(usePhotoButtonText, forState: UIControlState.Normal)
        }
    }

    weak var delegate: PostProductCameraViewDelegate? {
        didSet {
            viewModel.cameraDelegate = delegate
        }
    }
    private var viewModel: PostProductCameraViewModel

    private var fastCamera: FastttCamera?
    private var headerShown = true

    private let disposeBag = DisposeBag()
 

    // MARK: - View lifecycle

    convenience init() {
        self.init(viewModel: PostProductCameraViewModel(), frame: CGRect.zero)
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

    override func didBecomeActive(firstTime: Bool) {
        super.didBecomeActive(firstTime)
        updateCamera()
    }

    override func didBecomeInactive() {
        super.didBecomeInactive()
        updateCamera()
    }

    func showHeader(show: Bool) {
        guard headerShown != show else { return }
        headerShown = show
        let destinationAlpha: CGFloat = show ? 1.0 : 0.0
        UIView.animateWithDuration(0.2) { [weak self] in
            self?.headerContainer.alpha = destinationAlpha
        }
    }

    func takePhoto() {
        hideFirstTimeAlert()
        guard let fastCamera = fastCamera else { return }

        viewModel.takePhotoButtonPressed()
        fastCamera.takePicture()
    }


    // MARK: - Actions
    @IBAction func onCloseButton(sender: AnyObject) {
        hideFirstTimeAlert()
        viewModel.closeButtonPressed()
    }

    @IBAction func onToggleFlashButton(sender: AnyObject) {
        hideFirstTimeAlert()
        viewModel.flashButtonPressed()
    }

    @IBAction func onToggleCameraButton(sender: AnyObject) {
        hideFirstTimeAlert()
        viewModel.cameraButtonPressed()
    }

    @IBAction func onTakePhotoButton(sender: AnyObject) {
        hideFirstTimeAlert()
        guard let fastCamera = fastCamera else { return }

        fastCamera.takePicture()
    }

    @IBAction func onRetryPhotoButton(sender: AnyObject) {
        hideFirstTimeAlert()
        viewModel.retryPhotoButtonPressed()
    }

    @IBAction func onUsePhotoButton(sender: AnyObject) {
        hideFirstTimeAlert()
        viewModel.usePhotoButtonPressed()
    }


    // MARK: - Private methods

    private func setupUI() {

        NSBundle.mainBundle().loadNibNamed("PostProductCameraView", owner: self, options: nil)
        contentView.frame = bounds
        contentView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        contentView.backgroundColor = UIColor.black
        addSubview(contentView)

        //We're using same image for the 4 corners, so 3 of them must be rotated to the correct angle
        for (index, view) in cornersContainer.subviews.enumerate() {
            guard index > 0 else { continue }
            view.transform = CGAffineTransformMakeRotation(CGFloat(Double(index) * M_PI_2))
        }

        //i18n
        retryPhotoButton.setTitle(LGLocalizedString.productPostRetake, forState: UIControlState.Normal)
        usePhotoButton.setTitle(usePhotoButtonText, forState: UIControlState.Normal)
        usePhotoButton.setStyle(.Primary(fontSize: .Medium))

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
            guard let fastCamera = self?.fastCamera where fastCamera.isFlashAvailableForCurrentDevice() else { return }
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
    
    private func updateCamera() {
        if viewModel.active && viewModel.cameraState.value.captureMode {
            setupCamera()
        } else {
            removeCamera()
        }
    }

    private func setupCamera() {
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
        cameraContainerView.insertSubview(fastCamera.view, atIndex: 0)
        fastCamera.endAppearanceTransition()
        fastCamera.view.frame = cameraContainerView.frame
    }

    private func removeCamera() {
        guard let fastCamera = fastCamera else { return }
        fastCamera.willMoveToParentViewController(nil)
        fastCamera.beginAppearanceTransition(false, animated: false)
        fastCamera.view.removeFromSuperview()
        fastCamera.removeFromParentViewController()
        fastCamera.endAppearanceTransition()
        self.fastCamera = nil
    }
}


// MARK: - Info screen

extension PostProductCameraView {

    private func setupInfoView() {
        infoButton.setStyle(.Primary(fontSize: .Medium))

        viewModel.infoShown.asObservable().map{ !$0 }.bindTo(infoContainer.rx_hidden).addDisposableTo(disposeBag)
        viewModel.infoTitle.asObservable().bindTo(infoTitle.rx_text).addDisposableTo(disposeBag)
        viewModel.infoSubtitle.asObservable().bindTo(infoSubtitle.rx_text).addDisposableTo(disposeBag)
        viewModel.infoButton.asObservable().bindTo(infoButton.rx_title).addDisposableTo(disposeBag)
    }

    @IBAction func onInfoButtonPressed(sender: AnyObject) {
        viewModel.infoButtonPressed()
    }
}


// MARK: - First time alert view

extension PostProductCameraView{
    func setupFirstTimeAlertView() {
        firstTimeAlert.layer.cornerRadius = LGUIKitConstants.alertCornerRadius
        firstTimeAlertTitle.text = LGLocalizedString.productPostCameraFirstTimeAlertTitle
        firstTimeAlertSubtitle.text = LGLocalizedString.productPostCameraFirstTimeAlertSubtitle
    }
}


// MARK: - FastttCameraDelegate

extension PostProductCameraView: FastttCameraDelegate {
    func cameraController(cameraController: FastttCameraInterface!,
                          didFinishNormalizingCapturedImage capturedImage: FastttCapturedImage!) {
        viewModel.photoTaken(capturedImage.fullImage)
    }
}

extension CameraFlashMode {
    var fastttCameraFlash: FastttCameraFlashMode {
        switch self {
        case .Auto:
            return .Auto
        case .On:
            return .On
        case .Off:
            return .Off
        }
    }

    var imageIcon: UIImage? {
        switch self {
        case .Auto:
            return UIImage(named: "ic_post_flash_auto")
        case .On:
            return UIImage(named: "ic_post_flash")
        case .Off:
            return UIImage(named: "ic_post_flash_innactive")
        }
    }
}

extension CameraSourceMode {
    var fastttCameraDevice: FastttCameraDevice {
        switch self {
        case .Front:
            return .Front
        case .Rear:
            return .Rear
        }
    }
}


// MARK: - Accesibility

extension PostProductCameraView {
    func setAccesibilityIds() {
        closeButton.accessibilityId = .PostingCameraCloseButton
        imagePreview.accessibilityId = .PostingCameraImagePreview
        switchCamButton.accessibilityId = .PostingCameraSwitchCamButton
        usePhotoButton.accessibilityId = .PostingCameraUsePhotoButton
        infoButton.accessibilityId = .PostingCameraInfoScreenButton
        flashButton.accessibilityId = .PostingCameraFlashButton
        retryPhotoButton.accessibilityId = .PostingCameraRetryPhotoButton
        firstTimeAlert.accessibilityId = .PostingCameraFirstTimeAlert
    }
}
