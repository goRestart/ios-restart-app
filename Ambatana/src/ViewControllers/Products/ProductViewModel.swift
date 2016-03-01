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

public protocol ProductViewModelDelegate: class {
    
    func viewModelDidUpdate(viewModel: ProductViewModel)
    
    func viewModelDidStartSwitchingFavouriting(viewModel: ProductViewModel)
    func viewModelDidUpdateIsFavourite(viewModel: ProductViewModel)

    func viewModelDidStartRetrievingUserProductRelation(viewModel: ProductViewModel)

    func viewModelShowReportAlert(viewModel: ProductViewModel)
    func viewModelDidStartReporting(viewModel: ProductViewModel)
    func viewModelDidUpdateIsReported(viewModel: ProductViewModel)
    func viewModelDidCompleteReporting(viewModel: ProductViewModel)
    func viewModelDidFailReporting(viewModel: ProductViewModel, error: RepositoryError)

    func viewModelShowDeleteAlert(viewModel: ProductViewModel)
    func viewModelDidStartDeleting(viewModel: ProductViewModel)
    func viewModel(viewModel: ProductViewModel, didFinishDeleting result: ProductResult)
    
    func viewModelDidStartMarkingAsSold(viewModel: ProductViewModel)
    func viewModel(viewModel: ProductViewModel, didFinishMarkingAsSold result: ProductResult)

    func viewModelDidStartMarkingAsUnsold(viewModel: ProductViewModel)
    func viewModel(viewModel: ProductViewModel, didFinishMarkingAsUnsold result: ProductResult)

    func viewModel(viewModel: ProductViewModel, didFinishAsking chatVM: ChatViewModel)
}


public class ProductViewModel: BaseViewModel, UpdateDetailInfoDelegate {

    // Output
    // > Product
    public var name: String {
        return product.name?.lg_capitalizedWords() ?? ""
    }
    public var price: String {
        return product.priceString()
    }
    public var descr: String {
        return product.descr ?? ""
    }
    public var addressIconVisible: Bool {
        return !address.isEmpty
    }
    public var address: String {
        var address = ""
        if let city = product.postalAddress.city {
            if !city.isEmpty {
                address += city.lg_capitalizedWord()
            }
        }
        if let zipCode = product.postalAddress.zipCode {
            if !zipCode.isEmpty {
                if !address.isEmpty {
                    address += ", "
                }
                address += zipCode
            }
        }
        return address.lg_capitalizedWord()
    }
    public var location: LGLocationCoordinates2D? {
        return product.location
    }
    public let thumbnailImage : UIImage?
    
    // > User
    public var userName: String {
        if isMine {
            return myUserRepository.myUser?.name ?? product.user.name ?? ""
        }
        return product.user.name ?? ""
    }
    public var userAvatar: NSURL? {
        if isMine {
            return myUserRepository.myUser?.avatar?.fileURL ?? product.user.avatar?.fileURL
        }
        return product.user.avatar?.fileURL
    }
    public var userID: String? {
        if isMine {
            return myUserRepository.myUser?.objectId
        }
        return product.user.objectId
    }
    
    // > My User
    public private(set) var isFavourite: Bool
    public private(set) var isReported: Bool
    public private(set) var isMine: Bool

    public var shareSocialMessage: SocialMessage {
        let title = LGLocalizedString.productShareBody
        return SocialHelper.socialMessageWithTitle(title, product: product)
    }

    // Delegate
    public weak var delegate: ProductViewModelDelegate?
    
    // Data
    private var product: Product
    
    // Repository & Manager
    private let myUserRepository: MyUserRepository
    private let productRepository: ProductRepository
    private let tracker: Tracker
    
    // MARK: - Computed iVars
    
    private var isOnSale: Bool {
        switch product.status {
        case .Pending, .Approved, .Discarded:
            return true
            
        case .Deleted, .Sold, .SoldOld:
            return false
        }
    }
    
    public var isEditable: Bool {
        // It's editable when the product is mine and is on sale
        return isMine && isOnSale
    }

