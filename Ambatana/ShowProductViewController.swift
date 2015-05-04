//
//  ShowProductViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 11/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import MapKit
import MessageUI
import Parse
import Social
import UIKit

protocol ShowProductViewControllerDelegate {
    func letgoProduct(productId: String, statusUpdatedTo newStatus: LetGoProductStatus)
}

/**
 * This ViewController is in charge of showing a single product selected from the ProductList view controller. Depending on the ownership of the product, the user would be allowed
 * to modify the object if he/she owns it, or make offers/chat with the owner.
 */
class ShowProductViewController: UIViewController, UIScrollViewDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate, UIDocumentInteractionControllerDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate {

    // outlets & buttons
    @IBOutlet weak var imagesScrollView: UIScrollView!
    @IBOutlet weak var askQuestionButton: UIButton!
    @IBOutlet weak var makeOfferButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var userAvatarImageView: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var publishedTimeLabel: UILabel!
    @IBOutlet weak var itemLocationMapView: MKMapView!
    @IBOutlet weak var markSoldButton: UIButton!
    @IBOutlet weak var imagesPageControl: UIPageControl!
    @IBOutlet weak var markAsSoldActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var askQuestionActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var showMapButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var fromYouLabel: UILabel!
    var favoriteButton: UIButton!
    @IBOutlet weak var errorLoadingPhotosLabel: UILabel!
    
    @IBOutlet weak var bottomGuideLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lineDivider: UIView!
    @IBOutlet weak var butProductReport: UIButton!
    
    @IBOutlet weak var butProductReportHeightConstraint: NSLayoutConstraint!
    
    // Data
    var productObject: PFObject!
    var isFavourite = false
    var productImages: [UIImage] = []
    var productImageURLStrings: [String] = []
    var productUser: PFUser!
    var productStatus: LetGoProductStatus?
    var productLocation: PFGeoPoint?
    var scrollViewOffset: CGFloat = 0.0
    var pageControlBeingUsed = false
    var delegate: ShowProductViewControllerDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // appearance
        priceLabel.text = ""
        nameLabel.text = ""
        descriptionLabel.text = ""
        publishedTimeLabel.text = ""
        usernameLabel.text = ""
        
        // set scrollview content size.
        let svSize = self.scrollView.bounds.size
        scrollView.contentSize = svSize
        // disable the height constraint and prioritize the bottom layout constraint so scrollview adjust itself to the view bounds.
        if heightConstraint != nil { if iOSVersionAtLeast("8.0") { heightConstraint.active = false } else { heightConstraint.priority = 1 } }
        if bottomGuideLayoutConstraint != nil { bottomGuideLayoutConstraint.priority = 1000 }
        
        // set rights buttons and locate favorite button.
        let buttons = self.setLetGoRightButtonsWithImageNames(["item_share-generic", "item_fav_off"], andSelectors: ["shareItem", "markOrUnmarkAsFavorite"], withTags: [0, 1])
        for button in buttons { if button.tag == 1 { self.favoriteButton = button } }
        
        // UX/UI
        self.markAsSoldActivityIndicator.hidden = true
        self.askQuestionActivityIndicator.hidden = true
        self.imagesPageControl.numberOfPages = 0
        self.userAvatarImageView.layer.cornerRadius = self.userAvatarImageView.frame.size.width / 2.0
        self.userAvatarImageView.clipsToBounds = true
        self.errorLoadingPhotosLabel.hidden = true
        
