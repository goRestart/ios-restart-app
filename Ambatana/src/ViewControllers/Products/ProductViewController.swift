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
import RxCocoa
import RxSwift
import SDWebImage
import UIKit
import LGCollapsibleLabel

class ProductViewController: BaseViewController {
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
    @IBOutlet weak var mapViewButton: UIButton!
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
    @IBOutlet weak var promoteButton: UIButton!
    @IBOutlet weak var markSoldContainerView: UIView!
    @IBOutlet weak var promoteContainerView: UIView!
    @IBOutlet weak var markSoldAndPromoteContainerView: UIView!

    var promoteButtonLeadingConstraint: NSLayoutConstraint!
    var markSoldPromoteSeparationConstraint: NSLayoutConstraint!
    
    
    // >> Commercializer
    var commercialButton: CommercialButton = CommercialButton.commercialButton()!
    
    // > Other
    private var lines : [CALayer]
    
    // ViewModel
    private var viewModel : ProductViewModel!

    let disposeBag: DisposeBag

    
    // MARK: - Lifecycle

    init(viewModel: ProductViewModel) {
        self.viewModel = viewModel
        let size = CGSize(width: CGFloat.max, height: 44)
        self.navBarUserView = UserView.userView(.CompactShadow(size: size))
        self.navBarUserViewAlpha = 0
        self.lines = []
        self.disposeBag = DisposeBag()
        super.init(viewModel: viewModel, nibName: "ProductViewController")

        self.viewModel.delegate = self

        automaticallyAdjustsScrollViewInsets = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Constraints added manually to set the position of the Promote and MarkSold buttons
        // (both can't be active at the same time).
        promoteButtonLeadingConstraint = NSLayoutConstraint(item: promoteContainerView, attribute: .Leading,
            relatedBy: .Equal, toItem: markSoldAndPromoteContainerView, attribute: .Leading, multiplier: 1, constant: 5)
        markSoldPromoteSeparationConstraint = NSLayoutConstraint(item: promoteContainerView, attribute: .Leading,
            relatedBy: .Equal, toItem: markSoldContainerView, attribute: .Trailing, multiplier: 1, constant: 0)
        
        promoteButtonLeadingConstraint.active = false
        markSoldAndPromoteContainerView.addConstraints([promoteButtonLeadingConstraint, markSoldPromoteSeparationConstraint])
        
        navBarBgImage = navigationController?.navigationBar.backgroundImageForBarMetrics(.Default)
        navBarShadowImage = navigationController?.navigationBar.shadowImage

        setupUI()
        setupRxBindings()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()

        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)

        // UINavigationBar's title alpha gets resetted on view appear, does not allow initial 0.0 value
        let currentAlpha = navBarUserViewAlpha
        if let navBarUserView = navBarUserView {
            navBarUserView.hidden = true
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.01 * Double(NSEC_PER_SEC))),
                dispatch_get_main_queue()) {
                    navBarUserView.alpha = currentAlpha
                    navBarUserView.hidden = false
            }
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.navigationBar.setBackgroundImage(navBarBgImage, forBarPosition: .Any, barMetrics: .Default)
        navigationController?.navigationBar.shadowImage = navBarShadowImage

        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }
    
    override func viewWillLayoutSubviews() {
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        galleryFakeScrollView.contentSize = CGSize(width: galleryView.contentSize.width,
            height: galleryView.contentSize.height - mainScrollViewTop.constant)
        pageControlContainer.layer.cornerRadius = pageControlContainer.frame.height / 2
    }
}


// MARK: - GalleryViewDelegate

extension ProductViewController: GalleryViewDelegate {
    func galleryView(galleryView: GalleryView, didSelectPageAt index: Int) {
        pageControl.currentPage = index
    }

