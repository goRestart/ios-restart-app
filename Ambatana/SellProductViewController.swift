//
//  SellProductViewController.swift
//  Ambatana
//
//  Created by Ignacio Nieto Carvajal on 10/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit
import AddressBookUI

private let kAmbatanaSellProductControlsCornerRadius: CGFloat = 6.0
private let kAmbatanaAlreadyUploadedImageCellName = "AlreadyUploadedImageCell"
private let kAmbatanaAlreadyUploadedImageCellBigImageTag = 1
private let kAmbatanaTextfieldScrollingOffsetSpan: CGFloat = 72 // 20 (status bar height) + 44 (navigation controller height) + 8 (small span to leave some space)

private let kAmbatanaSellProductActionSheetTagCurrencyType = 100 // for currency selection
private let kAmbatanaSellProductActionSheetTagCategoryType = 101 // for category selection
private let kAmbatanaSellProductActionSheetTagImageSourceType = 102 // for image source selection
private let kAmbatanaSellProductActionSheetTagActionType = 103 // for image action selection

class SellProductViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIActionSheetDelegate {
    // outlets & buttons
    @IBOutlet weak var productTitleTextField: UITextField!
    @IBOutlet weak var productPriceTextfield: UITextField!
    @IBOutlet weak var currencyTypeButton: UIButton!
    @IBOutlet weak var descriptionTextView: PlaceholderTextView!
    @IBOutlet weak var chooseCategoryButton: UIButton!
    @IBOutlet weak var shareInFacebookSwitch: UISwitch!
    @IBOutlet weak var shareInFacebookLabel: UILabel!
    @IBOutlet weak var sellItButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addUpToLabel: UILabel!
    @IBOutlet weak var uploadingImageView: UIView!
    @IBOutlet weak var uploadingImageLabel: UILabel!
    @IBOutlet weak var uploadingImageProgressView: UIProgressView!
    var originalFrame: CGRect!
    
    // data
    var images: [UIImage] = [] {
        didSet { // hide "Add up to X photos" label if we have uploaded one or more photos.
            addUpToLabel.hidden = images.count > 0
        }
    }
    var imageFiles: [PFFile]? = nil

    let sellQueue = dispatch_queue_create("com.ambatana.SellProduct", DISPATCH_QUEUE_SERIAL) // we want the images to load sequentially.
    var currentCategory: ProductListCategory?
    var currentCurrency = CurrencyManager.sharedInstance.defaultCurrency
    var geocoder = CLGeocoder()
    var currenciesFromBackend: [PFObject]?
    var imageCounter = 0
    var imageUploadBackgroundTask = UIBackgroundTaskInvalid // used for allowing the App to keep on uploading an image if we go into background.
    var imageSelectedIndex = 0 // for actions (delete, save to disk...) in iOS7 and prior
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAmbatanaNavigationBarStyle(title: translate("sell"), includeBackArrow: true)
        
        // internationalization
        addUpToLabel.text = translateWithFormat("add_up_to_x_photos", [kAmbatanaProductImageKeys.count]).uppercaseString
        productTitleTextField.placeholder = translate("product_title")
        productPriceTextfield.placeholder = translate("price")
        descriptionTextView.placeholder = translate("description")
        chooseCategoryButton.setTitle(translate("choose_a_category"), forState: .Normal)
        shareInFacebookLabel.text = translate("share_product_facebook")
        sellItButton.setTitle(translate("sell_it"), forState: .Normal)
        uploadingImageLabel.text = translate("uploading_product_please_wait")
        