    public var editViewModelWithDelegate: EditSellProductViewModel {
        return EditSellProductViewModel(product: product)
    }
    
    public var isFavorite: Bool {
        return product.favorite
    }
    
    public var isFavouritable: Bool {
        return !isMine
    }
    
    public var isShareable: Bool {
        return isOnSale
    }

    public var isDeletable: Bool {
        return isMine
    }

    public var isReportable: Bool {
        return !isMine
    }

    public var hasMoreActions: Bool {
        return !moreActions.isEmpty
    }

    public var moreActions: [(String, () -> ())] {
        var actions: [(String, () -> ())] = []
        if isDeletable {
            actions.append((LGLocalizedString.productDeleteConfirmTitle, { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.viewModelShowDeleteAlert(strongSelf)
            }))
        }
        if isReportable {
            actions.append((LGLocalizedString.productReportProductButton, { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.viewModelShowReportAlert(strongSelf)
            }))
        }
        return actions
    }
    
    public var numberOfImages: Int {
        return product.images.count
    }
    
    // TODO: Refactor to return a view model as soon as UserProfile is refactored to MVVM
    public var productUserProfileViewModel: UIViewController? {
        guard let productUserId = product.user.objectId else { return nil }

        guard let myUser = myUserRepository.myUser, let myUserId = myUser.objectId else {
            //In case i'm not logged just open seller's profile
            return EditProfileViewController(user: product.user, source: .ProductDetail)
        }

        guard myUserId != productUserId  else { return nil }

        //If the seller is not me, open seller's profile
        return EditProfileViewController(user: product.user, source: .ProductDetail)
    }
    
    // TODO: Refactor to return a view model as soon as ProductLocationViewController is refactored to MVVM
    public var productLocationViewModel: UIViewController? {
        var vc: ProductLocationViewController?
        let location = product.location
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        vc = storyboard.instantiateViewControllerWithIdentifier("ProductLocationViewController") as? ProductLocationViewController
        
        if let actualVC = vc {
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            actualVC.location = coordinate
            actualVC.annotationTitle = product.name
            
            var subtitle = ""
            if let city = product.postalAddress.city {
                subtitle += city
            }
            if let countryCode = product.postalAddress.countryCode {
                if !subtitle.isEmpty {
                    subtitle += ", "
                }
                subtitle += countryCode
            }
            actualVC.annotationSubtitle = subtitle
        }
        
        return vc
    }
    
    public var shareText: String {
        return shareSocialMessage.shareText
    }
    
    public var shareEmailSubject: String {
        return shareSocialMessage.emailShareSubject
    }
    
    public var shareEmailBody: String {
        return shareSocialMessage.emailShareBody
    }
    
    public var shareFacebookContent: FBSDKShareLinkContent {
        return shareSocialMessage.fbShareContent
    }
    
    public var shouldSuggestMarkSoldWhenDeleting: Bool {
        let suggestMarkSold: Bool
        switch product.status {
        case .Pending, .Discarded, .Sold, .SoldOld, .Deleted:
            suggestMarkSold = false

        case .Approved:
            suggestMarkSold = true
        }
        return suggestMarkSold
    }

    public var isFooterVisible: Bool {
        let footerViewVisible: Bool
        switch product.status {
        case .Pending, .Discarded, .Deleted:
            footerViewVisible = false
        case .Approved:
            footerViewVisible = true
        case .Sold, .SoldOld:
            footerViewVisible = isMine
        }
        return footerViewVisible
    }

    public var markAsSoldButtonHidden: Bool {
        guard isMine else { return true }
        switch product.status {
        case .Approved:
            return false
        case .Pending, .Sold, .SoldOld, .Discarded, .Deleted:
            return true
        }
    }

    public var resellButtonHidden: Bool {
        guard isMine else { return true }
        switch product.status {
        case .Sold, .SoldOld:
            return false
        case .Pending, .Approved, .Discarded, .Deleted:
            return true
        }
    }
    