    func galleryView(galleryView: GalleryView, didPressPageAtIndex index: Int) {
        openFullScreenGalleryAtIndex(index)
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

        vc.imageURLs = viewModel.productImageURLs.value
        vc.initialImageToShow = index
        vc.productName = viewModel.productTitle.value ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - LGCollapsibleLabel

extension ProductViewController {
    dynamic private func toggleDescriptionState() {
        UIView.animateWithDuration(0.25) {
            self.descriptionCollapsible.toggleState()
            self.view.layoutIfNeeded()
        }
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


// MARK: - ProductViewModelDelegate

extension ProductViewController: ProductViewModelDelegate {
    func vmShowNativeShare(message: String) {
        presentNativeShareWith(shareText: message, delegate: self)
    }

    func vmOpenEditProduct(editProductVM: EditSellProductViewModel) {
        let vc = EditSellProductViewController(viewModel: editProductVM, updateDelegate: viewModel)
        let navCtl = UINavigationController(rootViewController: vc)
        navigationController?.presentViewController(navCtl, animated: true, completion: nil)
    }

    func vmOpenMainSignUp(signUpVM: SignUpViewModel, afterLoginAction: () -> ()) {
        let mainSignUpVC = MainSignUpViewController(viewModel: signUpVM)
        mainSignUpVC.afterLoginAction = afterLoginAction

        let navCtl = UINavigationController(rootViewController: mainSignUpVC)
        navCtl.view.backgroundColor = UIColor.whiteColor()
        presentViewController(navCtl, animated: true, completion: nil)
    }

    func vmOpenUser(userVM: UserViewModel) {
        let vc = UserViewController(viewModel: userVM)
        navigationController?.pushViewController(vc, animated: true)
    }

    func vmOpenChat(chatVM: ChatViewModel) {
        let chatVC = ChatViewController(viewModel: chatVM)
        navigationController?.pushViewController(chatVC, animated: true)
    }

    func vmOpenOffer(offerVC: MakeAnOfferViewController) {
        navigationController?.pushViewController(offerVC, animated: true)
    }

    func vmOpenPromoteProduct(promoteVM: PromoteProductViewModel) {
        let promoteProductVC = PromoteProductViewController(viewModel: promoteVM)
        promoteProductVC.delegate = self
        navigationController?.presentViewController(promoteProductVC, animated: true, completion: nil)
    }

    func vmOpenCommercialDisplay(displayVM: CommercialDisplayViewModel) {
        let commercialDisplayVC = CommercialDisplayViewController(viewModel: displayVM)
        navigationController?.presentViewController(commercialDisplayVC, animated: true, completion: nil)
    }
}

extension ProductViewController : PromoteProductViewControllerDelegate {
    func promoteProductViewControllerDidFinishFromSource(promotionSource: PromotionSource) {
    }
}


// MARK: - Rx

extension ProductViewController {
    private func setupRxBindings() {
        setupRxNavbarBindings()
        setupRxProductStatusBindings()
        setupRxGalleryBindings()
        setupRxBodyBindings()
        setupRxFooterBindings()
        setupRxVideoButton()
    }
    
    private func setupRxVideoButton() {
        viewModel.productHasCommercializer.asObservable().map{!$0}.bindTo(commercialButton.rx_hidden).addDisposableTo(disposeBag)
        commercialButton.innerButton.rx_tap.bindNext { [weak self] in
            self?.viewModel.openVideo()
            }.addDisposableTo(disposeBag)
    }

    private func setupRxNavbarBindings() {
        viewModel.navBarButtons.asObservable().subscribeNext { [weak self] navBarButtons in
            guard let strongSelf = self else { return }

            var buttons = [UIButton]()
            navBarButtons.forEach { navBarButton in
                let button = UIButton(type: .System)
                button.setImage(navBarButton.image, forState: .Normal)
                button.rx_tap.bindNext { _ in
                    navBarButton.action()
                }.addDisposableTo(strongSelf.disposeBag)
                buttons.append(button)
            }
            strongSelf.setNavigationBarRightButtons(buttons)
        }.addDisposableTo(disposeBag)
    }

    private func setupRxProductStatusBindings() {
        let productStatusLabelText = viewModel.productStatusLabelText.asObservable()
        productStatusLabelText.map({ status -> Bool in
            guard let status = status else { return false }
            return status.isEmpty
        }).bindTo(productStatusShadow.rx_hidden).addDisposableTo(disposeBag)

        productStatusLabelText.map({ status -> String in
            guard let status = status else { return "" }
            return status
        }).bindTo(productStatusLabel.rx_text).addDisposableTo(disposeBag)

        viewModel.productStatusLabelColor.asObservable().subscribeNext { [weak self] color in
            self?.productStatusLabel.textColor = color
            }.addDisposableTo(disposeBag)

        viewModel.productStatusBackgroundColor.asObservable().subscribeNext { [weak self] color in
            self?.productStatusShadow.backgroundColor = color
            }.addDisposableTo(disposeBag)
    }

    private func setupRxGalleryBindings() {
        viewModel.productImageURLs.asObservable().subscribeNext { [weak self] urls in
            guard let strongSelf = self else { return }

            let currentPageIndex = strongSelf.galleryView.currentPageIdx
            strongSelf.galleryView.removePages()
            for (i, url) in urls.enumerate() {
                let thumbnailImage = ( i == 0 ) ? strongSelf.viewModel.thumbnailImage : nil
                strongSelf.galleryView.addPageWithImageAtURL(url, previewImage: thumbnailImage)
            }
            strongSelf.galleryView.setCurrentPageIndex(currentPageIndex)
            strongSelf.galleryFakeScrollView.contentSize = CGSize(width: strongSelf.galleryView.contentSize.width,
                height: strongSelf.galleryView.contentSize.height - strongSelf.mainScrollViewTop.constant)

            strongSelf.pageControl.numberOfPages = urls.count
            strongSelf.pageControlContainer.hidden = urls.count <= 1
            strongSelf.pageControl.currentPage = min(urls.count - 1, currentPageIndex)
        }.addDisposableTo(disposeBag)
    }

    private func setupRxBodyBindings() {
        viewModel.productTitle.asObservable().bindTo(nameLabel.rx_optionalText).addDisposableTo(disposeBag)
        viewModel.productPrice.asObservable().bindTo(priceLabel.rx_text).addDisposableTo(disposeBag)
        viewModel.productDescription.asObservable().bindTo(descriptionCollapsible.rx_optionalMainText)
            .addDisposableTo(disposeBag)
        viewModel.productAddress.asObservable().bindTo(addressLabel.rx_optionalText).addDisposableTo(disposeBag)

        viewModel.productLocation.asObservable().subscribeNext { [weak self] coordinate in
            guard let coordinate = coordinate else { return }
            let clCoordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let region = MKCoordinateRegionMakeWithDistance(clCoordinate, 1000, 1000)
            self?.mapView.setRegion(region, animated: true)
            }.addDisposableTo(disposeBag)

        mapViewButton.rx_tap.bindNext { [weak self] in
            guard let strongSelf = self else { return }
            guard let productLocationVC = strongSelf.viewModel.openProductLocation() else { return }
            strongSelf.navigationController?.pushViewController(productLocationVC, animated: true)
        }.addDisposableTo(disposeBag)

        viewModel.socialMessage.asObservable().subscribeNext { [weak self] socialMessage in
            self?.socialShareView.socialMessage = socialMessage
        }.addDisposableTo(disposeBag)
    }

    private func setupRxFooterBindings() {
        viewModel.footerHidden.asObservable().subscribeNext { [weak self] hidden in
            self?.footerViewHeightConstraint.constant = hidden ? 0 : ProductViewController.footerViewVisibleHeight
            }.addDisposableTo(disposeBag)

        viewModel.footerOtherSellingHidden.asObservable().bindTo(otherSellingView.rx_hidden).addDisposableTo(disposeBag)
        askButton.rx_tap.bindNext { [weak self] in
            self?.viewModel.ask()
            }.addDisposableTo(disposeBag)
        offerButton.rx_tap.bindNext { [weak self] in
            self?.viewModel.offer()
            }.addDisposableTo(disposeBag)
        
        viewModel.footerMeSellingHidden.asObservable().bindTo(meSellingView.rx_hidden).addDisposableTo(disposeBag)
        
        markSoldButton.rx_tap.bindNext { [weak self] in
            self?.viewModel.markSold()
            }.addDisposableTo(disposeBag)
        resellButton.rx_tap.bindNext { [weak self] in
            self?.viewModel.resell()
            }.addDisposableTo(disposeBag)

        promoteButton.rx_tap.bindNext { [weak self] in
            self?.viewModel.promoteProduct()
        }.addDisposableTo(disposeBag)

        // Hide each button if necessary
        viewModel.resellButtonHidden.asObservable().bindTo(resellButton.rx_hidden).addDisposableTo(disposeBag)
        viewModel.markSoldButtonHidden.asObservable().bindTo(markSoldContainerView.rx_hidden).addDisposableTo(disposeBag)

        // If the product canBePromoted (there are templates and the status is ok) AND there are still not used templates
        let promotable = Observable.combineLatest(viewModel.canPromoteProduct.asObservable(), viewModel.productHasAvailableTemplates.asObservable()) {$0 && $1}
        
        promotable.map{!$0}.bindTo(promoteContainerView.rx_hidden).addDisposableTo(disposeBag)

        // Switch active constraints to show 1 o r 2 buttons
        Observable.combineLatest(promotable,
            viewModel.markSoldButtonHidden.asObservable()) { (!$0, $1) }
            .bindNext { [weak self] (promoteHidden, markSoldHidden) in
                guard let strongSelf = self else { return }
                let markSoldNeedsFullSize = (promoteHidden && !markSoldHidden)
                let promoteNeedsFullSize = (!promoteHidden && markSoldHidden)
                let someFullSize = markSoldNeedsFullSize || promoteNeedsFullSize
                strongSelf.promoteButtonLeadingConstraint.active = someFullSize
                strongSelf.markSoldPromoteSeparationConstraint.active = !someFullSize
            }.addDisposableTo(disposeBag)
        
        // If both containers are hidden (meSelling & otherSellign), hide footer
        viewModel.footerHidden.asObservable().bindNext {
            self.footerViewHeightConstraint.constant = $0 ? 0 : ProductViewController.footerViewVisibleHeight
        }.addDisposableTo(disposeBag)
        
        Observable.combineLatest(promotable,
            viewModel.markSoldButtonHidden.asObservable()) { !$0 && $1 }
            .bindTo(markSoldAndPromoteContainerView.rx_hidden)
            .addDisposableTo(disposeBag)
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


// MARK: - UI setup

extension ProductViewController {
    private func setupUI() {
        setupNavigationBar()
        setupGradientView()
        setupProductStatusView()
        setupGalleryView()
        setupUserView()
        setupBodyView()
        setupFooterView()
        setupSocialShareView()
        setupVideoButton()
    }
    
    private func setupVideoButton() {
        view.addSubview(commercialButton)
        commercialButton.translatesAutoresizingMaskIntoConstraints = false
        let top = NSLayoutConstraint(item: commercialButton, attribute: .Top, relatedBy: .Equal, toItem: view,
            attribute: .Top, multiplier: 1, constant: 74)
        let right = NSLayoutConstraint(item: commercialButton, attribute: .Trailing, relatedBy: .Equal, toItem: view,
            attribute: .Trailing, multiplier: 1, constant: -10)
        let height = NSLayoutConstraint(item: commercialButton, attribute: .Height, relatedBy: .Equal, toItem: nil,
            attribute: .NotAnAttribute, multiplier: 1, constant: 32)
        view.addConstraints([top, right, height])
    }

    private func setupNavigationBar() {
        if let navBarUserView = navBarUserView {
            setupUserView(navBarUserView)
            navBarUserView.delegate = self
            navBarUserView.alpha = 0
            navBarUserView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: CGFloat.max, height: 36))
        }

        let backIcon = UIImage(named: "navbar_back_white_shadow")
        setLetGoNavigationBarStyle(navBarUserView, backIcon: backIcon)

        galleryFakeScrollViewTapRecognizer = UITapGestureRecognizer(target: self,
            action: #selector(ProductViewController.openFullScreenGalleryAtCurrentIndex(_:)))
        if let galleryFakeScrollViewTapRecognizer = galleryFakeScrollViewTapRecognizer {
            galleryFakeScrollViewTapRecognizer.numberOfTapsRequired = 1
            galleryFakeScrollView.addGestureRecognizer(galleryFakeScrollViewTapRecognizer)
        }
    }

    private func setupGradientView() {
        let shadowLayer = CAGradientLayer.gradientWithColor(UIColor.blackColor(), alphas:[0.4,0.0],
            locations: [0.0,1.0])
        shadowLayer.frame = shadowGradientView.bounds
        shadowGradientView.layer.insertSublayer(shadowLayer, atIndex: 0)
    }

    private func setupProductStatusView() {
        StyleHelper.applyInfoBubbleShadow(productStatusShadow.layer)
    }

    private func setupGalleryView() {
        galleryView.delegate = self

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
    }

    private func setupUserView() {
        userView = UserView.userView(.Full)
        guard let userView = userView else { return }
        setupUserView(userView)

        userView.translatesAutoresizingMaskIntoConstraints = false
        userView.delegate = self
        mainScrollViewContentView.addSubview(userView)

        let leftMargin = NSLayoutConstraint(item: userView, attribute: .Left, relatedBy: .Equal,
            toItem: galleryFakeScrollView, attribute: .Left, multiplier: 1, constant: 16)
        let rightMargin = NSLayoutConstraint(item: userView, attribute: .Right, relatedBy: .LessThanOrEqual,
            toItem: pageControlContainer, attribute: .Left, multiplier: 1, constant: -32)
        let bottomMargin = NSLayoutConstraint(item: userView, attribute: .Bottom, relatedBy: .Equal,
            toItem: galleryFakeScrollView, attribute: .Bottom, multiplier: 1, constant: -16)
        let height = NSLayoutConstraint(item: userView, attribute: .Height, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: ProductViewController.userViewHeight)

        mainScrollViewContentView.addConstraints([leftMargin, rightMargin, bottomMargin, height])
    }

    private func setupUserView(userView: UserView) {
        userView.setupWith(userAvatar: viewModel.ownerAvatar, userName: viewModel.ownerName, userId: viewModel.ownerId)
    }

    private func setupBodyView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ProductViewController.toggleDescriptionState))
        descriptionCollapsible.textColor = StyleHelper.productDescriptionTextColor
        descriptionCollapsible.addGestureRecognizer(tapGesture)
        descriptionCollapsible.expandText = LGLocalizedString.commonExpand.uppercase
        descriptionCollapsible.collapseText = LGLocalizedString.commonCollapse.uppercase
    }

    private func setupFooterView() {
        askButton.setTitle(LGLocalizedString.productAskAQuestionButton, forState: .Normal)
        askButton.setSecondaryStyle()

        offerButton.setTitle(LGLocalizedString.productMakeAnOfferButton, forState: .Normal)
        offerButton.setPrimaryStyle()

        resellButton.setTitle(LGLocalizedString.productSellAgainButton, forState: .Normal)
        resellButton.setSecondaryStyle()

        markSoldButton.setTitle(LGLocalizedString.productMarkAsSoldButton, forState: .Normal)
        markSoldButton.backgroundColor = StyleHelper.soldColor
        markSoldButton.setCustomButtonStyle()
        markSoldButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        markSoldButton.titleLabel?.font = StyleHelper.defaultButtonFont
        
        promoteButton.setTitle(LGLocalizedString.productCreateCommercialButton, forState: .Normal)
        promoteButton.setPrimaryStyle()
    }
    
    private func setupSocialShareView() {
        shareTitleLabel.text = LGLocalizedString.productShareTitleLabel
        socialShareView.delegate = self
    }
}


// MARK: - UIScrollViewDelegate

extension ProductViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {

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


// MARK: -  UserViewDelegate

extension ProductViewController: UserViewDelegate {
    func userViewAvatarPressed(userView: UserView) {
        viewModel.openProductOwnerProfile()
    }
}
