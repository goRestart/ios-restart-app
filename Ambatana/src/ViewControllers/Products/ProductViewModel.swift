//
//  ProductViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 12/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import CoreLocation
import FBSDKShareKit
import LGCoreKit
import Result
import RxSwift


protocol ProductViewModelDelegate: class, BaseViewModelDelegate {
    func vmShowNativeShare(message: String)

    func vmOpenEditProduct(editProductVM: EditSellProductViewModel)
    func vmOpenMainSignUp(signUpVM: SignUpViewModel, afterLoginAction: () -> ())
    func vmOpenUserVC(userVC: EditProfileViewController)
    func vmOpenChat(chatVM: ChatViewModel)
    func vmOpenOffer(offerVC: MakeAnOfferViewController)

    func vmOpenPromoteProduct(promoteVM: PromoteProductViewModel?)
}

private enum ProductViewModelStatus {
    case Pending
    case Available
    case NotAvailable
    case Sold

    var string: String? {
        switch self {
        case .Sold:
            return LGLocalizedString.productListItemSoldStatusLabel
        case .Pending, .NotAvailable, .Available:
            return nil
        }
    }

    var labelColor: UIColor {
        switch self {
        case .Sold:
            return UIColor.whiteColor()
        case .Pending, .NotAvailable, .Available:
            return UIColor.clearColor()
        }
    }

    var bgColor: UIColor {
        switch self {
        case .Sold:
            return StyleHelper.soldColor
        case .Pending, .NotAvailable, .Available:
            return UIColor.clearColor()
        }
    }
}

class ProductViewModel: BaseViewModel {
    // Data
    private let product: Variable<Product>
    private var commercializer: Variable<Commercializer?>

    let thumbnailImage: UIImage?

    private let status = Variable<ProductViewModelStatus>(.Pending)
    private let isReported = Variable<Bool>(false)
    private let isFavorite = Variable<Bool>(false)
    
    let socialMessage = Variable<SocialMessage?>(nil)

    // Repository & tracker
    private let myUserRepository: MyUserRepository
    private let productRepository: ProductRepository
    private let commercializerRepository: CommercializerRepository
    private let tracker: Tracker

    // Delegate
    weak var delegate: ProductViewModelDelegate?

    // UI
    let navBarButtons = Variable<[UIAction]>([])
    let favoriteButtonEnabled = Variable<Bool>(false)
    let productStatusBackgroundColor = Variable<UIColor>(UIColor.blackColor())
    let productStatusLabelText = Variable<String?>(nil)
    let productStatusLabelColor = Variable<UIColor>(UIColor.whiteColor())

    let productImageURLs = Variable<[NSURL]>([])

    let productTitle = Variable<String?>(nil)
    let productPrice = Variable<String>("")
    let productDescription = Variable<String?>(nil)
    let productAddress = Variable<String?>(nil)
    let productLocation = Variable<LGLocationCoordinates2D?>(nil)

    let ownerId: String?
    let ownerName: String
    let ownerAvatar: NSURL?

    let footerHidden = Variable<Bool>(true)

    let footerOtherSellingHidden = Variable<Bool>(true)
    let footerMeSellingHidden = Variable<Bool>(true)
    let markSoldButtonHidden = Variable<Bool>(true)
    let resellButtonHidden = Variable<Bool>(true)

    let canPromoteProduct = Variable<Bool>(false)
    let productHasCommercializer = Variable<Bool>(false)
    let productHasAvailableTemplates = Variable<Bool>(false)
    
    // Rx
    private let disposeBag: DisposeBag


    // MARK: - Lifecycle

    convenience init(product: Product, thumbnailImage: UIImage?) {
        let myUserRepository = Core.myUserRepository
        let productRepository = Core.productRepository
        let commercializerRepository = Core.commercializerRepository
        let tracker = TrackerProxy.sharedInstance
        self.init(myUserRepository: myUserRepository, productRepository: productRepository,
            commercializerRepository: commercializerRepository, product: product, thumbnailImage: thumbnailImage,
            tracker: tracker)
    }

