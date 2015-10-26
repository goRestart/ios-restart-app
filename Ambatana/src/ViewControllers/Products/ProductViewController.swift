//
//  ProductViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 12/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import FBSDKShareKit
import LGCoreKit
import MapKit
import MessageUI
import Result
import SDWebImage
import UIKit

public class ProductViewController: BaseViewController, FBSDKSharingDelegate, GalleryViewDelegate, MFMailComposeViewControllerDelegate, ProductViewModelDelegate {

    // Constants
    private static let addressIconVisibleHeight: CGFloat = 16
    private static let footerViewVisibleHeight: CGFloat = 64
    
    // UI
    // > Navigation Bar
    private var favoriteButton: UIButton?
    
    // > Main
    @IBOutlet weak var galleryView: GalleryView!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var usernameContainerView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var addressIconHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    // Rounded views can't have shadow the standard way, so there's an extra view:
    // http://stackoverflow.com/questions/3690972/why-maskstobounds-yes-prevents-calayer-shadow
    @IBOutlet weak var productStatusLabel: UILabel!
    @IBOutlet weak var productStatusShadow: UIView!     // just for the shadow
    
    // > Bottom
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!

    // > Footer
    @IBOutlet weak var footerViewHeightConstraint: NSLayoutConstraint!
    
    // >> Other selling
    @IBOutlet weak var otherSellingView: UIView!
    @IBOutlet weak var askButton: UIButton!
    @IBOutlet weak var offerButton: UIButton!
    
    // >> Me selling
    @IBOutlet weak var meSellingView: UIView!
    @IBOutlet weak var markSoldButton: UIButton!
    
    // > Other
    private var lines : [CALayer]
    
    // ViewModel
    private var viewModel : ProductViewModel!
    
    // MARK: - Lifecycle
    
    public init(viewModel: ProductViewModel) {
        self.viewModel = viewModel
        self.lines = []
        super.init(viewModel: viewModel, nibName: "ProductViewController")
        
        self.viewModel.delegate = self
        
        automaticallyAdjustsScrollViewInsets = false
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Redraw the lines
        for line in lines {
            line.removeFromSuperlayer()
        }
        lines = []
        lines.append(bottomView.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
    }
    
    // MARK: - Public methods
    
    // MARK: > Actions
    
    @IBAction func userButtonPressed(sender: AnyObject) {
        openProductUserProfile()
    }
    
    @IBAction func mapViewButtonPressed(sender: AnyObject) {
        openMap()
    }
    
    @IBAction func shareFBButtonPressed(sender: AnyObject) {
        viewModel.shareInFacebook("bottom")
        let content = viewModel.shareFacebookContent
        FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: self)
    }
    
    @IBAction func shareEmailButtonPressed(sender: AnyObject) {
        let isEmailAccountConfigured = MFMailComposeViewController.canSendMail()
        if isEmailAccountConfigured {
            let vc = MFMailComposeViewController()
            vc.mailComposeDelegate = self
            vc.setSubject(viewModel.shareEmailSubject)
            vc.setMessageBody(viewModel.shareEmailBody, isHTML: false)
            presentViewController(vc, animated: true, completion: nil)
            viewModel.shareInEmail("bottom")
        }
        else {
            showAutoFadingOutMessageAlert(LGLocalizedString.productShareEmailError)
        }
    }
    
    @IBAction func shareWhatsAppButtonPressed(sender: AnyObject) {
        let isWhatsAppInstalled = viewModel.shareInWhatsApp()
        if !isWhatsAppInstalled {
            showAutoFadingOutMessageAlert(LGLocalizedString.productShareWhatsappError)
        }
    }
    
    @IBAction func reportButtonPressed(sender: AnyObject) {
        ifLoggedInThen(.ReportFraud, loggedInAction: {
            self.showReportAlert()
        },
        elsePresentSignUpWithSuccessAction: {
            self.updateUI()
            self.showReportAlert()
        })
    }
    
    @IBAction func deleteButtonPressed(sender: AnyObject) {
        ifLoggedInThen(.Delete, loggedInAction: {
            self.showDeleteAlert()
        },
        elsePresentSignUpWithSuccessAction: {
            self.updateUI()
            self.showDeleteAlert()
        })
    }
    
