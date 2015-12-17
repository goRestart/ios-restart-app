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

protocol SellProductViewModelDelegate : class {
    func sellProductViewModel(viewModel: SellProductViewModel, archetype: Bool)
    
    func sellProductViewModel(viewModel: SellProductViewModel, didSelectCategoryWithName categoryName: String)
    func sellProductViewModelDidStartSavingProduct(viewModel: SellProductViewModel)
    
    func sellProductViewModel(viewModel: SellProductViewModel, didUpdateProgressWithPercentage percentage: Float)
    
    func sellProductViewModel(viewModel: SellProductViewModel, didFinishSavingProductWithResult result: ProductSaveServiceResult)
    func sellProductViewModel(viewModel: SellProductViewModel, shouldUpdateDescriptionWithCount count: Int)
    func sellProductViewModeldidAddOrDeleteImage(viewModel: SellProductViewModel)
    func sellProductViewModel(viewModel: SellProductViewModel, didFailWithError error: ProductSaveServiceError)

    func sellProductViewModelFieldCheckSucceeded(viewModel: SellProductViewModel)
}

public class SellProductViewModel: BaseViewModel {
    
    // Input
    var title: String
    internal var currency: Currency
    var price: String
    internal var category: ProductCategory?
    var shouldShareInFB: Bool
    // TODO: remove this flag for image modification tracking on update, and manage it properly @ coreKit
    var imagesModified: Bool

    var descr: String {
        didSet {
            delegate?.sellProductViewModel(self, shouldUpdateDescriptionWithCount: descriptionCharCount)
        }
    }
    
    var shouldTrack :Bool = true

    // Data
    internal var images: [UIImage?]
    internal var savedProduct: Product?
    
    // Managers
    private let productManager: ProductManager
    
    // Delegate
    weak var delegate: SellProductViewModelDelegate?
    weak var editDelegate: EditSellProductViewModelDelegate?

    
    // MARK: - Lifecycle
    
    public override init() {
        self.title = ""
        self.currency = CurrencyHelper.sharedInstance.currentCurrency
        self.price = ""
        self.descr = ""
        self.category = nil
        self.images = []

        self.shouldShareInFB = MyUserManager.sharedInstance.myUser()?.didLogInByFacebook ?? true
        self.imagesModified = false

        self.productManager = ProductManager()
        
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

    internal func trackStart() {
        
    }
    
    
    internal func trackValidationFailedWithError(error: ProductSaveServiceError) {
        
    }
    
    internal func trackSharedFB() {
        
    }
    
    internal func trackComplete(product: Product) {
        
    }
    
    var numberOfImages: Int {
        return images.count
    }
    
    func imageAtIndex(index: Int) -> UIImage? {
        return images[index]
    }
    
    var numberOfCategories: Int {
        return ProductCategory.allValues().count
    }
    
    var categoryName: String? {
        return category?.name
    }
    
    var descriptionCharCount: Int {
        
        return Constants.productDescriptionMaxLength-descr.characters.count
    }
    
    // fills action sheet
    public func categoryNameAtIndex(index: Int) -> String {
        return ProductCategory.allValues()[index].name
    }
    
    // fills category field
    public func selectCategoryAtIndex(index: Int) {
        category = ProductCategory(rawValue: index+1) // ???????? index from 0 to N and prodCat from 1 to N+1
        delegate?.sellProductViewModel(self, didSelectCategoryWithName: category?.name ?? "")
        
    }
    
    public func appendImage(image: UIImage) {
        imagesModified = true
        images.append(image)
        delegate?.sellProductViewModeldidAddOrDeleteImage(self)
    }

    public func deleteImageAtIndex(index: Int) {
        imagesModified = true
        images.removeAtIndex(index)
        delegate?.sellProductViewModeldidAddOrDeleteImage(self)
    }

    public func checkProductFields() {
        //TODO MOVE VALIDATION TO PRODUCT CREATION ON PRODUCTMANAGER
        let error = validate()
        if let actualError = error {
            delegate?.sellProductViewModel(self, didFailWithError: actualError)
            trackValidationFailedWithError(actualError)
        }
        else {
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

        // TODO: New product handling
        //        if new should add more info (location, user...)
        //        if product == nil {
        //
        //        }

        var theProduct = product ?? productManager.newProduct()
        guard let category = category else {
            let error = ProductSaveServiceError.NoCategory
            delegate?.sellProductViewModel(self, didFailWithError: error)
            return
        }
        theProduct = productManager.updateProduct(theProduct, name: title, price: Double(price), description: descr, category: category, currency: currency)

        saveTheProduct(theProduct, withImages: noEmptyImages(images))
    }
    
    func validate() -> ProductSaveServiceError? {
        
        if images.count < 1 {
            // iterar x assegurar-se que hi ha imatges
            return .NoImages
        } else if title.characters.count < 1 {
            return .NoTitle
        } else if !price.isValidPrice() {
            return .NoPrice
        } else if descr.characters.count < 1 {
            return .NoDescription
        } else if descr.characters.count > Constants.productDescriptionMaxLength {
            return .LongDescription
        } else if category == nil {
            return .NoCategory
        }
        return nil
    }

    func saveTheProduct(product: Product, withImages images: [UIImage]) {

        delegate?.sellProductViewModelDidStartSavingProduct(self)
        
        productManager.saveProduct(product, withImages: images, progress: { [weak self] (p: Float) -> Void in
            if let strongSelf = self {
                strongSelf.delegate?.sellProductViewModel(strongSelf, didUpdateProgressWithPercentage: p)
            }
            
            }) { [weak self] (r: ProductSaveServiceResult) -> Void in
                if let strongSelf = self {
                    if let actualProduct = r.value {
                        strongSelf.savedProduct = actualProduct
                        
                        strongSelf.trackComplete(actualProduct)
                        strongSelf.delegate?.sellProductViewModel(strongSelf, didFinishSavingProductWithResult: r)
                    }
                    else {
                        let error = r.error ?? ProductSaveServiceError.Internal
                        strongSelf.delegate?.sellProductViewModel(strongSelf, didFailWithError: error)
                    }
                }
        }
    }
    
    func noEmptyImages(imgs: [UIImage?]) -> [UIImage] {
        var noNilImages : [UIImage] = []
        for image in imgs {
            if image != nil {
                noNilImages.append(image!)
            }
        }
        return noNilImages
    }
}