    init(myUserRepository: MyUserRepository, productRepository: ProductRepository,
        commercializerRepository: CommercializerRepository, product: Product, thumbnailImage: UIImage?,
        tracker: Tracker) {
            self.product = Variable<Product>(product)
            self.thumbnailImage = thumbnailImage
            self.myUserRepository = myUserRepository
            self.productRepository = productRepository
            self.tracker = tracker
            self.commercializerRepository = commercializerRepository
            self.commercializer = Variable<Commercializer?>(nil)
            
            self.ownerId = product.user.objectId
            let myUser = myUserRepository.myUser
            let ownerIsMyUser: Bool
            if let productUserId = product.user.objectId, myUser = myUser, myUserId = myUser.objectId {
                ownerIsMyUser = ( productUserId == myUserId )
            } else {
                ownerIsMyUser = false
            }
            let myUsername = myUser?.name
            let ownerUsername = product.user.name
            self.ownerName = ownerIsMyUser ? (myUsername ?? ownerUsername ?? "") : (ownerUsername ?? "")
            let myAvatarURL = myUser?.avatar?.fileURL
            let ownerAvatarURL = product.user.avatar?.fileURL
            self.ownerAvatar = ownerIsMyUser ? (myAvatarURL ?? ownerAvatarURL) : ownerAvatarURL

            self.disposeBag = DisposeBag()

            super.init()

            trackVisit()
            setupRxBindings()
    }

    internal override func didSetActive(active: Bool) {
        super.didSetActive(active)

        guard active else { return }
        guard let productId = product.value.objectId else { return }

        productRepository.retrieveUserProductRelation(productId) { [weak self] result in
            guard let strongSelf = self else { return }
            if let favorited = result.value?.isFavorited, let reported = result.value?.isReported {
                strongSelf.isFavorite.value = favorited
                strongSelf.isReported.value = reported
            }
        }
        
        commercializerRepository.index(productId) { [weak self] result in
            if let value = result.value, let strongSelf = self {
                self?.productHasCommercializer.value = true
                self?.productHasAvailableTemplates.value = value.count < strongSelf.numberOfCommercializerTemplates()
                
                if  let first = value.first {
                    self?.commercializer = Variable<Commercializer?>(first)
                }
            }
        }
    }
    
    private func numberOfCommercializerTemplates() -> Int {
        guard let countryCode = product.value.postalAddress.countryCode else { return 0 }
        return commercializerRepository.templatesForCountryCode(countryCode).count
    }
    
    private func commercializerIsAvailable() -> Bool {
        return numberOfCommercializerTemplates() > 0
    }

    private func setupRxBindings() {
        status.asObservable().subscribeNext { [weak self] status in
            guard let strongSelf = self else { return }
            strongSelf.productStatusBackgroundColor.value = status.bgColor
            strongSelf.productStatusLabelText.value = status.string
            strongSelf.productStatusLabelColor.value = status.labelColor
        }.addDisposableTo(disposeBag)

        product.asObservable().subscribeNext { [weak self] product in
            guard let strongSelf = self else { return }
            let status = product.productViewModelStatus
            strongSelf.status.value = status
            strongSelf.isFavorite.value = product.favorite
            let socialTitle = LGLocalizedString.productShareBody
            strongSelf.socialMessage.value = SocialHelper.socialMessageWithTitle(socialTitle, product: product)
            strongSelf.navBarButtons.value = strongSelf.buildNavBarButtons()
            strongSelf.productStatusBackgroundColor.value = status.bgColor
            strongSelf.productStatusLabelText.value = status.string
            strongSelf.productStatusLabelColor.value = status.labelColor

            strongSelf.productImageURLs.value = product.images.flatMap { return $0.fileURL }

            strongSelf.productTitle.value = product.name
            strongSelf.productDescription.value = product.descr
            strongSelf.productPrice.value = product.priceString()
            strongSelf.productAddress.value = product.postalAddress.string
            strongSelf.productLocation.value = product.location

            strongSelf.footerOtherSellingHidden.value = product.footerOtherSellingHidden
            strongSelf.markSoldButtonHidden.value = product.markAsSoldButtonHidden
            strongSelf.resellButtonHidden.value = product.resellButtonButtonHidden
            strongSelf.canPromoteProduct.value = product.canBePromoted && strongSelf.commercializerIsAvailable()
            strongSelf.footerMeSellingHidden.value = product.footerMeSellingHidden && !strongSelf.canPromoteProduct.value
            strongSelf.footerHidden.value = product.footerHidden && !strongSelf.canPromoteProduct.value
        }.addDisposableTo(disposeBag)
    }
}


// MARK: - Public actions

extension ProductViewModel {
    func openProductOwnerProfile() {
        // TODO: Refactor to return a view model as soon as UserProfile is refactored to MVVM
        guard let productOwnerId = product.value.user.objectId else { return }

        let userVC = EditProfileViewController(user: product.value.user, source: .ProductDetail)

        // If logged in and i'm not the product owner then open the user profile
        if Core.sessionManager.loggedIn {
            if myUserRepository.myUser?.objectId != productOwnerId {
                delegate?.vmOpenUserVC(userVC)
            }
        } else {
            delegate?.vmOpenUserVC(userVC)
        }
    }