        // initialize product UI.
        if productObject != nil {
            // check if this is a favorite product
            initializeFavoriteButtonAnimations()
            checkFavoriteProduct()
            
            // check if this is our product
            productUser = productObject["user"] as! PFUser
            let thisProductIsMine = productUser.objectId == PFUser.currentUser()!.objectId
            self.askQuestionButton.hidden = thisProductIsMine
            self.makeOfferButton.hidden = thisProductIsMine
            self.markSoldButton.hidden = !thisProductIsMine
            // if product is sold, disable markAsSold button.
            if let statusCode = productObject["status"] as? Int {
                productStatus = LetGoProductStatus(rawValue: statusCode)
                if productStatus == .Sold {
                    // update appearance
                    markSoldButton.enabled = false
                    self.markSoldButton.hidden = true
                    makeOfferButton.hidden = true
                    askQuestionButton.hidden = true
                    
                } else {
                    markSoldButton.setTitle(translate("mark_as_sold"), forState: .Normal)
                }
            }

            // load owner user information
            let userQuery = PFUser.query()
            userQuery!.whereKey("objectId", equalTo: productUser.objectId!)
            userQuery!.getFirstObjectInBackgroundWithBlock({
                [weak self] (retrievedUser, error) -> Void in
                if let strongSelf = self {
                    // user name
                    if error == nil {
                        let usernamePublic = retrievedUser?["username_public"] as? String ?? translate("unknown")
                        strongSelf.usernameLabel.text = usernamePublic
                        if let avatarFile = retrievedUser?["avatar"] as? PFFile {
                            ImageManager.sharedInstance.retrieveImageFromParsePFFile(avatarFile, completion: { (success, image) -> Void in
                                if success {
                                    strongSelf.userAvatarImageView.setImage(image, forState: .Normal)
                                } else { strongSelf.userAvatarImageView.setImage(UIImage(named: "no_photo"), forState: .Normal) }
                                }, andAddToCache: true)
                        } else { strongSelf.userAvatarImageView.setImage(UIImage(named: "no_photo"), forState: .Normal) }
                    } else {
                        //println("Error retrieving user object: \(error!.localizedDescription)")
                        strongSelf.usernameLabel.hidden = true
                        strongSelf.userAvatarImageView.hidden = true
                    }
                }
            })
            
            // fill fields
            
            // images first (as they need to be downloaded).
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                // do we have processed images?
                var useThumbnails = false
                if let processed = self.productObject["processed"] as? Bool {
                    useThumbnails = processed
                }
                
                // retrieve from Parse / from thumbnail
                if useThumbnails { self.retrieveImagesFromProcessedThumbnails() }
                else { self.retrieveImagesFromParse() }
            })
            
            // product name
            if let productName = productObject["name"] as? String {
                nameLabel.text = productName.lg_capitalizedWords()
            }
            else {
                nameLabel.text = ""
            }
            TrackingManager.sharedInstance.trackEvent(kLetGoTrackingEventNameProductDetailVisit, eventParameters: self.getPropertiesForProductDetailTracking())
            self.setLetGoNavigationBarStyle(title: "", includeBackArrow: true)
            
            // product price
            if let price = productObject["price"] as? Double {
                let currencyString = productObject["currency"] as? String ?? CurrencyManager.sharedInstance.defaultCurrency.iso4217Code
                if let currency = CurrencyManager.sharedInstance.currencyForISO4217Symbol(currencyString) {
                    priceLabel.text = currency.formattedCurrency(price)
                    priceLabel.hidden = false
                } else { // fallback to just the price.
                    priceLabel.text = "\(price)"
                    priceLabel.hidden = false
                }
            } else { priceLabel.hidden = true }
            
            // product description
            if let description = productObject["description"] as? String {
                descriptionLabel.text = description.lg_capitalizedParagraph()
                descriptionLabel.hidden = false
            }
            else {
                descriptionLabel.hidden = true
            }
            
            // product published date.
            if productObject.createdAt != nil {
                publishedTimeLabel.text = productObject.createdAt!.relativeTimeString().lowercaseString
                publishedTimeLabel.hidden = false
            } else { publishedTimeLabel.hidden = true }
            
            // location in map
            if let productLocation = productObject["gpscoords"] as? PFGeoPoint {
                self.productLocation = productLocation
                // set map region
                let coordinate = CLLocationCoordinate2D(latitude: productLocation.latitude, longitude: productLocation.longitude)
                let region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
                itemLocationMapView.setRegion(region, animated: true)
                // add pin
                itemLocationMapView.setPinInTheMapAtCoordinate(coordinate)
                // set location label
                let locationString = distanceStringToGeoPoint(productLocation)
                locationLabel.text = locationString
                if locationString == translate("here") { fromYouLabel.hidden = true } else { fromYouLabel.hidden = false }
            }
            
            // fraud report
            if thisProductIsMine {
                if let statusCode = productObject["status"] as? Int {
                    self.lineDivider.hidden = true
                    self.butProductReport.hidden = true
                    
                    productStatus = LetGoProductStatus(rawValue: statusCode)
                    if productStatus == .Sold {
                        self.butProductReportHeightConstraint.constant = 0
                    }
                    else {
                        self.butProductReportHeightConstraint.constant = 20
                    }
                }
                else {
                    self.butProductReportHeightConstraint.constant = 20
                }
            }
            else {
                self.lineDivider.hidden = false
                self.butProductReport.hidden = false
                self.butProductReportHeightConstraint.constant = 80
            }
            
        } else { // hide all buttons
            self.markSoldButton.hidden = true
            self.askQuestionButton.hidden = true
            self.makeOfferButton.hidden = true
            self.lineDivider.hidden = true
            self.butProductReport.hidden = true
        }
        
        // internationalization
        makeOfferButton.setTitle(translate("make_an_offer"), forState: .Normal)
        askQuestionButton.setTitle(translate("ask_a_question"), forState: .Normal)
        fromYouLabel.text = translate("from_you")
        errorLoadingPhotosLabel.text = translate("error_loading_photos_product")
        butProductReport.setTitle(translate("report_product"), forState: .Normal)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        TrackingManager.sharedInstance.trackEvent(kLetGoTrackingEventNameScreenPrivate, eventParameters: [kLetGoTrackingParameterNameScreenName: "show-product"])

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Product detail tracking event properties
    
    /** Generates the properties for the product-detail tracking event. NOTE: This would probably change once Parse is not used anymore */
    func getPropertiesForProductDetailTracking() -> [String: AnyObject] {
        var properties: [String: AnyObject] = [:]
        if productObject != nil {
            if let productCity = productObject[kLetGoRestAPIParameterCity] as? String { properties[kLetGoTrackingParameterNameProductCity] = productCity }
            if let productCountry = productObject[kLetGoRestAPIParameterCountryCode] as? String { properties[kLetGoTrackingParameterNameProductCountry] = productCountry }
            if let productZipCode = productObject[kLetGoRestAPIParameterZipCode] as? String { properties[kLetGoTrackingParameterNameProductZipCode] = productZipCode }
            if let productCategoryId = productObject[kLetGoRestAPIParameterCategoryId] as? String { properties[kLetGoTrackingParameterNameCategoryId] = productCategoryId }
            if let productName = productObject[kLetGoRestAPIParameterName] as? String { properties[kLetGoTrackingParameterNameProductName] = productName }
            properties[kLetGoTrackingParameterNameItemType] = "real" // we suppose it's real unless TrackingManager says otherwise.
        }
        
        return properties
    }
    
    
    // MARK: - Image retrieval
    
    func retrieveImagesFromParse() {
        var retrievedImages: [UIImage] = []
        var retrievedImageURLS: [String] = []
        // iterate and retrieve all images.
        for imageKey in kLetGoProductImageKeys {
            if let imageFile = self.productObject[imageKey] as? PFFile {
                if let data = imageFile.getData(nil) { // retrieve from parse synchronously
                    if let retrievedImage = UIImage(data: data) {
                        retrievedImages.append(retrievedImage)
                        retrievedImageURLS.append(imageFile.url!)
                    }
                }
            }
        }
        // set images and update scrollview. Must be done in main queue.
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.productImages = retrievedImages
            self.setProductMainImages()
            self.productImageURLStrings = retrievedImageURLS
        })
    }
    
    func retrieveImagesFromProcessedThumbnails() {
        var retrievedImages: [UIImage] = []
        var retrievedImageURLS: [String] = []
        // iterate and retrieve all images.
        for imageKey in kLetGoProductImageKeys {
            if let imageFile = self.productObject[imageKey] as? PFFile {
                let bigImageURL = ImageManager.sharedInstance.calculateBigImageURLForProductImage(self.productObject.objectId!, imageURL: imageFile.url!)
                if let image = ImageManager.sharedInstance.retrieveImageSynchronouslyFromURLString(bigImageURL, andAddToCache: true) {
                    retrievedImages.append(image)
                    retrievedImageURLS.append(bigImageURL)
                }
            }
        }
        
        if retrievedImages.count > 0 { // we managed to retrieve at least one thumbnail.
            // set images and update scrollview. Must be done in main queue.
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.productImages = retrievedImages
                self.setProductMainImages()
                self.productImageURLStrings = retrievedImageURLS
            })
        } else { // fallback to Parse images.
            retrieveImagesFromParse()
        }
        
    }

    // MARK: - Button actions
    @IBAction func askQuestion(sender: AnyObject) {
        // safety checks
        if productUser == nil || productObject == nil { showAutoFadingOutMessageAlert(translate("unable_show_conversation")); return }
        
        // Tracking
        TrackingManager.sharedInstance.trackEvent(kLetGoTrackingEventNameProductDetailAskQuestion, eventParameters: self.getPropertiesForProductDetailTracking())
        
        // loading interface...
        enableAskQuestionLoadingInterface()
        
        // check if we have some current conversation with the user
        ChatManager.sharedInstance.retrieveMyConversationWithUser(productUser!, aboutProduct: productObject!) { (success, conversation) -> Void in
            if success { // we have a conversation.
                self.launchChatWithConversation(conversation!)
            } else { // we need to create a conversation and pass it.
                ChatManager.sharedInstance.createConversationWithUser(self.productUser!, aboutProduct: self.productObject!, completion: { (success, conversation) -> Void in
                    if success { self.launchChatWithConversation(conversation!) }
                    else { self.disableAskQuestionLoadingInterface(); self.showAutoFadingOutMessageAlert(translate("unable_start_conversation")) }
                })
            }
        }
    }
    
    func launchChatWithConversation(conversation: PFObject) {
        if let chatVC = self.storyboard?.instantiateViewControllerWithIdentifier("productChatConversationVC") as? ChatViewController {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                chatVC.letgoConversation = LetGoConversation(parseConversationObject: conversation)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.disableAskQuestionLoadingInterface()
                    self.navigationController?.pushViewController(chatVC, animated: true) ?? self.showAutoFadingOutMessageAlert(translate("unable_start_conversation"))
                })
            })
        } else { disableAskQuestionLoadingInterface(); showAutoFadingOutMessageAlert(translate("unable_start_conversation")) }
    }
    
    func enableAskQuestionLoadingInterface() {
        // disable back navigation.
        self.navigationItem.backBarButtonItem?.enabled = false
        self.navigationItem.leftBarButtonItem?.enabled = false
        // disable interaction
        self.view.userInteractionEnabled = false
        // appearance
        askQuestionActivityIndicator.center = askQuestionButton.center
        askQuestionActivityIndicator.startAnimating()
        askQuestionActivityIndicator.hidden = false
        askQuestionButton.setTitle("", forState: .Normal)
        askQuestionButton.setImage(nil, forState: .Normal)
        askQuestionButton.enabled = false
    }
    
    func disableAskQuestionLoadingInterface() {
        // appearance
        askQuestionActivityIndicator.hidden = true
        askQuestionActivityIndicator.stopAnimating()
        askQuestionButton.setTitle(translate("ask_a_question"), forState: .Normal)
        askQuestionButton.setImage(UIImage(named: "item_chat")!, forState: .Normal)
        askQuestionButton.enabled = true
        // re-enable back navigation.
        self.navigationItem.backBarButtonItem?.enabled = true
        self.navigationItem.leftBarButtonItem?.enabled = true
        // re-enable interaction
        self.view.userInteractionEnabled = true
    }
    
    @IBAction func showProductLocation(sender: AnyObject) {
        // push the location controller if there's a location
        if productLocation != nil {
            let coords = CLLocationCoordinate2DMake(productLocation!.latitude, productLocation!.longitude)
            self.performSegueWithIdentifier("ShowProductLocation", sender: sender)
        }
    }
    
    @IBAction func makeOffer(sender: AnyObject) {
        TrackingManager.sharedInstance.trackEvent(kLetGoTrackingEventNameProductDetailVisit, eventParameters: self.getPropertiesForProductDetailTracking())
        self.performSegueWithIdentifier("MakeAnOffer", sender: sender)
    }
    
    @IBAction func markProductAsSold(sender: AnyObject) {
        TrackingManager.sharedInstance.trackEvent(kLetGoTrackingEventNameProductDetailSold, eventParameters: self.getPropertiesForProductDetailTracking())
        if iOSVersionAtLeast("8.0") {
            let alert = UIAlertController(title: translate("mark_as_sold"), message: translate("are_you_sure_mark_sold"), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: translate("cancel"), style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: translate("mark_as_sold"), style: .Default, handler: { (markAction) -> Void in
                self.definitelyMarkProductAsSold()
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        } else { // ios7 fallback --> ActionSheet.
            let alert = UIAlertView(title: translate("mark_as_sold"), message: translate("are_you_sure_mark_sold"), delegate: self, cancelButtonTitle: translate("cancel"))
            alert.addButtonWithTitle(translate("mark_as_sold"))
            alert.show()
        }
        
    }

    @IBAction func reportProductButtonPressed(sender: AnyObject) {

        if let product = productObject, let myUser = PFUser.currentUser(), let productOwner = productUser {
            
            butProductReport.enabled = false
            butProductReport.setTitle(translate("reporting_product"), forState: .Normal)
            
            let report = PFObject(className: "UserReports")
            report["product_reported"] = productObject
            report["user_reporter"] = PFUser.currentUser()
            report["user_reported"] = productUser
            
            report.saveInBackgroundWithBlock({ [weak self] (success, error) -> Void in
                if let strongSelf = self {
                    
                    strongSelf.butProductReport.enabled = true
                    
                    if success {
                        strongSelf.butProductReport.setTitle(translate("reported_product"), forState: .Normal)
                    }
                    else {
                        strongSelf.butProductReport.setTitle(translate("report_product"), forState: .Normal)
                    }
                }
                })
        }
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            self.definitelyMarkProductAsSold()
        }
    }
    
    // if user answered "yes" to the question: "Do you really want to mark this product as sold?"...
    func definitelyMarkProductAsSold() {
        self.enableMarkAsSoldLoadingInterface()
        self.productObject["status"] = LetGoProductStatus.Sold.rawValue
        self.productObject.saveInBackgroundWithBlock({ (success, error) -> Void in
            if success {
                self.productStatus = .Sold
                // animated hiding of the button, restore alpha once hidden.
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.markSoldButton.alpha = 0.0
                    }, completion: { (success) -> Void in
                        self.markSoldButton.hidden = true
                        self.markSoldButton.alpha = 1.0
                        self.showAutoFadingOutMessageAlert(translate("marked_as_sold"), completionBlock: nil)
                })
                
                self.delegate?.letgoProduct(self.productObject.objectId!, statusUpdatedTo: self.productStatus!)
            } else {
                self.markSoldButton.enabled = true
                self.showAutoFadingOutMessageAlert(translate("error_marking_as_sold"))
            }
            self.disableMarkAsSoldLoadingInterface()
        })
    }
    
    // MARK: - Mark as sold UI/UX
    
    func enableMarkAsSoldLoadingInterface() {
        self.markSoldButton.userInteractionEnabled = false
        self.markAsSoldActivityIndicator.startAnimating()
        self.markAsSoldActivityIndicator.hidden = false
        self.markSoldButton.setTitle("", forState: .Normal)
        self.markSoldButton.setImage(nil, forState: .Normal)
    }
    
    func disableMarkAsSoldLoadingInterface() {
        self.markAsSoldActivityIndicator.hidden = true
        self.markAsSoldActivityIndicator.stopAnimating()
        if productStatus == .Sold {
            // markSoldButton.setTitle(translate("marked_as_sold"), forState: .Normal)
            // remove all buttons
            markSoldButton.hidden = true
        } else {
            markSoldButton.setTitle(translate("mark_as_sold"), forState: .Normal)
        }
        self.markSoldButton.setImage(UIImage(named: "item_offer"), forState: .Normal)
        self.markSoldButton.userInteractionEnabled = true
    }
    
    // MARK: - Sharing & searching...
    
    func shareItem() {
        // build items to share
        var itemsToShare: [AnyObject] = []
        
        // text
        let productName = productObject?["name"] as? String ?? ""
        let userName = usernameLabel.text!
        let textToShare = letgoTextForSharingBody(productName, userName, andObjectId: productObject!.objectId!)
        itemsToShare.append(textToShare)
        // image
        if productImages.count > 0 {
            let firstImage = productImages.first!
            itemsToShare.append(firstImage)
        }
        // url
        itemsToShare.append(letgoWebLinkForObjectId(productObject!.objectId!))
        
        // show activity view controller.
        let activityVC = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeSaveToCameraRoll] // we don't want those to show in the sharing dialog.
