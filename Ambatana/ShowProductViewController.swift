//
//  ShowProductViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 11/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import LGCoreKit
import MapKit
import MessageUI
import Parse
import pop
import SDWebImage
import Social
import UIKit

protocol ShowProductViewControllerDelegate {
    func letgoProduct(productId: String, statusUpdatedTo newStatus: LetGoProductStatus)
}

/**
 * This ViewController is in charge of showing a single product selected from the ProductList view controller. Depending on the ownership of the product, the user would be allowed
 * to modify the object if he/she owns it, or make offers/chat with the owner.
 */
class ShowProductViewController: UIViewController, GalleryViewDelegate, UIScrollViewDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate, UIDocumentInteractionControllerDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate {

    // outlets & buttons
    @IBOutlet weak var galleryView: GalleryView!
    @IBOutlet weak var askQuestionButton: UIButton!
    @IBOutlet weak var makeOfferButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var itemLocationMapView: MKMapView!
    @IBOutlet weak var markSoldButton: UIButton!
    @IBOutlet weak var markAsSoldActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var askQuestionActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var showMapButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var fromYouLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var zipCodelLabel: UILabel!   
    
    var favoriteButton: UIButton!
    
    @IBOutlet weak var bottomGuideLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lineDivider: UIView!
    @IBOutlet weak var butProductReport: UIButton!
    
    @IBOutlet weak var butProductReportHeightConstraint: NSLayoutConstraint!
    
    // Data
    var product: Product
    
    var isFavourite = false
    var productStatus: LetGoProductStatus?
    var scrollViewOffset: CGFloat = 0.0
    var pageControlBeingUsed = false
    var delegate: ShowProductViewControllerDelegate?
    
    // MARK: - Lifecycle

    init(product: Product) {
        self.product = product
        
        super.init(nibName: "ShowProductViewController", bundle: nil)
        automaticallyAdjustsScrollViewInsets = false
        hidesBottomBarWhenPushed = true

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
       
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // appearance
        priceLabel.text = ""
        nameLabel.text = ""
        descriptionLabel.text = ""
        usernameLabel.text = ""
        cityLabel.text = ""
        zipCodelLabel.text = ""
        
        // Navbar
        self.setLetGoNavigationBarStyle(title: "")
        
        // set scrollview content size.
        let svSize = self.scrollView.bounds.size
        scrollView.contentSize = svSize
        // disable the height constraint and prioritize the bottom layout constraint so scrollview adjust itself to the view bounds.
        if heightConstraint != nil { if iOSVersionAtLeast("8.0") { heightConstraint.active = false } else { heightConstraint.priority = 1 } }
        if bottomGuideLayoutConstraint != nil { bottomGuideLayoutConstraint.priority = 1000 }
        
        // set rights buttons and locate favorite button.
        let buttons = self.setLetGoRightButtonsWithImageNames(["navbar_share", "navbar_fav_off"], andSelectors: ["shareItem", "markOrUnmarkAsFavorite"], withTags: [0, 1])
        for button in buttons { if button.tag == 1 { self.favoriteButton = button } }
        
        // UX/UI
        self.markAsSoldActivityIndicator.hidden = true
        self.askQuestionActivityIndicator.hidden = true
        self.userAvatarImageView.layer.cornerRadius = self.userAvatarImageView.frame.size.width / 2.0
        self.userAvatarImageView.clipsToBounds = true
        
        // initialize product UI.
        // check if this is a favorite product
        initializeFavoriteButtonAnimations()
        checkFavoriteProduct()
        
        // check if this is product is mine
        var thisProductIsMine = false
        if let productUser = product.user, let userId = productUser.objectId, let myUser = MyUserManager.sharedInstance.myUser() {
            thisProductIsMine = userId == myUser.objectId
        }
        
        // Buttons
        switch product.status {
            // If approved show action buttons depending on if it's mine or not
        case .Approved:
            self.askQuestionButton.hidden = thisProductIsMine
            self.makeOfferButton.hidden = thisProductIsMine
            self.markSoldButton.hidden = !thisProductIsMine
            // Otherwise no other action can be performed
        default:
            self.askQuestionButton.hidden = true
            self.makeOfferButton.hidden = true
            self.markSoldButton.hidden = true
        }
        
        // User
        usernameLabel.text = product.user?.publicUsername ?? ""
        if let userAvatarURL = product.user?.avatarURL {
            userAvatarImageView.sd_setImageWithURL(userAvatarURL, placeholderImage: UIImage(named: "no_photo"))
        }
        
        // fill fields
        setProductMainImages()
        
        // product name & price
        nameLabel.text = product.name?.lg_capitalizedWords() ?? ""
        priceLabel.text = product.formattedPrice()
        
        // product description
        descriptionLabel.text = product.descr ?? ""
        
        // city & zip code
        cityLabel.text = product.postalAddress.city?.lg_capitalizedWord() ?? ""
        if let zipCode = product.postalAddress.zipCode {
            if !zipCode.isEmpty {
                zipCodelLabel.text = "(" +  zipCode + ")"
            }
        }
        
        // location in map
        if let location = product.location {
            // set map region
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
            itemLocationMapView.setRegion(region, animated: true)
            // add pin
            itemLocationMapView.setPinInTheMapAtCoordinate(coordinate)
        }
        
        // distance
        locationLabel.text = product.formattedDistance()
        
        // fraud report
        if thisProductIsMine {
            self.lineDivider.hidden = true
            self.butProductReport.hidden = true
            
            self.butProductReportHeightConstraint.constant = 0
            if product.status == .Sold {
                self.butProductReportHeightConstraint.constant = 0
            }
            else {
                self.butProductReportHeightConstraint.constant = 20
            }
        }
        else {
            self.lineDivider.hidden = false
            self.butProductReport.hidden = false
            self.butProductReportHeightConstraint.constant = 50
        }
        
        // internationalization
        makeOfferButton.setTitle(translate("make_an_offer"), forState: .Normal)
        askQuestionButton.setTitle(translate("ask_a_question"), forState: .Normal)
        markSoldButton.setTitle(translate("mark_as_sold"), forState: .Normal)
        fromYouLabel.text = translate("from_you")
        butProductReport.setTitle(translate("report_product"), forState: .Normal)
        
        // Tracking
        TrackingHelper.trackEvent(.ProductDetailVisit, parameters: trackingParams)
    }
    
