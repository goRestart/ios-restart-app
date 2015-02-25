//
//  ShowProductViewController.swift
//  Ambatana
//
//  Created by Nacho on 11/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit
import MapKit
import MessageUI
import Social

protocol ShowProductViewControllerDelegate {
    func ambatanaProduct(product: PFObject, statusUpdatedTo newStatus: ProductStatus)
}

/**
 * This ViewController is in charge of showing a single product selected from the ProductList view controller. Depending on the ownership of the product, the user would be allowed
 * to modify the object if he/she owns it, or make offers/chat with the owner.
 */
class ShowProductViewController: UIViewController, UIScrollViewDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate, UIDocumentInteractionControllerDelegate, MFMailComposeViewControllerDelegate {
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
    @IBOutlet weak var shareThisLabel: UILabel!
    @IBOutlet weak var shareFacebookButton: UIButton!
    @IBOutlet weak var shareWhatsappButton: UIButton!
    @IBOutlet weak var shareMailButton: UIButton!
    @IBOutlet weak var shareMoreButton: UIButton!
    @IBOutlet weak var markSoldButton: UIButton!
    @IBOutlet weak var imagesPageControl: UIPageControl!
    @IBOutlet weak var markAsSoldActivityIndicator: UIActivityIndicatorView!
    
    // data
    var productObject: PFObject!
    var productImages: [UIImage] = []
    var productImageURLStrings: [String] = []
    var productUser: PFUser!
    var productStatus: ProductStatus?
    var scrollViewOffset: CGFloat = 0.0
    var pageControlBeingUsed = false
    var delegate: ShowProductViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // UX/UI
        self.markAsSoldActivityIndicator.hidden = true
        self.imagesPageControl.numberOfPages = 0
        self.userAvatarImageView.layer.cornerRadius = self.userAvatarImageView.frame.size.width / 2.0
        self.userAvatarImageView.clipsToBounds = true
        
