//
//  NewSellProductViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 10/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import AddressBookUI
import CoreLocation
import FBSDKShareKit
import LGCoreKit
import Parse
import UIKit

private let kLetGoSellProductControlsCornerRadius: CGFloat = 6.0
private let kLetGoAlreadyUploadedImageCellName = "AlreadyUploadedImageCell"
private let kLetGoUploadFirstImageCellName = "UploadFirstImageCell"
private let kLetGoUploadOtherImageCellName = "UploadOtherImageCell"
private let kLetGoAlreadyUploadedImageCellBigImageTag = 1
private let kLetGoUploadFirstImageCellLabelTag = 2
private let kLetGoTextfieldScrollingOffsetSpan: CGFloat = 72 // 20 (status bar height) + 44 (navigation controller height) + 8 (small span to leave some space)
private let kLetGoSellingItemTextViewMaxCharacterPassedColor = UIColor(red: 0.682, green: 0.098, blue: 0.098, alpha: 1.0)
private let kLetGoSellProductActionSheetTagCurrencyType = 100 // for currency selection
private let kLetGoSellProductActionSheetTagCategoryType = 101 // for category selection
private let kLetGoSellProductActionSheetTagImageSourceType = 102 // for image source selection
private let kLetGoSellProductActionSheetTagActionType = 103 // for image action selection

@objc protocol NewSellProductViewControllerDelegate {
    optional func sellProductViewController(sellVC: NewSellProductViewController?, didCompleteSell successfully: Bool)
}

class NewSellProductViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIActionSheetDelegate, FBSDKSharingDelegate {
    
    // constants
    private static let addPictureCellIdentifier = "SellAddPictureCell"
    private static let pictureCellIdentifier = "SellPictureCell"
    private static let emptyCellIdentifier = "SellEmptyCell"
    
    // outlets & buttons
    @IBOutlet weak var productTitleTextField: LGTextField!
    @IBOutlet weak var productPriceTextfield: LGTextField!
    @IBOutlet weak var currencyTypeButton: UIButton!
    @IBOutlet weak var descriptionTextView: PlaceholderTextView!
    @IBOutlet weak var chooseCategoryButton: UIButton!
    @IBOutlet weak var shareInFacebookSwitch: UISwitch!
    @IBOutlet weak var shareInFacebookLabel: UILabel!
    @IBOutlet weak var sellItButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var uploadingImageView: UIView!
    @IBOutlet weak var uploadingImageLabel: UILabel!
    @IBOutlet weak var uploadingImageProgressView: UIProgressView!
    @IBOutlet weak var characterCounterLabel: UILabel!
    var originalFrame: CGRect!

    var lines: [CALayer] = []

    // data
    var images: [UIImage] = []
    var imageFiles: [PFFile]? = nil
    var charactersRemaining = Constants.productDescriptionMaxLength

    let sellQueue = dispatch_queue_create("com.letgo.SellProduct", DISPATCH_QUEUE_SERIAL) // we want the images to load sequentially.
    var currentCategory: ProductCategory?
    var currentCurrency = CurrencyHelper.sharedInstance.currentCurrency
    var geocoder = CLGeocoder()
    var currenciesFromBackend: [PFObject]?
    var imageCounter = 0
    var imageSelectedIndex = 0 // for actions (delete, save to disk...) in iOS7 and prior
    var productWasSold = false
    var productId: String?
    
    // Synch
    let productSynchronizeService = LGProductSynchronizeService()
    
    // Delegate
    weak var delegate: NewSellProductViewControllerDelegate?
    
