//
//  SellProductViewController.swift
//  LetGo
//
//  Created by Dídac on 23/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Result
import FBSDKShareKit

class SellProductViewController: BaseViewController, SellProductViewModelDelegate, UITextFieldDelegate, UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FBSDKSharingDelegate {
    
    // UI
    
    enum TextFieldTag: Int {
        case ProductTitle = 1000, ProductPrice, ProductDescription
    }
    
    let descrPlaceholder = NSLocalizedString("sell_description_field_hint", comment: "")
    let descrPlaceholderColor = UIColor(rgb: 0xC7C7CD)
    let sellProductCellReuseIdentifier = "SellProductCell"
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextField: LGTextField!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var priceTextField: LGTextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionCharCountLabel: UILabel!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var shareFBSwitch: UISwitch!
    @IBOutlet weak var shareFBLabel: UILabel!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loadingProgressView: UIProgressView!
    
    var lines: [CALayer] = []

    // viewModel
    
    private var viewModel : SellProductViewModel!
    
    // MARK: - Lifecycle
    
    convenience init() {
        self.init(viewModel: SellProductViewModel())
    }
    
    init(viewModel: SellProductViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "EditSellProductViewController")
        
        self.viewModel.delegate = self
        
        automaticallyAdjustsScrollViewInsets = false
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        descriptionTextView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: false)
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Redraw the lines
        for line in lines {
            line.removeFromSuperlayer()
        }
        lines = []
        lines.append(titleTextField.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
        lines.append(priceTextField.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
        lines.append(currencyButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
        lines.append(descriptionTextView.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
        lines.append(categoryButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
        lines.append(categoryButton.addBottomBorderWithWidth(1, color: StyleHelper.lineColor))
    }
    
    // MARK: - Public methods
    
    // MARK: > Actions
    
  
    @IBAction func categoryButtonPressed(sender: AnyObject) {
        
        let alert = UIAlertController(title: NSLocalizedString("sell_choose_category_dialog_title", comment: ""), message: nil, preferredStyle: .ActionSheet)

        for i in 0..<viewModel.numberOfCategories {
            alert.addAction(UIAlertAction(title: viewModel.categoryNameAtIndex(i), style: .Default, handler: { (categoryAction) -> Void in
                self.viewModel.selectCategoryAtIndex(i)
            }))
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("sell_choose_category_dialog_cancel_button", comment: ""), style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)

    }
    
    @IBAction func sendButtonPressed(sender: AnyObject) {
        viewModel.save()
    }
    
    @IBAction func shareFBSwitchChanged(sender: AnyObject) {
        viewModel.shouldShareInFB = shareFBSwitch.on
    }
    
    // MARK: - SellProductViewModelDelegate Methods
    
    func sellProductViewModel(viewModel: SellProductViewModel, archetype: Bool) {
        
    }
    
    func sellProductViewModel(viewModel: SellProductViewModel, didSelectCategoryWithName categoryName: String) {
        categoryButton.setTitle(categoryName, forState: .Normal)
    }
    
    func sellProductViewModelDidStartSavingProduct(viewModel: SellProductViewModel) {
        loadingView.hidden = false
        loadingProgressView.setProgress(0, animated: false)
    }
    
    func sellProductViewModel(viewModel: SellProductViewModel, didUpdateProgressWithPercentage percentage: Float) {
        loadingProgressView.setProgress(percentage, animated: false)
    }
    
    func sellProductViewModel(viewModel: SellProductViewModel, didFinishSavingProductWithResult result: Result<Product, ProductSaveServiceError>) {
        loadingView.hidden = true
    }

    func sellProductViewModel(viewModel: SellProductViewModel, shouldUpdateDescriptionWithCount count: Int) {
        
        if count <= 0 {
            descriptionCharCountLabel.textColor = StyleHelper.textFieldTintColor
        } else {
            descriptionCharCountLabel.textColor = UIColor.blackColor()
        }
        descriptionCharCountLabel.text = "\(count)"
    }

    func sellProductViewModeldidAddOrDeleteImage(viewModel: SellProductViewModel) {
        imageCollectionView.reloadSections(NSIndexSet(index: 0))
    }
    
    func sellProductViewModel(viewModel: SellProductViewModel, didFailWithError error: ProductSaveServiceError) {
        loadingView.hidden = true
    }

    func sellProductViewModelShareContentinFacebook(viewModel: SellProductViewModel, withContent content: FBSDKShareLinkContent) {
        FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: self)
    }


    
    // MARK: - TextField Delegate Methods
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)

        if let tag = TextFieldTag(rawValue: textField.tag) {
            switch (tag) {
            case .ProductTitle:
                viewModel.title = text
            case .ProductPrice:
                viewModel.price = text
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
        let text = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        if text != descrPlaceholder && textView.textColor != descrPlaceholderColor {
            viewModel.descr = text
        }
        return true
    }
    
    
    // MARK: - Collection View Data Source methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(sellProductCellReuseIdentifier, forIndexPath: indexPath) as! SellProductCell
        
        if indexPath.item < viewModel.numberOfImages {
            // cell with image
            if let image = viewModel.imageAtIndex(indexPath.item) {
                cell.setupCellWithImage(image)
            }
            else {
                //image not loaded yet, show activity indicator
                cell.setupLoadingCell()
            }
            
            cell.label.text = ""
        }
        else if indexPath.item == viewModel.numberOfImages {
            // add image icon
            cell.setupAddPictureCell()
        }
        else {
            // empty cell
            cell.setupEmptyCell()
        }

        return cell
    }
    
    
    // MARK: - Collection View Delegate methods

    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // add image
        if indexPath.item == viewModel.numberOfImages {
            // launch image picker
            let alert = UIAlertController(title: NSLocalizedString("sell_picture_image_source_title", comment: ""), message: nil, preferredStyle: .ActionSheet)
            alert.addAction(UIAlertAction(title: NSLocalizedString("sell_picture_image_source_camera_button", comment: ""), style: .Default, handler: { (alertAction) -> Void in
                self.openImagePickerWithSource(.Camera)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("sell_picture_image_source_camera_roll_button", comment: ""), style: .Default, handler: { (alertAction) -> Void in
                self.openImagePickerWithSource(.PhotoLibrary)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("sell_picture_image_source_cancel_button", comment: ""), style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
            if indexPath.item > 1 && indexPath.item < 4 {
                collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: indexPath.item+1, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Right, animated: true)
            }
            
        } else if (indexPath.item < viewModel.numberOfImages) {
            // remove image
            let alert = UIAlertController(title: NSLocalizedString("sell_picture_selected_title", comment: ""), message: nil, preferredStyle: .ActionSheet)
            alert.addAction(UIAlertAction(title: NSLocalizedString("sell_picture_selected_delete_button", comment: ""), style: .Destructive, handler: { (deleteAction) -> Void in
                self.deleteAlreadyUploadedImageWithIndex(indexPath.row)
                if indexPath.item > 0 {
                    collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: indexPath.item-1, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
                }

            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("sell_picture_selected_save_into_camera_roll_button", comment: ""), style: .Default, handler: { (saveAction) -> Void in
                self.saveProductImageToDiskAtIndex(indexPath.row)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("sell_picture_selected_cancel_button", comment: ""), style: .Cancel, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: UIImagePicker Delegate
    
    func openImagePickerWithSource(source: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.delegate = self
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil { image = info[UIImagePickerControllerOriginalImage] as? UIImage }
        
        // Tracking
        
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
        // reload collection view
    }
    
    func saveProductImageToDiskAtIndex(index: Int) {
        showLoadingMessageAlert(customMessage: NSLocalizedString("sell_picture_save_into_camera_roll_loading", comment: ""))
        
        // get the image and launch the saving action.
        UIImageWriteToSavedPhotosAlbum(viewModel.imageAtIndex(index), self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    func image(image: UIImage!, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
        self.dismissLoadingMessageAlert(completion: { () -> Void in
            if error == nil { // success
                self.showAutoFadingOutMessageAlert(NSLocalizedString("sell_picture_save_into_camera_roll_ok", comment: ""));
            } else {
                self.showAutoFadingOutMessageAlert(NSLocalizedString("sell_picture_save_into_camera_roll_error_generic", comment: ""));
            }
        })
    }
    
    // MARK: - Private methods
    
    
    func setupUI() {
        
        titleTextField.placeholder = NSLocalizedString("sell_title_field_hint", comment: "")
        titleTextField.text = viewModel.title
        titleTextField.tag = TextFieldTag.ProductTitle.rawValue
        currencyButton.setTitle(viewModel.currency.symbol, forState: .Normal)
        currencyButton.titleEdgeInsets = UIEdgeInsetsMake(12.0, 17.0, 12.0, 11.0);

        priceTextField.placeholder = NSLocalizedString("sell_price_field_hint", comment: "")
        priceTextField.text = viewModel.price
        priceTextField.tag = TextFieldTag.ProductPrice.rawValue
        
        if count(viewModel.descr) > 0 {
            descriptionTextView.text = viewModel.descr
            descriptionTextView.textColor = UIColor.blackColor()
        }
        else {
            descriptionTextView.text = descrPlaceholder
            descriptionTextView.textColor = descrPlaceholderColor
        }
        descriptionTextView.textContainerInset = UIEdgeInsetsMake(12.0, 11.0, 12.0, 11.0)
        descriptionTextView.tintColor = StyleHelper.textFieldTintColor
        descriptionTextView.tag = TextFieldTag.ProductDescription.rawValue
        descriptionCharCountLabel.text = "\(viewModel.descriptionCharCount)"
        
        let categoryButtonTitle = viewModel.categoryName ?? NSLocalizedString("sell_category_selection_label", comment: "")
        categoryButton.setTitle(categoryButtonTitle, forState: .Normal)
        
        sendButton.setTitle(NSLocalizedString("sell_send_button", comment: ""), forState: .Normal)  // edit VC will override this
        sendButton.layer.cornerRadius = 4
        shareFBSwitch.on = viewModel.shouldShareInFB
        shareFBLabel.text = NSLocalizedString("sell_share_on_facebook_label", comment: "")
        
        // CollectionView
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        let sellProductCellNib = UINib(nibName: "SellProductCell", bundle: nil)
        self.imageCollectionView.registerNib(sellProductCellNib, forCellWithReuseIdentifier: sellProductCellReuseIdentifier)
        
        loadingLabel.text = NSLocalizedString("sell_uploading_label", comment: "")
        
    }
    
    override func popBackViewController() {
        super.popBackViewController()
    }
    
    // MARK: - Share in facebook.
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        viewModel.trackSharedFB()
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        showAutoFadingOutMessageAlert(NSLocalizedString("sell_send_error_sharing_facebook", comment: ""))
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        
    }


}