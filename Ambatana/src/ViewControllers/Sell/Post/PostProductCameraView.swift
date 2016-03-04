//
//  PostProductCameraView.swift
//  LetGo
//
//  Created by Eli Kohen on 03/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import FastttCamera

protocol PostProductCameraViewDelegate: class {
    func productCameraCloseButton()
    func productCameraDidTakeImage(image: UIImage)
}

class PostProductCameraView: UIView {

    @IBOutlet var contentView: UIView!

    @IBOutlet weak var cameraContainerView: UIView!
    @IBOutlet weak var cameraContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var cornersContainer: UIView!

    @IBOutlet weak var bottomControlsContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var cameraTextsContainer: UIView!
    @IBOutlet weak var cameraTitleLabel: UILabel!
    @IBOutlet weak var cameraSubtitleLabel: UILabel!
    @IBOutlet weak var switchCamButton: UIButton!
    @IBOutlet weak var usePhotoButton: UIButton!
    @IBOutlet weak var makePhotoButton: UIButton!

    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var retryPhotoButton: UIButton!

    private static let bottomControlsCollapsedSize: CGFloat = 88
    private static let bottomControlsExpandedSize: CGFloat = 140

    private var flashMode: FastttCameraFlashMode = .Auto
    private var cameraDevice: FastttCameraDevice = .Rear

    private var fastCamera : FastttCamera?

    var usePhotoButtonText: String? {
        set {
            usePhotoButton?.setTitle(newValue, forState: UIControlState.Normal)
        }
        get {
            return usePhotoButton?.titleForState(UIControlState.Normal)
        }
    }
    var imageSelected: UIImage? {
        return imagePreview.image
    }
    weak var delegate: PostProductCameraViewDelegate?
    weak var parentController: UIViewController?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        adaptLayoutsToScreenSize()
    }

    func viewWillAppear() {
        setupCamera()
    }

    func viewWillDisappear() {
        removeCamera()
    }


    // MARK: - Actions
    @IBAction func onCloseButton(sender: AnyObject) {
        delegate?.productCameraCloseButton()
    }

    @IBAction func onToggleFlashButton(sender: AnyObject) {
        guard let fastCamera = fastCamera where fastCamera.isFlashAvailableForCurrentDevice() else { return }

        flashMode = flashMode.next
        setFlashModeButton()
        fastCamera.cameraFlashMode = flashMode
    }

    @IBAction func onToggleCameraButton(sender: AnyObject) {
        guard let fastCamera = fastCamera else { return }

        cameraDevice = cameraDevice.toggle
        fastCamera.cameraDevice = cameraDevice
        flashButton.hidden = cameraDevice == .Front
    }

    @IBAction func onTakePhotoButton(sender: AnyObject) {
        guard let fastCamera = fastCamera else { return }

        fastCamera.takePicture()
    }

    @IBAction func onRetryPhotoButton(sender: AnyObject) {
        switchToCaptureMode()
    }

    @IBAction func onUsePhotoButton(sender: AnyObject) {
        guard let image = imagePreview.image else { return }
        delegate?.productCameraDidTakeImage(image)
    }


    // MARK: - Private methods

    private func setupUI() {

        NSBundle.mainBundle().loadNibNamed("PostProductCameraView", owner: self, options: nil)
        contentView.frame = bounds
        contentView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        contentView.backgroundColor = UIColor.blackColor()
        addSubview(contentView)

        //We're using same image for the 4 corners, so 3 of them must be rotated to the correct angle
        for (index, view) in cornersContainer.subviews.enumerate() {
            guard index > 0 else { continue }
            view.transform = CGAffineTransformMakeRotation(CGFloat(Double(index) * M_PI_2))
        }

        //i18n
        cameraTitleLabel.text = LGLocalizedString.productPostCameraTitle
        cameraSubtitleLabel.text = LGLocalizedString.productPostCameraSubtitle
        retryPhotoButton.setTitle(LGLocalizedString.productPostRetake, forState: UIControlState.Normal)
        usePhotoButton.setTitle(usePhotoButtonText, forState: UIControlState.Normal)
    }

    private func setupCamera() {
        guard let parentCtrl = parentController where fastCamera == nil && imagePreview.hidden else { return }

        MediaPickerManager.requestCameraPermissions(parentCtrl) { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.fastCamera = FastttCamera()
            guard let fastCamera = strongSelf.fastCamera else { return }

            fastCamera.scalesImage = false
            fastCamera.normalizesImageOrientations = true
            fastCamera.delegate = self
            strongSelf.addCameraToView(fastCamera)
        }
    }

    private func addCameraToView(fastCamera: FastttCamera) {
        fastCamera.beginAppearanceTransition(true, animated: false)
        parentController?.addChildViewController(fastCamera)
        cameraContainerView.addSubview(fastCamera.view)
        fastCamera.didMoveToParentViewController(parentController)
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

    private func adaptLayoutsToScreenSize() {

        if DeviceFamily.current == .iPhone4 {
            //Small screen mode -> collapse buttons (hiding some info) + expand camera
            bottomControlsContainerHeight.constant = PostProductCameraView.bottomControlsCollapsedSize
            cameraTextsContainer.hidden = true
            cameraContainerViewHeight.constant = contentView.height
        } else {
            let expectedCameraHeight = contentView.width * (4/3) //Camera aspect ratio is 4/3
            let bottomSpace = contentView.height - expectedCameraHeight
            bottomControlsContainerHeight.constant = bottomSpace
            cameraContainerViewHeight.constant = expectedCameraHeight
        }

        if let fastCamera = fastCamera {
            fastCamera.view.frame = cameraContainerView.frame
        }
    }

    private func switchToPreviewWith(image: UIImage?) {
        guard let image = image else { return }

        imagePreview.image = image
        setCaptureStateButtons(false)
        removeCamera()
    }

    private func switchToCaptureMode() {
        imagePreview.image = nil
        setCaptureStateButtons(true)
        setupCamera()
    }

    private func setCaptureStateButtons(captureState: Bool) {
        cornersContainer.hidden = !captureState
        imagePreview.hidden = captureState
        switchCamButton.hidden = !captureState
        flashButton.hidden = !captureState
        makePhotoButton.hidden = !captureState
        retryPhotoButton.hidden = captureState
        usePhotoButton.hidden = captureState
        cameraTextsContainer.hidden = !captureState
    }

    private func setFlashModeButton() {
        switch flashMode {
        case .Auto:
            flashButton.setImage(UIImage(named: "ic_post_flash_auto"), forState: UIControlState.Normal)
        case .On:
            flashButton.setImage(UIImage(named: "ic_post_flash"), forState: UIControlState.Normal)
        case .Off:
            flashButton.setImage(UIImage(named: "ic_post_flash_innactive"), forState: UIControlState.Normal)
        }
    }
}


// MARK: - FastttCameraDelegate

extension PostProductCameraView: FastttCameraDelegate {
    func cameraController(cameraController: FastttCameraInterface!, didFinishNormalizingCapturedImage
        capturedImage: FastttCapturedImage!) {
        switchToPreviewWith(capturedImage.fullImage)
    }
}


// MARK: - FastttCamera Enum extensions

private extension FastttCameraFlashMode {
    var next: FastttCameraFlashMode {
        switch self {
        case .Auto:
            return .On
        case .On:
            return .Off
        case .Off:
            return .Auto
        }
    }
}

private extension FastttCameraDevice {
    var toggle: FastttCameraDevice {
        switch self {
        case .Front:
            return .Rear
        case .Rear:
            return .Front
        }
    }
}

