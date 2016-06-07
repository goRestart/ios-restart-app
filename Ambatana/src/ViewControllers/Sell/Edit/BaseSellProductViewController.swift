//
//  SellProductViewController.swift
//  LetGo
//
//  Created by Dídac on 23/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import FBSDKShareKit
import LGCoreKit
import Result
import RxSwift


class BaseSellProductViewController: BaseViewController, SellProductViewModelDelegate, UITextFieldDelegate,
UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, FBSDKSharingDelegate, SellProductViewController {
    
    // UI
    
    enum TextFieldTag: Int {
        case ProductTitle = 1000, ProductPrice, ProductDescription
    }
    
    let descrPlaceholder = LGLocalizedString.sellDescriptionFieldHint
    let descrPlaceholderColor = UIColor(rgb: 0xC7C7CD)
    let sellProductCellReuseIdentifier = "SellProductCell"
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleContainerView: UIView!
    @IBOutlet weak var titleTextField: LGTextField!
    @IBOutlet weak var titleDisclaimer: UILabel!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var priceTextField: LGTextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionCharCountLabel: UILabel!

    @IBOutlet weak var setLocationTitleLabel: UILabel!
    @IBOutlet weak var setLocationLocationLabel: UILabel!
    @IBOutlet weak var setLocationButton: UIButton!

    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var shareFBSwitch: UISwitch!
    @IBOutlet weak var shareFBLabel: UILabel!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loadingProgressView: UIProgressView!

    var lines: [CALayer] = []

    // viewModel
    private var viewModel : BaseSellProductViewModel!

    // Rx
    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle
    
    convenience init() {
        self.init(viewModel: BaseSellProductViewModel())
    }
    
    init(viewModel: BaseSellProductViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "BaseSellProductViewController")
        
        self.viewModel.delegate = self
        
        automaticallyAdjustsScrollViewInsets = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupRxBindings()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        descriptionTextView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: false)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Redraw the lines
        lines.forEach { $0.removeFromSuperlayer() }
        lines = []
        lines.append(titleContainerView.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
        lines.append(titleContainerView.addBottomBorderWithWidth(1, color: StyleHelper.lineColor))
        lines.append(descriptionTextView.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
        lines.append(setLocationButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
        lines.append(categoryButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
        lines.append(categoryButton.addBottomBorderWithWidth(1, color: StyleHelper.lineColor))
    }

    
    // MARK: - Public methods
    
    // MARK: > Actions
  
    @IBAction func categoryButtonPressed(sender: AnyObject) {
        
        let alert = UIAlertController(title: LGLocalizedString.sellChooseCategoryDialogTitle, message: nil,
            preferredStyle: .ActionSheet)

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


    // MARK: - SellProductViewModelDelegate Methods

    func sellProductViewModel(viewModel: BaseSellProductViewModel, archetype: Bool) { }

    func sellProductViewModel(viewModel: BaseSellProductViewModel, didSelectCategoryWithName categoryName: String) {
        categoryButton.setTitle(categoryName, forState: .Normal)
    }

    func sellProductViewModel(viewModel: BaseSellProductViewModel, shouldUpdateDescriptionWithCount count: Int) {

        if count <= 0 {
            descriptionCharCountLabel.textColor = StyleHelper.textFieldTintColor
        } else {
            descriptionCharCountLabel.textColor = UIColor.blackColor()
        }
        descriptionCharCountLabel.text = "\(count)"
    }

    func sellProductViewModeldidAddOrDeleteImage(viewModel: BaseSellProductViewModel) {
        imageCollectionView.reloadSections(NSIndexSet(index: 0))
    }

    func sellProductViewModelDidStartSavingProduct(viewModel: BaseSellProductViewModel) {
        loadingView.hidden = false
        loadingProgressView.setProgress(0, animated: false)
    }

    func sellProductViewModel(viewModel: BaseSellProductViewModel, didUpdateProgressWithPercentage percentage: Float) {
        loadingProgressView.setProgress(percentage, animated: false)
    }

    func sellProductViewModel(viewModel: BaseSellProductViewModel, didFinishSavingProductWithResult
        result: ProductResult) {
        loadingView.hidden = true

        if viewModel.shouldShareInFB {
            viewModel.shouldDisableTracking()
            let content = viewModel.fbShareContent
            FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: self)
        } else {
            sellCompleted()
        }
    }

    func sellProductViewModel(viewModel: BaseSellProductViewModel, didFailWithError error: ProductCreateValidationError) {
        loadingView.hidden = true
    }

    func sellProductViewModelFieldCheckSucceeded(viewModel: BaseSellProductViewModel) {
        ifLoggedInThen(.Sell, loggedInAction: {
            self.viewModel.save()
            }, elsePresentSignUpWithSuccessAction: {
                self.viewModel.save()
        })
    }

    func vmShouldOpenMapWithViewModel(locationViewModel: EditLocationViewModel) {
        let vc = EditLocationViewController(viewModel: locationViewModel)
        navigationController?.pushViewController(vc, animated: true)
    }


    // MARK: - TextField Delegate Methods

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
        replacementString string: String) -> Bool {
            guard !string.hasEmojis() else { return false }
            if textField == priceTextField && !textField.shouldChangePriceInRange(range, replacementString: string) {
                 return false
            }

            let text = textField.textReplacingCharactersInRange(range, replacementString: string)
            if let tag = TextFieldTag(rawValue: textField.tag) {
                switch (tag) {
                case .ProductTitle:
                    viewModel.title = text.isEmpty ? nil : text
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
            let nextView = view.viewWithTag(nextTag)
            nextView!.becomeFirstResponder()
        }
        return true
    }


    // MARK: - TextView Delegate Methods

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
        guard !text.hasEmojis() else { return false }
        if let textViewText = textView.text {
            let text = (textViewText as NSString).stringByReplacingCharactersInRange(range, withString: text)
            if text != descrPlaceholder && textView.textColor != descrPlaceholderColor {
                viewModel.descr = text.isEmpty ? nil : text
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
            MediaPickerManager.showImagePickerIn(self)
            
            if indexPath.item > 1 && indexPath.item < 4 {
                collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: indexPath.item+1, inSection: 0),
                    atScrollPosition: UICollectionViewScrollPosition.Right, animated: true)
            }
            
        } else if (indexPath.item < viewModel.numberOfImages) {
            // remove image
            let alert = UIAlertController(title: LGLocalizedString.sellPictureSelectedTitle, message: nil,
                preferredStyle: .ActionSheet)
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
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(BaseSellProductViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        case .Remote(let file):
            guard let fileUrl = file.fileURL else {
                self.dismissLoadingMessageAlert(){
                    self.showAutoFadingOutMessageAlert(LGLocalizedString.sellPictureSaveIntoCameraRollErrorGeneric)
                }
                return
            }
            ImageDownloader.sharedInstance.downloadImageWithURL(fileUrl) { [weak self] (result, _) in
                guard let strongSelf = self, let image = result.value?.image else { return }
                UIImageWriteToSavedPhotosAlbum(image, strongSelf, #selector(BaseSellProductViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
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
        
        titleTextField.placeholder = LGLocalizedString.sellTitleFieldHint
        titleTextField.text = viewModel.title
        titleTextField.tag = TextFieldTag.ProductTitle.rawValue
        titleDisclaimer.textColor = StyleHelper.editTitleDisclaimerTextColor
        titleDisclaimer.font = StyleHelper.editTitleDisclaimerFont
        currencyButton.setTitle(viewModel.currency?.symbol, forState: .Normal)

        priceTextField.placeholder = LGLocalizedString.productNegotiablePrice
        priceTextField.text = viewModel.price
        priceTextField.tag = TextFieldTag.ProductPrice.rawValue
        priceTextField.insetX = 8.0
        
        if viewModel.descr?.characters.count > 0 {
            descriptionTextView.text = viewModel.descr
            descriptionTextView.textColor = UIColor.blackColor()
        } else {
            descriptionTextView.text = descrPlaceholder
            descriptionTextView.textColor = descrPlaceholderColor
        }
        descriptionTextView.textContainerInset = UIEdgeInsetsMake(12.0, 11.0, 12.0, 11.0)
        descriptionTextView.tintColor = StyleHelper.textFieldTintColor
        descriptionTextView.tag = TextFieldTag.ProductDescription.rawValue
        descriptionCharCountLabel.text = "\(viewModel.descriptionCharCount)"

        setLocationTitleLabel.text = LGLocalizedString.changeLocationApplyButton

        let categoryButtonTitle = viewModel.categoryName ?? LGLocalizedString.sellCategorySelectionLabel
        categoryButton.setTitle(categoryButtonTitle, forState: .Normal)
        
        sendButton.setTitle(LGLocalizedString.sellSendButton, forState: .Normal)  // edit VC will override this
        sendButton.layer.cornerRadius = 4
        shareFBSwitch.on = viewModel.shouldShareInFB
        shareFBLabel.text = LGLocalizedString.sellShareOnFacebookLabel
        
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

        viewModel.titleAutogenerated.asObservable()

        viewModel.locationInfo.asObservable().bindTo(setLocationLocationLabel.rx_text).addDisposableTo(disposeBag)

        setLocationButton.rx_tap.bindNext { [weak self] in
            self?.viewModel.openMap()
        }.addDisposableTo(disposeBag)
    }
    
    override func popBackViewController() {
        super.popBackViewController()
    }
    
    internal func sellCompleted() {
        // Note: overriden in children
    }
    
    // MARK: - Share in facebook.
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        viewModel.shouldEnableTracking()
        viewModel.trackSharedFB()
        // @ahl: delayed is needed thanks to facebook
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.sellCompleted()
        }
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        viewModel.shouldEnableTracking()
        // @ahl: delayed is needed thanks to facebook
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.showAutoFadingOutMessageAlert(LGLocalizedString.sellSendErrorSharingFacebook) {
                self.sellCompleted()
            }
        }
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        viewModel.shouldEnableTracking()
        // @ahl: delayed is needed thanks to facebook
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.sellCompleted()
        }
    }
}
