//
//  PostProductCameraView.swift
//  LetGo
//
//  Created by Eli Kohen on 03/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
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
            usePhotoButton?.setTitle(usePhotoButtonText, for: .normal)
        }
    }

    weak var delegate: PostProductCameraViewDelegate? {
        didSet {
            viewModel.cameraDelegate = delegate
        }
    }
    fileprivate var viewModel: PostProductCameraViewModel

    fileprivate let cameraWrapper = CameraWrapper()
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
        if !cameraWrapper.isAttached {
            cameraWrapper.addPreviewLayerTo(view: cameraView)
        }
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
        guard cameraWrapper.isReady else { return }
        viewModel.takePhotoButtonPressed()
        cameraWrapper.capturePhoto { [weak self] result in
            if let image = result.value {
                self?.viewModel.photoTaken(image)
            } else {
                self?.viewModel.retryPhotoButtonPressed()
            }
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
        retryPhotoButton.setTitle(LGLocalizedString.productPostRetake, for: .normal)
        usePhotoButton.setTitle(usePhotoButtonText, for: .normal)
        usePhotoButton.setStyle(.primary(fontSize: .medium))

        setupInfoView()
        setupFirstTimeAlertView()
        setAccesibilityIds()
        setupRX()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideFirstTimeAlert))
        addGestureRecognizer(tapRecognizer)
    }

    private func setupRX() {
        let state = viewModel.cameraState.asObservable()
        state.subscribeNext{ [weak self] state in self?.updateCamera() }.addDisposableTo(disposeBag)
        let previewModeHidden = state.map{ !$0.previewMode }
        previewModeHidden.bindTo(imagePreview.rx.isHidden).addDisposableTo(disposeBag)
        previewModeHidden.bindTo(retryPhotoButton.rx.isHidden).addDisposableTo(disposeBag)
        previewModeHidden.bindTo(usePhotoButton.rx.isHidden).addDisposableTo(disposeBag)
        let captureModeHidden = state.map{ !$0.captureMode }
        captureModeHidden.bindTo(cornersContainer.rx.isHidden).addDisposableTo(disposeBag)
        captureModeHidden.bindTo(switchCamButton.rx.isHidden).addDisposableTo(disposeBag)
        captureModeHidden.bindTo(flashButton.rx.isHidden).addDisposableTo(disposeBag)
        
        viewModel.imageSelected.asObservable().bindTo(imagePreview.rx.image).addDisposableTo(disposeBag)

        let flashMode = viewModel.cameraFlashState.asObservable()
        flashMode.subscribeNext{ [weak self] flashMode in
            guard let cameraWrapper = self?.cameraWrapper, cameraWrapper.hasFlash else { return }
            cameraWrapper.flashMode = flashMode
        }.addDisposableTo(disposeBag)
        flashMode.map{ $0.imageIcon }.bindTo(flashButton.rx.image).addDisposableTo(disposeBag)

        viewModel.cameraSource.asObservable().subscribeNext{ [weak self] cameraSource in
            self?.cameraWrapper.cameraSource = cameraSource
        }.addDisposableTo(disposeBag)

        viewModel.shouldShowFirstTimeAlert.asObservable().map { !$0 }.bindTo(firstTimeAlertContainer.rx.isHidden).addDisposableTo(disposeBag)
    }

    private dynamic func hideFirstTimeAlert() {
        viewModel.hideFirstTimeAlert()
    }
}


// MARK: - Camera related

extension PostProductCameraView {
    
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

extension PostProductCameraView {

    fileprivate func setupInfoView() {
        infoButton.setStyle(.primary(fontSize: .medium))

        viewModel.infoShown.asObservable().map{ !$0 }.bindTo(infoContainer.rx.isHidden).addDisposableTo(disposeBag)
        viewModel.infoTitle.asObservable().bindTo(infoTitle.rx.text).addDisposableTo(disposeBag)
        viewModel.infoSubtitle.asObservable().bindTo(infoSubtitle.rx.text).addDisposableTo(disposeBag)
        viewModel.infoButton.asObservable().bindTo(infoButton.rx.title).addDisposableTo(disposeBag)
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
