//
//  SellProductViewController.swift
//  Ambatana
//
//  Created by Nacho on 10/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit
import AddressBookUI

private let kAmbatanaSellProductControlsCornerRadius: CGFloat = 6.0
private let kAmbatanaAlreadyUploadedImageCellName = "AlreadyUploadedImageCell"
private let kAmbatanaAlreadyUploadedImageCellBigImageTag = 1
private let kAmbatanaTextfieldScrollingOffsetSpan: CGFloat = 72 // 20 (status bar height) + 44 (navigation controller height) + 8 (small span to leave some space)

class SellProductViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    // outlets & buttons
    @IBOutlet weak var productTitleTextField: UITextField!
    @IBOutlet weak var productPriceTextfield: UITextField!
    @IBOutlet weak var currencyTypeButton: UIButton!
    @IBOutlet weak var descriptionTextView: PlaceholderTextView!
    @IBOutlet weak var chooseCategoryButton: UIButton!
    @IBOutlet weak var shareInFacebookSwitch: UISwitch!
    @IBOutlet weak var shareInFacebookLabel: UILabel!
    @IBOutlet weak var sellItButton: UIButton!
    @IBOutlet weak var sellItActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addUpToLabel: UILabel!
    @IBOutlet weak var uploadingImageView: UIView!
    @IBOutlet weak var uploadingImageLabel: UILabel!
    @IBOutlet weak var uploadingImageProgressView: UIProgressView!
    
    
    
    var originalFrame: CGRect!
    
    // data
    var images: [UIImage] = []
    var imageFiles: [PFFile] = [] {
        didSet { // hide "Add up to X photos" label if we have uploaded one or more photos.
            addUpToLabel.hidden = imageFiles.count > 0
        }
    }
    var currentCategory: ProductListCategory?
    var currentCurrency = CurrencyManager.sharedInstance.defaultCurrency
    var geocoder = CLGeocoder()
    var currenciesFromBackend: [PFObject]?
    
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
        uploadingImageLabel.text = translate("uploading_image_please_wait")
        
        // UX/UI & appearance.
        uploadingImageView.hidden = true
        sellItActivityIndicator.hidden = true
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
        // retrieve currencies, fallback to locally defined ones meanwhile

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        originalFrame = self.view.frame
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button actions
    
    @IBAction func changeCurrencyType(sender: AnyObject) {
        restoreOriginalPosition()
        // show alert controller for currency selection
        let alert = UIAlertController(title: translate("choose_currency"), message: nil, preferredStyle: .ActionSheet)
        
        // iterate and add all currencies.
        for currency in CurrencyManager.sharedInstance.allCurrencies() {
            alert.addAction(UIAlertAction(title: currency.currencyCode, style: .Default, handler: { (currencyAction) -> Void in
                self.currentCurrency = currency
                self.currencyTypeButton.setTitle(currency.currencyCode, forState: .Normal)
            }))
        }

        // complete alert and show.
        alert.addAction(UIAlertAction(title: translate("cancel"), style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func chooseCategory(sender: AnyObject) {
        restoreOriginalPosition()
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
    }
    
    @IBAction func shareInFacebookSwitchChanged(sender: AnyObject) {
        restoreOriginalPosition()
    }
    
    @IBAction func sellProduct(sender: AnyObject) {
        // safety checks first (and we have a lot to check here...)
        // 1. do we have at least one image?
        if imageFiles.count < 1 { showAutoFadingOutMessageAlert(translate("upload_at_least_one_image")); return }
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
        
        // Ok, if we reached this point we are ready to sell! Now let's build the new product object.
        enableLoadingWhileSellingObjectInterface()
        let productObject = PFObject(className: "Products")
        // fill in all product fields
        productObject["category_id"] = currentCategory!.rawValue
        productObject["currency"] = currentCurrency.iso4217Code
        productObject["description"] = descriptionTextView.text
        productObject["gpscoords"] = PFGeoPoint(latitude: currentLocationCoordinate.latitude, longitude: currentLocationCoordinate.longitude)
        productObject["processed"] = false
        productObject["language_code"] = NSLocale.preferredLanguages().first as? String ?? kAmbatanaDefaultCategoriesLanguage
        productObject["name"] = productTitleTextField.text
        productObject["name_dirify"] = productTitleTextField.text
        productObject["price"] = productPrice
        productObject["status"] = ProductStatus.Pending.rawValue
        productObject["user"] = PFUser.currentUser()
        
        // images
        for (var i = 0; i < imageFiles.count; i++) {
            let imageKey = kAmbatanaProductImageKeys[i]
            productObject[imageKey] = imageFiles[i]
        }
        
        // ACL status
        productObject.ACL = globalReadAccessACL()
        
        // Last (but not least) try to extract the geolocation address for the object based on the current coordinates
        let currentLocation = CLLocation(coordinate: currentLocationCoordinate, altitude: 1, horizontalAccuracy: 1, verticalAccuracy: -1, timestamp: nil)
        geocoder.reverseGeocodeLocation(currentLocation, completionHandler: { (placemarks, error) -> Void in
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
            
            // save the object.
            // TODO: Una barra de progreso aquí o cuando se suben imágenes???
            productObject.saveInBackgroundWithBlock({ (success, error) -> Void in
                self.disableLoadingWhileSellingObjectInterface()
                if success {
                    self.showAutoFadingOutMessageAlert(translate("successfully_uploaded_product"))
                    self.popBackViewController()
                    if self.shareInFacebookSwitch.on { self.checkFacebookSharing(productObject.objectId) }
                } else {
                    self.showAutoFadingOutMessageAlert(translate("error_uploading_product"))
                }
            })
        })
    }
    
    // MARK: - Share in facebook.
    
    func checkFacebookSharing(objectId: String) {
        // first we need to check that the current FBSession is valid.
        if FBSession.activeSession().state != FBSessionState.Open {
            if FBSession.openActiveSessionWithAllowLoginUI(false) {
                shareCurrentProductInFacebook(objectId)
            } else { showAutoFadingOutMessageAlert(translate("error_sharing_facebook")) }
        } else { shareCurrentProductInFacebook(objectId) }
    }
    
    func shareCurrentProductInFacebook(objectId: String) {
        let fbSharingParams = FBLinkShareParams()
        fbSharingParams.link = NSURL(string: ambatanaWebLinkForObjectId(objectId))!
        fbSharingParams.linkDescription = productTitleTextField.text
        if imageFiles.count > 0 { fbSharingParams.picture = NSURL(string: imageFiles.first!.url) }
        // check if we can present the dialog.
        if FBDialogs.canPresentShareDialogWithParams(fbSharingParams) {
            FBDialogs.presentShareDialogWithParams(fbSharingParams, clientState: nil, handler: { (call, result, error) -> Void in
                if error == nil {
                    self.showAutoFadingOutMessageAlert(translate("completed"))
                } else {
                    self.showAutoFadingOutMessageAlert(translate("error_sharing_facebook"))
                    println("Error: \(error.localizedDescription): \(error)")
                }
            })
        } else { // Present a fallback HTML dialog.
            var shareParamsForBrowserFallback: [String: AnyObject] = [:]
            shareParamsForBrowserFallback["name"] = productTitleTextField.text
            shareParamsForBrowserFallback["caption"] = translate("have_a_look")
            shareParamsForBrowserFallback["description"] = translate("have_a_look")
            if imageFiles.count > 0 { shareParamsForBrowserFallback["picture"] = imageFiles.first!.url }
            // show dialog
            FBWebDialogs.presentFeedDialogModallyWithSession(nil, parameters: shareParamsForBrowserFallback, handler: { (result, url, error) -> Void in
                if error != nil { // error
                    self.showAutoFadingOutMessageAlert(translate("error_sharing_facebook"))
                } else { // check result status
                    if result == FBWebDialogResult.DialogNotCompleted { // user cancelled
                        self.showAutoFadingOutMessageAlert(translate("canceled_by_user"))
                    } else { // success
                        self.showAutoFadingOutMessageAlert(translate("completed"))
                    }
                }
            })
        }
        
    }
    

    // MARK: - UIImagePickerControllerDelegate methods
    
    func showImageSourceSelection() {
        let alert = UIAlertController(title: translate("choose_image_source"), message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: translate("camera"), style: .Default, handler: { (alertAction) -> Void in
            self.openImagePickerWithSource(.Camera)
        }))
        alert.addAction(UIAlertAction(title: translate("photo_library"), style: .Default, handler: { (alertAction) -> Void in
            self.openImagePickerWithSource(.PhotoLibrary)
        }))
        alert.addAction(UIAlertAction(title: translate("cancel"), style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
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
        enableAddPhotoLoadingInterface()
        var resizedImage: UIImage?
        if image != nil {
            let newHeight = kAmbatanaMaxProductImageSide * image!.size.height / image!.size.width
            resizedImage = image!.resizedImage(CGSizeMake(kAmbatanaMaxProductImageSide, newHeight), interpolationQuality: kCGInterpolationHigh)
            if resizedImage != nil {
                // update parse DDBB
                let imageData = UIImageJPEGRepresentation(resizedImage, kAmbatanaMaxProductImageJPEGQuality)
                imageFile = PFFile(data: imageData)
            }
        }
        
        if imageFile == nil { // we were unable to generate the image file.
            disableAddPhotoLoadingInterface()
            showAutoFadingOutMessageAlert(translate("unable_upload_photo"))
        } else { // we have a valid image PFFile, now update current user's avatar with it.
            imageFile?.saveInBackgroundWithBlock({ (success, error) -> Void in
                if success {
                    // store locally
                    self.images.append(resizedImage!)
                    self.imageFiles.append(imageFile!)
                    // add some visual clue to the user
                    self.disableAddPhotoLoadingInterface()
                    self.collectionView.reloadSections(NSIndexSet(index: 0))
                } else {
                    self.disableAddPhotoLoadingInterface()
                    self.showAutoFadingOutMessageAlert(translate("unable_upload_photo"))
                }
            }, progressBlock: { (progress) -> Void in
                self.uploadingImageProgressView.setProgress(Float(progress)/100.0, animated: true)
            })

        }
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func enableAddPhotoLoadingInterface() {
        // disable collection view and sell button
        collectionView.userInteractionEnabled = false
        sellItButton.userInteractionEnabled = false

        // show loading progress indicator.
        uploadingImageProgressView.setProgress(0.0, animated: false)
        uploadingImageView.hidden = false
    }
    
    func disableAddPhotoLoadingInterface() {
        // hide loading progress indicator
        uploadingImageView.hidden = true
        
        // restore collection view and sell button
        sellItButton.userInteractionEnabled = true
        collectionView.userInteractionEnabled = true
    }
    
    func enableLoadingWhileSellingObjectInterface() {
        self.navigationItem.backBarButtonItem?.enabled = false
        self.view.userInteractionEnabled = false
        self.sellItButton.setTitle("", forState: .Normal)
        self.sellItActivityIndicator.startAnimating()
        self.sellItActivityIndicator.hidden = false
    }
    
    func disableLoadingWhileSellingObjectInterface() {
        self.sellItActivityIndicator.hidden = true
        self.sellItActivityIndicator.stopAnimating()
        sellItButton.setTitle(translate("sell_it"), forState: .Normal)
        self.view.userInteractionEnabled = true
        self.navigationItem.backBarButtonItem?.enabled = true
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
        if indexPath.row < images.count {
            let alert = UIAlertController(title: translate("choose_action"), message: nil, preferredStyle: .ActionSheet)
            alert.addAction(UIAlertAction(title: translate("delete"), style: .Destructive, handler: { (deleteAction) -> Void in
                self.deleteAlreadyUploadedImageWithIndex(indexPath.row)
            }))
            alert.addAction(UIAlertAction(title: translate("save_to_disk"), style: .Default, handler: { (saveAction) -> Void in
                self.saveProductImageToDiskAtIndex(indexPath.row)
            }))
            alert.addAction(UIAlertAction(title: "cancel", style: .Cancel, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
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
        imageFiles.removeAtIndex(index)
        
        // reload collection view
        collectionView.reloadSections(NSIndexSet(index: 0))
    }
    
    func saveProductImageToDiskAtIndex(index: Int) {
        showLoadingMessageAlert(customMessage: translate("saving_to_disk"))
        
        // get the image and launch the saving action.
        UIImageWriteToSavedPhotosAlbum(images[index], self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    func image(image: UIImage!, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
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