    func openProductLocation() -> UIViewController? {
        // TODO: Refactor to return a view model as soon as ProductLocationViewController is refactored to MVVM
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewControllerWithIdentifier("ProductLocationViewController")
            as? ProductLocationViewController else { return nil }

        let location = product.value.location
        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        vc.location = coordinate
        vc.annotationTitle = product.value.name
        vc.annotationSubtitle = product.value.postalAddress.string
        return vc
    }

    func markSold() {
        ifLoggedInRunActionElseOpenMainSignUp({ [weak self] in

            var alertActions: [UIAction] = []
            let markAsSoldAction = UIAction(interface: .Text(LGLocalizedString.productMarkAsSoldConfirmOkButton),
                action: { [weak self] in
                    self?.markSold(.MarkAsSold)
                })
            alertActions.append(markAsSoldAction)
            self?.delegate?.vmShowAlert( LGLocalizedString.productMarkAsSoldConfirmTitle,
                message: LGLocalizedString.productMarkAsSoldConfirmMessage,
                cancelLabel: LGLocalizedString.productMarkAsSoldConfirmCancelButton,
                actions: alertActions)

            }, source: .MarkAsSold)
    }

    func resell() {
        ifLoggedInRunActionElseOpenMainSignUp({ [weak self] in

            var alertActions: [UIAction] = []
            let sellAgainAction = UIAction(interface: .Text(LGLocalizedString.productSellAgainConfirmOkButton),
                action: { [weak self] in
                    self?.markUnsold()
                })
            alertActions.append(sellAgainAction)
            self?.delegate?.vmShowAlert(LGLocalizedString.productSellAgainConfirmTitle,
                message: LGLocalizedString.productSellAgainConfirmMessage,
                cancelLabel: LGLocalizedString.productSellAgainConfirmCancelButton,
                actions: alertActions)

            }, source: .MarkAsUnsold)
    }

    func ask() {
        ifLoggedInRunActionElseOpenMainSignUp({ [weak self] in
            guard let strongSelf = self else { return }
            guard let chatVM = ChatViewModel(product: strongSelf.product.value) else { return }
            chatVM.askQuestion = .ProductDetail
            strongSelf.delegate?.vmOpenChat(chatVM)
            }, source: .AskQuestion)
    }

    func offer() {
        ifLoggedInRunActionElseOpenMainSignUp({ [weak self] in
            guard let strongSelf = self else { return }

            // TODO: Refactor to return a view model as soon as MakeAnOfferViewController is refactored to MVVM
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let offerVC = storyboard.instantiateViewControllerWithIdentifier("MakeAnOfferViewController")
                as? MakeAnOfferViewController else { return }
            offerVC.product = strongSelf.product.value
            strongSelf.delegate?.vmOpenOffer(offerVC)
            }, source: .MakeOffer)
    }
    
    func openVideo() {
        // TODO: Open Commercializer Video
    }

    func promoteProduct() {
        let theProduct = product.value
        if let countryCode = theProduct.postalAddress.countryCode {
            let themes = commercializerRepository.templatesForCountryCode(countryCode) ?? []
            let promoteProductVM = PromoteProductViewModel(product: theProduct, themes: themes, promotionSource: .ProductSell)
            delegate?.vmOpenPromoteProduct(promoteProductVM)
        }
    }
}


// MARK: - Helper

extension ProductViewModel {
    private func buildNavBarButtons() -> [UIAction] {
        var navBarButtons = [UIAction]()

        let isMine = product.value.isMine
        let isFavouritable = !isMine
        let isEditable: Bool
        let isShareable = true
        let isReportable = !isMine
        let isDeletable: Bool
        switch status.value {
        case .Pending:
            isEditable = isMine
            isDeletable = isMine
        case .Available:
            isEditable = isMine
            isDeletable = isMine
        case .NotAvailable:
            isEditable = false
            isDeletable = false
        case .Sold:
            isEditable = false
            isDeletable = isMine
        }

        if isFavouritable {
            navBarButtons.append(buildFavoriteNavBarAction())
        }
        if isEditable {
            navBarButtons.append(buildEditNavBarAction())
        }
        if isShareable {
            navBarButtons.append(buildShareNavBarAction())
        }

        let hasMoreActions = isReportable || isDeletable
        if hasMoreActions {
            navBarButtons.append(buildMoreNavBarAction(isReportable, isDeletable: isDeletable))
        }
        return navBarButtons
    }

