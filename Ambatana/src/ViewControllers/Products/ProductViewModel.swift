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
import Parse
import Result

public protocol ProductViewModelDelegate: class {
    
    func viewModelDidUpdate(viewModel: ProductViewModel)
    
    func viewModelDidStartRetrievingFavourite(viewModel: ProductViewModel)
    func viewModelDidStartSwitchingFavouriting(viewModel: ProductViewModel)
    func viewModelDidUpdateIsFavourite(viewModel: ProductViewModel)

    func viewModelDidStartRetrievingReported(viewModel: ProductViewModel)
    func viewModelDidStartReporting(viewModel: ProductViewModel)
    func viewModelDidUpdateIsReported(viewModel: ProductViewModel)
    
    func viewModelDidStartDeleting(viewModel: ProductViewModel)
    func viewModel(viewModel: ProductViewModel, didFinishDeleting result: Result<Nil, ProductDeleteServiceError>)
    
    func viewModelDidStartAskingQuestion(viewModel: ProductViewModel)
    func viewModel(viewModel: ProductViewModel, didFinishAskingQuestion viewController: UIViewController?)
    
    func viewModelDidStartMarkingAsSold(viewModel: ProductViewModel)
    func viewModel(viewModel: ProductViewModel, didFinishMarkingAsSold result: Result<Product, ProductMarkSoldServiceError>)
}

public class ProductViewModel: BaseViewModel, UpdateDetailInfoDelegate {

