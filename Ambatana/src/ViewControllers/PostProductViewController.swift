//
//  PostProductViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 11/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import FastttCamera

class PostProductViewController: BaseViewController, SellProductViewController {

    weak var delegate: SellProductViewControllerDelegate?

    @IBOutlet weak var cameraContainerView: UIView!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var cornersContainer: UIView!

    @IBOutlet weak var switchCamButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var retryPhotoButton: UIButton!
    @IBOutlet weak var usePhotoButton: UIButton!
    @IBOutlet weak var makePhotoButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!

    @IBOutlet weak var selectPriceContainer: UIView!


    var flashMode: FastttCameraFlashMode = .Auto
    var cameraDevice: FastttCameraDevice = .Rear

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
//        self.viewModel.delegate = self
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
        startUploadAndSwitchToSelectPrice()
    }

    // MARK: - Private methods

    private func setupView() {
        //Corners
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
    }

    private func setupCamera() {
        fastCamera = FastttCamera()
        guard let fastCamera = fastCamera else { return }

        fastCamera.scalesImage = true
        fastCamera.maxScaledDimension = 1024
        fastCamera.normalizesImageOrientations = true
        fastCamera.delegate = self
        fastttAddChildViewController(fastCamera, belowSubview: cameraContainerView)
        fastCamera.view.frame = cameraContainerView.frame
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

    private func startUploadAndSwitchToSelectPrice() {
        // TODO: START UPLOAD

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
    *  Called when the camera controller has obtained the raw data containing the image and metadata.
    *
    *  @param cameraController The FastttCamera instance that captured a photo.
    *
    *  @param rawJPEGData The plain, raw data from the camera, ready to be written to a file if desired.
    *
    */
    func cameraController(cameraController: FastttCameraInterface!, didFinishCapturingImageData rawJPEGData: NSData!) {
        print("didFinishCapturingImageData")
    }

    /**
    *  Called when the camera controller has finished capturing a photo.
    *
    *  @param cameraController The FastttCamera instance that captured a photo.
    *
    *  @param capturedImage The FastttCapturedImage object, containing a full-resolution (UIImage *)fullImage that has not
    *  yet had its orientation normalized (it has not yet been rotated so that its orientation is UIImageOrientationUp),
    *  and a (UIImage *)previewImage that has its image orientation set so that it is rotated to match the camera preview's
    *  orientation as it was captured, so if the device was held landscape left, the image returned will be set to display so
    *  that landscape left is "up". This is great if your interface doesn't rotate, or if the photo was taken with orientation lock on.
    *
    *  @note if you set returnsRotatedPreview=NO, there will be no previewImage here, and if you set cropsImageToVisibleAspectRatio=NO,
    *  the fullImage will be the raw image captured by the camera, while by default the fullImage will have been cropped to the visible
    *  camera preview's aspect ratio.
    */
    func cameraController(cameraController: FastttCameraInterface!, didFinishCapturingImage capturedImage: FastttCapturedImage!) {
        print("didFinishCapturingImage")
    }

    /**
    *  Called when the camera controller has finished scaling the captured photo.
    *
    *  @param cameraController The FastttCamera instance that captured a photo.
    *
    *  @param capturedImage    The FastttCapturedImage object, which now also contains a scaled (UIImage *)scaledImage, that has not yet
    *  had its orientation normalized. The image by default is scaled to fit within the camera's preview window, but you can
    *  set a custom maxScaledDimension above.
    *
    *  @note This method will not be called if scalesImage is set to NO.
    */
    func cameraController(cameraController: FastttCameraInterface!, didFinishScalingCapturedImage capturedImage: FastttCapturedImage!) {
        print("didFinishScalingCapturedImage")
    }

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

    /**
    *  Called when the camera controller asks for permission to access the user's camera and is denied.
    *
    *  @param cameraController The FastttCamera instance.
    *
    *  @note Use this optional method to handle gracefully the case where the user has denied camera access, either disabling the camera
    *  if not necessary or redirecting the user to your app's Settings page where they can enable the camera permissions. Remember that iOS
    *  will only show the user an alert requesting permission in-app one time. If the user denies permission, they must change this setting
    *  in the app's permissions page within the Settings App. This method will be called every time the app launches or becomes active and
    *  finds that permission to access the camera has not been granted.
    */
    func userDeniedCameraPermissionsForCameraController(cameraController: FastttCameraInterface!) {
        print("userDeniedCameraPermissionsForCameraController")
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
