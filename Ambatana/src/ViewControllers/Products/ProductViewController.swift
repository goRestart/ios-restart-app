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
    private static let userViewHeight: CGFloat = 40
    private static let footerViewVisibleHeight: CGFloat = 64

    // UI
    // > Navigation Bar
    private var navBarBgImage: UIImage?
    private var navBarShadowImage: UIImage?
    private var navBarUserView: UserView?
    private var navBarUserViewAlpha: CGFloat
    private var favoriteButton: UIButton?
    @IBOutlet weak var navBarBlurEffectView: UIVisualEffectView!

    // > Main
    @IBOutlet weak var shadowGradientView: UIView!
    @IBOutlet weak var galleryView: GalleryView!
    @IBOutlet weak var galleryAspectHeight: NSLayoutConstraint!
    @IBOutlet weak var productStatusShadow: UIView!
    @IBOutlet weak var productStatusLabel: UILabel!
    private var pageControlContainer: UIView = UIView(frame: CGRect.zero)
    private var pageControl: UIPageControl = UIPageControl(frame: CGRect.zero)

    // > ScrollView
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var mainScrollViewTop: NSLayoutConstraint!
    @IBOutlet weak var mainScrollViewContentView: UIView!
    @IBOutlet weak var galleryFakeScrollView: UIScrollView!
    private var galleryFakeScrollViewTapRecognizer: UITapGestureRecognizer?
    private var userView: UserView?

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionCollapsible: LGCollapsibleLabel!

    @IBOutlet weak var separatorView: UIView!

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    // > Share Buttons
    @IBOutlet weak var shareTitleLabel: UILabel!
    @IBOutlet weak var socialShareView: SocialShareView!

    // > Footer
    @IBOutlet weak var footerViewHeightConstraint: NSLayoutConstraint!
    
    // >> Other selling
    @IBOutlet weak var otherSellingView: UIView!
    @IBOutlet weak var askButton: UIButton!
    @IBOutlet weak var offerButton: UIButton!
    
    // >> Me selling
    @IBOutlet weak var meSellingView: UIView!
    @IBOutlet weak var markSoldButton: UIButton!
    @IBOutlet weak var resellButton: UIButton!
    
    // > Other
    private var lines : [CALayer]
    
    // ViewModel
    private var viewModel : ProductViewModel!


    // MARK: - Lifecycle

    public init(viewModel: ProductViewModel) {
        self.viewModel = viewModel
        let size = CGSize(width: CGFloat.max, height: 44)
        self.navBarUserView = UserView.userView(.Compact(size: size))
        self.navBarUserViewAlpha = 0
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

        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)

        updateUI()
    }

    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.navigationBar.setBackgroundImage(navBarBgImage, forBarPosition: .Any, barMetrics: .Default)
        navigationController?.navigationBar.shadowImage = navBarShadowImage

        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Redraw the lines
        for line in lines {
            line.removeFromSuperlayer()
        }
        lines = []
        lines.append(separatorView.addTopBorderWithWidth(1, color: StyleHelper.lineColor))

        // Adjust gradient layer
        if let layers = shadowGradientView.layer.sublayers {
            layers.forEach { $0.frame = shadowGradientView.bounds }
        }
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        galleryFakeScrollView.contentSize = CGSize(width: galleryView.contentSize.width,
            height: galleryView.contentSize.height - mainScrollViewTop.constant)
        pageControlContainer.layer.cornerRadius = pageControlContainer.frame.height / 2
    }

    
    // MARK: - Public methods
    // MARK: > Actions
    
    @IBAction func mapViewButtonPressed(sender: AnyObject) {
        openMap()
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

    @IBAction func resellPressed(sender: AnyObject) {
        ifLoggedInThen(.MarkAsUnsold, loggedInAction: {
            self.showMarkUnsoldAlert()
            },
            elsePresentSignUpWithSuccessAction: {
                self.updateUI()
                self.showMarkUnsoldAlert()
        })
    }


    // MARK: - GalleryViewDelegate

    public func galleryView(galleryView: GalleryView, didSelectPageAt index: Int) {
        pageControl.currentPage = index
    }

    public func galleryView(galleryView: GalleryView, didPressPageAtIndex index: Int) {
        openFullScreenGalleryAtIndex(index)
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
    }

    public func viewModelDidStartReporting(viewModel: ProductViewModel) {
        showLoadingMessageAlert(LGLocalizedString.productReportingLoadingMessage)
    }

    public func viewModelShowReportAlert(viewModel: ProductViewModel) {
        showReportAlert()
    }

    public func viewModelDidUpdateIsReported(viewModel: ProductViewModel) {

    }
    
    public func viewModelDidCompleteReporting(viewModel: ProductViewModel) {
        
        let completion = {
            self.showAutoFadingOutMessageAlert(LGLocalizedString.productReportedSuccessMessage, time: 3)
        }
        
        dismissLoadingMessageAlert(completion)
    }
    
    public func viewModelDidFailReporting(viewModel: ProductViewModel, error: RepositoryError) {
        dismissLoadingMessageAlert() { [weak self] in
            self?.showAutoFadingOutMessageAlert(LGLocalizedString.productReportedErrorGeneric, time: 3)
        }
    }

    public func viewModelShowDeleteAlert(viewModel: ProductViewModel) {
        showDeleteAlert()
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


    public func viewModelDidStartPromoting(viewModel: ProductViewModel, promoteProductViewModel: PromoteProductViewModel) {
        let promoteProductVC = PromoteProductViewController(viewModel: promoteProductViewModel)
        presentViewController(promoteProductVC, animated: true, completion: nil)
    }


    // MARK: - Private methods
    // MARK: > UI

    private func setupUI() {
        // Setup
        // > Navigation Bar
        if let navBarUserView = navBarUserView {
            navBarUserView.delegate = self
            navBarUserView.alpha = 0
            navBarUserView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: CGFloat.max, height: 36))

            let backIcon = UIImage(named: "navbar_back_white_shadow")
            setLetGoNavigationBarStyle(navBarUserView, backIcon: backIcon)
        }

        // > Shadow gradient
        let shadowLayer = CAGradientLayer.gradientWithColor(UIColor.blackColor(), alphas:[0.4,0.0],
            locations: [0.0,1.0])
        shadowLayer.frame = shadowGradientView.bounds
        shadowGradientView.layer.insertSublayer(shadowLayer, atIndex: 0)

        // > Gallery
        galleryFakeScrollViewTapRecognizer = UITapGestureRecognizer(target: self,
            action: "openFullScreenGalleryAtCurrentIndex:")
        if let galleryFakeScrollViewTapRecognizer = galleryFakeScrollViewTapRecognizer {
            galleryFakeScrollViewTapRecognizer.numberOfTapsRequired = 1
            galleryFakeScrollView.addGestureRecognizer(galleryFakeScrollViewTapRecognizer)
        }

        // > Product status
        StyleHelper.applyInfoBubbleShadow(productStatusShadow.layer)

        // > User product price view
        userView = UserView.userView(.Full)
        if let userView = userView {
            userView.translatesAutoresizingMaskIntoConstraints = false
            userView.delegate = self
            mainScrollViewContentView.addSubview(userView)

            let leftMargin = NSLayoutConstraint(item: userView, attribute: .Left, relatedBy: .Equal,
                toItem: galleryFakeScrollView, attribute: .Left, multiplier: 1, constant: 16)
            let bottomMargin = NSLayoutConstraint(item: userView, attribute: .Bottom, relatedBy: .Equal,
                toItem: galleryFakeScrollView, attribute: .Bottom, multiplier: 1, constant: -16)
            let height = NSLayoutConstraint(item: userView, attribute: .Height, relatedBy: .Equal,
                toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: ProductViewController.userViewHeight)
            let minWidth = NSLayoutConstraint(item: userView, attribute: .Width,
                relatedBy: .GreaterThanOrEqual, toItem: galleryFakeScrollView, attribute: .Width, multiplier: 0.35,
                constant: 0)
            let maxWidth = NSLayoutConstraint(item: userView, attribute: .Width,
                relatedBy: .LessThanOrEqual, toItem: galleryFakeScrollView, attribute: .Width, multiplier: 0.75,
                constant: 0)

            mainScrollViewContentView.addConstraints([leftMargin, bottomMargin, height, minWidth, maxWidth])
        }

        // > Page control
        pageControlContainer.backgroundColor = UIColor(rgb: 0x000000, alpha: 0.16)
        pageControlContainer.translatesAutoresizingMaskIntoConstraints = false
        mainScrollViewContentView.addSubview(pageControlContainer)

        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControlContainer.addSubview(pageControl)

        let right = NSLayoutConstraint(item: pageControlContainer, attribute: .Right, relatedBy: .Equal,
            toItem: galleryFakeScrollView, attribute: .Right, multiplier: 1, constant: -16)
        let bottom = NSLayoutConstraint(item: pageControlContainer, attribute: .Bottom, relatedBy: .Equal,
            toItem: galleryFakeScrollView, attribute: .Bottom, multiplier: 1, constant: -16)
        mainScrollViewContentView.addConstraints([right, bottom])

        let pageControlContainerViews = ["pageControl": pageControl]
        pageControlContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[pageControl(18)]|",
            options: [], metrics: nil, views: pageControlContainerViews))
        pageControlContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[pageControl]-10-|",
            options: [], metrics: nil, views: pageControlContainerViews))

        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("toggleDescriptionState"))
        descriptionCollapsible.textColor = StyleHelper.productDescriptionTextColor
        descriptionCollapsible.addGestureRecognizer(tapGesture)
        descriptionCollapsible.expandText = LGLocalizedString.commonExpand.uppercase
        descriptionCollapsible.collapseText = LGLocalizedString.commonCollapse.uppercase

        askButton.setTitle(LGLocalizedString.productAskAQuestionButton, forState: .Normal)
        askButton.setSecondaryStyle()

        offerButton.setTitle(LGLocalizedString.productMakeAnOfferButton, forState: .Normal)
        offerButton.setPrimaryStyle()

        resellButton.setTitle(LGLocalizedString.productSellAgainButton, forState: .Normal)
        resellButton.setSecondaryStyle()

        markSoldButton.setTitle(LGLocalizedString.productMarkAsSoldButton, forState: .Normal)
        markSoldButton.backgroundColor = StyleHelper.soldColor
        markSoldButton.setCustomButtonStyle()

        shareTitleLabel.text = LGLocalizedString.productShareTitleLabel
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
        var imageNames: [String] = []
        var renderingMode: [UIImageRenderingMode] = []
        var selectors: [String] = []
        var tags: [Int] = []
        var favTag: Int? = nil
        var currentTag = 0

        if viewModel.isFavouritable {
            imageNames.append("navbar_fav_off")
            renderingMode.append(.AlwaysOriginal)
            selectors.append("favouriteButtonPressed")
            favTag = currentTag
            tags.append(currentTag)
            currentTag++
        } else if viewModel.isEditable {
            imageNames.append("navbar_edit")
            renderingMode.append(.AlwaysOriginal)
            selectors.append("editButtonPressed")
            tags.append(currentTag)
            currentTag++
        }

        if viewModel.isShareable {
            imageNames.append("navbar_share")
            renderingMode.append(.AlwaysOriginal)
            selectors.append("shareButtonPressed")
            tags.append(currentTag)
            currentTag++
        }

        if viewModel.hasMoreActions {
            imageNames.append("navbar_more")
            renderingMode.append(.AlwaysOriginal)
            selectors.append("moreActionsButtonPressed")
            tags.append(currentTag)
            currentTag++
        }
        let buttons = setLetGoRightButtonsWith(imageNames: imageNames, renderingMode: renderingMode,
            selectors: selectors, tags: tags)
        if let favTag = favTag {
            favoriteButton = buttons.filter({ $0.tag == favTag }).first
        }
        if let navBarUserView = navBarUserView {
            navBarUserView.setupWith(userAvatar: viewModel.userAvatar, userName: viewModel.userName,
                userId: viewModel.userID)

            // UINavigationBar's title alpha gets resetted on view appear, does not allow initial 0.0 value
            let currentAlpha = navBarUserViewAlpha
            navBarUserView.hidden = true
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.01 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                navBarUserView.alpha = currentAlpha
                navBarUserView.hidden = false
            }
        }

        // Fav status
        setFavouriteButtonAsFavourited(viewModel.isFavorite)

        // Product Status Label
        productStatusShadow.hidden = !viewModel.isProductStatusLabelVisible
        productStatusShadow.backgroundColor = viewModel.productStatusLabelBackgroundColor
        productStatusLabel.textColor = viewModel.productStatusLabelFontColor
        productStatusLabel.text = viewModel.productStatusLabelText
        
        // Gallery
        let currentPageIndex = galleryView.currentPageIdx
        galleryView.delegate = self
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
        galleryView.setCurrentPageIndex(currentPageIndex)
        galleryFakeScrollView.contentSize = CGSize(width: galleryView.contentSize.width,
            height: galleryView.contentSize.height - mainScrollViewTop.constant)

        // UserView
        if let userView = userView {
            userView.setupWith(userAvatar: viewModel.userAvatar, userName: viewModel.userName, userId: viewModel.userID)
        }

        // Page control
        pageControl.numberOfPages = viewModel.numberOfImages
        pageControlContainer.hidden = viewModel.numberOfImages <= 1
        pageControl.currentPage = galleryView.currentPageIdx

        // Main
        nameLabel.text = viewModel.name
        descriptionCollapsible.mainText = viewModel.descr
        descriptionCollapsible.layoutSubviews() //TODO: Make LGCollapsibleLabel to do it automatically when setting the text
        priceLabel.text = viewModel.price

        addressLabel.text = viewModel.address
        if let location = viewModel.location {
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
            mapView.setRegion(region, animated: true)
        }

        // Footer
        footerViewHeightConstraint.constant = viewModel.isFooterVisible ?
            ProductViewController.footerViewVisibleHeight : 0

        markSoldButton.hidden = viewModel.markAsSoldButtonHidden
        resellButton.hidden = viewModel.resellButtonHidden
        
        // Footer other / me selling subviews
        otherSellingView.hidden = viewModel.isMine
        meSellingView.hidden = !viewModel.isMine
    }
    
    private func setFavouriteButtonAsFavourited(favourited: Bool) {
        let imageName = favourited ? "navbar_fav_on" : "navbar_fav_off"
        let image = UIImage(named: imageName)
        favoriteButton?.setImage(image, forState: .Normal)
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

    dynamic private func moreActionsButtonPressed() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        for action in viewModel.moreActions {
            alert.addAction(UIAlertAction(title: action.0, style: .Default, handler: { _ -> Void in action.1() }))
        }
        alert.addAction(UIAlertAction(title: LGLocalizedString.commonCancel, style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
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


// MARK: -  UserViewDelegate

extension ProductViewController: UserViewDelegate {
    func userViewAvatarPressed(userView: UserView) {
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


// MARK: - UIScrollViewDelegate

extension ProductViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(scrollView: UIScrollView) {

        switch scrollView {
        case mainScrollView:
            mainScrollViewDidScroll(scrollView)
        case galleryFakeScrollView:
            galleryFakeScrollViewDidScroll(scrollView)
        default:
            break
        }
    }

    private func mainScrollViewDidScroll(scrollView: UIScrollView) {
        // Zoom-in if bouncing at the top, reduce height if scrolling down until 1/4 of the view
        let yMax = view.frame.height/4
        galleryAspectHeight.constant = min(yMax, scrollView.contentOffset.y)
        let y = scrollView.contentOffset.y
        let percentage = max(0, -y / view.frame.height)
        galleryView.zoom(percentage)

        // Nav bar blur alpha
        let galleryHeight = galleryAspectHeight.multiplier * view.frame.width
        let navBarBlurEnd = galleryHeight - navBarBlurEffectView.frame.height
        let navBarBlurStart = galleryHeight * 0.6
        var navBarBlurAlpha = (scrollView.contentOffset.y - navBarBlurStart) / (navBarBlurEnd - navBarBlurStart)
        navBarBlurAlpha = max(0, min(1, navBarBlurAlpha))
        navBarBlurEffectView.alpha = navBarBlurAlpha

        // User price view in navbar
        if let navBarUserView = navBarUserView, userView = userView {
            let navBarUserViewAlpha: CGFloat = navBarBlurAlpha > 0.2 ? 1 : 0
            let userViewAlpha: CGFloat = navBarBlurAlpha > 0.2 ? 0 : 1

            UIView.animateWithDuration(0.35, animations: { () -> Void in
                navBarUserView.alpha = navBarUserViewAlpha
                userView.alpha = userViewAlpha
            })
        }
        navBarUserViewAlpha = navBarBlurAlpha
    }

    private func galleryFakeScrollViewDidScroll(scrollView: UIScrollView) {
        galleryView.contentOffset = scrollView.contentOffset
    }
}


extension ProductViewController {
    dynamic private func openFullScreenGalleryAtCurrentIndex(recognizer: UIGestureRecognizer) {
        let index = galleryView.currentPageIdx
        openFullScreenGalleryAtIndex(index)
    }

    private func openFullScreenGalleryAtIndex(index: Int) {
        // TODO: Refactor into GalleryViewController with proper MVVM
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewControllerWithIdentifier("PhotosInDetailViewController")
            as? PhotosInDetailViewController else { return }

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
}
