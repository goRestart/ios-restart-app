//
//  SellProductViewModel.swift
//  LetGo
//
//  Created by Dídac on 23/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import FBSDKShareKit
import LGCoreKit
import Result
import RxSwift

enum ProductCreateValidationError: String, ErrorType {
    case Network = "network"
    case Internal = "internal"
    case NoImages = "no images present"
    case NoTitle  = "no title"
    case NoPrice = "invalid price"
    case NoDescription = "no description"
    case LongDescription = "description too long"
    case NoCategory = "no category selected"
    
    init(repoError: RepositoryError) {
        switch repoError {
        case .Internal:
            self = .Internal
        case .Network:
            self = .Network
        case .NotFound, .Forbidden:
            self = .Internal
        case .Unauthorized:
            self = .Internal
        }
    }
}


protocol SellProductViewModelDelegate : class {
    func sellProductViewModel(viewModel: BaseSellProductViewModel, archetype: Bool)
    func sellProductViewModel(viewModel: BaseSellProductViewModel, didSelectCategoryWithName categoryName: String)
    func sellProductViewModelDidStartSavingProduct(viewModel: BaseSellProductViewModel)
    func sellProductViewModel(viewModel: BaseSellProductViewModel, didUpdateProgressWithPercentage percentage: Float)
    func sellProductViewModel(viewModel: BaseSellProductViewModel, didFinishSavingProductWithResult
        result: ProductResult)
    func sellProductViewModel(viewModel: BaseSellProductViewModel, shouldUpdateDescriptionWithCount count: Int)
    func sellProductViewModeldidAddOrDeleteImage(viewModel: BaseSellProductViewModel)
    func sellProductViewModel(viewModel: BaseSellProductViewModel, didFailWithError error: ProductCreateValidationError)
    func sellProductViewModelFieldCheckSucceeded(viewModel: BaseSellProductViewModel)

    func vmShouldAskForPermissionsWithAlertWithTitle(title: String, text: String, iconName: String?, actions: [UIAction]?)
    func vmShouldOpenMapWithViewModel(locationViewModel: EditLocationViewModel)
}

enum SellProductImageType {
    case Local(image: UIImage)
    case Remote(file: File)
}

class ProductImages {
    var images: [SellProductImageType] = []
    var localImages: [UIImage] {
        return images.flatMap {
            switch $0 {
            case .Local(let image):
                return image
            case .Remote:
                return nil
            }
        }
    }
    var remoteImages: [File] {
        return images.flatMap {
            switch $0 {
            case .Local:
                return nil
            case .Remote(let file):
                return file
            }
        }
    }

    func append(image: UIImage) {
        images.append(.Local(image: image))
    }

    func append(file: File) {
        images.append(.Remote(file: file))
    }

    func removeAtIndex(index: Int) {
        images.removeAtIndex(index)
    }
}

class BaseSellProductViewModel: BaseViewModel, EditLocationDelegate {
    
    // Input
    var title: String?
    let titleAutogenerated = Variable<Bool>(false)
    let titleAutotranslated = Variable<Bool>(false)
    var currency: Currency?
    var price: String?
    var postalAddress: PostalAddress?
    var location: LGLocationCoordinates2D?
    var locationInfo = Variable<String>("")
    var category: ProductCategory?
    var shouldShareInFB: Bool

    var descr: String? {
        didSet {
            delegate?.sellProductViewModel(self, shouldUpdateDescriptionWithCount: descriptionCharCount)
        }
    }
    
    var shouldTrack :Bool = true

    // Data
    var productImages: ProductImages
    var images: [SellProductImageType] {
        return productImages.images
    }
    var savedProduct: Product?
    
    // Managers
    let myUserRepository: MyUserRepository
    let productRepository: ProductRepository
    let tracker: Tracker
    
    // Delegate
    weak var delegate: SellProductViewModelDelegate?
    weak var editDelegate: EditSellProductViewModelDelegate?

    
    // MARK: - Lifecycle
    
    convenience override init() {
        let myUserRepository = Core.myUserRepository
        let productRepository = Core.productRepository
        let tracker = TrackerProxy.sharedInstance
        self.init(myUserRepository: myUserRepository, productRepository: productRepository, tracker: tracker)
    }
    
    init(myUserRepository: MyUserRepository, productRepository: ProductRepository, tracker: Tracker) {
        self.myUserRepository = myUserRepository
        self.productRepository = productRepository
        self.tracker = tracker
        
        self.title = nil
        self.currency = nil
        self.price = nil
        self.descr = nil
        self.postalAddress = nil
        self.location = nil
        self.category = nil
        self.productImages = ProductImages()
        self.shouldShareInFB = myUserRepository.myUser?.facebookAccount != nil
        
        super.init()
        
        trackStart()
    }
    
    
    // MARK: - methods
    
    func shouldEnableTracking() {
        shouldTrack = true
    }

    func shouldDisableTracking() {
        shouldTrack = false
    }

    internal func trackStart() { }
    
    internal func trackValidationFailedWithError(error: ProductCreateValidationError) { }

    internal func trackSharedFB() { }
    
    internal func trackComplete(product: Product) { }

    var numberOfImages: Int {
        return images.count
    }
    
    func imageAtIndex(index: Int) -> SellProductImageType {
        return images[index]
    }
    
    var numberOfCategories: Int {
        return ProductCategory.allValues().count
    }
    
    var categoryName: String? {
        return category?.name
    }
    
