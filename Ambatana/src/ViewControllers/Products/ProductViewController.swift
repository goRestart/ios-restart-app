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
import LGCollapsibleLabel

public class ProductViewController: BaseViewController, GalleryViewDelegate, ProductViewModelDelegate {

    // Constants
    private static let addressIconVisibleHeight: CGFloat = 16
    private static let footerViewVisibleHeight: CGFloat = 64
    private static let labelsTopMargin: CGFloat = 15
    private static let addressTopMarginWithDescription: CGFloat = 30

    // UI
    // > Navigation Bar
    private var navBarBgImage: UIImage?
    private var navBarShadowImage: UIImage?
    private var favoriteButton: UIButton?
    private var userInfo: NavBarUserInfo?

    @IBOutlet weak var shadowGradientView: UIView!
    
    // > Main
    @IBOutlet weak var galleryView: GalleryView!

    @IBOutlet weak var priceTitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var nameTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionCollapsible: LGCollapsibleLabel!
    
    @IBOutlet weak var addressIconTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var addressIconHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    // Rounded views can't have shadow the standard way, so there's an extra view:
    // http://stackoverflow.com/questions/3690972/why-maskstobounds-yes-prevents-calayer-shadow
    @IBOutlet weak var productStatusLabel: UILabel!
    @IBOutlet weak var productStatusShadow: UIView!     // just for the shadow
    
    // > Share Buttons
    @IBOutlet weak var socialShareView: SocialShareView!
    
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
    @IBOutlet weak var markSoldButton: UIButton! // used to mark as sold or "resell" depending on the product status
    
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

        navBarBgImage = navigationController?.navigationBar.backgroundImageForBarMetrics(.Default)
        navBarShadowImage = navigationController?.navigationBar.shadowImage

        setupUI()
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()