    // MARK: - Product detail tracking event properties
    
    private var trackingParams: [TrackingParameter: AnyObject] {
        get {
            var properties: [TrackingParameter: AnyObject] = [:]
            
            
            if let city = product.postalAddress.city {
                properties[.ProductCity] = city
            }
            if let countryCode = product.postalAddress.countryCode {
                properties[.ProductCountry] = countryCode
            }
            if let zipCode = product.postalAddress.zipCode {
                properties[.ProductZipCode] = zipCode
            }
            if let categoryId = product.categoryId {
                properties[.CategoryId] = categoryId.stringValue
            }
            if let name = product.name {
                properties[.ProductName] = name
            }
            if let productUser = product.user {
                if let isDummy = TrackingHelper.isDummyUser(productUser) {
                    properties[.ItemType] = TrackingHelper.productTypeParamValue(isDummy)
                }
            }
            
            return properties
        }
    }

    // MARK: - Button actions
    @IBAction func askQuestion(sender: AnyObject) {
        // safety checks
        if product.user == nil { showAutoFadingOutMessageAlert(translate("unable_show_conversation")); return }
        
        // loading interface...
        enableAskQuestionLoadingInterface()

        // check if we have some current conversation with the user
        ChatManager.sharedInstance.retrieveMyConversationWithUser(product.user!, aboutProduct: product) { [weak self] (success, conversation) -> Void in
            if let strongSelf = self {
                if success { // we have a conversation.
                    strongSelf.launchChatWithConversation(conversation!)
                }
                else { // we need to create a conversation and pass it.
                    ChatManager.sharedInstance.createConversationWithUser(strongSelf.product.user!, aboutProduct: strongSelf.product, completion: { (success, conversation) -> Void in
                        if success {
                            strongSelf.launchChatWithConversation(conversation!)
                        }
                        else {
                            strongSelf.disableAskQuestionLoadingInterface(); strongSelf.showAutoFadingOutMessageAlert(translate("unable_start_conversation"))
                        }
                    })
                }
            }
        }
    }
    
