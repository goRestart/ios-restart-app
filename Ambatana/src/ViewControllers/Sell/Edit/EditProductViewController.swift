//
//  EditProductViewController.swift
//  LetGo
//
//  Created by Dídac on 23/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import FBSDKShareKit
import LGCoreKit
import Result
import RxSwift


class EditProductViewController: BaseViewController, UITextFieldDelegate,
    UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate,
    UINavigationControllerDelegate, FBSDKSharingDelegate {
    
    // UI
    private static let loadingTitleDisclaimerLeadingConstraint: CGFloat = 8
    private static let completeTitleDisclaimerLeadingConstraint: CGFloat = -20
    private static let titleDisclaimerHeightConstraint: CGFloat = 16
    private static let titleDisclaimerBottomConstraintVisible: CGFloat = 24
    private static let titleDisclaimerBottomConstraintHidden: CGFloat = 8
    private static let separatorOptionsViewDistance = LGUIKitConstants.onePixelSize
    private static let viewOptionGenericHeight: CGFloat = 50

    enum TextFieldTag: Int {
        case ProductTitle = 1000, ProductPrice, ProductDescription
    }
    
    let descrPlaceholder = LGLocalizedString.sellDescriptionFieldHint
    let descrPlaceholderColor = UIColor(rgb: 0xC7C7CD)
    let sellProductCellReuseIdentifier = "SellProductCell"
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var containerEditOptionsView: UIView!
    
    @IBOutlet var separatorContainerViewsConstraints: [NSLayoutConstraint]!
    @IBOutlet weak var priceViewSeparatorTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var freePostViewSeparatorTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var titleContainerView: UIView!
    @IBOutlet weak var titleTextField: LGTextField!
    @IBOutlet weak var titleDisclaimer: UILabel!
    @IBOutlet weak var autoGeneratedTitleButton: UIButton!
    @IBOutlet weak var titleDisclaimerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleDisclaimerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleDisclaimerBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var postFreeView: UIView!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var priceContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var postFreeViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var freePostingSwitch: UISwitch!
    
    @IBOutlet weak var postFreeLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var priceTextField: LGTextField!
    
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionCharCountLabel: UILabel!
    @IBOutlet weak var titleDisclaimerActivityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var setLocationTitleLabel: UILabel!
    @IBOutlet weak var setLocationLocationLabel: UILabel!
    @IBOutlet weak var setLocationButton: UIButton!

    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var categorySelectedLabel: UILabel!
    @IBOutlet weak var categoryButton: UIButton!

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var shareFBSwitch: UISwitch!
    @IBOutlet weak var shareFBLabel: UILabel!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loadingProgressView: UIProgressView!

    var lines: [CALayer] = []

    // viewModel
    private var viewModel : EditProductViewModel

    // Rx
    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle
    

    init(viewModel: EditProductViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "EditProductViewController")
        
        self.viewModel.delegate = self
        automaticallyAdjustsScrollViewInsets = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setAccesibilityIds()
        setupRxBindings()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        descriptionTextView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: false)
    }
    
    // MARK: - Public methods
    
    // MARK: > Actions
  
    @IBAction func categoryButtonPressed(sender: AnyObject) {
        
        let alert = UIAlertController(title: LGLocalizedString.sellChooseCategoryDialogTitle, message: nil,
            preferredStyle: .ActionSheet)
        alert.popoverPresentationController?.sourceView = categoryButton
        alert.popoverPresentationController?.sourceRect = categoryButton.frame

        for i in 0..<viewModel.numberOfCategories {
            alert.addAction(UIAlertAction(title: viewModel.categoryNameAtIndex(i), style: .Default,
                handler: { (categoryAction) -> Void in
                    self.viewModel.selectCategoryAtIndex(i)
            }))
        }
        
        alert.addAction(UIAlertAction(title: LGLocalizedString.sellChooseCategoryDialogCancelButton,
            style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)

    }
    
    @IBAction func sendButtonPressed(sender: AnyObject) {
        viewModel.checkProductFields()
    }
    
    @IBAction func shareFBSwitchChanged(sender: AnyObject) {
        viewModel.shouldShareInFB = shareFBSwitch.on
    }

    // MARK: - TextField Delegate Methods

    func textFieldDidEndEditing(textField: UITextField) {
        guard let tag = TextFieldTag(rawValue: textField.tag) where tag == .ProductTitle else { return }
        if let text = textField.text {
            viewModel.userFinishedEditingTitle(text)
        }
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool {
        if textField == priceTextField && !textField.shouldChangePriceInRange(range, replacementString: string,
                                                                              acceptsSeparator: true) {
             return false
        }

        let cleanReplacement = string.stringByRemovingEmoji()

        let text = textField.textReplacingCharactersInRange(range, replacementString: cleanReplacement)
        if let tag = TextFieldTag(rawValue: textField.tag) {
            switch (tag) {
            case .ProductTitle:
                viewModel.title = text.isEmpty ? nil : text
                if string.hasEmojis() {
                    //Forcing the new text (without emojis) by returning false
                    textField.text = text
                    return false
                }
                viewModel.userWritesTitle(text)
            case .ProductPrice:
                viewModel.price = text.isEmpty ? nil : text
            case .ProductDescription:
                break
            }
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag == TextFieldTag.ProductTitle.rawValue {
            let nextTag = textField.tag + 1
            if let nextView = view.viewWithTag(nextTag) {
                nextView.becomeFirstResponder()
            }
        }
        return true
    }

    func textFieldShouldClear(textField: UITextField) -> Bool {
        if let tag = TextFieldTag(rawValue: textField.tag) where tag == .ProductTitle {
            viewModel.title = ""
            viewModel.userWritesTitle(textField.text)
        }
        return true
    }

    // MARK: - UITextViewDelegate Methods

    func textViewDidBeginEditing(textView: UITextView) {
        // clear text view placeholder
        if textView.text == descrPlaceholder && textView.textColor ==  descrPlaceholderColor {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
        scrollView.setContentOffset(CGPointMake(0,textView.frame.origin.y-64), animated: true)

    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = descrPlaceholder
            textView.textColor = descrPlaceholderColor
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if let textViewText = textView.text {
            let cleanReplacement = text.stringByRemovingEmoji()
            let finalText = (textViewText as NSString).stringByReplacingCharactersInRange(range, withString: cleanReplacement)
            if finalText != descrPlaceholder && textView.textColor != descrPlaceholderColor {
                viewModel.descr = finalText.isEmpty ? nil : finalText
                if text.hasEmojis() {
                    //Forcing the new text (without emojis) by returning false
                    textView.text = finalText
                    return false
                }
            }
        }
        return true
    }
    
    
    // MARK: - Collection View Data Source methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath)
        -> UICollectionViewCell {
        
            guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(sellProductCellReuseIdentifier,
                forIndexPath: indexPath) as? SellProductCell else { return UICollectionViewCell() }
            cell.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
            if indexPath.item < viewModel.numberOfImages {
                cell.setupCellWithImageType(viewModel.imageAtIndex(indexPath.item))
                cell.label.text = ""
            } else if indexPath.item == viewModel.numberOfImages {
                cell.setupAddPictureCell()
            } else {
                cell.setupEmptyCell()
            }
            return cell
    }
    
    
    // MARK: - Collection View Delegate methods

    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.item == viewModel.numberOfImages {
            // add image
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as? SellProductCell
            cell?.highlight()
            MediaPickerManager.showImagePickerIn(self)
            if indexPath.item > 1 && indexPath.item < 4 {
                collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: indexPath.item+1, inSection: 0),
                    atScrollPosition: UICollectionViewScrollPosition.Right, animated: true)
            }
            
        } else if (indexPath.item < viewModel.numberOfImages) {
            // remove image
            let alert = UIAlertController(title: LGLocalizedString.sellPictureSelectedTitle, message: nil,
                preferredStyle: .ActionSheet)
            
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as? SellProductCell
            alert.popoverPresentationController?.sourceView = cell
            alert.popoverPresentationController?.sourceRect = cell?.bounds ?? CGRectZero
            
            alert.addAction(UIAlertAction(title: LGLocalizedString.sellPictureSelectedDeleteButton,
                style: .Destructive, handler: { (deleteAction) -> Void in
                    self.deleteAlreadyUploadedImageWithIndex(indexPath.row)
                    guard indexPath.item > 0 else { return }
                    collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: indexPath.item-1, inSection: 0),
                            atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
            }))
            alert.addAction(UIAlertAction(title: LGLocalizedString.sellPictureSelectedSaveIntoCameraRollButton,
                style: .Default, handler: { (saveAction) -> Void in
                    self.saveProductImageToDiskAtIndex(indexPath.row)
            }))
            alert.addAction(UIAlertAction(title: LGLocalizedString.sellPictureSelectedCancelButton,
                style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    // MARK: UIImagePicker Delegate
 
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo
        info: [String : AnyObject]) {
            var image = info[UIImagePickerControllerEditedImage] as? UIImage
            if image == nil { image = info[UIImagePickerControllerOriginalImage] as? UIImage }
            
            self.dismissViewControllerAnimated(true, completion: nil)

            if let theImage = image {
                viewModel.appendImage(theImage)
            }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    // MARK: - Managing images.
    
    func deleteAlreadyUploadedImageWithIndex(index: Int) {
        // delete the image file locally
        viewModel.deleteImageAtIndex(index)
    }
    
    func saveProductImageToDiskAtIndex(index: Int) {
        showLoadingMessageAlert(LGLocalizedString.sellPictureSaveIntoCameraRollLoading)
        
        // get the image and launch the saving action.
        let imageTypeAtIndex = viewModel.imageAtIndex(index)
        switch imageTypeAtIndex {
        case .Local(let image):
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(EditProductViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        case .Remote(let file):
            guard let fileUrl = file.fileURL else {
                self.dismissLoadingMessageAlert(){
                    self.showAutoFadingOutMessageAlert(LGLocalizedString.sellPictureSaveIntoCameraRollErrorGeneric)
                }
                return
            }
            ImageDownloader.sharedInstance.downloadImageWithURL(fileUrl) { [weak self] (result, _) in
                guard let strongSelf = self, let image = result.value?.image else { return }
                UIImageWriteToSavedPhotosAlbum(image, strongSelf, #selector(EditProductViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
    
    func image(image: UIImage!, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
        self.dismissLoadingMessageAlert(){
            if error == nil { // success
                self.showAutoFadingOutMessageAlert(LGLocalizedString.sellPictureSaveIntoCameraRollOk)
            } else {
                self.showAutoFadingOutMessageAlert(LGLocalizedString.sellPictureSaveIntoCameraRollErrorGeneric)
            }
        }
    }


    // MARK: - Private methods

    func setupUI() {

        setNavBarTitle(LGLocalizedString.editProductTitle)
        let closeButton = UIBarButtonItem(image: UIImage(named: "navbar_close"), style: UIBarButtonItemStyle.Plain,
                                          target: self, action: #selector(EditProductViewController.closeButtonPressed))
        self.navigationItem.leftBarButtonItem = closeButton;
        
        separatorContainerViewsConstraints.forEach { $0.constant = EditProductViewController.separatorOptionsViewDistance }
        containerEditOptionsView.layer.cornerRadius = LGUIKitConstants.containerCornerRadius
        
        titleTextField.placeholder = LGLocalizedString.sellTitleFieldHint
        titleTextField.text = viewModel.title
        titleTextField.tag = TextFieldTag.ProductTitle.rawValue
        titleDisclaimer.textColor = UIColor.darkGrayText
        titleDisclaimer.font = UIFont.smallBodyFont

        autoGeneratedTitleButton.layer.cornerRadius = autoGeneratedTitleButton.frame.height/2
        titleDisclaimerActivityIndicator.transform = CGAffineTransformScale(titleDisclaimerActivityIndicator.transform, 0.8, 0.8)

        postFreeLabel.text = LGLocalizedString.sellPostFreeLabel
        
        currencyLabel.text = viewModel.currency?.code

        priceTextField.placeholder = LGLocalizedString.productNegotiablePrice
        priceTextField.text = viewModel.price
        priceTextField.tag = TextFieldTag.ProductPrice.rawValue
        priceTextField.insetX = 16.0
        
        if viewModel.descr?.characters.count > 0 {
            descriptionTextView.text = viewModel.descr
            descriptionTextView.textColor = UIColor.blackColor()
        } else {
            descriptionTextView.text = descrPlaceholder
            descriptionTextView.textColor = descrPlaceholderColor
        }
        descriptionTextView.textContainerInset = UIEdgeInsetsMake(12.0, 11.0, 12.0, 11.0)
        descriptionTextView.tintColor = UIColor.primaryColor
        descriptionTextView.tag = TextFieldTag.ProductDescription.rawValue
        descriptionCharCountLabel.text = "\(viewModel.descriptionCharCount)"

        setLocationTitleLabel.text = LGLocalizedString.settingsChangeLocationButton

        categoryTitleLabel.text = LGLocalizedString.sellCategorySelectionLabel
        categorySelectedLabel.text = viewModel.categoryName ?? ""

        sendButton.setTitle(LGLocalizedString.editProductSendButton, forState: .Normal)
        sendButton.setStyle(.Primary(fontSize:.Big))
        
        shareFBSwitch.on = viewModel.shouldShareInFB
        shareFBLabel.text = LGLocalizedString.sellShareOnFacebookLabel
        
        if FeatureFlags.freePostingMode.enabled {
            postFreeViewHeightConstraint.constant = EditProductViewController.viewOptionGenericHeight
            freePostViewSeparatorTopConstraint.constant = EditProductViewController.separatorOptionsViewDistance
        } else {
            postFreeViewHeightConstraint.constant = 0
            freePostViewSeparatorTopConstraint.constant = 0
        }
        
        // CollectionView
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        let cellNib = UINib(nibName: "SellProductCell", bundle: nil)
        self.imageCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: sellProductCellReuseIdentifier)
        
        loadingLabel.text = LGLocalizedString.sellUploadingLabel
    }

    private func setupRxBindings() {
        Observable.combineLatest(viewModel.titleAutogenerated.asObservable(),
        viewModel.titleAutotranslated.asObservable()) { ($0, $1) }
            .map { (titleAutogenerated, titleAutotranslated) in
                if titleAutogenerated && titleAutotranslated {
                    return LGLocalizedString.sellTitleAutogenAutotransLabel
                } else if titleAutogenerated {
                    return LGLocalizedString.sellTitleAutogenLabel
                } else {
                    return nil
                }
            }
            .bindTo(titleDisclaimer.rx_optionalText)
            .addDisposableTo(disposeBag)

        viewModel.titleDisclaimerStatus.asObservable().bindNext { [weak self] status in
            guard let strongSelf = self else { return }
            switch status {
            case .Completed:
                strongSelf.autoGeneratedTitleButton.hidden = true
                strongSelf.titleDisclaimerActivityIndicator.stopAnimating()

                if strongSelf.viewModel.titleAutogenerated.value || strongSelf.viewModel.titleAutotranslated.value {
                    strongSelf.titleDisclaimer.hidden = false
                    strongSelf.titleDisclaimerLeadingConstraint.constant = EditProductViewController.completeTitleDisclaimerLeadingConstraint
                    strongSelf.titleDisclaimerHeightConstraint.constant = EditProductViewController.titleDisclaimerHeightConstraint
                    strongSelf.titleDisclaimerBottomConstraint.constant = EditProductViewController.titleDisclaimerBottomConstraintVisible
                } else {
                    strongSelf.titleDisclaimer.hidden = true
                    strongSelf.titleDisclaimerLeadingConstraint.constant = EditProductViewController.loadingTitleDisclaimerLeadingConstraint
                    strongSelf.titleDisclaimerHeightConstraint.constant = 0
                    strongSelf.titleDisclaimerBottomConstraint.constant = EditProductViewController.titleDisclaimerBottomConstraintHidden
                }
            case .Ready:
                strongSelf.autoGeneratedTitleButton.hidden = false
                strongSelf.titleDisclaimerActivityIndicator.stopAnimating()
                strongSelf.titleDisclaimer.hidden = true
                strongSelf.titleDisclaimerHeightConstraint.constant = EditProductViewController.titleDisclaimerHeightConstraint
                strongSelf.titleDisclaimerBottomConstraint.constant = EditProductViewController.titleDisclaimerBottomConstraintVisible
            case .Loading:
                strongSelf.autoGeneratedTitleButton.hidden = true
                strongSelf.titleDisclaimerActivityIndicator.startAnimating()
                strongSelf.titleDisclaimerLeadingConstraint.constant = 8
                strongSelf.titleDisclaimer.hidden = false
                strongSelf.titleDisclaimerHeightConstraint.constant = EditProductViewController.titleDisclaimerHeightConstraint
                strongSelf.titleDisclaimerBottomConstraint.constant = EditProductViewController.titleDisclaimerBottomConstraintVisible
                strongSelf.titleDisclaimer.text = LGLocalizedString.editProductSuggestingTitle
            case .Clean:
                strongSelf.autoGeneratedTitleButton.hidden = true
                strongSelf.titleDisclaimerActivityIndicator.stopAnimating()
                strongSelf.titleDisclaimer.hidden = true
                strongSelf.titleDisclaimerHeightConstraint.constant = 0
                strongSelf.titleDisclaimerBottomConstraint.constant = EditProductViewController.titleDisclaimerBottomConstraintHidden
            }
            strongSelf.view.layoutIfNeeded()
        }.addDisposableTo(disposeBag)

        viewModel.proposedTitle.asObservable().bindTo(autoGeneratedTitleButton.rx_title).addDisposableTo(disposeBag)

        autoGeneratedTitleButton.rx_tap.bindNext { [weak self] in
            self?.titleTextField.text = self?.autoGeneratedTitleButton.titleLabel?.text
            self?.viewModel.title = self?.titleTextField.text
            self?.viewModel.userSelectedSuggestedTitle()
        }.addDisposableTo(disposeBag)

        viewModel.titleAutogenerated.asObservable()

        viewModel.locationInfo.asObservable().bindTo(setLocationLocationLabel.rx_text).addDisposableTo(disposeBag)

        setLocationButton.rx_tap.bindNext { [weak self] in
            self?.viewModel.openMap()
        }.addDisposableTo(disposeBag)
        
        viewModel.isFreePosting.asObservable().bindTo(freePostingSwitch.rx_value).addDisposableTo(disposeBag)
        freePostingSwitch.rx_value.bindTo(viewModel.isFreePosting).addDisposableTo(disposeBag)
        viewModel.isFreePosting.asObservable().bindNext{[weak self] active in
            self?.updateFreePostViews(active)
            }.addDisposableTo(disposeBag)
    }
    
    override func popBackViewController() {
        super.popBackViewController()
    }
    
    internal func editCompleted() {
        showAutoFadingOutMessageAlert(LGLocalizedString.editProductSendOk) { [weak self] in
            self?.dismiss(nil)
        }
    }
    
    // MARK: - Private methods
    
    private func updateFreePostViews(active: Bool) {
        if active {
            priceContainerHeightConstraint.constant = 0
            priceViewSeparatorTopConstraint.constant = 0
        } else {
            priceContainerHeightConstraint.constant = EditProductViewController.viewOptionGenericHeight
            priceViewSeparatorTopConstraint.constant = EditProductViewController.separatorOptionsViewDistance
        }
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }

    dynamic func closeButtonPressed() {
        dismiss()
    }

    private func dismiss(action: (() -> ())? = nil) {
        dismissViewControllerAnimated(true) { [weak self] in

            // TODO: Refactor w EditCoordinator
            self?.viewModel.didClose()
            action?()
        }
    }
    
    // MARK: - Share in facebook.
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        viewModel.shouldEnableTracking()
        viewModel.trackSharedFB()
        // @ahl: delayed is needed thanks to facebook
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.editCompleted()
        }
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        viewModel.shouldEnableTracking()
        // @ahl: delayed is needed thanks to facebook
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.showAutoFadingOutMessageAlert(LGLocalizedString.sellSendErrorSharingFacebook) {
                self.editCompleted()
            }
        }
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        viewModel.shouldEnableTracking()
        // @ahl: delayed is needed thanks to facebook
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.editCompleted()
        }
    }
}


// MARK: - EditProductViewModelDelegate Methods

extension EditProductViewController: EditProductViewModelDelegate {


    func vmDidSelectCategoryWithName(categoryName: String) {
        categorySelectedLabel.text = categoryName
    }

    func vmShouldUpdateDescriptionWithCount(count: Int) {

        if count <= 0 {
            descriptionCharCountLabel.textColor = UIColor.primaryColor
        } else {
            descriptionCharCountLabel.textColor = UIColor.blackColor()
        }
        descriptionCharCountLabel.text = "\(count)"
    }

    func vmDidAddOrDeleteImage() {
        imageCollectionView.reloadSections(NSIndexSet(index: 0))
    }

    func vmDidStartSavingProduct() {
        loadingView.hidden = false
        loadingProgressView.setProgress(0, animated: false)
    }

    func vmDidUpdateProgressWithPercentage(percentage: Float) {
        loadingProgressView.setProgress(percentage, animated: false)
    }

    func vmDidFinishSavingProductWithResult(result: ProductResult) {
        loadingView.hidden = true

        if viewModel.shouldShareInFB {
            viewModel.shouldDisableTracking()
            let content = viewModel.fbShareContent
            FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: self)
        } else {
            editCompleted()
        }
    }

    func vmDidFailWithError(error: ProductCreateValidationError) {
        loadingView.hidden = true

        var completion: ((Void) -> Void)? = nil

        let message: String
        switch (error) {
        case .Network, .Internal, .ServerError:
            self.viewModel.shouldDisableTracking()
            message = LGLocalizedString.editProductSendErrorUploadingProduct
            completion = {
                self.viewModel.shouldEnableTracking()
            }
        case .NoImages:
            message = LGLocalizedString.sellSendErrorInvalidImageCount
        case .NoTitle:
            message = LGLocalizedString.sellSendErrorInvalidTitle
        case .NoPrice:
            message = LGLocalizedString.sellSendErrorInvalidPrice
        case .NoDescription:
            message = LGLocalizedString.sellSendErrorInvalidDescription
        case .LongDescription:
            message = LGLocalizedString.sellSendErrorInvalidDescriptionTooLong(Constants.productDescriptionMaxLength)
        case .NoCategory:
            message = LGLocalizedString.sellSendErrorInvalidCategory
        }
        self.showAutoFadingOutMessageAlert(message, completion: completion)
    }

    func vmFieldCheckSucceeded() {
        ifLoggedInThen(.Sell, loggedInAction: { [weak self] in
            self?.viewModel.save()
            }, elsePresentSignUpWithSuccessAction: { [weak self] in
                self?.viewModel.save()
            })
    }

    func vmShouldOpenMapWithViewModel(locationViewModel: EditLocationViewModel) {
        let vc = EditLocationViewController(viewModel: locationViewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - Accesibility 

extension EditProductViewController {
    func setAccesibilityIds() {
        navigationItem.leftBarButtonItem?.accessibilityId = .EditProductCloseButton
        scrollView.accessibilityId = .EditProductScroll
        titleTextField.accessibilityId = .EditProductTitleField
        autoGeneratedTitleButton.accessibilityId = .EditProductAutoGenTitleButton
        imageCollectionView.accessibilityId = .EditProductImageCollection
        currencyLabel.accessibilityId = .EditProductCurrencyButton
        priceTextField.accessibilityId = .EditProductPriceField
        descriptionTextView.accessibilityId = .EditProductDescriptionField
        setLocationButton.accessibilityId = .EditProductLocationButton
        categoryButton.accessibilityId = .EditProductCategoryButton
        sendButton.accessibilityId = .EditProductSendButton
        shareFBSwitch.accessibilityId = .EditProductShareFBSwitch
        loadingView.accessibilityId = .EditProductLoadingView
        freePostingSwitch.accessibilityId = .EditProductPostFreeSwitch
    }
}
