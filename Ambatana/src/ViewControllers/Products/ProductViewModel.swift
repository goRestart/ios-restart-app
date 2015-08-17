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

public class ProductViewModel: BaseViewModel {

    // Output
    // > Product
    public private(set) var name: String
    public private(set) var price: String
    public private(set) var descr: String
    public private(set) var distance: String
    public private(set) var address: String
    public private(set) var location: LGLocationCoordinates2D?
    public private(set) var status: ProductStatus
    
    // > User
    public private(set) var userName: String
    public private(set) var userAvatar: NSURL?
    
    // > My User
    public private(set) var isFavourite: Bool
    public private(set) var isReported: Bool
    public private(set) var isMine: Bool
    
    public var numberOfImages: Int {
        return product.images.count
    }
    
    // Delegate
    public weak var delegate: ProductViewModelDelegate?
    
    // Data
    private var product: Product
    
    // Manager
    private var productManager: ProductManager
    
    // MARK: - Lifecycle
    
    public init(product: Product) {
        // Product
        self.name = product.name ?? ""
        self.price = product.formattedPrice()
        self.descr = product.descr ?? ""
        self.distance = product.formattedDistance()
        var address = ""
        if let city = product.postalAddress.city {
            if !city.isEmpty {
                address += city
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
        self.address = address.lg_capitalizedWord()
        self.location = product.location
        self.status = product.status
        
        // User
        self.userName = product.user?.publicUsername ?? ""
        self.userAvatar = product.user?.avatar?.fileURL
        
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
        self.productManager = ProductManager(productSaveService: productSaveService, fileUploadService: fileUploadService, productSynchronizeService: productSynchronizeService, productDeleteService: productDeleteService, productMarkSoldService: productMarkSoldService)
        
        super.init()
    }
    
    internal override func didSetActive(active: Bool) {
        
        // When getting active, update report & favourite
        if active {
            delegate?.viewModelDidStartRetrievingFavourite(self)
            retrieveIsFavourite { [weak self] (_) -> Void in
                if let strongSelf = self {
                    strongSelf.delegate?.viewModelDidUpdateIsFavourite(strongSelf)
                }
            }
            
            delegate?.viewModelDidStartRetrievingReported(self)
            retrieveIsReported { [weak self] (_) -> Void in
                if let strongSelf = self {
                    strongSelf.delegate?.viewModelDidUpdateIsReported(strongSelf)
                }
            }
        }
    }
    
    // MARK: - Public methods
    
    public func imageURLAtIndex(index: Int) -> NSURL? {
        return product.images[index].fileURL
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
    
    // MARK: > Favourite
    
    public func switchFavourite() {
        delegate?.viewModelDidStartSwitchingFavouriting(self)
        
        if isFavourite {
            deleteFavourite()
        }
        else {
            saveFavourite()
        }
    }
    
    // MARK: > Share
    
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
    
    public func shareInWhatsApp() -> Bool {
        var success = false
        let url = NSURL(string: String(format: Constants.whatsAppShareURL, arguments: [shareText]))
        if let actualURL = url {
            let application = UIApplication.sharedApplication()
            if application.canOpenURL(actualURL) {
                success = application.openURL(actualURL)
            }
        }
        return success
    }
    
    private var shareSocialMessage: SocialMessage {
        let title = NSLocalizedString("product_share_body", comment: "")
        return SocialHelper.socialMessageWithTitle(title, product: product)
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
        
        // TODO: Refactor in a service + manager
        if let myUser = MyUserManager.sharedInstance.myUser(), let productOwner = product.user {
            
            let report = PFObject(className: "UserReports")
            report["product_reported"] = PFObject(withoutDataWithClassName:PAProduct.parseClassName(), objectId:product.objectId)
            report["user_reporter"] = PFUser(withoutDataWithObjectId: myUser.objectId)
            report["user_reported"] = PFUser(withoutDataWithObjectId: productOwner.objectId)
            
            report.saveInBackgroundWithBlock({ [weak self] (success, error) -> Void in
                if let strongSelf = self {
                    if success {
                        strongSelf.isReported = true
                        strongSelf.reportCompleted()
                    }
                    strongSelf.delegate?.viewModelDidUpdateIsReported(strongSelf)
                }
            })
        }
    }
    
    // MARK: > Delete
    
    public var shouldSuggestMarkSoldWhenDeleting: Bool {
        return ( product.status != .Pending && product.status != .Sold )
    }
    
    public func deleteStarted() {
        // Tracking
        let myUser = MyUserManager.sharedInstance.myUser()
        let trackerEvent = TrackerEvent.productDeleteStart(product, user: myUser)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    public func deleteAbandon() {
        // Tracking
        let myUser = MyUserManager.sharedInstance.myUser()
        let trackerEvent = TrackerEvent.productDeleteAbandon(product, user: myUser)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    public func delete() {
        delegate?.viewModelDidStartDeleting(self)
        productManager.deleteProduct(product) { [weak self] (result: Result<Nil, ProductDeleteServiceError>) -> Void in
            if let strongSelf = self {
                if let success = result.value {
                    // Update the status
                    strongSelf.status = .Sold
                    strongSelf.product.status = .Sold
                    
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
    
    // MARK: > Offer
    
    // TODO: Refactor to return a view model as soon as MakeAnOfferViewController is refactored to MVVM
    public var offerViewModel: UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("MakeAnOfferViewController") as! MakeAnOfferViewController
        vc.product = product
        return vc
    }
    
    // MARK: > Edit

    // TODO: Refactor to return a view model
    public func editViewModelWithDelegate(delegate: UpdateDetailInfoDelegate?) -> UIViewController {
        return EditSellProductViewController(product: product, updateDelegate: delegate)
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
                    strongSelf.status = .Sold
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
    
    // MARK: - Private methods
    
    private func reportCompleted() {
    }
    
    private func markSoldCompleted(soldProduct: Product, source: EventParameterSellSourceValue) {
        // Tracking
        let myUser = MyUserManager.sharedInstance.myUser()
        let trackerEvent = TrackerEvent.productMarkAsSold(source, product: soldProduct, user: myUser)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    private func deleteCompleted() {
        // Tracking
        let myUser = MyUserManager.sharedInstance.myUser()
        let trackerEvent = TrackerEvent.productDeleteComplete(product, user: myUser)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
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
    
    // MARK: - Services (REFACTOR)
    
    // TODO: Refactor in a service + manager
    private func retrieveIsReported(completion: ((PFObject?) -> Void)?) {
        if let productId = product.objectId, let myUserId = MyUserManager.sharedInstance.myUser()?.objectId, let productOwnerId = product.user?.objectId {
            
            let productReported = PFObject(withoutDataWithClassName:PAProduct.parseClassName(), objectId: productId)
            let userReporter = PFUser(withoutDataWithObjectId: myUserId)
            let userReported = PFUser(withoutDataWithObjectId: productOwnerId)
            
            let query = PFQuery(className: "UserReports")
            query.whereKey("product_reported", equalTo: productReported)
            query.whereKey("user_reporter", equalTo: userReporter)
            query.whereKey("user_reported", equalTo: userReported)
            query.findObjectsInBackgroundWithBlock { [weak self] (results: [AnyObject]?, error: NSError?) -> Void in
                if let strongSelf = self {
                    let report = results?.first as? PFObject
                    
                    // Update the flag
                    strongSelf.isReported = ( report != nil )
                    
                    // Run the completion
                    completion?(report)
                }
            }
        }
    }
    
    // TODO: Refactor in a service + manager
    private func retrieveIsFavourite(completion: ((PFObject?) -> Void)?) {
        if let productId = product.objectId, let myUserId = MyUserManager.sharedInstance.myUser()?.objectId, let productOwnerId = product.user?.objectId {
            
            let myUser = PFUser(withoutDataWithObjectId: myUserId)
            let theProduct = PFObject(withoutDataWithClassName:PAProduct.parseClassName(), objectId: productId)
            
            let query = PFQuery(className: "UserFavoriteProducts")
            query.whereKey("user", equalTo: myUser)
            query.whereKey("product", equalTo: theProduct)
            query.findObjectsInBackgroundWithBlock { [weak self] (results: [AnyObject]?, error: NSError?) -> Void in
                if let strongSelf = self {
                    let favProduct = results?.first as? PFObject
                    
                    // Update the flag
                    strongSelf.isFavourite = ( favProduct != nil )
                    
                    // Run the completion
                    completion?(favProduct)
                }
            }
        }
    }
    
    // TODO: Refactor in a service + manager
    private func saveFavourite() {

        // Retrieve if is already favourite
        retrieveIsFavourite { [weak self] (favProduct: PFObject?) in
            if let strongSelf = self {
                
                // If it's not favourited
                if favProduct == nil {
                    
                    // Then, create a new favourite
                    if let productId = strongSelf.product.objectId, let myUserId = MyUserManager.sharedInstance.myUser()?.objectId {
                        let favProduct = PFObject(className: "UserFavoriteProducts")
                        favProduct["user"] = PFUser(withoutDataWithObjectId: myUserId)
                        favProduct["product"] = PFObject(withoutDataWithClassName:PAProduct.parseClassName(), objectId:productId)
                        
                        // Save it
                        favProduct.saveInBackgroundWithBlock { [weak self] (success: Bool, error: NSError?) -> Void in
                            if let strongSelf = self {
                                
                                // Update the flag
                                if success {
                                    strongSelf.isFavourite = true
                                }
                                
                                // Notify the delegate
                                strongSelf.delegate?.viewModelDidUpdateIsFavourite(strongSelf)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // TODO: Refactor in a service + manager
    private func deleteFavourite() {
        
        // Retrieve if is already favourite
        retrieveIsFavourite { [weak self] (favProduct: PFObject?) in
            if let strongSelf = self {
                
                // If it's favourited
                if let actualFavProduct = favProduct {
                    
                    // Then delete it
                    actualFavProduct.deleteInBackgroundWithBlock{ (success: Bool, error: NSError?) -> Void in
                        
                        // Update the flag
                        if success {
                            strongSelf.isFavourite = false
                            
                            // Notify the delegate
                            strongSelf.delegate?.viewModelDidUpdateIsFavourite(strongSelf)
                        }
                    }
                }
            }
        }
    }
}