    @IBAction func askButtonPressed(sender: AnyObject) {
        ifLoggedInThen(.AskQuestion, loggedInAction: {
            self.ask()
        },
        elsePresentSignUpWithSuccessAction: {
            self.updateUI()
            self.ask()
        })
    }
    
    @IBAction func offerButtonPressed(sender: AnyObject) {
        ifLoggedInThen(.MakeOffer, loggedInAction: {
            self.offer()
        },
        elsePresentSignUpWithSuccessAction: {
            self.updateUI()
            self.offer()
        })
    }
    
    @IBAction func markSoldPressed(sender: AnyObject) {
        ifLoggedInThen(.MarkAsSold, loggedInAction: {
            self.showMarkSoldAlert()
        },
        elsePresentSignUpWithSuccessAction: {
            self.updateUI()
            self.showMarkSoldAlert()
        })
    }
    
    // MARK: - FBSDKSharingDelegate
    
    public func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        viewModel.shareInFBCompleted()
        showAutoFadingOutMessageAlert(LGLocalizedString.sellSendSharingFacebookOk)  // TODO: Create a string for this screen
    }
    
    public func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        showAutoFadingOutMessageAlert(LGLocalizedString.sellSendSharingFacebookOk)  // TODO: Create a string for this screen
    }
    
    public func sharerDidCancel(sharer: FBSDKSharing!) {
        viewModel.shareInFBCancelled()
    }
    
    // MARK: - GalleryViewDelegate
    
    public func galleryView(galleryView: GalleryView, didPressPageAtIndex index: Int) {
        // TODO: Refactor into GalleryViewController with proper MVVM
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("PhotosInDetailViewController") as! PhotosInDetailViewController
        
        // add the images
        var imageURLs : [NSURL] = []
        for i in 0..<viewModel.numberOfImages {
            if let imageURL = viewModel.imageURLAtIndex(i) {
                imageURLs.append(imageURL)
            }
        }
        vc.imageURLs = imageURLs
        vc.initialImageToShow = index
        vc.productName = viewModel.name
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    
    public func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        var message: String? = nil
        if result.rawValue == MFMailComposeResultFailed.rawValue { // we just give feedback if something nasty happened.
            message = LGLocalizedString.productShareEmailError
        }
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            if message != nil { self.showAutoFadingOutMessageAlert(message!) }
        })
    }
    
    // MARK: - ProductViewModelDelegate
    
    public func viewModelDidUpdate(viewModel: ProductViewModel) {
        updateUI()
    }
    
    public func viewModelDidStartSwitchingFavouriting(viewModel: ProductViewModel) {
        favoriteButton?.userInteractionEnabled = false
    }
    
    public func viewModelDidUpdateIsFavourite(viewModel: ProductViewModel) {
        favoriteButton?.userInteractionEnabled = true
        setFavouriteButtonAsFavourited(viewModel.isFavourite)
    }
    
    public func viewModelForbiddenAccessToFavourite(viewModel: ProductViewModel) {
        showAutoFadingOutMessageAlert(LGLocalizedString.logInErrorSendErrorGeneric, completionBlock: { (completion) -> Void in
            MyUserManager.sharedInstance.logout(nil)
        })
    }
    
    public func viewModelDidStartRetrievingUserProductRelation(viewModel: ProductViewModel) {
        favoriteButton?.userInteractionEnabled = false
        reportButton.enabled = false
    }

    public func viewModelDidStartReporting(viewModel: ProductViewModel) {
        reportButton.enabled = false
        reportButton.setTitle(LGLocalizedString.productReportingProductLabel, forState: .Normal)
        showLoadingMessageAlert(LGLocalizedString.productReportingLoadingMessage)
    }
    
    public func viewModelDidUpdateIsReported(viewModel: ProductViewModel) {
        setReportButtonAsReported(viewModel.isReported)
    }
    
    public func viewModelDidCompleteReporting(viewModel: ProductViewModel) {
        
        let completion = {
            self.showAutoFadingOutMessageAlert(LGLocalizedString.productReportedSuccessMessage, time: 3)
        }
        
        dismissLoadingMessageAlert(completion)
    }
    
    public func viewModelDidFailReporting(viewModel: ProductViewModel, error: ProductReportSaveServiceError) {

        var completion: () -> Void
        
        if error == .Forbidden {
            completion = {
                self.showAutoFadingOutMessageAlert(LGLocalizedString.logInErrorSendErrorGeneric, completionBlock: { (completion) -> Void in
                    MyUserManager.sharedInstance.logout(nil)
                })
            }
        }
        else {
            completion = {
                self.reportButton.enabled = true
                self.showAutoFadingOutMessageAlert(LGLocalizedString.productReportedErrorGeneric, time: 3)
            }
        }
        
        dismissLoadingMessageAlert(completion)
        setReportButtonAsReported(viewModel.isReported)
    }

    
    public func viewModelDidStartDeleting(viewModel: ProductViewModel) {
        showLoadingMessageAlert()
    }
    
    public func viewModel(viewModel: ProductViewModel, didFinishDeleting result: ProductDeleteServiceResult) {
        let completion: () -> Void
        if let _ = result.value {
            completion = {
                self.showAutoFadingOutMessageAlert(LGLocalizedString.productDeleteSuccessMessage, time: 3) {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        }
        else {
            completion = {
                self.showAutoFadingOutMessageAlert(LGLocalizedString.productDeleteSendErrorGeneric)
            }
        }
        dismissLoadingMessageAlert(completion)
    }
    
    public func viewModelDidStartMarkingAsSold(viewModel: ProductViewModel) {
        showLoadingMessageAlert()
    }
    
    public func viewModel(viewModel: ProductViewModel, didFinishMarkingAsSold result: ProductMarkSoldServiceResult) {
        let completion: (() -> Void)?
        if let _ = result.value {
            
            completion = {
                self.showAutoFadingOutMessageAlert(LGLocalizedString.productMarkAsSoldSuccessMessage, time: 3) {

                    if let tabBarCtrl = self.tabBarController as? TabBarController {
                        tabBarCtrl.showAppRatingViewIfNeeded()
                    }
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
            updateUI()
        }
        else {
            completion = {
                self.showAutoFadingOutMessageAlert(LGLocalizedString.productMarkAsSoldErrorGeneric)
            }
        }
        dismissLoadingMessageAlert(completion)
    }
    
    public func viewModelDidStartAsking(viewModel: ProductViewModel) {
        showLoadingMessageAlert()
    }

    public func viewModel(viewModel: ProductViewModel, didFinishAsking result: Result<UIViewController, ChatRetrieveServiceError>) {
        var completion: (() -> Void)?
        if let viewController = result.value {
            completion = {
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
        else {
            completion = {
                self.showAutoFadingOutMessageAlert(LGLocalizedString.productChatErrorGeneric)
            }
            if let actualError = result.error {
                if actualError == .Forbidden {
                    completion = {
                        self.showAutoFadingOutMessageAlert(LGLocalizedString.logInErrorSendErrorGeneric, completionBlock: { (completion) -> Void in
                            MyUserManager.sharedInstance.logout(nil)
                        })
                    }
                }
            }
        }
        dismissLoadingMessageAlert(completion)
    }
    
    // MARK: - Private methods
    
    // MARK: > UI
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        view.layoutIfNeeded()
        productStatusLabel.sizeToFit()
        
        var originX = 0.0
        if productStatusLabel.frame.size.width >= 60 {
            originX = -20.0
        } else {
            originX = -20.0 + Double((productStatusLabel.frame.size.width - 60)/2)
        }
        
        productStatusLabel.preferredMaxLayoutWidth = max(60, productStatusLabel.frame.size.width) + 40 // min width = 100
        
        let size = CGSize(width: productStatusLabel.preferredMaxLayoutWidth, height: 36)

        productStatusLabel.frame = CGRect(origin: CGPoint(x: originX, y: 0.0), size: size)
        view.layoutIfNeeded()
    }
    
    private func setupUI() {
        // Setup
        // > Navigation Bar
        setLetGoNavigationBarStyle("")
        setFavouriteButtonAsFavourited(false)
        
        // > Main
        usernameContainerView.layer.cornerRadius = 2
        
        productStatusLabel.layer.cornerRadius = 18
        productStatusLabel.layer.masksToBounds = true
        
        productStatusShadow.layer.shadowColor = UIColor.blackColor().CGColor
        productStatusShadow.layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
        productStatusShadow.layer.shadowOpacity = 0.24
        productStatusShadow.layer.shadowRadius = 8.0

        userAvatarImageView.layer.cornerRadius = CGRectGetWidth(userAvatarImageView.frame) / 2
        userAvatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
        userAvatarImageView.layer.borderWidth = 2

        reportButton.titleLabel?.numberOfLines = 2
        reportButton.titleLabel?.lineBreakMode = .ByWordWrapping
        deleteButton.titleLabel?.numberOfLines = 2
        deleteButton.titleLabel?.lineBreakMode = .ByWordWrapping
        
        setReportButtonAsReported(false)
        
        askButton.layer.cornerRadius = 4
        askButton.layer.borderColor = askButton.titleColorForState(.Normal)?.CGColor
        askButton.layer.borderWidth = 2
        askButton.setBackgroundImage(askButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        
        offerButton.layer.cornerRadius = 4
        offerButton.setBackgroundImage(offerButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        
        markSoldButton.layer.cornerRadius = 4
        markSoldButton.layer.borderColor = markSoldButton.titleColorForState(.Normal)?.CGColor
        markSoldButton.layer.borderWidth = 2
        markSoldButton.setBackgroundImage(markSoldButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        
        // i18n
        reportButton.setTitle(LGLocalizedString.productReportProductButton, forState: .Normal)
        deleteButton.setTitle(LGLocalizedString.productDeleteConfirmTitle, forState: .Normal)
        
        askButton.setTitle(LGLocalizedString.productAskAQuestionButton, forState: .Normal)
        offerButton.setTitle(LGLocalizedString.productMakeAnOfferButton, forState: .Normal)
        markSoldButton.setTitle(LGLocalizedString.productMarkAsSoldButton, forState: .Normal)
        
        // Delegates
        galleryView.delegate = self
        
        // Update the UI
        updateUI()
    }
    
    private func updateUI() {
        // Navigation bar
        // > If editing, place a text button
        if viewModel.isEditable {
            let editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: Selector("editButtonPressed"))
            let rightMargin = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
            rightMargin.width = 6
            let items = [rightMargin, editButton]
            navigationItem.setRightBarButtonItems(items, animated: false)
        }
        // Else, it will be image buttons
        else {
            var imageNames: [String] = []
            var selectors: [String] = []
            var tags: [Int] = []
            let favTag = 0
            var currentTag = favTag
            
            if viewModel.isFavouritable {
                imageNames.append("navbar_fav_off")
                selectors.append("favouriteButtonPressed")
                tags.append(currentTag)
                currentTag++
            }
            if viewModel.isShareable {
                imageNames.append("navbar_share")
                selectors.append("shareButtonPressed")
                tags.append(currentTag)
                currentTag++
            }
            
            let buttons = setLetGoRightButtonsWithImageNames(imageNames, andSelectors: selectors, withTags: tags)
            for button in buttons {
                if button.tag == favTag {
                    favoriteButton = button
                }
            }
        }
       
        // Product Status Label
        productStatusLabel.hidden = !viewModel.isProductStatusLabelVisible
        productStatusLabel.backgroundColor = viewModel.productStatusLabelBackgroundColor
        productStatusLabel.textColor = viewModel.productStatusLabelFontColor
        productStatusLabel.text = viewModel.productStatusLabelText
        
        // Gallery
        galleryView.removePages()
        for i in 0..<viewModel.numberOfImages {
            if let imageURL = viewModel.imageURLAtIndex(i) {
                if i == 0 {
                    if let thumbnailURL = viewModel.thumbnailURL {
                        galleryView.addPageWithImageAtURL(imageURL, previewURL: thumbnailURL)
                    }
                    else {
                        galleryView.addPageWithImageAtURL(imageURL, previewURL: nil)
                    }
                    
                }
                else {
                    galleryView.addPageWithImageAtURL(imageURL, previewURL: nil)
                }
            }
        }
        
        // Main
        if let userAvatarURL = viewModel.userAvatar {
            userAvatarImageView.sd_setImageWithURL(userAvatarURL, placeholderImage: UIImage(named: "no_photo"))
        }
        usernameLabel.text = viewModel.userName
        
        nameLabel.text = viewModel.name
        priceLabel.text = viewModel.price
        descriptionLabel.text = viewModel.descr
        addressIconHeightConstraint.constant = viewModel.addressIconVisible ? ProductViewController.addressIconVisibleHeight : 0
        addressLabel.text = viewModel.address
        if let location = viewModel.location {
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
            mapView.setRegion(region, animated: true)
        }
        
        // Bottom
        reportButton.hidden = !viewModel.isReportable
        deleteButton.hidden = !viewModel.isDeletable
        
        // Footer
        footerViewHeightConstraint.constant = viewModel.isFooterVisible ? ProductViewController.footerViewVisibleHeight : 0
        
        // Footer other / me selling subviews
        otherSellingView.hidden = viewModel.isMine
        meSellingView.hidden = !viewModel.isMine
    }
    
    private func setFavouriteButtonAsFavourited(favourited: Bool) {
        let imageName = favourited ? "navbar_fav_on" : "navbar_fav_off"
        let image = UIImage(named: imageName)!.imageWithRenderingMode(.AlwaysOriginal)
        favoriteButton?.setImage(image, forState: .Normal)
    }
    
    private func setReportButtonAsReported(reported: Bool) {
        let reportButtonTitle: String
        let reportButtonEnabled: Bool
        
        if reported {
            reportButtonTitle = LGLocalizedString.productReportedProductLabel
            reportButtonEnabled = false
            
        }
        else {
            reportButtonTitle = LGLocalizedString.productReportProductButton
            reportButtonEnabled = true
        }
        reportButton.setTitle(reportButtonTitle, forState: .Normal)
        reportButton.enabled = reportButtonEnabled
    }
    
    // MARK: > Actions
    
    dynamic private func favouriteButtonPressed() {
        ifLoggedInThen(.Favourite, loggedInAction: {
            // Switch graphically
            if self.viewModel.isFavourite {
                self.setFavouriteButtonAsFavourited(false)
            }
            else {
                self.setFavouriteButtonAsFavourited(true)
            }
            
            // Tell the VM
            self.viewModel.switchFavourite()
        },
        elsePresentSignUpWithSuccessAction: {
            // Update UI
            self.updateUI()
            
            // Switch graphically
            if self.viewModel.isFavourite {
                self.setFavouriteButtonAsFavourited(false)
            }
            else {
                self.setFavouriteButtonAsFavourited(true)
            }
            
            // Tell the VM
            self.viewModel.switchFavourite()
        })
    }
    
    dynamic private func shareButtonPressed() {
        let activityItems: [AnyObject] = [viewModel.shareText]
        let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        // hack for eluding the iOS8 "LaunchServices: invalidationHandler called" bug from Apple.
        // src: http://stackoverflow.com/questions/25759380/launchservices-invalidationhandler-called-ios-8-share-sheet
        if vc.respondsToSelector("popoverPresentationController") {
            let presentationController = vc.popoverPresentationController
            presentationController?.sourceView = self.view
        }

        vc.completionWithItemsHandler = {
            (activity, success, items, error) in

            // TODO: comment left here as a clue to manage future activities
            /*   SAMPLES OF SHARING RESULTS VIA ACTIVITY VC
            
            println("Activity: \(activity) Success: \(success) Items: \(items) Error: \(error)")
            
            Activity: com.apple.UIKit.activity.PostToFacebook Success: true Items: nil Error: nil
            Activity: net.whatsapp.WhatsApp.ShareExtension Success: true Items: nil Error: nil
            Activity: com.apple.UIKit.activity.Mail Success: true Items: nil Error: nil
            Activity: com.apple.UIKit.activity.PostToTwitter Success: true Items: nil Error: nil
            */

            if success {
                if activity == UIActivityTypePostToFacebook {
                    self.viewModel.shareInFacebook("top")
                    self.viewModel.shareInFBCompleted()
                } else if activity == UIActivityTypePostToTwitter {
                    self.viewModel.shareInTwitterActivity()
                } else if activity == UIActivityTypeMail {
                    self.viewModel.shareInEmail("top")
                } else if activity != nil && activity!.rangeOfString("whatsapp") != nil {
                    self.viewModel.shareInWhatsappActivity()
                }
            }
        }

        presentViewController(vc, animated: true, completion: nil)
    }
    
    // MARK: > Actions w navigation
    
    // TODO: Refactor to retrieve a viewModel and build an VC
    dynamic private func editButtonPressed() {
        let vc = viewModel.editViewModelWithDelegate
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // TODO: Refactor to retrieve a viewModel and build an VC
    private func openProductUserProfile() {
        if let vc = viewModel.productUserProfileViewModel {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // TODO: Refactor to retrieve a viewModel and build an VC, when MakeAnOfferVC is switched to MVVM
    private func openMap() {
        if let vc = viewModel.productLocationViewModel {
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    private func ask() {
        viewModel.ask()
    }
    
    // TODO: Refactor to retrieve a viewModel and build an VC, when MakeAnOfferVC is switched to MVVM
    private func offer() {
        let vc = viewModel.offerViewModel
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: > Actions w dialogs
    
    private func showReportAlert() {
        let alert = UIAlertController(title: LGLocalizedString.productReportConfirmTitle, message: LGLocalizedString.productReportConfirmMessage, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: LGLocalizedString.commonNo, style: .Cancel, handler: { (_) -> Void in
            self.viewModel.reportAbandon()
        })
        let reportAction = UIAlertAction(title: LGLocalizedString.commonYes, style: .Default, handler: { (_) -> Void in
            self.viewModel.report()
        })
        alert.addAction(cancelAction)
        alert.addAction(reportAction)
        
        presentViewController(alert, animated: true, completion: {
            self.viewModel.reportStarted()
        })
    }
    
    private func showDeleteAlert() {
        let alert = UIAlertController(title: LGLocalizedString.productDeleteConfirmTitle, message: LGLocalizedString.productDeleteSoldConfirmMessage, preferredStyle: .Alert)
        
        if viewModel.shouldSuggestMarkSoldWhenDeleting {
            
            alert.message = LGLocalizedString.productDeleteConfirmMessage
            let cancelAction = UIAlertAction(title: LGLocalizedString.productDeleteConfirmCancelButton, style: .Cancel, handler: { (_) -> Void in
                self.viewModel.deleteAbandon()
            })
            let soldAction = UIAlertAction(title: LGLocalizedString.productDeleteConfirmSoldButton, style: .Default, handler: { (_) -> Void in
                self.viewModel.markSold(.Delete)
            })
            let deleteAction = UIAlertAction(title: LGLocalizedString.productDeleteConfirmOkButton, style: .Default, handler: { (_) -> Void in
                self.viewModel.delete()
            })
            alert.addAction(cancelAction)
            alert.addAction(soldAction)
            alert.addAction(deleteAction)
        }
        else {
            
            alert.message = LGLocalizedString.productDeleteSoldConfirmMessage

            let cancelAction = UIAlertAction(title: LGLocalizedString.productDeleteConfirmCancelButton, style: .Cancel, handler: { (markAction) -> Void in
                self.viewModel.deleteAbandon()
            })
            let deleteAction = UIAlertAction(title: LGLocalizedString.commonOk, style: .Default, handler: { (_) -> Void in
                self.viewModel.delete()
            })
            alert.addAction(cancelAction)
            alert.addAction(deleteAction)
        }
        presentViewController(alert, animated: true, completion: {
            self.viewModel.deleteStarted()
        })
    }
    
    private func showMarkSoldAlert() {
        let source: EventParameterSellSourceValue = .MarkAsSold
        let alert = UIAlertController(title: LGLocalizedString.productMarkAsSoldConfirmTitle, message: LGLocalizedString.productMarkAsSoldConfirmMessage, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: LGLocalizedString.commonNo, style: .Cancel, handler: { (_) -> Void in
            self.viewModel.markSoldAbandon(source)
        })
        let soldAction = UIAlertAction(title: LGLocalizedString.commonYes, style: .Default, handler: { (_) -> Void in
            self.viewModel.markSold(source)
        })
        alert.addAction(cancelAction)
        alert.addAction(soldAction)
        
        presentViewController(alert, animated: true, completion: {
            self.viewModel.markSoldStarted(source)
        })
    }
}
