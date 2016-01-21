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
    @IBOutlet weak var selectPriceContentContainerCenterY: NSLayoutConstraint!
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
        modalPresentationStyle = .OverCurrentContext
        self.viewModel = viewModel
        self.viewModel.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:",
            name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:",
            name: UIKeyboardWillHideNotification, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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


    // MARK: - Actions
    
    @IBAction func onCloseButton(sender: AnyObject) {
        priceTextField.resignFirstResponder()
        if viewModel.shouldShowCloseAlert() {
            let alert = UIAlertController(title: LGLocalizedString.productPostCloseAlertTitle,
                message: LGLocalizedString.productPostCloseAlertDescription, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: LGLocalizedString.productPostCloseAlertCloseButton,
                style: .Cancel, handler: { [weak self] action in
                    guard let strongSelf = self else { return }
                    strongSelf.viewModel.closeButtonPressed(sellController: strongSelf, delegate: strongSelf.delegate)
                })
            let postAction = UIAlertAction(title: LGLocalizedString.productPostCloseAlertOkButton, style: .Default,
                handler: { [weak self] action in
                    guard let strongSelf = self else { return }
                    strongSelf.viewModel.doneButtonPressed(priceText: nil, sellController: strongSelf,
                        delegate: strongSelf.delegate)
            })
            alert.addAction(cancelAction)
            alert.addAction(postAction)
            presentViewController(alert, animated: true, completion: nil)
        } else {
            viewModel.closeButtonPressed(sellController: self, delegate: delegate)
        }
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

    func postProductviewModelshouldClose(viewModel: PostProductViewModel, animated: Bool, completion: (() -> Void)?) {
        dismissViewControllerAnimated(animated, completion: completion)
    }

    func postProductviewModel(viewModel: PostProductViewModel, shouldAskLoginWithCompletion completion: () -> Void) {
        ifLoggedInThen(.Sell, loginStyle: .Popup(LGLocalizedString.productPostLoginMessage),
            preDismissAction: { [weak self] in
                self?.view.hidden = true
            },
            loggedInAction: completion,
            elsePresentSignUpWithSuccessAction: completion)
    }


    // MARK: - UITextFieldDelegate

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
        replacementString string: String) -> Bool {
            guard textField == priceTextField else { return true }
            return textField.shouldChangePriceInRange(range, replacementString: string)
    }


    // MARK: - Private methods

    private func setupView() {
        //We're using same image for the 4 corners, so 3 of them must be rotated to the correct angle
        for (index, view) in cornersContainer.subviews.enumerate() {
            guard index > 0 else { continue }
            view.transform = CGAffineTransformMakeRotation(CGFloat(Double(index) * M_PI_2))
        }

        //i18n
        cameraTitleLabel.text = LGLocalizedString.productPostCameraTitle
        cameraSubtitleLabel.text = LGLocalizedString.productPostCameraSubtitle
        retryPhotoButton.setTitle(LGLocalizedString.productPostRetake, forState: UIControlState.Normal)
        usePhotoButton.setTitle(viewModel.usePhotoButtonText, forState: UIControlState.Normal)
        addPriceLabel.text = LGLocalizedString.productPostPriceLabel.uppercaseString
        priceTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.productNegotiablePrice,
            attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        doneButton.setTitle(LGLocalizedString.productPostDone, forState: UIControlState.Normal)
        retryButton.setTitle(LGLocalizedString.commonErrorListRetryButton, forState: UIControlState.Normal)

        //Layers
        retryButton.setPrimaryStyle()
        doneButton.setPrimaryStyle()
        priceFieldContainer.layer.cornerRadius = StyleHelper.defaultCornerRadius
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

            fastCamera.scalesImage = false
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
        cornersContainer.hidden = !captureState
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

        postedInfoLabel.alpha = 0
        postedInfoLabel.text = error != nil ?
            LGLocalizedString.commonErrorTitle.capitalizedString : viewModel.confirmationOkText
        postErrorLabel.text = error

        if (loading) {
            setSelectPriceBottomItems(loading, error: error)
        } else {
            UIView.animateWithDuration(0.2,
                animations: { [weak self] in
                    self?.postedInfoLabel.alpha = 1
                },
                completion: { [weak self] completed in
                    self?.postedInfoLabel.alpha = 1
                    self?.setSelectPriceBottomItems(loading, error: error)
                }
            )
        }
    }

    private func setSelectPriceBottomItems(loading: Bool, error: String?) {
        addPriceLabel.alpha = 0
        priceFieldContainer.alpha = 0
        doneButton.alpha = 0
        postErrorLabel.alpha = 0
        retryButton.alpha = 0

        guard !loading else { return }

        let okItemsAlpha: CGFloat = error != nil ? 0 : 1
        let wrongItemsAlpha: CGFloat = error == nil ? 0 : 1
        let finalAlphaBlock = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.addPriceLabel.alpha = okItemsAlpha
            strongSelf.priceFieldContainer.alpha = okItemsAlpha
            strongSelf.doneButton.alpha = okItemsAlpha
            strongSelf.postErrorLabel.alpha = wrongItemsAlpha
            strongSelf.retryButton.alpha = wrongItemsAlpha
        }
        UIView.animateWithDuration(0.2, delay: 0.8, options: UIViewAnimationOptions(),
            animations: { () -> Void in
                finalAlphaBlock()
            }, completion: { [weak self] (completed: Bool) -> Void in
                finalAlphaBlock()

                if okItemsAlpha == 1 {
                    self?.priceTextField.becomeFirstResponder()
                } else {
                    self?.priceTextField.resignFirstResponder()
                }
            }
        )
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
        } else {
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
        viewModel.takenImageFromCamera(capturedImage.fullImage)
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


// MARK: - Keyboard notifications

extension PostProductViewController {
    
    func keyboardWillShow(notification: NSNotification) {
        centerPriceContentContainer(notification)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        centerPriceContentContainer(notification)
    }
    
    func centerPriceContentContainer(keyboardNotification: NSNotification) {
        let kbAnimation = KeyboardAnimation(keyboardNotification: keyboardNotification)
        UIView.animateWithDuration(kbAnimation.duration, delay: 0, options: kbAnimation.options, animations: {
            [weak self] in
            self?.selectPriceContentContainerCenterY.constant = -(kbAnimation.size.height/2)
            self?.selectPriceContainer.layoutIfNeeded()
        }, completion: nil)
    }
    
}


// MARK: - FastttCamera Enum extensions

extension FastttCameraFlashMode {
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

extension FastttCameraDevice {
    var toggle: FastttCameraDevice {
        switch self {
        case .Front:
            return .Rear
        case .Rear:
            return .Front
        }
    }
}
