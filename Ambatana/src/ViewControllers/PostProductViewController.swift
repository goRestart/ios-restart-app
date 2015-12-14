//
//  PostProductViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 11/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import FastttCamera

class PostProductViewController: BaseViewController, SellProductViewController, PostProductViewModelDelegate {

    weak var delegate: SellProductViewControllerDelegate?

    @IBOutlet weak var cameraContainerView: UIView!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var cornersContainer: UIView!

    @IBOutlet weak var cameraTextsContainer: UIView!
    @IBOutlet weak var cameraTitleLabel: UILabel!
    @IBOutlet weak var cameraSubtitleLabel: UILabel!
    @IBOutlet weak var switchCamButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var retryPhotoButton: UIButton!
    @IBOutlet weak var usePhotoButton: UIButton!
    @IBOutlet weak var makePhotoButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!

    @IBOutlet weak var selectPriceContainer: UIView!

    private var flashMode: FastttCameraFlashMode = .Auto
    private var cameraDevice: FastttCameraDevice = .Rear

    private var fastCamera : FastttCamera?

    // ViewModel
    private var viewModel : PostProductViewModel!


    // MARK: - Lifecycle

    convenience init() {
        self.init(viewModel: PostProductViewModel(), nibName: "PostProductViewController")
    }

    required init(viewModel: PostProductViewModel, nibName nibNameOrNil: String?) {
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        self.viewModel = viewModel
        self.viewModel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("PostProductViewController:deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        setupCamera()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeCamera()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }


    // MARK: - Actions
    @IBAction func onCloseButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onToggleFlashButton(sender: AnyObject) {
        guard let fastCamera = fastCamera else { return }
        guard fastCamera.isFlashAvailableForCurrentDevice() else { return }

        switch flashMode {
        case .Auto:
            flashMode = .On
        case .On:
            flashMode = .Off
        case .Off:
            flashMode = .Auto
        }

        setFlashModeButton()
        fastCamera.cameraFlashMode = flashMode
    }

    @IBAction func onToggleCameraButton(sender: AnyObject) {
        guard let fastCamera = fastCamera else { return }

        switch cameraDevice {
        case .Front:
            cameraDevice = .Rear
        case .Rear:
            cameraDevice = .Front
        }

        fastCamera.cameraDevice = cameraDevice
    }

    @IBAction func onTakePhotoButton(sender: AnyObject) {
        guard let fastCamera = fastCamera else { return }

        fastCamera.takePicture()
    }

    @IBAction func onGalleryButton(sender: AnyObject) {
        MediaPickerManager.showGalleryPickerIn(self)
    }

    @IBAction func onRetryPhotoButton(sender: AnyObject) {
        switchToCaptureMode()
    }

    @IBAction func onUsePhotoButton(sender: AnyObject) {
        guard let image = imagePreview.image else { return }
        viewModel.imageSelected(image)
    }


    // MARK: - PostProductViewModelDelegate

    func postProductViewModelDidStartUploadingImage(viewModel: PostProductViewModel) {
        switchToSelectPrice(true)
    }

    func postProductViewModelDidFinishUploadingImage(viewModel: PostProductViewModel, error: String?) {
        switchToSelectPrice(false)
    }


    // MARK: - Private methods

    private func setupView() {
        // Camera focus corners
        var i = 0
        for view in cornersContainer.subviews {
            switch i {
            case 1:
                view.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
            case 2:
                view.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            case 3:
                view.transform = CGAffineTransformMakeRotation(CGFloat(3*M_PI_2))
            default:
                break
            }
            i++
        }

        //i18n
        cameraTitleLabel.text = LGLocalizedString.productPostCameraTitle
        cameraSubtitleLabel.text = LGLocalizedString.productPostCameraSubtitle
        retryPhotoButton.setTitle(LGLocalizedString.productPostRetake, forState: UIControlState.Normal)
        usePhotoButton.setTitle(LGLocalizedString.productPostUsePhoto, forState: UIControlState.Normal)
    }

    private func setupCamera() {
        MediaPickerManager.requestCameraPermissions(self) { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.fastCamera = FastttCamera()
            guard let fastCamera = strongSelf.fastCamera else { return }

            fastCamera.scalesImage = true
            fastCamera.maxScaledDimension = 1024
            fastCamera.normalizesImageOrientations = true
            fastCamera.delegate = self
            strongSelf.fastttAddChildViewController(fastCamera, belowSubview: strongSelf.cameraContainerView)
            fastCamera.view.frame = strongSelf.cameraContainerView.frame
        }
    }

    private func removeCamera() {
        guard let fastCamera = fastCamera else { return }

        fastttRemoveChildViewController(fastCamera)
        self.fastCamera = nil
    }

    private func switchToPreviewWith(image: UIImage?) {
        guard let image = image else { return }

        imagePreview.image = image
        setCaptureStateButtons(false)
        removeCamera()
    }

    private func switchToCaptureMode() {
        setupCamera()
        imagePreview.image = nil
        setCaptureStateButtons(true)
    }

    private func switchToSelectPrice(loading: Bool) {
        selectPriceContainer.hidden = false
    }

    private func setCaptureStateButtons(captureState: Bool) {
        imagePreview.hidden = captureState
        switchCamButton.hidden = !captureState
        flashButton.hidden = !captureState
        makePhotoButton.hidden = !captureState
        galleryButton.hidden = !captureState
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

extension PostProductViewController: FastttCameraDelegate {
    /**
    *  Called when the camera controller has finished normalizing the captured photo.
    *
    *  @param cameraController The FastttCamera instance that captured the photo.
    *
    *  @param capturedImage    The FastttCapturedImage object, with the (UIImage *)fullImage and (UIImage *)scaledImage (if any) replaced
    *  by images that have been rotated so that their orientation is UIImageOrientationUp. This is a slower process than creating the
    *  initial images that are returned, which have varying orientations based on how the phone was held, but the normalized images
    *  are more ideal for uploading or saving as they are displayed more predictably in different browsers and applications than the
    *  initial images which have an orientation tag set that is not UIImageOrientationUp.
    *
    *  @note This method will not be called if normalizesImageOrientations is set to NO.
    */
    func cameraController(cameraController: FastttCameraInterface!, didFinishNormalizingCapturedImage capturedImage: FastttCapturedImage!) {
        print("didFinishNormalizingCapturedImage")

        switchToPreviewWith(capturedImage.scaledImage)
    }
}


// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension PostProductViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil { image = info[UIImagePickerControllerOriginalImage] as? UIImage }

        picker.dismissViewControllerAnimated(true, completion: nil)

        if let theImage = image {
            switchToPreviewWith(theImage)
        }
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