//        activityVC.setValue(translate("product_share_email_subject_intro"), forKey: "subject") // for email.
        
        // hack for eluding the iOS8 "LaunchServices: invalidationHandler called" bug from Apple.
        if activityVC.respondsToSelector("popoverPresentationController") {
            let presentationController = activityVC.popoverPresentationController
            presentationController?.sourceView = self.view
        }
        self.presentViewController(activityVC, animated: true, completion: nil)
    }

    // MARK: - Favourite Requests & helpers
    
    func initializeFavoriteButtonAnimations() {
        // save link animations
        let animatingImages = [UIImage(named: "item_fav_on")!.imageWithRenderingMode(.AlwaysOriginal), UIImage(named: "item_fav_off")!.imageWithRenderingMode(.AlwaysOriginal)]
        self.favoriteButton.imageView!.animationImages = animatingImages
        self.favoriteButton.imageView!.animationDuration = 0.50
        self.favoriteButton.imageView!.animationRepeatCount = 0
        
    }
    
    //@IBAction func markOrUnmarkAsFavorite(sender: AnyObject) {
    func markOrUnmarkAsFavorite() {
        self.favoriteButton.userInteractionEnabled = false
        
        // UI update for quick user feedback + Request
        self.favoriteButton.imageView!.startAnimating()
        
        if self.isFavourite {
            deleteFavouriteProductForUser(PFUser.currentUser(),
                product: self.productObject,
                completion: { (success) -> Void in
                    self.favoriteButton.userInteractionEnabled = true
                    self.isFavourite = !success
                    self.favoriteButton.imageView!.stopAnimating()
                    self.favoriteButton.setImage(self.isFavourite ? UIImage(named: "item_fav_on")!.imageWithRenderingMode(.AlwaysOriginal) : UIImage(named: "item_fav_off")!.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
            })
        }
        else {
            saveFavouriteProductForUser(PFUser.currentUser(),
                product: self.productObject,
                completion: { (success) -> Void in
                    self.favoriteButton.userInteractionEnabled = true
                    self.isFavourite = success
                    self.favoriteButton.imageView!.stopAnimating()
                    self.favoriteButton.setImage(self.isFavourite ? UIImage(named: "item_fav_on")!.imageWithRenderingMode(.AlwaysOriginal) : UIImage(named: "item_fav_off")!.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
            })
        }
    }
    
    func checkFavoriteProduct() {
        self.favoriteButton.userInteractionEnabled = false
        retrieveFavouriteProductForUser(
            PFUser.currentUser(),
            product: productObject,
            completion: { (success, favProduct) -> Void in
                self.favoriteButton.userInteractionEnabled = true
                
                if success {
                    self.isFavourite = favProduct != nil
                }
                self.favoriteButton.setImage(self.isFavourite ? UIImage(named: "item_fav_on")!.imageWithRenderingMode(.AlwaysOriginal) : UIImage(named: "item_fav_off")!.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
            })
    }
    
    func retrieveFavouriteProductForUser(user: PFUser?, product: PFObject?, completion: (Bool, PFObject?) -> (Void)) {
        if let actualUser = user {
            if let actualProduct = product {
                let favQuery = PFQuery(className: "UserFavoriteProducts")
                favQuery.whereKey("user", equalTo: actualUser)
                favQuery.whereKey("product", equalTo: actualProduct)
                favQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    let favProduct = objects?.first as? PFObject
                    let success = error == nil
                    completion(success, favProduct)
                })
            }
            else {
                completion(false, nil)
            }
        }
        else {
            completion(false, nil)
        }
    }
    
    func saveFavouriteProductForUser(user: PFUser?, product: PFObject?, completion: (Bool) -> (Void)) {
        if let favProduct = newFavProductForUser(user, product: product) {
            favProduct.saveInBackgroundWithBlock({ (success, error) -> Void in
                completion(success)
            })
        }
        else {
            completion(false)
        }
    }
    
    func deleteFavouriteProductForUser(user: PFUser?, product: PFObject?, completion: (Bool) -> (Void)) {
        retrieveFavouriteProductForUser(user, product: product, completion: { (success, favProduct) -> Void in
            if success && favProduct != nil {
                favProduct!.deleteInBackgroundWithBlock({ (success, error) -> Void in
                    if success {
                        completion(true)
                    }
                    else {
                        completion(false)
                    }
                })
            }
            else {
                completion(false)
            }
        })
    }
    
    func newFavProductForUser(user: PFUser?, product: PFObject?) -> PFObject? {
        if let actualUser = user {
            if let actualProduct = product {
                let favProduct = PFObject(className: "UserFavoriteProducts")
                favProduct["user"] = actualUser
                favProduct["product"] = actualProduct
                return favProduct
            }
        }
        return nil
    }
    
    // MARK: - Mail Composer Delegate methods    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        var message: String? = nil
        if result.value == MFMailComposeResultFailed.value { // we just give feedback if something nasty happened.
            message = translate("errorsendingmail")
        }
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            if message != nil { self.showAutoFadingOutMessageAlert(message!) }
        })
        
    }
    
    // MARK: - Images, pagination and scrollview.
    
    func setProductMainImages() {
        if self.productImages.count > 0 {
            self.imagesScrollView.alpha = 0
            self.errorLoadingPhotosLabel.hidden = true
            self.imagesScrollView.hidden = false
            var offset: CGFloat = 0
            var pageNumber = 0
            
            // add the images
            for image in productImages {
                // define image
                let imageView = UIImageView(frame: CGRectMake(offset, 0, self.imagesScrollView.frame.size.width, self.imagesScrollView.frame.size.height))
                imageView.image = image
                imageView.contentMode = .ScaleAspectFill
                imageView.clipsToBounds = true
                imageView.tag = pageNumber++
                
                // add to UIScrollView and update offset
                imagesScrollView.addSubview(imageView)
                offset += self.imagesScrollView.frame.size.width
            }
            // set the images scrollview global offset
            self.imagesScrollView.contentSize = CGSizeMake(offset, self.imagesScrollView.frame.size.height)
            
            // set UIGestureRecognizer to recognize taps and segue.
            let recognizer = UITapGestureRecognizer(target: self, action: "showImageInDetail:")
            recognizer.numberOfTapsRequired = 1
            imagesScrollView.addGestureRecognizer(recognizer)

            // show with fade-in animation
            self.imagesPageControl.numberOfPages = self.productImages.count
            if self.imagesPageControl.numberOfPages <= 1 { self.imagesPageControl.hidden = true }
            self.imagesPageControl.currentPage = 0
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.imagesScrollView.alpha = 1.0
            })
        } else {
            self.imagesScrollView.hidden = true
            self.errorLoadingPhotosLabel.hidden = false
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if !pageControlBeingUsed {
            let newPage = floor((self.imagesScrollView.contentOffset.x - self.imagesScrollView.frame.size.width / 2) / self.imagesScrollView.frame.size.width) + 1
            imagesPageControl.currentPage = Int(newPage)
        }

    }
    
    @IBAction func changePage(sender: AnyObject) {
        let offset = imagesScrollView.frame.size.width * CGFloat(imagesPageControl.currentPage)
        self.imagesScrollView.scrollRectToVisible(CGRectMake(offset, 0, imagesScrollView.frame.size.width, imagesScrollView.frame.size.height), animated: true)
        pageControlBeingUsed = true
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        pageControlBeingUsed = false
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        pageControlBeingUsed = false
    }
    
    func showImageInDetail(gestureRecognizer: UITapGestureRecognizer) {
        self.performSegueWithIdentifier("ShowPhotosInDetail", sender: nil)
    }
    
    // MARK: - MKMapViewDelegate methods
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var productPin = mapView.dequeueReusableAnnotationViewWithIdentifier("com.letgo.productpin")
        if productPin == nil {
            productPin = MKAnnotationView(annotation: annotation, reuseIdentifier: "com.letgo.productpin")
            productPin.canShowCallout = true
            productPin.image = UIImage(named: "map_circle")
        }
        return productPin
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let pdvc = segue.destinationViewController as? PhotosInDetailViewController {
            pdvc.productImages = self.productImages
            pdvc.initialImageToShow = self.imagesPageControl.currentPage
            pdvc.productName = nameLabel.text!
        } else if let epvc = segue.destinationViewController as? EditProfileViewController {
            epvc.userObject = self.productUser
        } else if let movc = segue.destinationViewController as? MakeAnOfferViewController {
            movc.productObject = self.productObject
            movc.productUser = self.productUser
        } else if let plvc = segue.destinationViewController as? ProductLocationViewController {
            if productLocation != nil {
                let coordinate = CLLocationCoordinate2DMake(productLocation!.latitude, productLocation!.longitude)
                plvc.location = coordinate
            }
        }
    }
    
    @IBAction func showProductUser(sender: AnyObject) {
        self.performSegueWithIdentifier("ShowProductUser", sender: sender)
    }
}

