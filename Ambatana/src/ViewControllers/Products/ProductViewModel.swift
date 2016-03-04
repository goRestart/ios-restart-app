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


public struct TitleAction {
    let title: String
    let action: () -> ()
}

protocol ProductViewModelDelegate: class {
    func vmShowLoading(loadingMessage: String?)
    func vmHideLoading(finishedMessage: String?)

    func vmShowAlert(title: String?, message: String?, cancelLabel: String, actions: [TitleAction])
    func vmShowActionSheet(cancelLabel: String, actions: [TitleAction])
    func vmShowNativeShare(message: String)

    func vmOpenEditProduct(editProductVM: EditSellProductViewModel)
    func vmOpenMainSignUp(signUpVM: SignUpViewModel, afterLoginAction: () -> ())
    func vmOpenUserVC(userVC: EditProfileViewController)
    func vmOpenChat(chatVM: ChatViewModel)
    func vmOpenOffer(offerVC: MakeAnOfferViewController)
}

struct NavBarButton {
    let icon: UIImage?
    let action: () -> ()
}

private enum Status {
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
    private let status: Variable<Status>
    private let product: Variable<Product>
    let thumbnailImage : UIImage?
    let isReported: Variable<Bool>
    let isFavorite: Variable<Bool>
    let socialMessage: Variable<SocialMessage>

    // Repository & tracker
    private let myUserRepository: MyUserRepository
    private let productRepository: ProductRepository
    private let tracker: Tracker

    // Delegate
    weak var delegate: ProductViewModelDelegate?

    // UI
    let navBarButtons: Variable<[NavBarButton]>
    let favoriteButtonEnabled: Variable<Bool>
    let productStatusBackgroundColor: Variable<UIColor>
    let productStatusLabelText: Variable<String?>
    let productStatusLabelColor: Variable<UIColor>

    let productImageURLs: Variable<[NSURL]>

    let productTitle: Variable<String?>
    let productPrice: Variable<String>
    let productDescription: Variable<String?>
    let productAddress: Variable<String?>
    let productLocation: Variable<LGLocationCoordinates2D?>

    let ownerId: String?
    let ownerName: String
    let ownerAvatar: NSURL?

    let footerHidden: Variable<Bool>

    let footerOtherSellingHidden: Variable<Bool>
    let footerMeSellingHidden: Variable<Bool>
    let markSoldButtonHidden: Variable<Bool>
    let resellButtonHidden: Variable<Bool>

    // Rx
    private let disposeBag: DisposeBag


    // MARK: - Lifecycle

    private static func getStatus(product: Product) -> Status {
        let status: Status
        switch product.status {
        case .Pending:
            status = .Pending
        case .Discarded, .Deleted:
            status = .NotAvailable
        case .Approved:
            status = .Available
        case .Sold, .SoldOld:
            status = .Sold
        }
        return status
    }

    convenience init(product: Product, thumbnailImage: UIImage?) {
        let myUserRepository = Core.myUserRepository
        let productRepository = Core.productRepository
        let tracker = TrackerProxy.sharedInstance
        self.init(myUserRepository: myUserRepository, productRepository: productRepository,
            product: product, thumbnailImage: thumbnailImage, tracker: tracker)
    }