    init() {
        super.init(nibName: "NewSellProductViewController", bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Navigation bar
        setLetGoNavigationBarStyle(title: NSLocalizedString("sell_title", comment: ""))
        let closeButton = UIBarButtonItem(image: UIImage(named: "navbar_close"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("closeButtonPressed"))
        self.navigationItem.leftBarButtonItem = closeButton;
        
        // internationalization
        productTitleTextField.placeholder = NSLocalizedString("sell_title_field_hint", comment: "")
        currencyTypeButton.setTitle(currentCurrency.symbol, forState: .Normal)
        productPriceTextfield.placeholder = NSLocalizedString("sell_price_field_hint", comment: "")
        descriptionTextView.placeholder = NSLocalizedString("sell_description_field_hint", comment: "")
        chooseCategoryButton.setTitle(NSLocalizedString("sell_category_selection_label", comment: ""), forState: .Normal)
        shareInFacebookLabel.text = NSLocalizedString("sell_share_on_facebook_label", comment: "")
        sellItButton.setTitle(NSLocalizedString("sell_send_button", comment: ""), forState: .Normal)
        uploadingImageLabel.text = NSLocalizedString("sell_uploading_label", comment: "")
        
        descriptionTextView.textContainerInset = UIEdgeInsetsMake(12.0, 11.0, 12.0, 11.0)
        descriptionTextView.tintColor = StyleHelper.textFieldTintColor
        sellItButton.layer.cornerRadius = 4
        
        // CollectionView
        let addPictureCellNib = UINib(nibName: "SellAddPictureCell", bundle: nil)
        self.collectionView.registerNib(addPictureCellNib, forCellWithReuseIdentifier: NewSellProductViewController.addPictureCellIdentifier)
        let pictureCellNib = UINib(nibName: "SellPictureCell", bundle: nil)
        self.collectionView.registerNib(pictureCellNib, forCellWithReuseIdentifier: NewSellProductViewController.pictureCellIdentifier)
        let emptyCellNib = UINib(nibName: "SellEmptyCell", bundle: nil)
        self.collectionView.registerNib(emptyCellNib, forCellWithReuseIdentifier: NewSellProductViewController.emptyCellIdentifier)
        
        // UX/UI & appearance.
        uploadingImageView.hidden = true
        // force 1-row horizontal layout.
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout { flowLayout.scrollDirection = .Horizontal }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)

        // Tracking
        let event: TrackingEvent = .ProductSellStart
        TrackingHelper.trackEvent(event, parameters: trackingParamsForEventType(event))
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        // Tracking
        if (productWasSold) {
            let event: TrackingEvent = .ProductSellComplete
            TrackingHelper.trackEvent(event, parameters: trackingParamsForEventType(event))
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        originalFrame = self.view.frame
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Redraw the lines
        for line in lines {
            line.removeFromSuperlayer()
        }
        lines = []
        lines.append(productTitleTextField.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
        lines.append(productPriceTextfield.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
        lines.append(currencyTypeButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
        lines.append(descriptionTextView.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
        lines.append(chooseCategoryButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
        lines.append(chooseCategoryButton.addBottomBorderWithWidth(1, color: StyleHelper.lineColor))
    }
    
    func keyboardWillHide(notification: NSNotification) { self.restoreOriginalPosition() }
    
    // MARK: - Tracking parameters
    
    func trackingParamsForEventType(eventType: TrackingEvent, value: AnyObject? = nil) -> [TrackingParameter: AnyObject]? {
        var params: [TrackingParameter: AnyObject] = [:]

        // Common
        if let myUser = MyUserManager.sharedInstance.myUser() {
            if let userId = myUser.objectId {
                params[.UserId] = userId
            }
            if let userCity = myUser.postalAddress.city {
                params[.UserCity] = userCity
            }
            if let userCountry = myUser.postalAddress.countryCode {
                params[.UserCountry] = userCountry
            }
            if let userZipCode = myUser.postalAddress.zipCode {
                params[.UserZipCode] = userZipCode
            }
        }
        
        // Non-common
        if eventType == .ProductSellAddPicture {
            params[.Number] = images.count
        }
        
        if eventType == .ProductSellSharedFB || eventType == .ProductSellComplete {
            params[.ProductName] = productTitleTextField.text ?? "none"
        }
        
        if eventType == .ProductSellFormValidationFailed {
            params[.Description] = value
        }
        
        if eventType == .ProductSellEditShareFB {
            params[.Enabled] = self.shareInFacebookSwitch.on
        }
        
        if eventType == .ProductSellEditCategory || eventType == .ProductSellComplete {
            params[.CategoryId] = currentCategory?.rawValue ?? 0
        }
        
        if eventType == .ProductSellComplete {
            if let actualProductId = productId {
                params[.ProductId] = actualProductId
            }
        }
        
        return params
    }
    
    // MARK: - iOS 7 Action Sheet deprecated selections for compatibility.
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        if actionSheet.tag == kLetGoSellProductActionSheetTagCategoryType { // category selection
            if buttonIndex != actionSheet.cancelButtonIndex { // 0 is cancel
                let category = ProductCategory.allValues()[buttonIndex]
                self.currentCategory = category
                self.chooseCategoryButton.setTitle(category.name(), forState: .Normal)
                
                // Tracking
                let event: TrackingEvent = .ProductSellEditCategory
                TrackingHelper.trackEvent(event, parameters: trackingParamsForEventType(event))
            }
        } else if actionSheet.tag == kLetGoSellProductActionSheetTagImageSourceType { // choose source for the images
            if buttonIndex == 0 { self.openImagePickerWithSource(.Camera) }
            else { self.openImagePickerWithSource(.PhotoLibrary) }
        } else if actionSheet.tag == kLetGoSellProductActionSheetTagActionType { // action type for uploaded image (download to disk? delete?...)
            if buttonIndex == 0 { self.deleteAlreadyUploadedImageWithIndex(imageSelectedIndex) }
            else { self.saveProductImageToDiskAtIndex(imageSelectedIndex) }
        }
    }
    
    // MARK: - Button actions
    
    func closeButtonPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let event: TrackingEvent = .ProductSellAbandon
        TrackingHelper.trackEvent(event, parameters: trackingParamsForEventType(event))
    }
    
    @IBAction func chooseCategory(sender: AnyObject) {
        restoreOriginalPosition()
        
        if iOSVersionAtLeast("8.0") {
            // show alert controller for category selection
            let alert = UIAlertController(title: NSLocalizedString("sell_choose_category_dialog_title", comment: ""),
                message: nil, preferredStyle: .ActionSheet)
            
            for category in ProductCategory.allValues() {
                alert.addAction(UIAlertAction(title: category.name(), style: .Default, handler: { (categoryAction) -> Void in
                    self.currentCategory = category
                    self.chooseCategoryButton.setTitle(category.name(), forState: .Normal)
                    
                    // Tracking
                    let event: TrackingEvent = .ProductSellEditCategory
                    TrackingHelper.trackEvent(event, parameters: self.trackingParamsForEventType(event))
                }))
            }
            alert.addAction(UIAlertAction(title: NSLocalizedString("sell_choose_category_dialog_cancel_button", comment: ""),
                style: .Cancel,
                handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)

        } else {
            let actionSheet = UIActionSheet(title: NSLocalizedString("sell_choose_category_dialog_title", comment: ""), delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
            actionSheet.tag = kLetGoSellProductActionSheetTagCategoryType
            for category in ProductCategory.allValues() {
                actionSheet.addButtonWithTitle(category.name())
            }
            actionSheet.cancelButtonIndex = actionSheet.addButtonWithTitle(NSLocalizedString("sell_choose_category_dialog_cancel_button", comment: ""))
            actionSheet.showInView(self.view)
        }
    }
    
    @IBAction func shareInFacebookSwitchChanged(sender: AnyObject) {
        restoreOriginalPosition()
        
        // Tracking
        let event: TrackingEvent = .ProductSellEditShareFB
        TrackingHelper.trackEvent(event, parameters: trackingParamsForEventType(event))
    }
    
    @IBAction func sellProduct(sender: AnyObject) {
        
        let lastKnownLocation = MyUserManager.sharedInstance.myUser()?.gpsCoordinates
        let productPrice = productPriceTextfield?.text.toInt()
        
        // safety checks first (and we have a lot to check here...)
        
        var alertMsg: String? = nil
        var validationFailureReason: String? = nil
        
        // 1. do we have at least one image?
        if images.count < 1 {
            alertMsg = NSLocalizedString("sell_send_error_invalid_image_count", comment: "")
            validationFailureReason = "no images present"
        }
        // 2. do we have a product title?
        else if productTitleTextField == nil || count(productTitleTextField.text) < 1 {
            alertMsg = NSLocalizedString("sell_send_error_invalid_title", comment: "")
            validationFailureReason = "no title"
        }
        // 3. do we have a price?
        else if productPrice == nil {
            alertMsg = NSLocalizedString("sell_send_error_invalid_price", comment: "")
            validationFailureReason = "invalid price"
        }
        // 4. do we have a valid description?
        else if descriptionTextView == nil || count(descriptionTextView.text) < 1 {
            alertMsg = NSLocalizedString("sell_send_error_invalid_description", comment: "")
            validationFailureReason = "no description"
        }
        else if self.charactersRemaining < 0 {
            alertMsg = String(format: NSLocalizedString("sell_send_error_invalid_description_too_long", comment: ""), Constants.productDescriptionMaxLength)
            validationFailureReason = "description too long"
        }
        // 5. do we have a category?
        else if currentCategory == nil {
            alertMsg = NSLocalizedString("sell_send_error_invalid_category", comment: "")
            validationFailureReason = "no category selected" }
        // 6. do we have a valid location?
        else if lastKnownLocation == nil {
            alertMsg = NSLocalizedString("sell_send_error_invalid_location", comment: "")
            validationFailureReason = "unable find location"
        }

        if let alertMessage = alertMsg {
            showAutoFadingOutMessageAlert(alertMessage)
        }
        
        if let failureReason = validationFailureReason {
            // Tracking
            let event: TrackingEvent = .ProductSellFormValidationFailed
            TrackingHelper.trackEvent(event, parameters: trackingParamsForEventType(event, value: failureReason))
            return
        }
        
        
        // enable loading interface.
        enableLoadingInterface()

        // Let's use our pretty sell queue for uploading everything in sequence and in order ;)
        dispatch_async(sellQueue, { () -> Void in
            // Ok, if we reached this point we are ready to sell! Now let's build the new product object.
            let productObject = PFObject(className: "Products") // product to sell
            
            // fill in all product fields
            productObject["category_id"] = self.currentCategory!.rawValue
            productObject["currency"] = self.currentCurrency.code
            productObject["description"] = self.descriptionTextView.text
            productObject["gpscoords"] = PFGeoPoint(latitude: lastKnownLocation!.latitude, longitude: lastKnownLocation!.longitude)
            productObject["processed"] = false
            productObject["language_code"] = NSLocale.preferredLanguages().first as? String ?? kLetGoDefaultCategoriesLanguage
            productObject["name"] = self.productTitleTextField.text
            productObject["name_dirify"] = self.productTitleTextField.text
            productObject["price"] = productPrice
            productObject["status"] = LetGoProductStatus.Pending.rawValue
            productObject["user"] = PFUser.currentUser()
            productObject["user_id"] = PFUser.currentUser()?.objectId ?? ""
            
            // generate image files
            self.generateParseImageFiles()
            if self.imageFiles == nil || self.imageFiles?.count == 0 { // If we were unable to get at least one valid picture of the item as PFFile...
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.showAutoFadingOutMessageAlert(NSLocalizedString("sell_send_error_uploading_picture", comment: ""), completionBlock: nil)
                    self.disableLoadingInterface()
                    return
                })
            }
            
            // upload images and give feedback to the user of the uploading process.
            for imageFile in self.imageFiles! {
                // We'll prepare a counter of images.count + 1, so the process is divided among uploading the images and finally uploading the product.
                let totalSteps = self.imageFiles!.count + 1
                let percentagePerImage = 1.0/Float(totalSteps)
                
                // the saving process is synchronous, because we want a "full upload", so it doesn't make sense to allow the user to perform any other activity while we are uploading the item.
                if imageFile.save() { // saving was successful
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.uploadingImageProgressView.progress += percentagePerImage
                    })
                } else { // try to save the image eventually later.
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        // show an error and stop the uploading process completely.
                        self.showAutoFadingOutMessageAlert(NSLocalizedString("sell_send_error_uploading_picture", comment: ""), completionBlock: nil)
                        self.disableLoadingInterface()
                        self.imageFiles = nil
                        return
                        // alternatively: continue and try to save it eventually later.
                        // imageFile.saveInBackgroundWithBlock(nil)
                    })
                }
            }
            
            // assign images to product images
            for (var i = 0; i < self.imageFiles!.count; i++) {
                let imageKey = kLetGoProductImageKeys[i]
                productObject[imageKey] = self.imageFiles![i]
            }
            
            // ACL status
            productObject.ACL = globalReadAccessACL()
            
            // Last (but not least) try to extract the geolocation address for the object based on the current coordinates
            let currentLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: lastKnownLocation!.latitude, longitude: lastKnownLocation!.longitude), altitude: 1, horizontalAccuracy: 1, verticalAccuracy: -1, timestamp: nil)
            self.geocoder.reverseGeocodeLocation(currentLocation, completionHandler: { (placemarks, error) -> Void in
                if placemarks?.count > 0 {
                    var addressString = ""
                    
                    if let placemark = placemarks?.first as? CLPlacemark {
                        // extract elements and update user.
                        if placemark.locality != nil {
                            productObject["city"] = placemark.locality
                        }
                        if placemark.postalCode != nil { productObject["zip_code"] = placemark.postalCode }
                        if placemark.ISOcountryCode != nil { productObject["country_code"] = placemark.ISOcountryCode }
                        if placemark.addressDictionary != nil {
                            addressString = ABCreateStringWithAddressDictionary(placemark.addressDictionary, false)
                            productObject["address"] = addressString
                        }
                    }
                }
                
                // last step of the saving process.
                self.uploadingImageProgressView.progress = 1.0
                
                var error : NSError?
                let success = productObject.save(&error)
                
                if success {
                    if let productId = productObject.objectId {
                        self.productSynchronizeService.synchSynchronizeProductWithId(productId) { () -> Void in }
                    }
                }

                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.disableLoadingInterface()
                    if success {
                        // for tracking purposes
                        self.productWasSold = true
                        self.productId = productObject.objectId
                        
                        // check facebook sharing
                        if self.shareInFacebookSwitch.on { self.shareCurrentProductInFacebook(productObject.objectId!) }
                        else {
                            self.showAutoFadingOutMessageAlert(NSLocalizedString("sell_send_ok", comment: ""), time: 3.5, completionBlock: { () -> Void in
                                self.dismissViewControllerAnimated(true, completion: { [weak self] in
                                    self?.delegate?.sellProductViewController?(self, didCompleteSell: true)
                                    })
                            })
                        }
                    } else {
                        self.showAutoFadingOutMessageAlert(NSLocalizedString("sell_send_error_uploading_product", comment: ""))
                    }
                })

                
                
                // finally save the object.
                productObject.saveInBackgroundWithBlock({ (success, error) -> Void in
                    
                    // disable loading interface and inform about the results
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.disableLoadingInterface()
                        if success {
                            // for tracking purposes
                            self.productWasSold = true
                            self.productId = productObject.objectId

                            // update product in LetGo backend
//                            RESTManager.sharedInstance.synchronizeProductFromParse(productObject.objectId!, attempt: 0, completion: nil)
                            
                            if let productId = productObject.objectId {
                                self.productSynchronizeService.synchSynchronizeProductWithId(productId) { () -> Void in }
                            }
                            
                            
                            // check facebook sharing
                            if self.shareInFacebookSwitch.on { self.shareCurrentProductInFacebook(productObject.objectId!) }
                            else {
                                self.showAutoFadingOutMessageAlert(NSLocalizedString("sell_send_ok", comment: ""), time: 3.5, completionBlock: { () -> Void in
                                    self.dismissViewControllerAnimated(true, completion: { [weak self] in
                                        self?.delegate?.sellProductViewController?(self, didCompleteSell: true)
                                    })
                                })
                            }
                        } else {
                            self.showAutoFadingOutMessageAlert(NSLocalizedString("sell_send_error_uploading_product", comment: ""))
                        }
                    })
                    
                })
            })

        })
        
    }
    
    