        // initialize product UI.
        if productObject != nil {
            // check if this is our product
            productUser = productObject["user"] as PFUser
            let thisProductIsMine = productUser.objectId == PFUser.currentUser().objectId
            self.askQuestionButton.hidden = thisProductIsMine
            self.makeOfferButton.hidden = thisProductIsMine
            self.markSoldButton.hidden = !thisProductIsMine
            // if product is sold, disable markAsSold button.
            if let statusCode = productObject["status"] as? Int {
                productStatus = ProductStatus(rawValue: statusCode)
                if productStatus == .Sold {
                    markSoldButton.enabled = false
                    //self.markSoldButton.setTitle(translate("marked_as_sold"), forState: .Normal)
                    self.markSoldButton.hidden = true
                } else {
                    markSoldButton.setTitle(translate("mark_as_sold"), forState: .Normal)
                }
            }

            // load owner user information
            let userQuery = PFUser.query()
            userQuery.whereKey("objectId", equalTo: productUser.objectId)
            userQuery.getFirstObjectInBackgroundWithBlock({ (retrievedUser, error) -> Void in
                // user name
                if error == nil {
                    let usernamePublic = retrievedUser["username_public"] as? String ?? translate("unknown")
                    self.usernameLabel.text = translate("by") + " " + usernamePublic
                    if let avatarFile = retrievedUser["avatar"] as? PFFile {
                        avatarFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                            if data != nil {
                                self.userAvatarImageView.setImage(UIImage(data: data), forState: .Normal)
                            } else { self.userAvatarImageView.setImage(UIImage(named: "no_photo"), forState: .Normal) }
                        })
                    } else { self.userAvatarImageView.setImage(UIImage(named: "no_photo"), forState: .Normal) }
                } else {
                    println("Error retrieving user object: \(error.localizedDescription)")
                    self.usernameLabel.hidden = true
                    self.userAvatarImageView.hidden = true
                }
            })
            
            // fill fields
            
            // images first (as they need to be downloaded).
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                var retrievedImages: [UIImage] = []
                var retrievedImageURLS: [String] = []
                // iterate and retrieve all images.
                for imageKey in kAmbatanaProductImageKeys {
                    if let imageFile = self.productObject[imageKey] as? PFFile {
                        if let data = imageFile.getData(nil) {
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
            })
            
            // product name
            nameLabel.text = productObject["name"] as? String ?? ""
            self.setAmbatanaNavigationBarStyle(title: nameLabel.text, includeBackArrow: true)
            
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
                descriptionLabel.text = description
                descriptionLabel.hidden = false
            } else { descriptionLabel.hidden = true }
            
            // product published date.
            if productObject.createdAt != nil {
                publishedTimeLabel.text = translate("published") + " " + productObject.createdAt.relativeTimeToString().lowercaseString
                publishedTimeLabel.hidden = false
            } else { publishedTimeLabel.hidden = true }
            
            // location in map
            if let location = productObject["gpscoords"] as? PFGeoPoint {
                // set map region
                let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                let region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
                itemLocationMapView.setRegion(region, animated: true)
                // add pin
                itemLocationMapView.setPinInTheMapAtCoordinate(coordinate)

            }
            
        } else { // hide all buttons
            self.markSoldButton.hidden = true
            self.askQuestionButton.hidden = true
            self.makeOfferButton.hidden = true
        }
        
        // internationalization
        makeOfferButton.setTitle(translate("make_an_offer"), forState: .Normal)
        askQuestionButton.setTitle(translate("ask_a_question"), forState: .Normal)
        shareThisLabel.text = translate("share_this_item")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button actions
    @IBAction func askQuestion(sender: AnyObject) {
    }
    
    @IBAction func makeOffer(sender: AnyObject) {
        self.performSegueWithIdentifier("MakeAnOffer", sender: sender)
    }
    
    @IBAction func markProductAsSold(sender: AnyObject) {
        let alert = UIAlertController(title: translate("mark_as_sold"), message: translate("are_you_sure_mark_sold"), preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: translate("mark_as_sold"), style: .Default, handler: { (markAction) -> Void in
            self.enableMarkAsSoldLoadingInterface()
            self.productObject["status"] = ProductStatus.Sold.rawValue
            self.productObject.saveInBackgroundWithBlock({ (success, error) -> Void in
                if success {
                    self.productStatus = .Sold
                    // animated hiding of the button, restore alpha once hidden.
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.markSoldButton.alpha = 0.0
                    }, completion: { (success) -> Void in
                        self.markSoldButton.hidden = true
                        self.markSoldButton.alpha = 1.0
                    })
                    //self.markSoldButton.setTitle(translate("marked_as_sold"), forState: .Normal)
                    //self.markSoldButton.enabled = false
                    self.delegate?.ambatanaProduct(self.productObject, statusUpdatedTo: self.productStatus!)
                } else {
                    self.markSoldButton.enabled = true
                    self.showAutoFadingOutMessageAlert("error_marking_as_sold")
                }
                self.disableMarkAsSoldLoadingInterface()
            })
        }))
        alert.addAction(UIAlertAction(title: translate("cancel"), style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
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
    
    // MARK: - Sharing buttons and sharing actions.
        
    @IBAction func shareFacebook(sender: AnyObject) {
        // first we need to check that the current FBSession is valid.
        if FBSession.activeSession().state != FBSessionState.Open {
            if FBSession.openActiveSessionWithAllowLoginUI(false) {
                shareCurrentProductInFacebook()
            } else { showAutoFadingOutMessageAlert(translate("error_sharing_facebook")) }
        } else { shareCurrentProductInFacebook() }
    }
    
    func shareCurrentProductInFacebook() {
        let fbSharingParams = FBLinkShareParams()
        fbSharingParams.link = NSURL(string: ambatanaWebLinkForObjectId(productObject.objectId))!
        fbSharingParams.linkDescription = productObject["name"] as? String ?? translate("ambatana_product")
        if productImageURLStrings.count > 0 { fbSharingParams.picture = NSURL(string: productImageURLStrings.first!) }
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
            if let productName = productObject["name"] as? String { shareParamsForBrowserFallback["name"] = productName }
            shareParamsForBrowserFallback["caption"] = translate("have_a_look")
            shareParamsForBrowserFallback["description"] = translate("have_a_look")
            if productImageURLStrings.count > 0 { shareParamsForBrowserFallback["picture"] = productImageURLStrings.first }
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
    
    @IBAction func shareWhatsapp(sender: AnyObject) {
        let sharingMessage = translate("have_a_look") + ambatanaWebLinkForObjectId(productObject.objectId)
        let encodedSharingMessage = "whatsapp://send?text=" + sharingMessage.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        if let whatsAppURL = NSURL(string: encodedSharingMessage) {
            if UIApplication.sharedApplication().canOpenURL(whatsAppURL) {
                UIApplication.sharedApplication().openURL(whatsAppURL)
            } else { self.showAutoFadingOutMessageAlert(translate("whatsapp_not_configured")) }
        } else { showAutoFadingOutMessageAlert(translate("error_sharing_whatsapp")) }

    }
    
    @IBAction func shareMail(sender: AnyObject) {
        // build and show a mail controller
        let mailComposerController: MFMailComposeViewController! = MFMailComposeViewController()
        
        mailComposerController.mailComposeDelegate = self
        mailComposerController.setSubject(translate("have_a_look"))
        
        let mailBody = ambatanaTextForSharingBody(productObject?["name"] as? String ?? "", andObjectId: productObject!.objectId)
        mailComposerController.setMessageBody(mailBody, isHTML: false)
        
        self.presentViewController(mailComposerController, animated: true, completion: nil)
    }
    
    @IBAction func shareMore(sender: AnyObject) {
        // build items to share
        var itemsToShare: [AnyObject] = []
        
        // text
        let textToShare = ambatanaTextForSharingBody(productObject?["name"] as? String ?? "", andObjectId: productObject!.objectId)
        itemsToShare.append(textToShare)
        // image
        if productImages.count > 0 {
            let firstImage = productImages.first!
            itemsToShare.append(firstImage)
        }
        // url
        itemsToShare.append(ambatanaWebLinkForObjectId(productObject!.objectId))
        
        // show activity view controller.
        let activityVC = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeSaveToCameraRoll] // we don't want those to show in the sharing dialog.
        activityVC.setValue(translate("have_a_look"), forKey: "subject") // for email.

        // hack for eluding the iOS8 "LaunchServices: invalidationHandler called" bug from Apple.
        if activityVC.respondsToSelector("popoverPresentationController") {
            let presentationController = activityVC.popoverPresentationController
            presentationController?.sourceView = sender as? UIButton ?? self.view
        }
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    // MARK: - Mail Composer Delegate methods
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        var message = NSLocalizedString("ok", comment: "")
        if result.value == MFMailComposeResultCancelled.value { message = NSLocalizedString("mailcancelled", comment: "") }
        else if result.value == MFMailComposeResultSaved.value { message = NSLocalizedString("mailsaved", comment: "") }
        else if result.value == MFMailComposeResultSent.value { message = NSLocalizedString("thanksforcontact", comment: "") }
        else if result.value == MFMailComposeResultFailed.value { message = NSLocalizedString("errorsendingmail", comment: "") }
        
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.showAutoFadingOutMessageAlert(message)
        })
    }
    
    // MARK: - Images, pagination and scrollview.
    
    func setProductMainImages() {
        if self.productImages.count > 0 {
            self.imagesScrollView.alpha = 0
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
        var productPin = mapView.dequeueReusableAnnotationViewWithIdentifier("com.ambatana.productpin")
        if productPin == nil {
            productPin = MKAnnotationView(annotation: annotation, reuseIdentifier: "com.ambatana.productpin")
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
            
        }
    }
    
    @IBAction func showProductUser(sender: AnyObject) {
        self.performSegueWithIdentifier("ShowProductUser", sender: sender)
    }
    
}

















