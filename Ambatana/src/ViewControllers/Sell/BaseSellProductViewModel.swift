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

public enum ProductCreateValidationError: String, ErrorType {
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
        case .NotFound:
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

public class BaseSellProductViewModel: BaseViewModel {
    
    // Input
    var title: String?
    internal var currency: Currency
    var price: String?
    internal var category: ProductCategory?
    var shouldShareInFB: Bool

    // TODO: remove this flag for image modification tracking on update, and manage it properly @ coreKit
    var imagesModified: Bool

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
    private let productRepository: ProductRepository
    let tracker: Tracker
    
    // Delegate
    weak var delegate: SellProductViewModelDelegate?
    weak var editDelegate: EditSellProductViewModelDelegate?

    
    // MARK: - Lifecycle
    
    public convenience override init() {
        let myUserRepository = MyUserRepository.sharedInstance
        let productRepository = ProductRepository.sharedInstance
        let tracker = TrackerProxy.sharedInstance
        self.init(myUserRepository: myUserRepository, productRepository: productRepository, tracker: tracker)
    }
    
    public init(myUserRepository: MyUserRepository, productRepository: ProductRepository, tracker: Tracker) {
        self.myUserRepository = myUserRepository
        self.productRepository = productRepository
        self.tracker = tracker
        
        self.title = nil
        self.currency = CurrencyHelper.sharedInstance.currentCurrency
        self.price = nil
        self.descr = nil
        self.category = nil
        self.productImages = ProductImages()
        self.shouldShareInFB = myUserRepository.myUser?.authProvider == .Facebook
        self.imagesModified = false
        
        super.init()
        
        trackStart()
    }
    
    
    // MARK: - Public methods
    
    public func shouldEnableTracking() {
        shouldTrack = true
    }

    public func shouldDisableTracking() {
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
    public func categoryNameAtIndex(index: Int) -> String {
        return ProductCategory.allValues()[index].name
    }
    
    // fills category field
    public func selectCategoryAtIndex(index: Int) {
        category = ProductCategory(rawValue: index+1) //index from 0 to N and prodCat from 1 to N+1
        delegate?.sellProductViewModel(self, didSelectCategoryWithName: category?.name ?? "")
        
    }
    
    public func appendImage(image: UIImage) {
        imagesModified = true
        productImages.append(image)
        delegate?.sellProductViewModeldidAddOrDeleteImage(self)
    }

    public func deleteImageAtIndex(index: Int) {
        imagesModified = true
        productImages.removeAtIndex(index)
        delegate?.sellProductViewModeldidAddOrDeleteImage(self)
    }

    public func checkProductFields() {
        let error = validate()
        if let actualError = error {
            delegate?.sellProductViewModel(self, didFailWithError: actualError)
            trackValidationFailedWithError(actualError)
        } else {
            delegate?.sellProductViewModelFieldCheckSucceeded(self)
        }
    }

    public func save() {
        saveProduct(nil)
    }
    
    public var fbShareContent: FBSDKShareLinkContent? {
        if let product = savedProduct {
            let title = LGLocalizedString.sellShareFbContent
            return SocialHelper.socialMessageWithTitle(title, product: product).fbShareContent
        }
        return nil
    }
    
    // MARK: - Private methods
    
    internal func saveProduct(product: Product? = nil) {

        var theProduct = product ?? productRepository.newProduct()
        guard let category = category else {
            delegate?.sellProductViewModel(self, didFailWithError: .NoCategory)
            return
        }
        let priceText = price ?? "0"
        
        theProduct = productRepository.updateProduct(theProduct, name: title, price: priceText.toPriceDouble(),
            description: descr, category: category, currency: currency)

        saveTheProduct(theProduct, withImages: productImages)
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
            if localImages.isEmpty {
                productRepository.update(product, images: remoteImages, completion: commonCompletion)
            } else {
                productRepository.update(product, images: localImages, progress: nil, completion: commonCompletion)
            }
        } else {
            if localImages.isEmpty {
                productRepository.create(product, images: remoteImages, completion: commonCompletion)
            } else {
                productRepository.create(product, images: localImages, progress: nil, completion: commonCompletion)
            }
        }
    }
}