//    self?.productSynchronizeService.synchronizeProductWithId(productId) { () -> Void in
//    
//    // Notify the sender, we do not care about synch result
//    result?(Result<Product, ProductSaveServiceError>.success(savedProduct))
//    }
    
    
    /** Generates the parse image files from the array of images and uploads it to parse. */
    func generateParseImageFiles() {
        var result: [PFFile] = []

        // iterate through all the images
        for image in images {
            var imageFile: PFFile? = nil
            var resizedImage: UIImage? = image.resizedImageToMaxSide(kLetGoMaxProductImageSide, interpolationQuality: kCGInterpolationMedium)
            if resizedImage != nil {
                // update parse DDBB
                let imageData = UIImageJPEGRepresentation(resizedImage, kLetGoMaxProductImageJPEGQuality)
                let imageName = NSUUID().UUIDString.stringByReplacingOccurrencesOfString("-", withString: "", options: nil, range: nil) + "_\(imageCounter++).jpg"
                
                imageFile = PFFile(name: imageName, data: imageData)
            }
            
            if imageFile == nil { // we were unable to generate the image file.  We inform about the error and return nil, because we suppose we want all images to upload at once or none.
                imageFiles = nil
                return
                // in case you want to continue with the uploading process without that image, just substitute the above code with this line:
                // continue
            } else { // we have a valid image PFFile, now update current user's avatar with it.
                result.append(imageFile!)
            }
        }
        
        // store the successfully uploaded image files.
        imageFiles = result
    }
    
    // MARK: - Share in facebook.
    
