//
//  SellProductViewModel.swift
//  LetGo
//
//  Created by Dídac on 23/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Result
import FBSDKShareKit

protocol SellProductViewModelDelegate : class {
    func sellProductViewModel(viewModel: SellProductViewModel, archetype: Bool)
    
    func sellProductViewModel(viewModel: SellProductViewModel, didSelectCategoryWithName categoryName: String)
    func sellProductViewModelDidStartSavingProduct(viewModel: SellProductViewModel)
    
    func sellProductViewModel(viewModel: SellProductViewModel, didUpdateProgressWithPercentage percentage: Float)
    
    func sellProductViewModel(viewModel: SellProductViewModel, didFinishSavingProductWithResult result: Result<Product, ProductSaveServiceError>)
    func sellProductViewModel(viewModel: SellProductViewModel, shouldUpdateDescriptionWithCount count: Int)
    func sellProductViewModeldidAddOrDeleteImage(viewModel: SellProductViewModel)
    func sellProductViewModel(viewModel: SellProductViewModel, didFailWithError error: ProductSaveServiceError)

    func sellProductViewModelShareContentinFacebook(viewModel: SellProductViewModel, withContent content: FBSDKShareLinkContent)
}

public class SellProductViewModel: BaseViewModel {
    
    // Input
    var title: String
    internal var currency: Currency
    var price: String
    internal var category: ProductCategory?
    var shouldShareInFB: Bool

    var descr: String {
        didSet {
            delegate?.sellProductViewModel(self, shouldUpdateDescriptionWithCount: descriptionCharCount)
        }
    }
    
    var shouldTrack :Bool = true

    // Data
    internal var images: [UIImage?]
    
    // Managers
    private let productManager: ProductManager
    
    // Delegate
    weak var delegate: SellProductViewModelDelegate?
    weak var editDelegate: EditSellProductViewModelDelegate?

    
    // MARK: - Lifecycle
    
    public override init() {
        title = ""
        currency = CurrencyHelper.sharedInstance.currentCurrency
        price = ""
        descr = ""
        category = nil
        images = []
        shouldShareInFB = true
        
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
    
    internal func trackAddedImage() {
        
    }
    
    public func trackEditedTitle() {
        
    }
    
    public func trackEditedPrice() {
        
    }
    
    public func trackEditedDescription() {
        
    }
    
    internal func trackEditedCategory() {
        
    }
    
    public func trackEditedFBChanged() {
        
    }
    
    internal func trackValidationFailedWithError(error: ProductSaveServiceError) {
        
    }
    
    public func trackSharedFB() {
        
    }
    
    internal func trackComplete() {
        
    }
    
    internal func trackAbandon() {
        
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
        return category?.name()
    }
    
    var descriptionCharCount: Int {
        
        return Constants.productDescriptionMaxLength-count(descr)
    }
    
    // fills action sheet
    public func categoryNameAtIndex(index: Int) -> String {
        return ProductCategory.allValues()[index].name()
    }
    
    // fills category field
    public func selectCategoryAtIndex(index: Int) {
        category = ProductCategory(rawValue: index+1) // ???????? index from 0 to N and prodCat from 1 to N+1
        delegate?.sellProductViewModel(self, didSelectCategoryWithName: category?.name() ?? "")
        
        trackEditedCategory()
    }
    
    public func appendImage(image: UIImage) {
        images.append(image)
        delegate?.sellProductViewModeldidAddOrDeleteImage(self)
        trackAddedImage()
    }

    public func deleteImageAtIndex(index: Int) {
        images.removeAtIndex(index)
        delegate?.sellProductViewModeldidAddOrDeleteImage(self)
    }

    public func save() {
        saveProduct(product: nil)
    }
    
    internal func saveProduct(product: Product? = nil) {
        let theProduct = product ?? PAProduct()
        theProduct.name = title
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        formatter.usesGroupingSeparator = false
        theProduct.price = formatter.numberFromString(price)

        theProduct.descr = descr
        theProduct.categoryId = category?.rawValue
        theProduct.currency = currency
        
        // TODO: New product handling
//         if new should add more info (location, user...)
//        if product == nil {
//
//        }
        
        let error = validate()
        if let actualError = error {
            delegate?.sellProductViewModel(self, didFailWithError: actualError)
            trackValidationFailedWithError(actualError)
        }
        else {
            saveTheProduct(theProduct, withImages: noEmptyImages(images))
        }
    }
    
    func validate() -> ProductSaveServiceError? {
        
        if images.count < 1 {
            // iterar x assegurar-se que hi ha imatges
            return .NoImages
        } else if count(title) < 1 {
            return .NoTitle
        } else if !price.isValidPrice() {
            return .NoPrice
        } else if count(descr) < 1 {
            return .NoDescription
        } else if count(descr) > Constants.productDescriptionMaxLength {
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
            
            }) { [weak self] (r: Result<Product, ProductSaveServiceError>) -> Void in
                if let strongSelf = self {
                    if let actualProduct = r.value {
                        strongSelf.trackComplete()
                        strongSelf.delegate?.sellProductViewModel(strongSelf, didFinishSavingProductWithResult: r)
                        
                        if strongSelf.shouldShareInFB {
                            strongSelf.shareCurrentProductInFacebook(actualProduct)
                        }
                        
                    } else {
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
    
    // MARK: - FB Share

    // TODO: Actual sharing must happen in VC (see ProductVC / ProductVM)
    func shareCurrentProductInFacebook(product: Product) {
        delegate?.sellProductViewModelShareContentinFacebook(self, withContent: shareFacebookContent(product))
    }
    
    // TODO: Refactor, this should be a computed iVar, and product should be generated in here or in parent class
    func shareFacebookContent(product: Product) -> FBSDKShareLinkContent {
        let title = NSLocalizedString("sell_share_fb_content", comment: "")
        return SocialHelper.socialMessageWithTitle(title, product: product).fbShareContent
    }
}