    init(myUserRepository: MyUserRepository, productRepository: ProductRepository,
        product: Product, thumbnailImage: UIImage?, tracker: Tracker) {
            let status = ProductViewModel.getStatus(product)
            self.status = Variable<Status>(status)
            self.product = Variable<Product>(product)
            self.thumbnailImage = thumbnailImage
            self.isReported = Variable<Bool>(false)
            self.isFavorite = Variable<Bool>(product.favorite)
            let socialTitle = LGLocalizedString.productShareBody
            self.socialMessage = Variable<SocialMessage>(SocialHelper.socialMessageWithTitle(socialTitle,
                product: product))

            self.myUserRepository = myUserRepository
            self.productRepository = productRepository
            self.tracker = tracker

            self.navBarButtons = Variable<[NavBarButton]>([])
            self.favoriteButtonEnabled = Variable<Bool>(false)
            self.productStatusBackgroundColor = Variable<UIColor>(status.bgColor)
            self.productStatusLabelText = Variable<String?>(status.string)
            self.productStatusLabelColor = Variable<UIColor>(status.labelColor)

            self.productImageURLs = Variable<[NSURL]>(product.images.flatMap { return $0.fileURL })

            self.productTitle = Variable<String?>(product.name)
            self.productPrice = Variable<String>(product.priceString())
            self.productDescription = Variable<String?>(product.descr)
            self.productAddress = Variable<String?>(product.postalAddress.string)
            self.productLocation = Variable<LGLocationCoordinates2D?>(product.location)

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

            // TODO: Ojo!
            self.footerHidden = Variable<Bool>(false)

            self.footerOtherSellingHidden = Variable<Bool>(false)
            self.footerMeSellingHidden = Variable<Bool>(false)
            self.markSoldButtonHidden = Variable<Bool>(false)
            self.resellButtonHidden = Variable<Bool>(false)

            self.disposeBag = DisposeBag()

            super.init()

            // Tracking
            let trackerEvent = TrackerEvent.productDetailVisit(product, user: myUser)
            tracker.trackEvent(trackerEvent)

            setupBindings()
    }


    // MARK: - Public methods

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