    private func buildFavoriteNavBarAction() -> UIAction {
        let icon = UIImage(named: isFavorite.value ? "navbar_fav_on" : "navbar_fav_off")?
            .imageWithRenderingMode(.AlwaysOriginal)
        return UIAction(interface: .Image(icon), action: { [weak self] in
            self?.ifLoggedInRunActionElseOpenMainSignUp({ [weak self] in
                self?.switchFavourite()
            }, source: .Favourite)
        })
    }

    private func buildEditNavBarAction() -> UIAction {
        let icon = UIImage(named: "navbar_edit")?.imageWithRenderingMode(.AlwaysOriginal)
        return UIAction(interface: .Image(icon), action: { [weak self] in
            guard let strongSelf = self else { return }
            let editProductVM = EditSellProductViewModel(product: strongSelf.product.value)
            strongSelf.delegate?.vmOpenEditProduct(editProductVM)
        })
    }

    private func buildShareNavBarAction() -> UIAction {
        let icon = UIImage(named: "navbar_share")?.imageWithRenderingMode(.AlwaysOriginal)
        return UIAction(interface: .Image(icon), action: { [weak self] in
            guard let strongSelf = self, socialMessage = strongSelf.socialMessage.value else { return }
            strongSelf.delegate?.vmShowNativeShare(socialMessage.shareText)
        })
    }

    private func buildMoreNavBarAction(isReportable: Bool, isDeletable: Bool) -> UIAction {
        let icon = UIImage(named: "navbar_more")?.imageWithRenderingMode(.AlwaysOriginal)
        return UIAction(interface: .Image(icon), action: { [weak self] in
            guard let strongSelf = self else { return }

            var actions = [UIAction]()
            if isReportable {
                actions.append(strongSelf.buildReportButton())
            }
            if isDeletable {
                actions.append(strongSelf.buildDeleteButton())
            }
            strongSelf.delegate?.vmShowActionSheet(LGLocalizedString.commonCancel, actions: actions)
        })
    }

    private func buildReportButton() -> UIAction {
        let title = LGLocalizedString.productReportProductButton
        return UIAction(interface: .Text(title), action: { [weak self] in
            self?.ifLoggedInRunActionElseOpenMainSignUp({ [weak self] () -> () in
                guard let strongSelf = self else { return }

                let alertOKAction = UIAction(interface: .Text(LGLocalizedString.commonYes), action: { [weak self] in
                    self?.ifLoggedInRunActionElseOpenMainSignUp({ [weak self] in
                        self?.report()
                        }, source: .ReportFraud)
                    })
                strongSelf.delegate?.vmShowAlert(LGLocalizedString.productReportConfirmTitle,
                    message: LGLocalizedString.productReportConfirmMessage,
                    cancelLabel: LGLocalizedString.commonNo,
                    actions: [alertOKAction])
            }, source: .ReportFraud)
        })
    }

    private func buildDeleteButton() -> UIAction {
        let title = LGLocalizedString.productDeleteConfirmTitle
        return UIAction(interface: .Text(title), action: { [weak self] in
            guard let strongSelf = self else { return }

            let message: String
            var alertActions = [UIAction]()
            if strongSelf.suggestMarkSoldWhenDeleting {
                message = LGLocalizedString.productDeleteConfirmMessage

                let soldAction = UIAction(interface: .Text(LGLocalizedString.productDeleteConfirmSoldButton),
                    action: { [weak self] in
                        self?.markSold(.Delete)
                    })
                alertActions.append(soldAction)

                let deleteAction = UIAction(interface: .Text(LGLocalizedString.productDeleteConfirmOkButton),
                    action: { [weak self] in
                        self?.delete()
                    })
                alertActions.append(deleteAction)
            } else {
                message = LGLocalizedString.productDeleteSoldConfirmMessage

                let deleteAction = UIAction(interface: .Text(LGLocalizedString.commonOk),
                    action: { [weak self] in
                        self?.delete()
                    })
                alertActions.append(deleteAction)
            }

            strongSelf.delegate?.vmShowAlert(LGLocalizedString.productDeleteConfirmTitle, message: message,
                cancelLabel: LGLocalizedString.productDeleteConfirmCancelButton,
                actions: alertActions)
        })
    }