    var descriptionCharCount: Int {
        guard let descr = descr else { return Constants.productDescriptionMaxLength }
        return Constants.productDescriptionMaxLength-descr.characters.count
    }
    
    // fills action sheet
    func categoryNameAtIndex(index: Int) -> String {
        return ProductCategory.allValues()[index].name
    }
    
    // fills category field
    func selectCategoryAtIndex(index: Int) {
        category = ProductCategory(rawValue: index+1) //index from 0 to N and prodCat from 1 to N+1
        delegate?.sellProductViewModel(self, didSelectCategoryWithName: category?.name ?? "")
        
    }
    
    func appendImage(image: UIImage) {
        productImages.append(image)
        delegate?.sellProductViewModeldidAddOrDeleteImage(self)
    }

    func deleteImageAtIndex(index: Int) {
        productImages.removeAtIndex(index)
        delegate?.sellProductViewModeldidAddOrDeleteImage(self)
    }

    func checkProductFields() {
        let error = validate()
        if let actualError = error {
            delegate?.sellProductViewModel(self, didFailWithError: actualError)
            trackValidationFailedWithError(actualError)
        } else {
            delegate?.sellProductViewModelFieldCheckSucceeded(self)
        }
    }

    func save() {
        createProduct()
    }
    
    var fbShareContent: FBSDKShareLinkContent? {
        if let product = savedProduct {
            let title = LGLocalizedString.sellShareFbContent
            return SocialHelper.socialMessageWithTitle(title, product: product).fbShareContent
        }
        return nil
    }

    func openMap() {
        var shouldAskForPermission = true
        var permissionsActionBlock: ()->() = {}
        // check location enabled
        switch Core.locationManager.locationServiceStatus {
        case let .Enabled(authStatus):
            switch authStatus {
            case .NotDetermined:
                shouldAskForPermission = true
                permissionsActionBlock = { Core.locationManager.startSensorLocationUpdates() }
            case .Restricted, .Denied:
                shouldAskForPermission = true
                permissionsActionBlock = { [weak self] in self?.openLocationAppSettings() }
            case .Authorized:
                shouldAskForPermission = false
            }
        case .Disabled:
            shouldAskForPermission = true
            permissionsActionBlock = { [weak self] in self?.openLocationAppSettings() }
        }

        if shouldAskForPermission {
            // not enabled
            let okAction = UIAction(interface: UIActionInterface.Button(LGLocalizedString.commonOk, .Primary(fontSize: .Medium)), action: permissionsActionBlock)
            delegate?.vmShouldAskForPermissionsWithAlertWithTitle(LGLocalizedString.editProductLocationAlertTitle, text: LGLocalizedString.editProductLocationAlertText, iconName: "ic_location_alert", actions: [okAction])
        } else {
            // enabled
            let locationVM = EditLocationViewModel(mode: .SelectLocation)
            locationVM.locationDelegate = self
            delegate?.vmShouldOpenMapWithViewModel(locationVM)
        }
    }


    // MARK: - Private methods

    func createProduct() {
        guard let category = category else {
            delegate?.sellProductViewModel(self, didFailWithError: .NoCategory)
            return
        }
        let name = title ?? ""
        let description = (descr ?? "").stringByRemovingEmoji()
        let priceAmount = (price ?? "0").toPriceDouble()

        guard let product = productRepository.buildNewProduct(name, description: description, price: priceAmount,
                                                              category: category) else {
            delegate?.sellProductViewModel(self, didFailWithError: .Internal)
            return
        }

        saveTheProduct(product, withImages: productImages)
    }

    func validate() -> ProductCreateValidationError? {
        
        if images.count < 1 {
            return .NoImages
        } else if descriptionCharCount < 0 {
            return .LongDescription
        } else if category == nil {
            return .NoCategory
        }
        return nil
    }
    
    func saveTheProduct(product: Product, withImages images: ProductImages) {
        
        delegate?.sellProductViewModelDidStartSavingProduct(self)
        
        let localImages = images.localImages
        let remoteImages = images.remoteImages
        
        let commonCompletion: ProductCompletion = { [weak self] result in
            guard let strongSelf = self else { return }
            if let actualProduct = result.value {
                strongSelf.savedProduct = actualProduct
                strongSelf.trackComplete(actualProduct)
                strongSelf.delegate?.sellProductViewModel(strongSelf, didFinishSavingProductWithResult: result)
            } else if let error = result.error {
                let newError = ProductCreateValidationError(repoError: error)
                strongSelf.delegate?.sellProductViewModel(strongSelf, didFailWithError: newError)
            }
        }
        
        if let _ = product.objectId {
            productRepository.update(product, oldImages: remoteImages, newImages: localImages, progress: nil, completion: commonCompletion)
        } else {
            if localImages.isEmpty {
                productRepository.create(product, images: remoteImages, completion: commonCompletion)
            } else {
                productRepository.create(product, images: localImages, progress: nil, completion: commonCompletion)
            }
        }
    }

    func openLocationAppSettings() {
        guard let settingsURL = NSURL(string:UIApplicationOpenSettingsURLString) else { return }
        UIApplication.sharedApplication().openURL(settingsURL)
    }
}


// MARK: EditLocationDelegate

extension BaseSellProductViewModel {
    func editLocationDidSelectPlace(place: Place) {
        print("🕌 🕌 🕌 🕌 🕌 🕌 🕌")
        print(place.placeResumedData)

        location = place.location
        postalAddress = place.postalAddress
        locationInfo.value = postalAddress?.city ?? postalAddress?.countryCode ?? ""
    }
}