    // TODO: Refactor to return a view model as soon as ProductLocationViewController is refactored to MVVM
    func openProductLocation() -> UIViewController? {
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
            self?.markSold(.MarkAsSold)
        }, source: .MarkAsSold)
    }

    func resell() {
        ifLoggedInRunActionElseOpenMainSignUp({ [weak self] in
            self?.markUnsold()
        }, source: .MarkAsUnsold)
    }

    func ask() {
        ifLoggedInRunActionElseOpenMainSignUp({ [weak self] in
            guard let strongSelf = self else { return }
            guard let chatVM = ChatViewModel(product: strongSelf.product.value) else { return }
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

    private func setupBindings() {
        product.asObservable().subscribeNext { [weak self] product in
            guard let strongSelf = self else { return }

            let status = ProductViewModel.getStatus(product)
            strongSelf.status.value = status
            let socialTitle = LGLocalizedString.productShareBody
            strongSelf.socialMessage.value = SocialHelper.socialMessageWithTitle(socialTitle, product: product)
            strongSelf.isFavorite.value = product.favorite
            strongSelf.navBarButtons.value = strongSelf.buildNavBarButtons()
            strongSelf.productStatusBackgroundColor.value = status.bgColor
            strongSelf.productStatusLabelText.value = status.string
            strongSelf.productStatusLabelColor.value = status.labelColor
            strongSelf.productTitle.value = product.name
            strongSelf.productDescription.value = product.descr
            strongSelf.productPrice.value = product.priceString()
            strongSelf.productAddress.value = product.postalAddress.string
            strongSelf.productLocation.value = product.location
//
//            self.ownerId = product.user.objectId
//
//            let myUser = myUserRepository.myUser
//            let ownerIsMyUser: Bool
//            if let productUserId = product.user.objectId, myUser = myUser, myUserId = myUser.objectId {
//                ownerIsMyUser = ( productUserId == myUserId )
//            } else {
//                ownerIsMyUser = false
//            }
//            let myUsername = myUser?.name
//            let ownerUsername = product.user.name
//            self.ownerName = ownerIsMyUser ? (myUsername ?? ownerUsername ?? "") : (ownerUsername ?? "")
//
//            let myAvatarURL = myUser?.avatar?.fileURL
//            let ownerAvatarURL = product.user.avatar?.fileURL
//            self.ownerAvatar = ownerIsMyUser ? (myAvatarURL ?? ownerAvatarURL) : ownerAvatarURL
        }.addDisposableTo(disposeBag)
    }

    // MARK: > Helper

    private var isMine: Bool {
        let myUserId = myUserRepository.myUser?.objectId
        guard ownerId != nil && myUserId != nil else { return false }
        return ownerId == myUserRepository.myUser?.objectId
    }

    private var socialShareMessage: SocialMessage {
        let title = LGLocalizedString.productShareBody
        return SocialHelper.socialMessageWithTitle(title, product: product.value)
    }

    var suggestMarkSoldWhenDeleting: Bool {
        switch product.value.status {
        case .Pending, .Discarded, .Sold, .SoldOld, .Deleted:
            return false
        case .Approved:
            return true
        }
    }

    // MARK: > Navigation bar

    private func buildNavBarButtons() -> [NavBarButton] {
        var navBarButtons = [NavBarButton]()

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
            isDeletable = isMine
        case .Sold:
            isEditable = false
            isDeletable = isMine
        }

        if isFavouritable {
            let icon = UIImage(named: isFavorite.value ? "navbar_fav_on" : "navbar_fav_off")?
                .imageWithRenderingMode(.AlwaysOriginal)
            let button = NavBarButton(icon: icon, action: { [weak self] in
                self?.ifLoggedInRunActionElseOpenMainSignUp({ [weak self] in
                    self?.switchFavourite()
                }, source: .Favourite)
            })
            navBarButtons.append(button)
        }
        if isEditable {
            let icon = UIImage(named: "navbar_edit")?.imageWithRenderingMode(.AlwaysOriginal)
            let button = NavBarButton(icon: icon, action: { [weak self] in
                guard let strongSelf = self else { return }
                let editProductVM = EditSellProductViewModel(product: strongSelf.product.value)
                strongSelf.delegate?.vmOpenEditProduct(editProductVM)
            })
            navBarButtons.append(button)
        }
        if isShareable {
            let icon = UIImage(named: "navbar_share")?.imageWithRenderingMode(.AlwaysOriginal)
            let button = NavBarButton(icon: icon, action: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.vmShowNativeShare(strongSelf.socialMessage.value.shareText)
            })
            navBarButtons.append(button)
        }

        let hasMoreActions = isReportable || isDeletable
        if hasMoreActions {
            let icon = UIImage(named: "navbar_more")?.imageWithRenderingMode(.AlwaysOriginal)
            let button = NavBarButton(icon: icon, action: { [weak self] in
                guard let strongSelf = self else { return }

                var actions = [TitleAction]()
                if isReportable {
                    let title = LGLocalizedString.productReportProductButton
                    let action = TitleAction(title: title, action: { () -> () in
                        strongSelf.ifLoggedInRunActionElseOpenMainSignUp({ () -> () in
                            let alertOKAction = TitleAction(title: LGLocalizedString.commonYes, action: { [weak self] in
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
                    actions.append(action)
                }
                if isDeletable {
                    let title = LGLocalizedString.productDeleteConfirmTitle
                    let action = TitleAction(title: title, action: { [weak self] in

                        var alertActions = [TitleAction]()
                        if strongSelf.suggestMarkSoldWhenDeleting {
                            let soldAction = TitleAction(title: LGLocalizedString.productDeleteConfirmSoldButton,
                                action: { [weak self] in
                                    self?.markSold(.Delete)
                                })
                            alertActions.append(soldAction)

                            let deleteAction = TitleAction(title: LGLocalizedString.productDeleteConfirmOkButton,
                                action: { [weak self] in
                                    self?.delete()
                                })
                            alertActions.append(deleteAction)
                        } else {
                            let deleteAction = TitleAction(title: LGLocalizedString.commonOk,
                                action: { [weak self] in
                                    self?.delete()
                                })
                            alertActions.append(deleteAction)
                        }

                        strongSelf.delegate?.vmShowAlert(LGLocalizedString.productDeleteConfirmTitle,
                            message: LGLocalizedString.productDeleteConfirmMessage,
                            cancelLabel: LGLocalizedString.productDeleteConfirmCancelButton,
                            actions: alertActions)
                        })
                    actions.append(action)
                }
                strongSelf.delegate?.vmShowActionSheet(LGLocalizedString.commonCancel, actions: actions)
            })
            navBarButtons.append(button)
        }
        return navBarButtons
    }

//    
//    public init(myUserRepository: MyUserRepository, productRepository: ProductRepository,
//        product: Product, thumbnailImage: UIImage?, tracker: Tracker) {
//            ...
//            // Tracking
//            let myUser = myUserRepository.myUser
//            let trackerEvent = TrackerEvent.productDetailVisit(product, user: myUser)
//            tracker.trackEvent(trackerEvent)
//    }
//    
//    internal override func didSetActive(active: Bool) {
//        guard active else { return }
//        guard let productId = product.objectId else { return }
//
//        delegate?.viewModelDidStartRetrievingUserProductRelation(self)
//        productRepository.retrieveUserProductRelation(productId) { [weak self] result in
//            guard let strongSelf = self else { return }
//            if let favorited = result.value?.isFavorited, let reported = result.value?.isReported {
//                strongSelf.isFavourite = favorited
//                strongSelf.isReported = reported
//            }
//            strongSelf.delegate?.viewModelDidUpdateIsFavourite(strongSelf)
//            strongSelf.delegate?.viewModelDidUpdateIsReported(strongSelf)
//        }
//    }
//    
//    // MARK: - Public methods
//    
//    // MARK: > Favourite
//    
//
//    // MARK: > Gallery
//    
//    public func imageURLAtIndex(index: Int) -> NSURL? {
//        return product.images[index].fileURL
//    }
//    
//    public func imageTokenAtIndex(index: Int) -> String? {
//        return product.images[index].objectId
//    }
//    
//    
//    // MARK: > Share
//
//    public func reportStarted() {
//        let trackerEvent = TrackerEvent.productReport(product, user: myUserRepository.myUser)
//        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
//    }
//
//    public func deleteStarted() {
//        // Tracking
//        let myUser = myUserRepository.myUser
//        let trackerEvent = TrackerEvent.productDeleteStart(product, user: myUser)
//        tracker.trackEvent(trackerEvent)
//    }
//
//    public func markSold(source: EventParameterSellSourceValue) {
//        delegate?.viewModelDidStartMarkingAsSold(self)
//        productRepository.markProductAsSold(product) { [weak self] result in
//            guard let strongSelf = self else { return }
//            if let value = result.value {
//                strongSelf.product = value
//                strongSelf.markSoldCompleted(value, source: source)
//            }
//            strongSelf.delegate?.viewModel(strongSelf, didFinishMarkingAsSold: result)
//        }
//    }
//
//    // MARK: - Private methods
//    
//    private func reportCompleted() {
//        delegate?.viewModelDidCompleteReporting(self)
//    }
//    
//    private func markSoldCompleted(soldProduct: Product, source: EventParameterSellSourceValue) {
//        // Tracking
//        let trackerEvent = TrackerEvent.productMarkAsSold(source, product: soldProduct, user: myUserRepository.myUser)
//        tracker.trackEvent(trackerEvent)
//        
//    }
//    
//    private func markUnsoldCompleted(unsoldProduct: Product) {
//        // Tracking
//        let trackerEvent = TrackerEvent.productMarkAsUnsold(unsoldProduct, user: myUserRepository.myUser)
//        tracker.trackEvent(trackerEvent)
//        
//    }
//    private func deleteCompleted() {
//        // Tracking
//        let trackerEvent = TrackerEvent.productDeleteComplete(product, user: myUserRepository.myUser)
//        tracker.trackEvent(trackerEvent)
//    }
//    
//    private func saveFavoriteCompleted() {
//        let trackerEvent = TrackerEvent.productFavorite(self.product, user: myUserRepository.myUser,
//            typePage: .ProductDetail)
//        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
//    }
}

// MARK: - Actions

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
                }
                strongSelf.favoriteButtonEnabled.value = true
            }
        }
    }

    private func report() {
        if isReported.value {
            delegate?.vmHideLoading(LGLocalizedString.productReportedSuccessMessage)
            return
        }
        delegate?.vmShowLoading(LGLocalizedString.productReportingLoadingMessage)

        productRepository.saveReport(product.value) { [weak self] result in
            guard let strongSelf = self else { return }

            var message: String? = nil
            if let _ = result.value {
                strongSelf.isReported.value = true
                message = LGLocalizedString.productReportedSuccessMessage
            } else if let _ = result.error {
                message = LGLocalizedString.productReportedErrorGeneric
            }
            strongSelf.delegate?.vmHideLoading(message)
        }
    }

    private func delete() {
        delegate?.vmShowLoading(LGLocalizedString.productReportingLoadingMessage)

        productRepository.delete(product.value) { [weak self] result in
            guard let strongSelf = self else { return }

            var message: String? = nil
            if let value = result.value {
                strongSelf.product.value = value
                message = LGLocalizedString.productDeleteSuccessMessage
            } else if let _ = result.error {
                message = LGLocalizedString.productDeleteSendErrorGeneric
            }
            strongSelf.delegate?.vmHideLoading(message)
        }
    }

    private func markSold(source: EventParameterSellSourceValue) {
        delegate?.vmShowLoading(nil)

        productRepository.markProductAsSold(product.value) { [weak self] result in
            guard let strongSelf = self else { return }

            let message: String
            if let value = result.value {
                strongSelf.product.value = value
                message = LGLocalizedString.productMarkAsSoldErrorGeneric
            } else {
                message = LGLocalizedString.productMarkAsSoldSuccessMessage
            }
            strongSelf.delegate?.vmHideLoading(message)
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
            } else {
                message = LGLocalizedString.productSellAgainErrorGeneric
            }
            strongSelf.delegate?.vmHideLoading(message)
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
        let trackerEvent = TrackerEvent.productShare(product.value, user: myUserRepository.myUser, network: .Email,
            buttonPosition: buttonPosition, typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInFacebook(buttonPosition: EventParameterButtonPosition) {
        let trackerEvent = TrackerEvent.productShare(product.value, user: myUserRepository.myUser, network: .Facebook,
            buttonPosition: buttonPosition, typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInFBCompleted() {
        let trackerEvent = TrackerEvent.productShareComplete(product.value, user: myUserRepository.myUser,
            network: .Facebook, typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInFBCancelled() {
        let trackerEvent = TrackerEvent.productShareCancel(product.value, user: myUserRepository.myUser,
            network: .Facebook, typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInFBMessenger() {
        let trackerEvent = TrackerEvent.productShare(product.value, user: myUserRepository.myUser,
            network: .FBMessenger, buttonPosition: .Bottom, typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInFBMessengerCompleted() {
        let trackerEvent = TrackerEvent.productShareComplete(product.value, user: myUserRepository.myUser,
            network: .FBMessenger, typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInFBMessengerCancelled() {
        let trackerEvent = TrackerEvent.productShareCancel(product.value, user: myUserRepository.myUser,
            network: .FBMessenger, typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInWhatsApp() {
        let trackerEvent = TrackerEvent.productShare(product.value, user: myUserRepository.myUser, network: .Whatsapp,
            buttonPosition: .Bottom, typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInWhatsappActivity() {
        let trackerEvent = TrackerEvent.productShare(product.value, user: myUserRepository.myUser, network: .Whatsapp,
            buttonPosition: .Top, typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInTwitterActivity() {
        let trackerEvent = TrackerEvent.productShare(product.value, user: myUserRepository.myUser, network: .Twitter,
            buttonPosition: .Top, typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }
}