        // UX/UI & appearance.
        uploadingImageView.hidden = true
        currencyTypeButton.layer.cornerRadius = kAmbatanaSellProductControlsCornerRadius
        descriptionTextView.layer.cornerRadius = kAmbatanaSellProductControlsCornerRadius
        chooseCategoryButton.layer.cornerRadius = kAmbatanaSellProductControlsCornerRadius
        sellItButton.layer.cornerRadius = kAmbatanaSellProductControlsCornerRadius
        // force 1-row horizontal layout.
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .Horizontal
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // force a location update
        LocationManager.sharedInstance.startUpdatingLocation()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)

    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        originalFrame = self.view.frame
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillHide(notification: NSNotification) { self.restoreOriginalPosition() }
    
    // MARK: - iOS 7 Action Sheet deprecated selections for compatibility.
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        if actionSheet.tag == kAmbatanaSellProductActionSheetTagCurrencyType { // currency type selection
            if buttonIndex > 0 { // 0 is cancel
                let allCurrencies = CurrencyManager.sharedInstance.allCurrencies()
                let buttonCurrency = allCurrencies[buttonIndex - 1]
                self.currentCurrency = buttonCurrency
                self.currencyTypeButton.setTitle(buttonCurrency.currencyCode, forState: .Normal)
            }
        } else if actionSheet.tag == kAmbatanaSellProductActionSheetTagCategoryType { // category selection
            if buttonIndex > 0 { // 0 is cancel
                let category = ProductListCategory.allCategories()[buttonIndex - 1]
                self.currentCategory = category
                self.chooseCategoryButton.setTitle(category.getName(), forState: .Normal)
            }
        } else if actionSheet.tag == kAmbatanaSellProductActionSheetTagImageSourceType { // choose source for the images
            if buttonIndex == 0 { self.openImagePickerWithSource(.Camera) }
            else { self.openImagePickerWithSource(.PhotoLibrary) }
        } else if actionSheet.tag == kAmbatanaSellProductActionSheetTagActionType { // action type for uploaded image (download to disk? delete?...)
            if buttonIndex == 0 { self.deleteAlreadyUploadedImageWithIndex(imageSelectedIndex) }
            else { self.saveProductImageToDiskAtIndex(imageSelectedIndex) }
        }
    }
    
    // MARK: - Button actions
    
    @IBAction func changeCurrencyType(sender: AnyObject) {
        restoreOriginalPosition()
        
        if iOSVersionAtLeast("8.0") {
            // show alert controller for currency selection
            let alert = UIAlertController(title: translate("choose_currency"), message: nil, preferredStyle: .ActionSheet)
            alert.addAction(UIAlertAction(title: translate("cancel"), style: .Cancel, handler: nil))
            // iterate and add all currencies.
            for currency in CurrencyManager.sharedInstance.allCurrencies() {
                alert.addAction(UIAlertAction(title: currency.currencyCode, style: .Default, handler: { (currencyAction) -> Void in
                    self.currentCurrency = currency
                    self.currencyTypeButton.setTitle(currency.currencyCode, forState: .Normal)
                }))
            }
            
            // complete alert and show.
            self.presentViewController(alert, animated: true, completion: nil)
        } else { // ios7 fallback
            let actionSheet = UIActionSheet(title: translate("choose_currency"), delegate: self, cancelButtonTitle: translate("cancel"), destructiveButtonTitle: nil)
            actionSheet.tag = kAmbatanaSellProductActionSheetTagCurrencyType
            for currency in CurrencyManager.sharedInstance.allCurrencies() {
                actionSheet.addButtonWithTitle(currency.currencyCode)
            }
            actionSheet.cancelButtonIndex = 0
            actionSheet.showInView(self.view)
        }
    }

    @IBAction func chooseCategory(sender: AnyObject) {
        restoreOriginalPosition()
        
        if iOSVersionAtLeast("8.0") {
            // show alert controller for category selection
            let alert = UIAlertController(title: translate("choose_a_category"), message: nil, preferredStyle: .ActionSheet)
            for category in ProductListCategory.allCategories() {
                alert.addAction(UIAlertAction(title: category.getName(), style: .Default, handler: { (categoryAction) -> Void in
                    self.currentCategory = category
                    self.chooseCategoryButton.setTitle(category.getName(), forState: .Normal)
                }))
            }
            alert.addAction(UIAlertAction(title: translate("cancel"), style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)

        } else {
            let actionSheet = UIActionSheet(title: translate("choose_a_category"), delegate: self, cancelButtonTitle: translate("cancel"), destructiveButtonTitle: nil)
            actionSheet.tag = kAmbatanaSellProductActionSheetTagCategoryType
            for category in ProductListCategory.allCategories() {
                actionSheet.addButtonWithTitle(category.getName())
            }
            actionSheet.cancelButtonIndex = 0
            actionSheet.showInView(self.view)
        }
        
    }
    
    @IBAction func shareInFacebookSwitchChanged(sender: AnyObject) {
        restoreOriginalPosition()
    }
    
    @IBAction func sellProduct(sender: AnyObject) {
        // safety checks first (and we have a lot to check here...)
        // 1. do we have at least one image?
        if images.count < 1 { showAutoFadingOutMessageAlert(translate("upload_at_least_one_image")); return }
        // 2. do we have a product title?
        if productTitleTextField == nil || countElements(productTitleTextField.text) < 1 { showAutoFadingOutMessageAlert(translate("insert_valid_title")); return }
        // 3. do we have a price?
        let productPrice = productPriceTextfield?.text.toInt()
        if productPrice == nil { showAutoFadingOutMessageAlert(translate("insert_valid_price")); return }
        // 4. do we have a description?
        if descriptionTextView == nil || countElements(descriptionTextView.text) < 1 { showAutoFadingOutMessageAlert(translate("insert_valid_description")); return }
        // 5. do we have a category?
        if currentCategory == nil { showAutoFadingOutMessageAlert(translate("insert_valid_category")); return }
        // 6. do we have a valid location?
        let currentLocationCoordinate = LocationManager.sharedInstance.currentLocation()
        if !CLLocationCoordinate2DIsValid(currentLocationCoordinate) { showAutoFadingOutMessageAlert(translate("unable_sell_product_location")); return }

        // enable loading interface.
        enableLoadingInterface()

        // Let's use our pretty sell queue for uploading everything in sequence and in order ;)
        dispatch_async(sellQueue, { () -> Void in
            // Ok, if we reached this point we are ready to sell! Now let's build the new product object.
            let productObject = PFObject(className: "Products") // product to sell
            
            // fill in all product fields
            productObject["category_id"] = self.currentCategory!.rawValue
            productObject["currency"] = self.currentCurrency.iso4217Code
            productObject["description"] = self.descriptionTextView.text
            productObject["gpscoords"] = PFGeoPoint(latitude: currentLocationCoordinate.latitude, longitude: currentLocationCoordinate.longitude)
            productObject["processed"] = false
            productObject["language_code"] = NSLocale.preferredLanguages().first as? String ?? kAmbatanaDefaultCategoriesLanguage
            productObject["name"] = self.productTitleTextField.text
            productObject["name_dirify"] = self.productTitleTextField.text
            productObject["price"] = productPrice
            productObject["status"] = ProductStatus.Pending.rawValue
            productObject["user"] = PFUser.currentUser()
            // We want the upload process to continue even if the user suspends the App or opens another, that's why we define a background task.
            self.imageUploadBackgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.imageUploadBackgroundTask)
                self.imageUploadBackgroundTask = UIBackgroundTaskInvalid
                self.disableLoadingInterface()
            })
            
            // generate image files
            self.generateParseImageFiles()
            if self.imageFiles == nil || self.imageFiles?.count == 0 { // If we were unable to get at least one valid picture of the item as PFFile...
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.showAutoFadingOutMessageAlert(translate("error_uploading_product") + translate("unable_upload_photo"), completionBlock: nil)
                    self.disableLoadingInterface()
                    UIApplication.sharedApplication().endBackgroundTask(self.imageUploadBackgroundTask)
                    self.imageUploadBackgroundTask = UIBackgroundTaskInvalid
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
                        self.showAutoFadingOutMessageAlert(translate("error_uploading_product") + translate("unable_upload_photo"), completionBlock: nil)
                        self.disableLoadingInterface()
                        self.imageFiles = nil
                        UIApplication.sharedApplication().endBackgroundTask(self.imageUploadBackgroundTask)
                        self.imageUploadBackgroundTask = UIBackgroundTaskInvalid
                        return
                        // alternatively: continue and try to save it eventually later.
                        // imageFile.saveInBackgroundWithBlock(nil)
                    })
                }
            }
            
            // assign images to product images
            for (var i = 0; i < self.imageFiles!.count; i++) {
                let imageKey = kAmbatanaProductImageKeys[i]
                productObject[imageKey] = self.imageFiles![i]
            }
            
            // ACL status
            productObject.ACL = globalReadAccessACL()
            
            // Last (but not least) try to extract the geolocation address for the object based on the current coordinates
            let currentLocation = CLLocation(coordinate: currentLocationCoordinate, altitude: 1, horizontalAccuracy: 1, verticalAccuracy: -1, timestamp: nil)
            self.geocoder.reverseGeocodeLocation(currentLocation, completionHandler: { (placemarks, error) -> Void in
                if placemarks?.count > 0 {
                    var addressString = ""
                    
                    if let placemark = placemarks?.first as? CLPlacemark {
                        // extract elements and update user.
                        if placemark.locality != nil {
                            productObject["city"] = placemark.locality
                            ConfigurationManager.sharedInstance.userLocation = placemark.locality
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
                
                // finally save the object.
                productObject.saveInBackgroundWithBlock({ (success, error) -> Void in
                    // at this point we consider our background task finished.
                    UIApplication.sharedApplication().endBackgroundTask(self.imageUploadBackgroundTask)
                    self.imageUploadBackgroundTask = UIBackgroundTaskInvalid
                    
                    // disable loading interface and inform about the results
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.disableLoadingInterface()
                        if success {
                            if self.shareInFacebookSwitch.on { self.checkFacebookSharing(productObject.objectId) }
                            else { self.showAutoFadingOutMessageAlert(translate("successfully_uploaded_product"), completionBlock: { () -> Void in
                                self.popBackViewController()
                            }) }
                        } else {
                            self.showAutoFadingOutMessageAlert(translate("error_uploading_product"))
                        }
                    })
                    
                })
            })

        })
        
    }
    
    /** Generates the parse image files from the array of images and uploads it to parse. */
    func generateParseImageFiles() {
        var result: [PFFile] = []

        // iterate through all the images
        for image in images {
            var imageFile: PFFile? = nil
            var resizedImage: UIImage? = image.resizedImageToMaxSide(kAmbatanaMaxProductImageSide, interpolationQuality: kCGInterpolationMedium)
            if resizedImage != nil {
                // update parse DDBB
                let imageData = UIImageJPEGRepresentation(resizedImage, kAmbatanaMaxProductImageJPEGQuality)
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
    
    func checkFacebookSharing(objectId: String) {
        // first we need to check that the current FBSession is valid.
        if FBSession.activeSession().state != FBSessionState.Open {
            if FBSession.openActiveSessionWithAllowLoginUI(false) {
                shareCurrentProductInFacebook(objectId)
            } else { // Unable to share in Facebook. Just pop out
                showAutoFadingOutMessageAlert(translate("error_sharing_facebook"), completionBlock: { () -> Void in
                    self.popBackViewController()
                })
            }
        } else { shareCurrentProductInFacebook(objectId) }
    }
    
    func shareCurrentProductInFacebook(objectId: String) {
        let fbSharingParams = FBLinkShareParams()
        fbSharingParams.link = NSURL(string: ambatanaWebLinkForObjectId(objectId))!
        fbSharingParams.linkDescription = productTitleTextField.text
        if imageFiles?.count > 0 { fbSharingParams.picture = NSURL(string: imageFiles!.first!.url) }
        // check if we can present the dialog.
        if FBDialogs.canPresentShareDialogWithParams(fbSharingParams) {
            FBDialogs.presentShareDialogWithParams(fbSharingParams, clientState: nil, handler: { (call, result, error) -> Void in
                if error == nil {
                    self.showAutoFadingOutMessageAlert(translate("completed"), completionBlock: { () -> Void in
                        self.popBackViewController()
                    })
                } else {
                    self.showAutoFadingOutMessageAlert(translate("error_sharing_facebook"), completionBlock: { () -> Void in
                        self.popBackViewController()
                    })
                    println("Error: \(error.localizedDescription): \(error)")
                }
            })
        } else { // Present a fallback HTML dialog.
            var shareParamsForBrowserFallback: [String: AnyObject] = [:]
            shareParamsForBrowserFallback["name"] = productTitleTextField.text
            shareParamsForBrowserFallback["caption"] = translate("have_a_look")
            shareParamsForBrowserFallback["description"] = translate("have_a_look")
            if imageFiles?.count > 0 { shareParamsForBrowserFallback["picture"] = imageFiles!.first!.url }
            // show dialog
            FBWebDialogs.presentFeedDialogModallyWithSession(nil, parameters: shareParamsForBrowserFallback, handler: { (result, url, error) -> Void in
                if error != nil { // error
                    self.showAutoFadingOutMessageAlert(translate("error_sharing_facebook"), completionBlock: { () -> Void in
                        self.popBackViewController()
                    })
                } else { // check result status
                    if result == FBWebDialogResult.DialogNotCompleted { // user cancelled
                        self.showAutoFadingOutMessageAlert(translate("canceled_by_user"), completionBlock: { () -> Void in
                            self.popBackViewController()
                        })
                    } else { // success
                        self.showAutoFadingOutMessageAlert(translate("completed"), completionBlock: { () -> Void in
                            self.popBackViewController()
                        })
                    }
                }
            })
        }
        
    }
    

    // MARK: - UIImagePickerControllerDelegate methods
    
    func showImageSourceSelection() {
        if iOSVersionAtLeast("8.0") {
            let alert = UIAlertController(title: translate("choose_image_source"), message: nil, preferredStyle: .ActionSheet)
            alert.addAction(UIAlertAction(title: translate("camera"), style: .Default, handler: { (alertAction) -> Void in
                self.openImagePickerWithSource(.Camera)
            }))
            alert.addAction(UIAlertAction(title: translate("photo_library"), style: .Default, handler: { (alertAction) -> Void in
                self.openImagePickerWithSource(.PhotoLibrary)
            }))
            alert.addAction(UIAlertAction(title: translate("cancel"), style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let actionSheet = UIActionSheet()
            actionSheet.delegate = self
            actionSheet.title = translate("choose_image_source")
            actionSheet.tag = kAmbatanaSellProductActionSheetTagImageSourceType
            actionSheet.addButtonWithTitle(translate("camera"))
            actionSheet.addButtonWithTitle(translate("photo_library"))
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
        
        self.dismissViewControllerAnimated(true, completion: nil)
        // safety check.
        if image != nil {
            self.images.append(image!)
            self.collectionView.reloadSections(NSIndexSet(index: 0))
        } else { // this shouldn't happen, but just in case have a beautiful message ready for the user...
            self.showAutoFadingOutMessageAlert(translate("unable_upload_photo"))
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
        } else if textField == productPriceTextfield {
            descriptionTextView.becomeFirstResponder()
        }
        return false
    }
    
    // animate view to put textfield at the top.
    func textFieldDidBeginEditing(textField: UITextField) {
        let newFrame = self.originalFrame.rectByOffsetting(dx: 0, dy: -textField.frame.origin.y +  kAmbatanaTextfieldScrollingOffsetSpan)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.frame = newFrame
        })
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        let newFrame = self.originalFrame.rectByOffsetting(dx: 0, dy: -textView.frame.origin.y + kAmbatanaTextfieldScrollingOffsetSpan)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.frame = newFrame
        })
    }
    
    // MARK: - Add Photo & Already uploaded images collection view DataSource & Delegate methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kAmbatanaAlreadyUploadedImageCellName, forIndexPath: indexPath) as UICollectionViewCell
        
        if indexPath.row < images.count { // already uploaded image
            // set image
            if let uploadedImageView = cell.viewWithTag(kAmbatanaAlreadyUploadedImageCellBigImageTag) as? UIImageView {
                uploadedImageView.image = images[indexPath.row]
                uploadedImageView.clipsToBounds = true
                uploadedImageView.contentMode = .ScaleAspectFill
                uploadedImageView.layer.cornerRadius = kAmbatanaSellProductControlsCornerRadius
            }
        } else { // add photo "button".
            if let addPhotoImageView = cell.viewWithTag(kAmbatanaAlreadyUploadedImageCellBigImageTag) as? UIImageView {
                addPhotoImageView.image = UIImage(named: "publish_add-photo")
                addPhotoImageView.layer.cornerRadius = addPhotoImageView.frame.size.width / 2.0
                addPhotoImageView.clipsToBounds = true
            }
        }

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < images.count { // choose action for currently uploaded image (save to disk? delete?...)
            if iOSVersionAtLeast("8.0") {
                let alert = UIAlertController(title: translate("choose_action"), message: nil, preferredStyle: .ActionSheet)
                alert.addAction(UIAlertAction(title: translate("delete"), style: .Destructive, handler: { (deleteAction) -> Void in
                    self.deleteAlreadyUploadedImageWithIndex(indexPath.row)
                }))
                alert.addAction(UIAlertAction(title: translate("save_to_disk"), style: .Default, handler: { (saveAction) -> Void in
                    self.saveProductImageToDiskAtIndex(indexPath.row)
                }))
                alert.addAction(UIAlertAction(title: "cancel", style: .Cancel, handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                let actionSheet = UIActionSheet()
                actionSheet.delegate = self
                actionSheet.title = translate("choose_action")
                actionSheet.tag = kAmbatanaSellProductActionSheetTagActionType
                actionSheet.addButtonWithTitle(translate("delete"))
                actionSheet.addButtonWithTitle(translate("save_to_disk"))
                self.imageSelectedIndex = indexPath.row
                actionSheet.showInView(self.view)
            }
            
        } else { // add photo button.
            // check number of photos.
            if images.count >= kAmbatanaProductImageKeys.count {
                showAutoFadingOutMessageAlert(translate("max_images_reached"))
            } else {
                showImageSourceSelection()
            }
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
        showLoadingMessageAlert(customMessage: translate("saving_to_disk"))
        
        // get the image and launch the saving action.
        UIImageWriteToSavedPhotosAlbum(images[index], self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    func image(image: UIImage!, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
        self.dismissLoadingMessageAlert(completion: { () -> Void in
            if error == nil { // success
                self.showAutoFadingOutMessageAlert(translate("successfully_saved_to_disk"));
            } else {
                self.showAutoFadingOutMessageAlert(translate("error_saving_to_disk"));
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
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        restoreOriginalPosition()
    }

}