        updateUI()
    }

    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.navigationBar.setBackgroundImage(navBarBgImage, forBarPosition: .Any, barMetrics: .Default)
        navigationController?.navigationBar.shadowImage = navBarShadowImage
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Redraw the lines
        for line in lines {
            line.removeFromSuperlayer()
        }
        lines = []
        lines.append(bottomView.addTopBorderWithWidth(1, color: StyleHelper.lineColor))

        // Adjust gradient layer
        if let layers = shadowGradientView.layer.sublayers {
            layers.forEach { $0.frame = shadowGradientView.bounds }
        }
    }
    
    // MARK: - Public methods
    
    // MARK: > Actions
    
    @IBAction func mapViewButtonPressed(sender: AnyObject) {
        openMap()
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
    
    /**
        markSoldPressed is the action related to the markSoldButton, works both ways: to "sell" and put it back to "available"
    */
    
    @IBAction func markSoldPressed(sender: AnyObject) {
        if viewModel.productIsSold {
            ifLoggedInThen(.MarkAsUnsold, loggedInAction: {
                self.showMarkUnsoldAlert()
                },
                elsePresentSignUpWithSuccessAction: {
                    self.updateUI()
                    self.showMarkUnsoldAlert()
            })
        } else {
            ifLoggedInThen(.MarkAsSold, loggedInAction: {
                self.showMarkSoldAlert()
                },
                elsePresentSignUpWithSuccessAction: {
                    self.updateUI()
                    self.showMarkSoldAlert()
            })
        }
    }
    

    // MARK: - GalleryViewDelegate
    
    public func galleryView(galleryView: GalleryView, didPressPageAtIndex index: Int) {
        // TODO: Refactor into GalleryViewController with proper MVVM
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewControllerWithIdentifier("PhotosInDetailViewController") as? PhotosInDetailViewController else { return }
        
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
    
    public func viewModelDidFailReporting(viewModel: ProductViewModel, error: RepositoryError) {
        dismissLoadingMessageAlert() { [weak self] in
            self?.reportButton.enabled = true
            self?.showAutoFadingOutMessageAlert(LGLocalizedString.productReportedErrorGeneric, time: 3)
        }
        setReportButtonAsReported(viewModel.isReported)
    }

    
    public func viewModelDidStartDeleting(viewModel: ProductViewModel) {
        showLoadingMessageAlert()
    }
    
    public func viewModel(viewModel: ProductViewModel, didFinishDeleting result: ProductResult) {
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
    
    public func viewModel(viewModel: ProductViewModel, didFinishMarkingAsSold result: ProductResult) {
        guard let _ = result.value else {
            dismissLoadingMessageAlert() { [weak self] in
                self?.showAutoFadingOutMessageAlert(LGLocalizedString.productMarkAsSoldErrorGeneric)
            }
            return
        }

        dismissLoadingMessageAlert() { [weak self] in
            self?.showAutoFadingOutMessageAlert(LGLocalizedString.productMarkAsSoldSuccessMessage) { [weak self] in
                let theTabBarCtrl = self?.tabBarController as? TabBarController
                self?.popViewController(animated: true) {
                    guard let tabBarCtrl = theTabBarCtrl else { return }
                    if !tabBarCtrl.showAppRatingViewIfNeeded() {
                        AppShareViewController.showOnViewControllerIfNeeded(tabBarCtrl)
                    }
                }
            }
        }
        updateUI()
    }
    
    public func viewModelDidStartMarkingAsUnsold(viewModel: ProductViewModel) {
        showLoadingMessageAlert()
    }
    
    public func viewModel(viewModel: ProductViewModel, didFinishMarkingAsUnsold result: ProductResult) {
        let completion: (() -> Void)?
        if let _ = result.value {
            
            completion = {
                self.showAutoFadingOutMessageAlert(LGLocalizedString.productSellAgainSuccessMessage, time: 3) {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
            updateUI()
        }
        else {
            completion = {
                self.showAutoFadingOutMessageAlert(LGLocalizedString.productSellAgainErrorGeneric)
            }
        }
        dismissLoadingMessageAlert(completion)
    }

    public func viewModel(viewModel: ProductViewModel, didFinishAsking chatVM: ChatViewModel) {
        let chatVC = ChatViewController(viewModel: chatVM)
        self.navigationController?.pushViewController(chatVC, animated: true)
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
        let navBarButtonsTintColor = UIColor.whiteColor()

        // Setup
        // > Navigation Bar
        userInfo = NavBarUserInfo.buildNavbarUserInfo()
        setLetGoNavigationBarStyle(userInfo, buttonsTintColor: navBarButtonsTintColor)
        setLetGoNavigationBarStyle("", buttonsTintColor: navBarButtonsTintColor)

        // > Shadow gradient
        let shadowLayer = CAGradientLayer.gradientWithColor(UIColor.blackColor(), alphas:[0.4,0.0],
            locations: [0.0,1.0])
        shadowLayer.frame = shadowGradientView.bounds
        shadowGradientView.layer.insertSublayer(shadowLayer, atIndex: 0)

        // > Main
        productStatusLabel.layer.cornerRadius = 18
        productStatusLabel.layer.masksToBounds = true
        
        productStatusShadow.layer.shadowColor = UIColor.blackColor().CGColor
        productStatusShadow.layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
        productStatusShadow.layer.shadowOpacity = 0.24
        productStatusShadow.layer.shadowRadius = 8.0

        priceTitleLabel.text = LGLocalizedString.productPriceLabel.uppercaseString
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("toggleDescriptionState"))
        descriptionCollapsible.addGestureRecognizer(tapGesture)
        descriptionCollapsible.expandText = LGLocalizedString.commonExpand.uppercaseString
        descriptionCollapsible.collapseText = LGLocalizedString.commonCollapse.uppercaseString

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
        
        let markSoldTitle = viewModel.productIsSold ? LGLocalizedString.productMarkAsSoldButton : LGLocalizedString.productMarkAsSoldButton
        markSoldButton.setTitle(markSoldTitle, forState: .Normal)

        // Delegates
        galleryView.delegate = self
        
        // Share Buttons
        socialShareView.delegate = self
        socialShareView.socialMessage = viewModel.shareSocialMessage
    }

    dynamic private func toggleDescriptionState() {
        UIView.animateWithDuration(0.25) {
            self.descriptionCollapsible.toggleState()
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateUI() {
        // Navigation bar
        // > If editing, place a text button
        if viewModel.isEditable {
            let editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: Selector("editButtonPressed"))
            editButton.tintColor = UIColor.whiteColor()
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
            
            let buttons = setLetGoRightButtonsWith(imageNames: imageNames, selectors: selectors, tags: tags,
                buttonsTintColor: UIColor.whiteColor())
            for button in buttons {
                if button.tag == favTag {
                    favoriteButton = button
                }
            }
        }
        
        // Fav status
        setFavouriteButtonAsFavourited(viewModel.isFavorite)
       
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
                    if let thumbnailImage = viewModel.thumbnailImage {
                        galleryView.addPageWithImageAtURL(imageURL, previewImage: thumbnailImage)
                    }
                    else {
                        galleryView.addPageWithImageAtURL(imageURL, previewImage: nil)
                    }
                }
                else {
                    galleryView.addPageWithImageAtURL(imageURL, previewImage: nil)
                }
            }
        }

        if let userInfo = userInfo {
            userInfo.setupWith(avatar: viewModel.userAvatar, text: viewModel.userName)
            userInfo.delegate = self
        }

        priceLabel.text = viewModel.price
        nameLabel.text = viewModel.name
        nameTopConstraint.constant = viewModel.name.isEmpty ? 0 : ProductViewController.labelsTopMargin
        descriptionCollapsible.mainText = viewModel.descr
        descriptionTopConstraint.constant = descriptionCollapsible.mainText.isEmpty ? 0 :
            ProductViewController.labelsTopMargin
        descriptionCollapsible.layoutSubviews() //TODO: Make LGCollapsibleLabel to to it automatically when setting the text
        addressIconTopConstraint.constant = descriptionCollapsible.mainText.isEmpty ?
            ProductViewController.labelsTopMargin : ProductViewController.addressTopMarginWithDescription
        addressIconHeightConstraint.constant = viewModel.addressIconVisible ?
            ProductViewController.addressIconVisibleHeight : 0
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
        footerViewHeightConstraint.constant = viewModel.isFooterVisible ?
            ProductViewController.footerViewVisibleHeight : 0

        let title = viewModel.productIsSold ?
            LGLocalizedString.productSellAgainButton : LGLocalizedString.productMarkAsSoldButton
        markSoldButton.setTitle(title, forState: .Normal)
        
        // Footer other / me selling subviews
        otherSellingView.hidden = viewModel.isMine
        meSellingView.hidden = !viewModel.isMine
    }
    
    private func setFavouriteButtonAsFavourited(favourited: Bool) {
        let imageName = favourited ? "navbar_fav_on" : "navbar_fav_off"
        let image = UIImage(named: imageName)
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
        presentNativeShareWith(shareText: viewModel.shareText, delegate: self)
    }
    
    // MARK: > Actions w navigation
    
    dynamic private func editButtonPressed() {
        let editVM = viewModel.editViewModelWithDelegate
        let vc = EditSellProductViewController(viewModel: editVM, updateDelegate: viewModel)
        let navCtl = UINavigationController(rootViewController: vc)
        navigationController?.presentViewController(navCtl, animated: true, completion: nil)
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
    
    private func showMarkUnsoldAlert() {
        let alert = UIAlertController(title: LGLocalizedString.productSellAgainConfirmTitle, message: LGLocalizedString.productSellAgainConfirmMessage, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: LGLocalizedString.commonNo, style: .Cancel, handler: { (_) -> Void in
            self.viewModel.markUnsoldAbandon()
        })
        let unsoldAction = UIAlertAction(title: LGLocalizedString.commonYes, style: .Default, handler: { (_) -> Void in
            self.viewModel.markUnsold()
        })
        alert.addAction(cancelAction)
        alert.addAction(unsoldAction)
        
        presentViewController(alert, animated: true, completion: {
            self.viewModel.markUnsoldStarted()
        })
    }
}


// MARK: - NavBarUserInfoDelegate

extension ProductViewController: NavBarUserInfoDelegate {
    func navBarUserInfoTapped(navbarUserInfo: NavBarUserInfo) {
        openProductUserProfile()
    }

    // TODO: Refactor to retrieve a viewModel and build an VC
    private func openProductUserProfile() {
        if let vc = viewModel.productUserProfileViewModel {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}


// MARK: - SocialShareViewDelegate

extension ProductViewController: SocialShareViewDelegate {

    func shareInEmail(){
        viewModel.shareInEmail(.Bottom)
    }

    func shareInFacebook() {
        viewModel.shareInFacebook(.Bottom)
    }

    func shareInFacebookFinished(state: SocialShareState) {
        switch state {
        case .Completed:
            viewModel.shareInFBCompleted()
        case .Cancelled:
            viewModel.shareInFBCancelled()
        case .Failed:
            showAutoFadingOutMessageAlert(LGLocalizedString.sellSendErrorSharingFacebook)
        }
    }

    func shareInFBMessenger() {
        viewModel.shareInFBMessenger()
    }

    func shareInFBMessengerFinished(state: SocialShareState) {
        switch state {
        case .Completed:
            viewModel.shareInFBMessengerCompleted()
        case .Cancelled:
            viewModel.shareInFBMessengerCancelled()
        case .Failed:
            showAutoFadingOutMessageAlert(LGLocalizedString.sellSendErrorSharingFacebook)
        }
    }

    func shareInWhatsApp() {
        viewModel.shareInWhatsApp()
    }

    func viewController() -> UIViewController? {
        return self
    }
}

// MARK: - NativeShareDelegate

extension ProductViewController: NativeShareDelegate {

    func nativeShareInFacebook() {
        viewModel.shareInFacebook(.Top)
        viewModel.shareInFBCompleted()
    }

    func nativeShareInTwitter() {
        viewModel.shareInTwitterActivity()
    }

    func nativeShareInEmail() {
        viewModel.shareInEmail(.Top)
    }

    func nativeShareInWhatsApp() {
        viewModel.shareInWhatsappActivity()
    }
}

