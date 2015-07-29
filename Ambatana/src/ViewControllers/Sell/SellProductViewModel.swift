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
    

    // Data
    internal var images: [UIImage?]
    
//    private var product: Product
    
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
        productManager = ProductManager(productSaveService: productSaveService, fileUploadService: fileUploadService)
        
        super.init()
    }

    // MARK: - Public methods
    
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
    func categoryNameAtIndex(index: Int) -> String {
        return ProductCategory.allValues()[index].name()
    }
    
    // fills category field
    func selectCategoryAtIndex(index: Int) {
        category = ProductCategory(rawValue: index+1) // ???????? index from 0 to N and prodCat from 1 to N+1
        delegate?.sellProductViewModel(self, didSelectCategoryWithName: category?.name() ?? "")
    }
    
    
    public func insertImage(image: UIImage, atIndex index: Int) {
        images.insert(image, atIndex: index)
        delegate?.sellProductViewModeldidAddOrDeleteImage(self)
    }

    public func appendImage(image: UIImage) {
        images.append(image)
        delegate?.sellProductViewModeldidAddOrDeleteImage(self)
    }

    public func deleteImageAtIndex(index: Int) {
        images.removeAtIndex(index)
        delegate?.sellProductViewModeldidAddOrDeleteImage(self)
    }

    
//    public func allCategories() -> [String] {
//        
//    }
    
    public func save() {
        saveProduct(product: nil)
    }
    
    internal func saveProduct(product: Product? = nil) {
    
        if let theProduct = product {
            // update
            
            theProduct.name = title
            let formatter = NSNumberFormatter()
            formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle;
            theProduct.price = formatter.numberFromString(price)
            theProduct.descr = descr
            theProduct.categoryId = category?.rawValue
            theProduct.currency = currency
            
            // validar
            
            if validateProduct(theProduct) {
                // guardar
                saveTheProduct(theProduct, withImages: noEmptyImages(images))
            }

        } else {
            // create Product

            var theProduct = PAProduct()
            
            theProduct.name = title
            let formatter = NSNumberFormatter()
            formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle;
            theProduct.price = formatter.numberFromString(price)
            theProduct.descr = descr
            theProduct.categoryId = category?.rawValue
            theProduct.currency = currency
            
            // should add more info (location, user...)
            
            if validateProduct(theProduct) {
                // guardar
                saveTheProduct(theProduct, withImages: noEmptyImages(images))
            }
            
        }
        
    }
    
    
    func validateProduct(product: Product) -> Bool {
        
        if images.count < 1 {
            // iterar x assegurar-se que hi ha imatges
            delegate?.sellProductViewModel(self, didFailWithError: .NoImages)
            return false
        } else if count(title) < 1 {
            delegate?.sellProductViewModel(self, didFailWithError: .NoTitle)
            return false
        } else if !price.isValidPrice() {
            delegate?.sellProductViewModel(self, didFailWithError: .NoPrice)
            return false
        } else if count(descr) < 1 {
            delegate?.sellProductViewModel(self, didFailWithError: .NoDescription)
            return false
        } else if count(descr) > Constants.productDescriptionMaxLength {
            delegate?.sellProductViewModel(self, didFailWithError: .LongDescription)
            return false
        } else if category == nil {
            delegate?.sellProductViewModel(self, didFailWithError: .NoCategory)
            return false
        } else {
            return true
        }
    }

    func saveTheProduct(product: Product, withImages images: [UIImage]) {

        delegate?.sellProductViewModelDidStartSavingProduct(self)
        
        // TODO: Make a delegate error method
        productManager.saveProduct(product, withImages: images, progress: { [weak self] (p: Float) -> Void in
            
            if let strongSelf = self {
                strongSelf.delegate?.sellProductViewModel(strongSelf, didUpdateProgressWithPercentage: p)
            }
            
            }) { [weak self] (r: Result<Product, ProductSaveServiceError>) -> Void in
                if let strongSelf = self {
                    if let actualProduct = r.value {
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
    
    func shareCurrentProductInFacebook(product: Product) {
        // build the sharing content.
        let fbSharingContent = FBSDKShareLinkContent()
        fbSharingContent.contentTitle = NSLocalizedString("sell_share_fb_content", comment: "")
        fbSharingContent.contentURL = NSURL(string: letgoWebLinkForObjectId(product.objectId))
        fbSharingContent.contentDescription = title
        if product.images.count > 0 { fbSharingContent.imageURL = product.images.first?.fileURL! }
        
        // share it.
        delegate?.sellProductViewModelShareContentinFacebook(self, withContent: fbSharingContent)
    }
    
}



