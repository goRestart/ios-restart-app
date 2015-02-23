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
    @IBOutlet weak var addPhotoActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var sellItActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addUpToLabel: UILabel!

    // data
    var images: [PFFile] = []
    var currentCategory: ProductListCategory?
    var currentCurrency: Currency = .Usd
    var geocoder = CLGeocoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAmbatanaNavigationBarStyle(title: translate("sell"), includeBackArrow: true)
        
        // internationalization
        addUpToLabel.text = translateWithFormat("add_up_to_x_photos", [kAmbatanaProductImageKeys.count])
        productTitleTextField.placeholder = translate("product_title")
        productPriceTextfield.placeholder = translate("price")
        descriptionTextView.placeholder = translate("description")
        chooseCategoryButton.setTitle(translate("choose_a_category"), forState: .Normal)
        shareInFacebookLabel.text = translate("share_product_facebook")
        sellItButton.setTitle(translate("sell_it"), forState: .Normal)
        
        // UX/UI & appearance.
        currencyTypeButton.layer.cornerRadius = kAmbatanaSellProductControlsCornerRadius
        descriptionTextView.layer.cornerRadius = kAmbatanaSellProductControlsCornerRadius
        chooseCategoryButton.layer.cornerRadius = kAmbatanaSellProductControlsCornerRadius
        sellItButton.layer.cornerRadius = kAmbatanaSellProductControlsCornerRadius
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        LocationManager.sharedInstance.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button actions
    
    @IBAction func changeCurrencyType(sender: AnyObject) {
        let alert = UIAlertController(title: translate("choose_currency"), message: nil, preferredStyle: .ActionSheet)
        for currency in Currency.allCurrencies() {
            alert.addAction(UIAlertAction(title: currency.symbol(), style: .Default, handler: { (categoryAction) -> Void in
                self.currentCurrency = currency
                self.currencyTypeButton.setTitle(currency.symbol(), forState: .Normal)
            }))
        }
        alert.addAction(UIAlertAction(title: translate("cancel"), style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func chooseCategory(sender: AnyObject) {
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
        // do nothing.
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
        
        // Ok, if we reached this point we are ready to sell! Now let's build the new product object.
        enableLoadingWhileSellingObjectInterface()
        let productObject = PFObject(className: "Products")
        // fill in all product fields
        productObject["category_id"] = currentCategory!.rawValue
        productObject["currency"] = currentCurrency.rawValue
        productObject["description"] = descriptionTextView.text
        productObject["gps_coords"] = PFGeoPoint(latitude: currentLocationCoordinate.latitude, longitude: currentLocationCoordinate.longitude)
        productObject["processed"] = false
        productObject["language_code"] = NSLocale.preferredLanguages().first as? String ?? kAmbatanaDefaultCategoriesLanguage
        productObject["name"] = productTitleTextField.text
        productObject["name_dirify"] = productTitleTextField.text
        productObject["price"] = productPrice
        productObject["status"] = ProductStatus.Pending.rawValue
        productObject["user"] = PFUser.currentUser()
        productObject["user_id"] = PFUser.currentUser().objectId
        
        // images
        for (var i = 0; i < images.count; i++) {
            let imageKey = kAmbatanaProductImageKeys[i]
            productObject[imageKey] = images[i]
        }
        
        // ACL status
        productObject.ACL = globalReadAccessACL()
        
        // Last, try to extract the geolocation address for the object based on the current coordinates
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
            productObject.saveInBackgroundWithBlock({ (success, error) -> Void in
                self.disableLoadingWhileSellingObjectInterface()
                if success {
                    self.showAutoFadingOutMessageAlert(translate("successfully_uploaded_product"))
                    self.popBackViewController()
                } else {
                    self.showAutoFadingOutMessageAlert(translate("error_uploading_product"))
                }
            })
        })
    }

    // MARK: - UIImagePickerControllerDelegate methods
    
    func showImageSourceSelection() {
        let alert = UIAlertController(title: translate("choose_image_source"), message: translate("choose_image_source_description"), preferredStyle: .ActionSheet)
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
        picker.allowsEditing = true
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var imageFile: PFFile? = nil
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil { image = info[UIImagePickerControllerOriginalImage] as? UIImage }
        
        enableAddPhotoLoadingInterface()
        if image != nil {
            if let resizedImage = image!.resizeDownToMaxSide(kAmbatanaMaxProductImageSide, contentMode: .ScaleAspectFill) {
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
                    self.images.append(imageFile!)
                    // add some visual clue to the user
                    self.disableAddPhotoLoadingInterface()
                    self.collectionView.reloadSections(NSIndexSet(index: 0))
                } else {
                    self.disableAddPhotoLoadingInterface()
                    self.showAutoFadingOutMessageAlert(translate("unable_upload_photo"))
                }
            })
        }
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func enableAddPhotoLoadingInterface() {
        collectionView.userInteractionEnabled = false
        addPhotoActivityIndicator.startAnimating()
        addPhotoActivityIndicator.hidden = false
    }
    
    func disableAddPhotoLoadingInterface() {
        collectionView.userInteractionEnabled = true
        addPhotoActivityIndicator.hidden = false
        addPhotoActivityIndicator.stopAnimating()
    }
    
    func enableLoadingWhileSellingObjectInterface() {
        self.navigationItem.backBarButtonItem?.enabled = false
        self.view.userInteractionEnabled = false
        self.sellItActivityIndicator.startAnimating()
        self.sellItActivityIndicator.hidden = false
    }
    
    func disableLoadingWhileSellingObjectInterface() {
        self.sellItActivityIndicator.hidden = true
        self.sellItActivityIndicator.stopAnimating()
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
    
    // MARK: - Add Photo & Already uploaded images collection view DataSource & Delegate methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kAmbatanaAlreadyUploadedImageCellName, forIndexPath: indexPath) as UICollectionViewCell
        
        if indexPath.row > 0 { // already uploaded image
            let imageFile = images[indexPath.row - 1]
            // set image
            if let uploadedImageView = cell.viewWithTag(kAmbatanaAlreadyUploadedImageCellBigImageTag) as? UIImageView {
                if let imageData = imageFile.getData() {
                    uploadedImageView.image = UIImage(data: imageData) ?? UIImage(named: "no_photo")!
                    uploadedImageView.clipsToBounds = true
                    uploadedImageView.layer.cornerRadius = kAmbatanaSellProductControlsCornerRadius
                } else { uploadedImageView.image = UIImage(named: "no_photo")! }
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
        if indexPath.row == 0 { // add photo button.
            // check number of photos.
            if images.count >= kAmbatanaProductImageKeys.count {
                showAutoFadingOutMessageAlert(translate("max_images_reached"))
            } else {
                showImageSourceSelection()
            }
        } else { // delete current photo or save to disk?
            let alert = UIAlertController(title: translate("choose_action"), message: nil, preferredStyle: .ActionSheet)
            alert.addAction(UIAlertAction(title: translate("delete"), style: .Destructive, handler: { (deleteAction) -> Void in
                self.deleteAlreadyUploadedImageWithIndex(indexPath.row - 1)
            }))
            alert.addAction(UIAlertAction(title: translate("save_to_disk"), style: .Default, handler: { (saveAction) -> Void in
                self.saveProductImageToDiskAtIndex(indexPath.row - 1)
            }))
            alert.addAction(UIAlertAction(title: "cancel", style: .Cancel, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
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
        var savingProcessLaunched = false
        
        // get the image and launch the saving action.
        if let imageData = images[index].getData() {
            if let image = UIImage(data: imageData) {
                UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
                savingProcessLaunched = true
            }
        }
        
        // If we were unable to generate the image, inform the user about the error.
        if !savingProcessLaunched {
            self.showAutoFadingOutMessageAlert(translate("error_saving_to_disk"));
        }
        
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
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.resignFirstResponder()
        self.view.endEditing(true)
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.frame.origin.x = 0
        })
    }

}