//    func checkFacebookSharing(objectId: String) {
//        // first we need to check that the current FBSession is valid.
//        if FBSDKAccessToken.currentAccessToken() != nil { // we have a valid token session.
//            shareCurrentProductInFacebook(objectId)
//        } else {
//            showAutoFadingOutMessageAlert(NSLocalizedString("sell_send_error_sharing_facebook", comment: ""), completionBlock: { () -> Void in
//                self.dismissViewControllerAnimated(true, completion: nil)
//            })
//        }
//    }
    
    func shareCurrentProductInFacebook(objectId: String) {
        // build the sharing content.
        let fbSharingContent = FBSDKShareLinkContent()
        fbSharingContent.contentTitle = NSLocalizedString("sell_share_fb_content", comment: "")
        fbSharingContent.contentURL = NSURL(string: letgoWebLinkForObjectId(objectId))
        fbSharingContent.contentDescription = productTitleTextField.text
        if imageFiles?.count > 0 { fbSharingContent.imageURL = NSURL(string: imageFiles!.first!.url!) }
        
        // share it.
        FBSDKShareDialog.showFromViewController(self, withContent: fbSharingContent, delegate: self)
    }
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        self.showAutoFadingOutMessageAlert(NSLocalizedString("sell_send_ok", comment: ""), time: 3.5, completionBlock: { () -> Void in
            self.dismissViewControllerAnimated(true, completion: { [weak self] in
                self?.delegate?.sellProductViewController?(self, didCompleteSell: true)
            })
        })

        // Tracking
        let event: TrackingEvent = .ProductSellSharedFB
        TrackingHelper.trackEvent(event, parameters: trackingParamsForEventType(event))
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        self.showAutoFadingOutMessageAlert(NSLocalizedString("sell_send_error_sharing_facebook", comment: ""), completionBlock: { () -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        self.showAutoFadingOutMessageAlert(NSLocalizedString("sell_send_error_sharing_facebook_cancelled", comment: ""), completionBlock: { () -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }

    // MARK: - UIImagePickerControllerDelegate methods
    
    func showImageSourceSelection() {
        if iOSVersionAtLeast("8.0") {
            let alert = UIAlertController(title: NSLocalizedString("sell_picture_image_source_title", comment: ""), message: nil, preferredStyle: .ActionSheet)
            alert.addAction(UIAlertAction(title: NSLocalizedString("sell_picture_image_source_camera_button", comment: ""), style: .Default, handler: { (alertAction) -> Void in
                self.openImagePickerWithSource(.Camera)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("sell_picture_image_source_camera_roll_button", comment: ""), style: .Default, handler: { (alertAction) -> Void in
                self.openImagePickerWithSource(.PhotoLibrary)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("sell_picture_image_source_cancel_button", comment: ""), style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let actionSheet = UIActionSheet()
            actionSheet.delegate = self
            actionSheet.title = NSLocalizedString("sell_picture_image_source_title", comment: "")
            actionSheet.tag = kLetGoSellProductActionSheetTagImageSourceType
            actionSheet.addButtonWithTitle(NSLocalizedString("sell_picture_image_source_camera_button", comment: ""))
            actionSheet.addButtonWithTitle(NSLocalizedString("sell_picture_image_source_camera_roll_button", comment: ""))
            actionSheet.showInView(self.view)
        }
    }
    
    func openImagePickerWithSource(source: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.delegate = self
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var imageFile: PFFile? = nil
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil { image = info[UIImagePickerControllerOriginalImage] as? UIImage }
        
        // Tracking
        let event: TrackingEvent = .ProductSellAddPicture
        TrackingHelper.trackEvent(event, parameters: trackingParamsForEventType(event))
        
        self.dismissViewControllerAnimated(true, completion: nil)
        // safety check.
        if image != nil {
            self.images.append(image!)
            self.collectionView.reloadSections(NSIndexSet(index: 0))
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func enableLoadingInterface() {
        // show loading progress indicator.
        uploadingImageView.hidden = false
        uploadingImageProgressView.setProgress(0.0, animated: false)
        uploadingImageView.setNeedsDisplay()
        
        // disable back navigation.
        self.navigationItem.backBarButtonItem?.enabled = false
        // disable collection view and sell button
        collectionView.userInteractionEnabled = false
        sellItButton.userInteractionEnabled = false

    }
    
    func disableLoadingInterface() {
        // disable back navigation.
        self.navigationItem.backBarButtonItem?.enabled = true
        // hide loading progress indicator
        uploadingImageView.hidden = true
        uploadingImageView.setNeedsDisplay()

        // restore collection view and sell button
        sellItButton.userInteractionEnabled = true
        collectionView.userInteractionEnabled = true
    }
    
    // MARK: - keyboard reaction in textfields and textareas.
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == productTitleTextField {
            productPriceTextfield.becomeFirstResponder()
        }
        else if textField == productPriceTextfield {
            descriptionTextView.becomeFirstResponder()
        }
        return false
    }
    
    // animate view to put textfield at the top.
    func textFieldDidBeginEditing(textField: UITextField) {
        let newFrame = self.originalFrame.rectByOffsetting(dx: 0, dy: -textField.frame.origin.y +  kLetGoTextfieldScrollingOffsetSpan)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.frame = newFrame
        })
        
        // Tracking
        if textField == productTitleTextField {
            let event: TrackingEvent = .ProductSellEditTitle
            TrackingHelper.trackEvent(event, parameters: trackingParamsForEventType(event))
        }
        else if textField == productPriceTextfield {
            let event: TrackingEvent = .ProductSellEditPrice
            TrackingHelper.trackEvent(event, parameters: trackingParamsForEventType(event))
        }
    }
    
    
    // MARK: - UITextViewDelegate
    
    func textViewDidBeginEditing(textView: UITextView) {
        let newFrame = self.originalFrame.rectByOffsetting(dx: 0, dy: -textView.frame.origin.y + kLetGoTextfieldScrollingOffsetSpan)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.frame = newFrame
        })

        // Tracking
        let event: TrackingEvent = .ProductSellEditDescription
        TrackingHelper.trackEvent(event, parameters: trackingParamsForEventType(event))
    }
    
    // MARK: - TextView character count.
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        self.charactersRemaining = Constants.productDescriptionMaxLength - (count(textView.text) - range.length + count(text))
        self.characterCounterLabel.text = "\(self.charactersRemaining)"
        if self.charactersRemaining < 0 {
            self.characterCounterLabel.textColor = kLetGoSellingItemTextViewMaxCharacterPassedColor
            self.sellItButton.enabled = false
            UIView.animateWithDuration(0.3, animations: { self.sellItButton.alpha = 0.5 })
        } else {
            self.characterCounterLabel.textColor = UIColor.lightGrayColor()
            self.sellItButton.enabled = true
            UIView.animateWithDuration(0.3, animations: { self.sellItButton.alpha = 1.0 })
        }
        return true
    }
    
    // MARK: - Add Photo & Already uploaded images collection view DataSource & Delegate methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return kLetGoProductImageKeys.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell!

        // let's try to find out which kind of cell is this
        if indexPath.row == images.count { // "first upload image" case.
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(NewSellProductViewController.addPictureCellIdentifier, forIndexPath: indexPath) as! SellAddPictureCell
        } else if indexPath.row < images.count { // already uploaded image case
            let pictureCell = collectionView.dequeueReusableCellWithReuseIdentifier(NewSellProductViewController.pictureCellIdentifier, forIndexPath: indexPath) as! SellPictureCell
            pictureCell.imageView.image = images[indexPath.row]
            cell = pictureCell
        } else { // "upload other image" case.
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(NewSellProductViewController.emptyCellIdentifier, forIndexPath: indexPath) as! SellEmptyCell
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < images.count { // choose action for currently uploaded image (save to disk? delete?...)
            if iOSVersionAtLeast("8.0") {
                let alert = UIAlertController(title: NSLocalizedString("sell_picture_selected_title", comment: ""), message: nil, preferredStyle: .ActionSheet)
                alert.addAction(UIAlertAction(title: NSLocalizedString("sell_picture_selected_delete_button", comment: ""), style: .Destructive, handler: { (deleteAction) -> Void in
                    self.deleteAlreadyUploadedImageWithIndex(indexPath.row)
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("sell_picture_selected_save_into_camera_roll_button", comment: ""), style: .Default, handler: { (saveAction) -> Void in
                    self.saveProductImageToDiskAtIndex(indexPath.row)
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("sell_picture_selected_cancel_button", comment: ""), style: .Cancel, handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                let actionSheet = UIActionSheet()
                actionSheet.delegate = self
                actionSheet.title = NSLocalizedString("sell_picture_selected_title", comment: "")
                actionSheet.tag = kLetGoSellProductActionSheetTagActionType
                actionSheet.addButtonWithTitle(NSLocalizedString("sell_picture_selected_delete_button", comment: ""))
                actionSheet.addButtonWithTitle(NSLocalizedString("sell_picture_selected_save_into_camera_roll_button", comment: ""))
                self.imageSelectedIndex = indexPath.row
                actionSheet.showInView(self.view)
            }
            
        } else { // add photo button.
            showImageSourceSelection()
        }
    }
    
    // MARK: - Managing images.
    
    func deleteAlreadyUploadedImageWithIndex(index: Int) {
        // delete the image file locally
        images.removeAtIndex(index)
        
        // reload collection view
        collectionView.reloadSections(NSIndexSet(index: 0))
    }
    
    func saveProductImageToDiskAtIndex(index: Int) {
        showLoadingMessageAlert(customMessage: NSLocalizedString("sell_picture_save_into_camera_roll_loading", comment: ""))
        
        // get the image and launch the saving action.
        UIImageWriteToSavedPhotosAlbum(images[index], self, "image:didFinishSavingWithError:contextInfo:", nil)
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

    // MARK: - UX
    
    // get view frame back to the original position when we are not editing a textfield.
    func restoreOriginalPosition() {
        self.view.resignFirstResponder()
        self.view.endEditing(true)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.frame = self.originalFrame
        })
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        restoreOriginalPosition()
    }

}