    // Output
    // > Product
    public var name: String {
        return product.name?.lg_capitalizedWords() ?? ""
    }
    public var price: String {
        return product.formattedPrice()
    }
    public var descr: String {
        return product.descr ?? ""
    }
    public var distance: String {
        return product.formattedDistance()
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
    
    // > User
    public var userName: String {
        return product.user?.publicUsername ?? ""
    }
    public var userAvatar: NSURL? {
        return product.user?.avatar?.fileURL
    }
    
    // > My User
    public private(set) var isFavourite: Bool
    public private(set) var isReported: Bool
    public private(set) var isMine: Bool
    
    // Delegate
    public weak var delegate: ProductViewModelDelegate?
    
    // Data
    private var product: Product
    
    // Manager
    private var productManager: ProductManager
    private var tracker: Tracker
    
    // MARK: - Computed iVars
    
    public var isEditable: Bool {
        let isOnSale: Bool
        switch product.status {
        case .Pending, .Approved, .Discarded:
            isOnSale = true
            
        case .Deleted, .Sold, .SoldOld:
            isOnSale = false
        }
        
        // It's editable when the product is mine and is on sale
        return isMine && isOnSale
    }
    
    // TODO: Refactor to return a view model
    public var editViewModelWithDelegate: UIViewController {
        return EditSellProductViewController(product: product, updateDelegate: self)
    }
    
    public var isFavouritable: Bool {
        return !isMine
    }
    
    public var isShareable: Bool {
        return !isMine
    }
    
    public var isReportable: Bool {
        return !isMine
    }
    
    public var numberOfImages: Int {
        return product.images.count
    }
    
    // TODO: Refactor to return a view model as soon as UserProfile is refactored to MVVM
    public var productUserProfileViewModel: UIViewController? {
        let productUserId = product.user?.objectId
        if let myUser = MyUserManager.sharedInstance.myUser(), let myUserId = myUser.objectId, let productUser = product.user, let productUserId = productUser.objectId {
            if myUserId != productUserId {
                return EditProfileViewController(user: productUser)
            }
        }
        return nil
    }
    
    // TODO: Refactor to return a view model as soon as ProductLocationViewController is refactored to MVVM
    public var productLocationViewModel: UIViewController? {
        var vc: ProductLocationViewController?
        if let location = product.location {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            vc = storyboard.instantiateViewControllerWithIdentifier("ProductLocationViewController") as? ProductLocationViewController
            
            if let actualVC = vc {
                let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                actualVC.location = coordinate
            }
        }
        return vc
    }
    
    public var shareText: String {
        return shareSocialMessage.shareText
    }
    
    public var shareEmailSubject: String {
        return shareSocialMessage.title
    }
    
    public var shareEmailBody: String {
        return shareSocialMessage.emailShareText
    }
    
    public var shareFacebookContent: FBSDKShareLinkContent {
        return shareSocialMessage.fbShareContent
    }
    
    private var shareSocialMessage: SocialMessage {
        let title = NSLocalizedString("product_share_body", comment: "")
        return SocialHelper.socialMessageWithTitle(title, product: product)
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
    
    public var isDeletable: Bool {
        return isMine
    }
    
    public var isFooterVisible: Bool {
        let footerViewVisible: Bool
        switch product.status {
        case .Pending, .Discarded, .Sold, .SoldOld, .Deleted:
            footerViewVisible = false

        case .Approved:
            footerViewVisible = true
        }
        return footerViewVisible
    }
    
    // TODO: Refactor to return a view model as soon as MakeAnOfferViewController is refactored to MVVM
    public var offerViewModel: UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("MakeAnOfferViewController") as! MakeAnOfferViewController
        vc.product = product
        return vc
    }
    
    // MARK: - Lifecycle
    
    public init(product: Product, tracker: Tracker) {
        // My user
        self.isFavourite = false
        self.isReported = false
        if let productUser = product.user, let productUserId = productUser.objectId, let myUser = MyUserManager.sharedInstance.myUser(), let myUserId = myUser.objectId {
            self.isMine = ( productUserId == myUserId )
        }
        else {
            self.isMine = false
        }
        
        // Data
        self.product = product
        
        // Manager
        let productSaveService = PAProductSaveService()
        let fileUploadService = PAFileUploadService()
        let productSynchronizeService = LGProductSynchronizeService()
        let productDeleteService = LGProductDeleteService()
        let productMarkSoldService = PAProductMarkSoldService()
        let productFavouriteRetrieveService = PAProductFavouriteRetrieveService()
        let productFavouriteSaveService = PAProductFavouriteSaveService()
        let productFavouriteDeleteService = PAProductFavouriteDeleteService()
        let productReportRetrieveService = PAProductReportRetrieveService()
        let productReportSaveService = PAProductReportSaveService()

        self.productManager = ProductManager(productSaveService: productSaveService, fileUploadService: fileUploadService, productSynchronizeService: productSynchronizeService, productDeleteService: productDeleteService, productMarkSoldService: productMarkSoldService, productFavouriteRetrieveService: productFavouriteRetrieveService, productFavouriteSaveService: productFavouriteSaveService, productFavouriteDeleteService: productFavouriteDeleteService, productReportRetrieveService: productReportRetrieveService, productReportSaveService: productReportSaveService)
        self.tracker = TrackerProxy.sharedInstance
        
        super.init()
        
        // Tracking
        let myUser = MyUserManager.sharedInstance.myUser()
        let trackerEvent = TrackerEvent.productDetailVisit(product, user: myUser)
        tracker.trackEvent(trackerEvent)
    }
    
    internal override func didSetActive(active: Bool) {
        
        if active {
            // Update favourite
            delegate?.viewModelDidStartRetrievingFavourite(self)
            productManager.retrieveFavourite(product) { [weak self] (result: Result<ProductFavourite, ProductFavouriteRetrieveServiceError>) -> Void in
                if let strongSelf = self {
                    // Update the flag
                    strongSelf.isFavourite = (result.value != nil)
                    
                    // Notify the delegate
                    strongSelf.delegate?.viewModelDidUpdateIsFavourite(strongSelf)
                }
            }
            
            // Update reported
            delegate?.viewModelDidStartRetrievingReported(self)
            productManager.retrieveReport(product) { [weak self] (result: Result<ProductReport, ProductReportRetrieveServiceError>) -> Void in
                if let strongSelf = self {
                    // Update the flag
                    strongSelf.isReported = (result.value != nil)
                    
                    // Notify the delegate
                    strongSelf.delegate?.viewModelDidUpdateIsReported(strongSelf)
                }
            }
        }
    }
    
    // MARK: - Public methods
    
    // MARK: > Favourite
    
    public func switchFavourite() {
        delegate?.viewModelDidStartSwitchingFavouriting(self)
        
        // If favourite, then remove from favourites / delete
        if isFavourite {
            productManager.deleteFavourite(product) { [weak self] (result: Result<Nil, ProductFavouriteDeleteServiceError>) -> Void in
                if let strongSelf = self {
                    // Success
                    if let success = result.value {
                        // Update the flag
                        strongSelf.isFavourite = false
                        
                        // Run completed
                        strongSelf.deleteFavouriteCompleted()
                    }
                    
                    // Notify the delegate
                    strongSelf.delegate?.viewModelDidUpdateIsFavourite(strongSelf)
                }
            }
        }
        // Otherwise, add it / save
        else {
            productManager.saveFavourite(product) { [weak self] (result: Result<ProductFavourite, ProductFavouriteSaveServiceError>) -> Void in
                if let strongSelf = self {
                    // Success
                    if let success = result.value {
                        // Update the flag
                        strongSelf.isFavourite = true
                        
                        // Run completed
                        strongSelf.saveFavouriteCompleted()
                    }
                    
                    // Notify the delegate
                    strongSelf.delegate?.viewModelDidUpdateIsFavourite(strongSelf)
                }
            }
        }
    }
    
    // MARK: > Gallery
    
    public func imageURLAtIndex(index: Int) -> NSURL? {
        return product.images[index].fileURL
    }
    
    // MARK: > Share
    
    public func shareInFBCompleted() {
    }
    
    public func shareInFBCancelled() {
    }
    
    public func shareInWhatsApp() -> Bool {
        var success = false
        
        let queryCharSet = NSCharacterSet.URLQueryAllowedCharacterSet()
        if let urlEncodedShareText = shareText.stringByAddingPercentEncodingWithAllowedCharacters(queryCharSet),
           let url = NSURL(string: String(format: Constants.whatsAppShareURL, arguments: [urlEncodedShareText])) {
            let application = UIApplication.sharedApplication()
            if application.canOpenURL(url) {
                success = application.openURL(url)
            }
        }
        return success
    }
    
    // MARK: >  Report
    
    public func reportStarted() {
    }
    
    public func reportAbandon() {
    }
    
    public func report() {
        // If it's already reported, then do nothing
        if isReported {
            return
        }
        
        // Otherwise, start
        delegate?.viewModelDidStartReporting(self)
        productManager.saveReport(product) { [weak self] (result: Result<Nil, ProductReportSaveServiceError>) -> Void in
            if let strongSelf = self {
                // Success
                if let success = result.value {
                    // Update the flag
                    strongSelf.isReported = true
                    
                    // Run completed
                    strongSelf.reportCompleted()
                }
                // Notify the delegate
                strongSelf.delegate?.viewModelDidUpdateIsReported(strongSelf)
            }
        }
    }
    
    // MARK: > Delete
    
    public func deleteStarted() {
        // Tracking
        let myUser = MyUserManager.sharedInstance.myUser()
        let trackerEvent = TrackerEvent.productDeleteStart(product, user: myUser)
        tracker.trackEvent(trackerEvent)
    }
    
    public func deleteAbandon() {
        // Tracking
        let myUser = MyUserManager.sharedInstance.myUser()
        let trackerEvent = TrackerEvent.productDeleteAbandon(product, user: myUser)
        tracker.trackEvent(trackerEvent)
    }
    
    public func delete() {
        delegate?.viewModelDidStartDeleting(self)
        productManager.deleteProduct(product) { [weak self] (result: Result<Nil, ProductDeleteServiceError>) -> Void in
            if let strongSelf = self {
                if let success = result.value {
                    // Update the status
                    strongSelf.product.status = .Deleted
                    
                    // Run completed
                    strongSelf.deleteCompleted()
                }
                
                // Notify the delegate
                strongSelf.delegate?.viewModel(strongSelf, didFinishDeleting: result)
            }
        }
    }

    // MARK: >  Ask
    
    public func askStarted() {
    }
    
    public func ask() {
        delegate?.viewModelDidStartAskingQuestion(self)
        
        if let productUser = product.user {

            // Retrieve the conversation
            ChatManager.sharedInstance.retrieveMyConversationWithUser(productUser, aboutProduct: product) { [weak self] (success, conversation) -> Void in
                if let strongSelf = self {
                    
                    // If we've the conversation
                    if let actualConversation = conversation {
                        strongSelf.askCompleted(actualConversation)
                    }
                    // Otherwise, we need to create it
                    else {
                        ChatManager.sharedInstance.createConversationWithUser(productUser, aboutProduct: strongSelf.product, completion: { (success, conversation) -> Void in

                            // If we successfully created it
                            if let actualConversation = conversation {
                                strongSelf.askCompleted(actualConversation)
                            }
                            // Otherwise it's an error
                            else {
                                strongSelf.delegate?.viewModel(strongSelf, didFinishAskingQuestion: nil)
                            }
                        })
                    }
                }
            }
        }
        else {
            delegate?.viewModel(self, didFinishAskingQuestion: nil)
        }
    }
    
    // MARK: > Mark as Sold
    
    public func markSoldStarted(source: EventParameterSellSourceValue) {
    }
    
    public func markSold(source: EventParameterSellSourceValue) {
        delegate?.viewModelDidStartMarkingAsSold(self)
        productManager.markProductAsSold(product) { [weak self] ( result: Result<Product, ProductMarkSoldServiceError>) -> Void in
            if let strongSelf = self {
                // Success
                if let soldProduct = result.value {
                    // Update the status
                    strongSelf.product.status = .Sold
                    
                    // Run completed
                    strongSelf.markSoldCompleted(soldProduct, source: source)
                }
                
                // Notify the delegate
                strongSelf.delegate?.viewModel(strongSelf, didFinishMarkingAsSold: result)
            }
        }
    }
    
    public func markSoldAbandon(source: EventParameterSellSourceValue) {
    }
    
    // MARK: - UpdateDetailInfoDelegate
    
    public func updateDetailInfo(viewModel: EditSellProductViewModel) {
        delegate?.viewModelDidUpdate(self)
    }
    
    // MARK: - Private methods
    
    private func reportCompleted() {
    }
    
    private func markSoldCompleted(soldProduct: Product, source: EventParameterSellSourceValue) {
        // Tracking
        let myUser = MyUserManager.sharedInstance.myUser()
        let trackerEvent = TrackerEvent.productMarkAsSold(source, product: soldProduct, user: myUser)
        tracker.trackEvent(trackerEvent)
    }
    
    private func deleteCompleted() {
        // Tracking
        let myUser = MyUserManager.sharedInstance.myUser()
        let trackerEvent = TrackerEvent.productDeleteComplete(product, user: myUser)
        tracker.trackEvent(trackerEvent)
    }
    
    private func askCompleted(conversation: PFObject) {
        // TODO: Needs refactor
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            let chatVC = ChatViewController()
            chatVC.letgoConversation = LetGoConversation(parseConversationObject: conversation)
            chatVC.askQuestion = true
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                delegate?.viewModel(self, didFinishAskingQuestion: chatVC)
            })
        })
    }
    
    private func saveFavouriteCompleted() {
    }
    
    private func deleteFavouriteCompleted() {
    }
}