    private var socialShareMessage: SocialMessage {
        let title = LGLocalizedString.productShareBody
        return SocialHelper.socialMessageWithTitle(title, product: product.value)
    }

    private var suggestMarkSoldWhenDeleting: Bool {
        switch product.value.status {
        case .Pending, .Discarded, .Sold, .SoldOld, .Deleted:
            return false
        case .Approved:
            return true
        }
    }
}


// MARK: - Private actions

extension ProductViewModel {
    private func switchFavourite() {
        favoriteButtonEnabled.value = false

        if isFavorite.value {
            productRepository.deleteFavorite(product.value) { [weak self] result in
                guard let strongSelf = self else { return }
                if let product = result.value {
                    strongSelf.product.value = product
                    strongSelf.isFavorite.value = product.favorite
                }
                strongSelf.favoriteButtonEnabled.value = true
            }
        } else {
            productRepository.saveFavorite(product.value) { [weak self] result in
                guard let strongSelf = self else { return }
                if let product = result.value {
                    strongSelf.product.value = product
                    strongSelf.isFavorite.value = product.favorite
                    self?.trackSaveFavoriteCompleted()
                }
                strongSelf.favoriteButtonEnabled.value = true
            }
        }
    }

    private func report() {
        if isReported.value {
            delegate?.vmHideLoading(LGLocalizedString.productReportedSuccessMessage, afterMessageCompletion: nil)
            return
        }
        delegate?.vmShowLoading(LGLocalizedString.productReportingLoadingMessage)

        productRepository.saveReport(product.value) { [weak self] result in
            guard let strongSelf = self else { return }

            var message: String? = nil
            if let _ = result.value {
                strongSelf.isReported.value = true
                message = LGLocalizedString.productReportedSuccessMessage
                self?.trackReportCompleted()
            } else if let _ = result.error {
                message = LGLocalizedString.productReportedErrorGeneric
            }
            strongSelf.delegate?.vmHideLoading(message, afterMessageCompletion: nil)
        }
    }

    private func delete() {
        delegate?.vmShowLoading(LGLocalizedString.commonLoading)
        trackDeleteStarted()

        productRepository.delete(product.value) { [weak self] result in
            guard let strongSelf = self else { return }

            var message: String? = nil
            if let value = result.value {
                strongSelf.product.value = value
                message = LGLocalizedString.productDeleteSuccessMessage
                self?.trackDeleteCompleted()
            } else if let _ = result.error {
                message = LGLocalizedString.productDeleteSendErrorGeneric
            }
            strongSelf.delegate?.vmHideLoading(message, afterMessageCompletion: { () -> () in
                strongSelf.delegate?.vmPop()
            })
        }
    }

    private func markSold(source: EventParameterSellSourceValue) {
        delegate?.vmShowLoading(nil)

        productRepository.markProductAsSold(product.value) { [weak self] result in
            guard let strongSelf = self else { return }

            let message: String
            if let value = result.value {
                strongSelf.product.value = value
                message = LGLocalizedString.productMarkAsSoldSuccessMessage
                self?.trackMarkSoldCompleted(source)
            } else {
                message = LGLocalizedString.productMarkAsSoldErrorGeneric
            }
            strongSelf.delegate?.vmHideLoading(message, afterMessageCompletion: nil)
        }
    }

    private func markUnsold() {
        delegate?.vmShowLoading(nil)

        productRepository.markProductAsUnsold(product.value) { [weak self] result in
            guard let strongSelf = self else { return }

            let message: String
            if let value = result.value {
                strongSelf.product.value = value
                message = LGLocalizedString.productSellAgainSuccessMessage
                self?.trackMarkUnsoldCompleted()
            } else {
                message = LGLocalizedString.productSellAgainErrorGeneric
            }
            strongSelf.delegate?.vmHideLoading(message, afterMessageCompletion: nil)
        }
    }
}


// MARK: - UpdateDetailInfoDelegate

extension ProductViewModel: UpdateDetailInfoDelegate {

    func updateDetailInfo(viewModel: EditSellProductViewModel, withSavedProduct savedProduct: Product) {
        product.value = savedProduct
    }
}

extension ProductViewModel {
    private func ifLoggedInRunActionElseOpenMainSignUp(action: () -> (), source: EventParameterLoginSourceValue) {
        if Core.sessionManager.loggedIn {
            action()
        } else {
            let signUpVM = SignUpViewModel(source: source)
            delegate?.vmOpenMainSignUp(signUpVM, afterLoginAction: { action() })
        }
    }
}


// MARK: - Share

