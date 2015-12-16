//
//  PostProductViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 11/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import FastttCamera

class PostProductViewController: BaseViewController, SellProductViewController, PostProductViewModelDelegate,
UITextFieldDelegate {

    weak var delegate: SellProductViewControllerDelegate?

    @IBOutlet weak var cameraContainerView: UIView!
    @IBOutlet weak var cameraContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var cornersContainer: UIView!

    @IBOutlet weak var bottomControlsContainerHeight: NSLayoutConstraint!
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
    @IBOutlet weak var customLoadingView: LoadingIndicator!
    @IBOutlet weak var postedInfoLabel: UILabel!
    @IBOutlet weak var addPriceLabel: UILabel!
    @IBOutlet weak var priceFieldContainer: UIView!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var postErrorLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!

    private static let bottomControlsCollapsedSize: CGFloat = 88
    private static let bottomControlsExpandedSize: CGFloat = 140

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

        viewModel.onViewLoaded()

        setupView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        adaptLayoutsToScreenSize()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        setupCamera()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().statusBarHidden = true
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        UIApplication.sharedApplication().statusBarHidden = false
        removeCamera()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Actions
    @IBAction func onCloseButton(sender: AnyObject) {
        viewModel.closeButtonPressed(sellController: self, delegate: delegate)
        priceTextField.resignFirstResponder()
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
        viewModel.pressedRetakeImage()
    }

    @IBAction func onUsePhotoButton(sender: AnyObject) {
        guard let image = imagePreview.image else { return }
        viewModel.imageSelected(image)
    }
    
    @IBAction func onCurrencyButton(sender: AnyObject) {
        //Not implemented right now
    }

    @IBAction func onDoneButton(sender: AnyObject) {
        priceTextField.resignFirstResponder()
        viewModel.doneButtonPressed(priceText: priceTextField.text, sellController: self, delegate: delegate)
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onRetryButton(sender: AnyObject) {
        onUsePhotoButton(sender)
    }


    // MARK: - PostProductViewModelDelegate

    func postProductViewModelDidRestartTakingImage(viewModel: PostProductViewModel) {
        switchToCaptureMode()
    }

    func postProductViewModel(viewModel: PostProductViewModel, didSelectImage image: UIImage) {
        switchToPreviewWith(image)
    }

    func postProductViewModelDidStartUploadingImage(viewModel: PostProductViewModel) {
        setSelectPriceState(loading: true, error: nil)
    }

    func postProductViewModelDidFinishUploadingImage(viewModel: PostProductViewModel, error: String?) {
        setSelectPriceState(loading: false, error: error)
    }


    // MARK: - UITextFieldDelegate

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
        replacementString string: String) -> Bool {

            guard textField == priceTextField else { return true }

            let updatedText: String
            if let text = textField.text {
                updatedText = (text as NSString).stringByReplacingCharactersInRange(range, withString: string)
            } else {
                updatedText = string
            }
            return updatedText.isValidLengthPrice()
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
        addPriceLabel.text = LGLocalizedString.productPostPriceLabel
        priceTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.productNegotiablePrice,
            attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        doneButton.setTitle(LGLocalizedString.productPostDone, forState: UIControlState.Normal)
        retryButton.setTitle(LGLocalizedString.commonErrorListRetryButton, forState: UIControlState.Normal)

        //Layers
        retryButton.layer.cornerRadius = 4
        doneButton.layer.cornerRadius = 4
        priceFieldContainer.layer.cornerRadius = 4
        priceFieldContainer.layer.borderColor = UIColor.whiteColor().CGColor
        priceFieldContainer.layer.borderWidth = 1

        currencyButton.setTitle(viewModel.currency.symbol, forState: UIControlState.Normal)
    }

    private func setupCamera() {
        guard fastCamera == nil && imagePreview.hidden && selectPriceContainer.hidden else { return }

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
        imagePreview.image = nil
        setCaptureStateButtons(true)
        setupCamera()
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
        selectPriceContainer.hidden = true
    }

    private func setSelectPriceState(loading loading: Bool, error: String?) {
        selectPriceContainer.hidden = false
        let hasError = error != nil

        if(loading) {
            customLoadingView.startAnimating()
            setSelectPriceItems(loading, error: error)
        }
        else {
            customLoadingView.stopAnimating(!hasError) { [weak self] in
                self?.setSelectPriceItems(loading, error: error)
            }
        }
    }

    private func setSelectPriceItems(loading: Bool, error: String?) {
        let hasError = error != nil
        postedInfoLabel.hidden = loading
        postedInfoLabel.text = hasError ?
            LGLocalizedString.commonErrorTitle.capitalizedString : LGLocalizedString.productPostProductPosted
        addPriceLabel.hidden = loading || hasError
        priceFieldContainer.hidden = loading || hasError
        doneButton.hidden = loading || hasError
        postErrorLabel.hidden = loading || !hasError
        postErrorLabel.text = error
        retryButton.hidden = loading || !hasError

        if !loading && !hasError {
            priceTextField.becomeFirstResponder()
        }
        else {
            priceTextField.resignFirstResponder()
        }

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

    private func adaptLayoutsToScreenSize() {

        let expectedCameraHeight = self.view.width * (4/3) //Camera aspect ratio is 4/3
        let bottomSpace = self.view.height - expectedCameraHeight

        if bottomSpace < PostProductViewController.bottomControlsExpandedSize {
            //Small screen mode -> collapse buttons (hiding some info) + expand camera
            bottomControlsContainerHeight.constant = PostProductViewController.bottomControlsCollapsedSize
            cameraTextsContainer.hidden = true
            cameraContainerViewHeight.constant = self.view.height
        }
        else {
            bottomControlsContainerHeight.constant = bottomSpace
            cameraContainerViewHeight.constant = expectedCameraHeight
        }

        if let fastCamera = fastCamera {
            fastCamera.view.frame = cameraContainerView.frame
        }
    }
}


// MARK: - FastttCameraDelegate

extension PostProductViewController: FastttCameraDelegate {
    func cameraController(cameraController: FastttCameraInterface!, didFinishNormalizingCapturedImage capturedImage: FastttCapturedImage!) {
        print("didFinishNormalizingCapturedImage")
        viewModel.takenImageFromCamera(capturedImage.scaledImage)
    }
}


// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension PostProductViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil { image = info[UIImagePickerControllerOriginalImage] as? UIImage }

        if let theImage = image {
            viewModel.takenImageFromGallery(theImage)
        }

        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