    func launchChatWithConversation(conversation: PFObject) {
        let chatVC = ChatViewController()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            chatVC.letgoConversation = LetGoConversation(parseConversationObject: conversation)
            chatVC.askQuestion = true
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.disableAskQuestionLoadingInterface()
                self.navigationController?.pushViewController(chatVC, animated: true) ?? self.showAutoFadingOutMessageAlert(translate("unable_start_conversation"))
            })
        })
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
        if let location = product.location {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("ProductLocationViewController") as! ProductLocationViewController
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            vc.location = coordinate
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func makeOffer(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("MakeAnOfferViewController") as! MakeAnOfferViewController
        vc.product = product
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func markProductAsSold(sender: AnyObject) {
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

        if let let myUser = MyUserManager.sharedInstance.myUser(), let productOwner = product.user {
            
            butProductReport.enabled = false
            butProductReport.setTitle(translate("reporting_product"), forState: .Normal)
            
            let report = PFObject(className: "UserReports")
            report["product_reported"] = PFObject(withoutDataWithClassName:PAProduct.parseClassName(), objectId:product.objectId)
            report["user_reporter"] = PFUser(withoutDataWithObjectId: myUser.objectId)
            report["user_reported"] = PFUser(withoutDataWithObjectId: productOwner.objectId)
            
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
        
        if let parseProduct = product as? PAProduct {
            parseProduct.status = .Sold
            parseProduct.processed = false
            parseProduct.saveInBackgroundWithBlock({ (success, error) -> Void in
                if success {
                    self.productStatus = .Sold
                    
                    // Tracking
                    TrackingHelper.trackEvent(.ProductMarkAsSold, parameters: self.trackingParams)
                    
                    // animated hiding of the button, restore alpha once hidden.
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.markSoldButton.alpha = 0.0
                        }, completion: { (success) -> Void in
                            self.markSoldButton.hidden = true
                            self.markSoldButton.alpha = 1.0
                            self.showAutoFadingOutMessageAlert(translate("marked_as_sold"), completionBlock: nil)
                    })
                    
                    self.delegate?.letgoProduct(parseProduct.objectId!, statusUpdatedTo: self.productStatus!)
                } else {
                    self.markSoldButton.enabled = true
                    self.showAutoFadingOutMessageAlert(translate("error_marking_as_sold"))
                }
                self.disableMarkAsSoldLoadingInterface()
            })
        }
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
        if let objectId = product.objectId {
            // build items to share
            var itemsToShare: [AnyObject] = []
            
            // text
            let productName = product.name ?? ""
            let userName = usernameLabel.text!
            let textToShare = letgoTextForSharingBody(productName, userName, andObjectId: objectId)
            itemsToShare.append(textToShare)
            
//            // image
//            if let thumbURL = ImageHelper.thumbnailURLForProduct(product) {
//                itemsToShare.append(thumbURL)
//            }
            
            // show activity view controller.
            let activityVC = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)

            activityVC.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeSaveToCameraRoll] // we don't want those to show in the sharing dialog.
//            activityVC.setValue(translate("product_share_email_subject_intro"), forKey: "subject") // for email.
            
            // hack for eluding the iOS8 "LaunchServices: invalidationHandler called" bug from Apple.
            // src: http://stackoverflow.com/questions/25759380/launchservices-invalidationhandler-called-ios-8-share-sheet
            if activityVC.respondsToSelector("popoverPresentationController") {
                let presentationController = activityVC.popoverPresentationController
                presentationController?.sourceView = self.view
            }
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }

    // MARK: - Favourite Requests & helpers
    
    func initializeFavoriteButtonAnimations() {
        // save link animations
        let animatingImages = [UIImage(named: "navbar_fav_on")!.imageWithRenderingMode(.AlwaysOriginal), UIImage(named: "navbar_fav_off")!.imageWithRenderingMode(.AlwaysOriginal)]
        self.favoriteButton.imageView!.animationImages = animatingImages
        self.favoriteButton.imageView!.animationDuration = 0.50
        self.favoriteButton.imageView!.animationRepeatCount = 0
        
    }
    
    func markOrUnmarkAsFavorite() {
        self.favoriteButton.userInteractionEnabled = false
        
        // UI update for quick user feedback + Request
        self.favoriteButton.imageView!.startAnimating()
        
        if self.isFavourite {
            deleteFavouriteProductForUser(MyUserManager.sharedInstance.myUser(),
                product: product,
                completion: { (success) -> Void in
                    self.favoriteButton.userInteractionEnabled = true
                    self.isFavourite = !success
                    self.favoriteButton.imageView!.stopAnimating()
                    self.favoriteButton.setImage(self.isFavourite ? UIImage(named: "navbar_fav_on")!.imageWithRenderingMode(.AlwaysOriginal) : UIImage(named: "navbar_fav_off")!.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
            })
        }
        else {
            saveFavouriteProductForUser(MyUserManager.sharedInstance.myUser(),
                product: product,
                completion: { (success) -> Void in
                    self.favoriteButton.userInteractionEnabled = true
                    self.isFavourite = success
                    self.favoriteButton.imageView!.stopAnimating()
                    self.favoriteButton.setImage(self.isFavourite ? UIImage(named: "navbar_fav_on")!.imageWithRenderingMode(.AlwaysOriginal) : UIImage(named: "navbar_fav_off")!.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
            })
        }
    }
    
    func checkFavoriteProduct() {
        self.favoriteButton.userInteractionEnabled = false
        retrieveFavouriteProductForUser(
            MyUserManager.sharedInstance.myUser(),
            product: product,
            completion: { (success, favProduct) -> Void in
                self.favoriteButton.userInteractionEnabled = true
                
                if success {
                    self.isFavourite = favProduct != nil
                }
                self.favoriteButton.setImage(self.isFavourite ? UIImage(named: "navbar_fav_on")!.imageWithRenderingMode(.AlwaysOriginal) : UIImage(named: "navbar_fav_off")!.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
            })
    }
    
    func retrieveFavouriteProductForUser(user: User?, product: Product?, completion: (Bool, PFObject?) -> (Void)) {
        if let actualUser = user as? PFUser {
            if let actualProduct = product {
                let favQuery = PFQuery(className: "UserFavoriteProducts")
                favQuery.whereKey("user", equalTo: actualUser)
                favQuery.whereKey("product", equalTo: PFObject(withoutDataWithClassName:PAProduct.parseClassName(), objectId:actualProduct.objectId))
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
    
    func saveFavouriteProductForUser(user: User?, product: Product?, completion: (Bool) -> (Void)) {
        if let favProduct = newFavProductForUser(user, product: product) {
            favProduct.saveInBackgroundWithBlock({ (success, error) -> Void in
                completion(success)
            })
        }
        else {
            completion(false)
        }
    }
    
    func deleteFavouriteProductForUser(user: User?, product: Product?, completion: (Bool) -> (Void)) {
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
    
    func newFavProductForUser(user: User?, product: Product?) -> PFObject? {
        if let actualUser = user as? PFUser {
            if let actualProduct = product {
                let favProduct = PFObject(className: "UserFavoriteProducts")
                favProduct["user"] = actualUser
                favProduct["product"] = PFObject(withoutDataWithClassName:PAProduct.parseClassName(), objectId:actualProduct.objectId)
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
        var offset: CGFloat = 0
        var pageNumber = 0
        
        // add the images
        for imageURL in product.imageURLs {
            galleryView.addPageWithImageAtURL(imageURL)
        }
        galleryView.delegate = self
    }
    
    // MARK: - GalleryViewDelegate
    
    func galleryView(galleryView: GalleryView, didPressPageAtIndex index: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("PhotosInDetailViewController") as! PhotosInDetailViewController
        vc.imageURLs = product.imageURLs
        vc.initialImageToShow = index
        vc.productName = nameLabel.text!
        self.navigationController?.pushViewController(vc, animated: true)
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
    
    @IBAction func showProductUser(sender: AnyObject) {
        var shouldPushUserVC = true
        
        // If we're the ones selling the product do not allow to push the view to avoid circular navigation
        if let myUser = MyUserManager.sharedInstance.myUser() {
            if myUser.objectId == product.user?.objectId {
                shouldPushUserVC = false
            }
        }
        
        if let myUser = MyUserManager.sharedInstance.myUser(), let productUser = product.user {
            
            // If i'm not the seller
            if myUser.objectId != productUser.objectId {
                let vc = EditProfileViewController(user: productUser)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