    // TODO: Refactor to return a view model as soon as MakeAnOfferViewController is refactored to MVVM
    public var offerViewModel: UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewControllerWithIdentifier("MakeAnOfferViewController") as? MakeAnOfferViewController else { return MakeAnOfferViewController() }
        vc.product = product
        return vc
    }
    
    public var isProductStatusLabelVisible: Bool {
        let statusLabelVisible: Bool
        switch product.status {
        case .Pending:
            statusLabelVisible = false
        case .Approved:
            statusLabelVisible = false
        case .Discarded:
            statusLabelVisible = false
        case .Sold:
            statusLabelVisible = true
        case .SoldOld:
            statusLabelVisible = true
        case .Deleted:
            statusLabelVisible = true
        }
        return statusLabelVisible
    }
    
    public var productStatusLabelBackgroundColor: UIColor {
        let color: UIColor
        switch product.status {
        case .Pending, .Approved, .Discarded, .Deleted:
            color = UIColor.whiteColor()
        case .Sold, .SoldOld:
            color = StyleHelper.soldColor
        }
        return color
    }
    
    public var productStatusLabelFontColor: UIColor {
        let color: UIColor
        switch product.status {
        case .Pending, .Approved, .Discarded, .Deleted:
            color = UIColor.blackColor()
        case .Sold, .SoldOld:
            color = UIColor.whiteColor()
        }
        return color
    }
    
    public var productStatusLabelText: String {
        let text: String
        switch product.status {
        case .Pending:
            text = LGLocalizedString.productStatusLabelPending
        case .Approved:
            text = LGLocalizedString.productStatusLabelApproved
        case .Discarded:
            text = LGLocalizedString.productStatusLabelDiscarded
        case .Sold, .SoldOld:
            text = LGLocalizedString.productListItemSoldStatusLabel
        case .Deleted:
            text = LGLocalizedString.productStatusLabelDeleted
        }
        return text
    }
    
    
    // MARK: - Lifecycle
    
    public convenience init(product: Product, thumbnailImage: UIImage?) {
        let myUserRepository = Core.myUserRepository
        let productRepository = Core.productRepository
        let tracker = TrackerProxy.sharedInstance
        self.init(myUserRepository: myUserRepository, productRepository: productRepository,
            product: product, thumbnailImage: thumbnailImage, tracker: tracker)
    }
    
    public init(myUserRepository: MyUserRepository, productRepository: ProductRepository,
        product: Product, thumbnailImage: UIImage?, tracker: Tracker) {
            // My user
            self.isFavourite = false
            self.isReported = false
            let productUser = product.user
            if let productUserId = productUser.objectId, let myUser = myUserRepository.myUser,
                let myUserId = myUser.objectId {
                    self.isMine = ( productUserId == myUserId )
            } else {
                self.isMine = false
            }
            
            // Data
            self.product = product
            self.thumbnailImage = thumbnailImage
            
            // Manager
            self.myUserRepository = myUserRepository
            self.productRepository = productRepository
            self.tracker = tracker
            
            super.init()
            
            // Tracking
            let myUser = myUserRepository.myUser
            let trackerEvent = TrackerEvent.productDetailVisit(product, user: myUser)
            tracker.trackEvent(trackerEvent)
    }
    
    internal override func didSetActive(active: Bool) {
        guard active else { return }
        guard let productId = product.objectId else { return }

        delegate?.viewModelDidStartRetrievingUserProductRelation(self)
        productRepository.retrieveUserProductRelation(productId) { [weak self] result in
            guard let strongSelf = self else { return }
            if let favorited = result.value?.isFavorited, let reported = result.value?.isReported {
                strongSelf.isFavourite = favorited
                strongSelf.isReported = reported
            }
            strongSelf.delegate?.viewModelDidUpdateIsFavourite(strongSelf)
            strongSelf.delegate?.viewModelDidUpdateIsReported(strongSelf)
        }
    }
    
    // MARK: - Public methods
    
    // MARK: > Favourite
    
    public func switchFavourite() {
        delegate?.viewModelDidStartSwitchingFavouriting(self)

        if isFavourite {
            productRepository.deleteFavorite(product) { [weak self] result in
                guard let strongSelf = self else { return }
                if let product = result.value {
                    strongSelf.product = product
                    strongSelf.isFavourite = product.favorite
                    strongSelf.deleteFavoriteCompleted()
                }
                strongSelf.delegate?.viewModelDidUpdateIsFavourite(strongSelf)
            }
        } else {
            productRepository.saveFavorite(product) { [weak self] result in
                guard let strongSelf = self else { return }
                if let product = result.value {
                    strongSelf.product = product
                    strongSelf.isFavourite = product.favorite
                    strongSelf.saveFavoriteCompleted()
                }
                strongSelf.delegate?.viewModelDidUpdateIsFavourite(strongSelf)
            }
        }
    }
    
    // MARK: > Gallery
    
    public func imageURLAtIndex(index: Int) -> NSURL? {
        return product.images[index].fileURL
    }
    
    public func imageTokenAtIndex(index: Int) -> String? {
        return product.images[index].objectId
    }
    
    
    // MARK: > Share

    public func shareInEmail(buttonPosition: EventParameterButtonPosition) {
        let trackerEvent = TrackerEvent.productShare(self.product, user: myUserRepository.myUser, network: .Email,
            buttonPosition: buttonPosition, typePage: .ProductDetail)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    public func shareInFacebook(buttonPosition: EventParameterButtonPosition) {
        let trackerEvent = TrackerEvent.productShare(self.product, user: myUserRepository.myUser, network: .Facebook,
            buttonPosition: buttonPosition, typePage: .ProductDetail)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    public func shareInFBCompleted() {
        let trackerEvent = TrackerEvent.productShareComplete(self.product, user: myUserRepository.myUser,
            network: .Facebook, typePage: .ProductDetail)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    public func shareInFBCancelled() {
        let trackerEvent = TrackerEvent.productShareCancel(self.product, user: myUserRepository.myUser,
            network: .Facebook, typePage: .ProductDetail)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    public func shareInFBMessenger() {
        let trackerEvent = TrackerEvent.productShare(self.product, user: myUserRepository.myUser, network: .FBMessenger,
            buttonPosition: .Bottom, typePage: .ProductDetail)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    public func shareInFBMessengerCompleted() {
        let trackerEvent = TrackerEvent.productShareComplete(self.product, user: myUserRepository.myUser,
            network: .FBMessenger, typePage: .ProductDetail)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    public func shareInFBMessengerCancelled() {
        let trackerEvent = TrackerEvent.productShareCancel(self.product, user: myUserRepository.myUser,
            network: .FBMessenger, typePage: .ProductDetail)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    public func shareInWhatsApp() {
        let trackerEvent = TrackerEvent.productShare(self.product, user: myUserRepository.myUser, network: .Whatsapp,
            buttonPosition: .Bottom, typePage: .ProductDetail)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    public func shareInWhatsappActivity() {
        let trackerEvent = TrackerEvent.productShare(self.product, user: myUserRepository.myUser, network: .Whatsapp,
            buttonPosition: .Top, typePage: .ProductDetail)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    public func shareInTwitterActivity() {
        let trackerEvent = TrackerEvent.productShare(self.product, user: myUserRepository.myUser, network: .Twitter,
            buttonPosition: .Top, typePage: .ProductDetail)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    
    // MARK: >  Report
    
    public func reportStarted() {
        let trackerEvent = TrackerEvent.productReport(product, user: myUserRepository.myUser)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    public func reportAbandon() {
    }
    
    public func report() {
        // If it's already reported, then do nothing
        if isReported {
            reportCompleted()
            return
        }
        
        // Otherwise, start
        delegate?.viewModelDidStartReporting(self)
        
        productRepository.saveReport(product) { [weak self] result in
            guard let strongSelf = self else { return }
            if let _ = result.value {
                strongSelf.isReported = true
                strongSelf.reportCompleted()
                strongSelf.delegate?.viewModelDidUpdateIsReported(strongSelf)
            } else if let error = result.error {
                strongSelf.delegate?.viewModelDidFailReporting(strongSelf, error: error)
            }
        }
    }
    
    
    // MARK: > Delete
    
    public func deleteStarted() {
        // Tracking
        let myUser = myUserRepository.myUser
        let trackerEvent = TrackerEvent.productDeleteStart(product, user: myUser)
        tracker.trackEvent(trackerEvent)
    }
    
    public func deleteAbandon() {
    }
    
    public func delete() {
        delegate?.viewModelDidStartDeleting(self)
        productRepository.delete(product) { [weak self] result in
            guard let strongSelf = self else { return }
            if let value = result.value {
                strongSelf.product = value
                strongSelf.deleteCompleted()
            }
            strongSelf.delegate?.viewModel(strongSelf, didFinishDeleting: result)
        }
    }


    // MARK: >  Ask

    public func ask() {
        guard let _ = myUserRepository.myUser, let viewModel = ChatViewModel(product: self.product) else { return }
        viewModel.askQuestion = .ProductDetail
        delegate?.viewModel(self, didFinishAsking: viewModel)
    }

    
    // MARK: > Mark as Sold
    
    public func markSoldStarted(source: EventParameterSellSourceValue) {
    }
    
    public func markSold(source: EventParameterSellSourceValue) {
        delegate?.viewModelDidStartMarkingAsSold(self)
        productRepository.markProductAsSold(product) { [weak self] result in
            guard let strongSelf = self else { return }
            if let value = result.value {
                strongSelf.product = value
                strongSelf.markSoldCompleted(value, source: source)
            }
            strongSelf.delegate?.viewModel(strongSelf, didFinishMarkingAsSold: result)
        }
    }
    
    public func markSoldAbandon(source: EventParameterSellSourceValue) {
    }
    
    
    public func markUnsoldStarted() {
    }
    
    public func markUnsold() {
        delegate?.viewModelDidStartMarkingAsUnsold(self)
        productRepository.markProductAsUnsold(product) { [weak self] result in
            guard let strongSelf = self else { return }
            if let value = result.value {
                strongSelf.markUnsoldCompleted(value)
            }
            strongSelf.delegate?.viewModel(strongSelf, didFinishMarkingAsUnsold: result)
        }
    }
    
    public func markUnsoldAbandon() {
    }
    
    // MARK: - UpdateDetailInfoDelegate
    
    public func updateDetailInfo(viewModel: EditSellProductViewModel,  withSavedProduct savedProduct: Product) {
        product = savedProduct
        delegate?.viewModelDidUpdate(self)
    }
    
    // MARK: - Private methods
    
    private func reportCompleted() {
        delegate?.viewModelDidCompleteReporting(self)
    }
    
    private func markSoldCompleted(soldProduct: Product, source: EventParameterSellSourceValue) {
        // Tracking
        let trackerEvent = TrackerEvent.productMarkAsSold(source, product: soldProduct, user: myUserRepository.myUser)
        tracker.trackEvent(trackerEvent)
        
    }
    
    private func markUnsoldCompleted(unsoldProduct: Product) {
        // Tracking
        let trackerEvent = TrackerEvent.productMarkAsUnsold(unsoldProduct, user: myUserRepository.myUser)
        tracker.trackEvent(trackerEvent)
        
    }
    private func deleteCompleted() {
        // Tracking
        let trackerEvent = TrackerEvent.productDeleteComplete(product, user: myUserRepository.myUser)
        tracker.trackEvent(trackerEvent)
    }
    
    private func saveFavoriteCompleted() {
        let trackerEvent = TrackerEvent.productFavorite(self.product, user: myUserRepository.myUser,
            typePage: .ProductDetail)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    private func deleteFavoriteCompleted() {
    }
}