extension ProductViewModel {
    func shareInEmail(buttonPosition: EventParameterButtonPosition) {
        let trackerEvent = TrackerEvent.productShare(product.value, network: .Email,
            buttonPosition: buttonPosition, typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInFacebook(buttonPosition: EventParameterButtonPosition) {
        let trackerEvent = TrackerEvent.productShare(product.value, network: .Facebook,
            buttonPosition: buttonPosition, typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInFBCompleted() {
        let trackerEvent = TrackerEvent.productShareComplete(product.value, network: .Facebook,
            typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInFBCancelled() {
        let trackerEvent = TrackerEvent.productShareCancel(product.value, network: .Facebook, typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInFBMessenger() {
        let trackerEvent = TrackerEvent.productShare(product.value, network: .FBMessenger, buttonPosition: .Bottom,
            typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInFBMessengerCompleted() {
        let trackerEvent = TrackerEvent.productShareComplete(product.value, network: .FBMessenger,
            typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInFBMessengerCancelled() {
        let trackerEvent = TrackerEvent.productShareCancel(product.value, network: .FBMessenger,
            typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInWhatsApp() {
        let trackerEvent = TrackerEvent.productShare(product.value, network: .Whatsapp, buttonPosition: .Bottom,
            typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInWhatsappActivity() {
        let trackerEvent = TrackerEvent.productShare(product.value, network: .Whatsapp, buttonPosition: .Top,
            typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInTwitterActivity() {
        let trackerEvent = TrackerEvent.productShare(product.value, network: .Twitter, buttonPosition: .Top,
            typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }
}


// MARK: - Tracking

extension ProductViewModel {
    private func trackVisit() {
        let trackerEvent = TrackerEvent.productDetailVisit(product.value)
        tracker.trackEvent(trackerEvent)
    }

    private func trackReportCompleted() {
        let trackerEvent = TrackerEvent.productReport(product.value)
        tracker.trackEvent(trackerEvent)
    }

    private func trackDeleteStarted() {
        let trackerEvent = TrackerEvent.productDeleteStart(product.value)
        tracker.trackEvent(trackerEvent)
    }

    private func trackDeleteCompleted() {
        let trackerEvent = TrackerEvent.productDeleteComplete(product.value)
        tracker.trackEvent(trackerEvent)
    }

    private func trackMarkSoldCompleted(source: EventParameterSellSourceValue) {
        let trackerEvent = TrackerEvent.productMarkAsSold(source, product: product.value)
        tracker.trackEvent(trackerEvent)
    }

    private func trackMarkUnsoldCompleted() {
        let trackerEvent = TrackerEvent.productMarkAsUnsold(product.value)
        tracker.trackEvent(trackerEvent)
    }

    private func trackSaveFavoriteCompleted() {
        let trackerEvent = TrackerEvent.productFavorite(product.value, typePage: .ProductDetail)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
}


// MARK : - Product

extension Product {
    private var productViewModelStatus: ProductViewModelStatus {
        switch status {
        case .Pending:
            return .Pending
        case .Discarded, .Deleted:
            return .NotAvailable
        case .Approved:
            return .Available
        case .Sold, .SoldOld:
            return .Sold
        }
    }

    private var footerHidden: Bool {
        return footerOtherSellingHidden && footerMeSellingHidden
    }

    private var isMine: Bool {
        let myUserId = Core.myUserRepository.myUser?.objectId
        let ownerId = user.objectId
        guard user.objectId != nil && myUserId != nil else { return false }
        return ownerId == myUserId
    }
    private var footerOtherSellingHidden: Bool {
        switch productViewModelStatus {
        case .Pending, .NotAvailable, .Sold:
            return true
        case .Available:
            return isMine
        }
    }

    private var footerMeSellingHidden: Bool {
        return markAsSoldButtonHidden && resellButtonButtonHidden
    }

    private var markAsSoldButtonHidden: Bool {
        guard isMine else { return true }
        switch productViewModelStatus {
        case .Pending, .NotAvailable, .Sold:
            return true
        case .Available:
            return false
        }
    }

    private var resellButtonButtonHidden: Bool {
        guard isMine else { return true }
        switch productViewModelStatus {
        case .Pending, .Available, .NotAvailable:
            return true
        case .Sold:
            return false
        }
    }
    
    private var canBePromoted: Bool {
        guard isMine else { return false }
        switch productViewModelStatus {
        case .Available, .Pending:
            return true
        case .NotAvailable, .Sold:
            return false
        }
    }
}
