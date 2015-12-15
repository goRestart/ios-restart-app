//
//  ProductManager.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 04/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

// TODO: In the services use just product ids whenever possible, user ids as well and handling in here.

import Parse
import Result

public class ProductManager {
    
    private var productSaveService: ProductSaveService
    private var fileUploadService: FileUploadService
    private var productDeleteService: ProductDeleteService
    private var productMarkSoldService : ProductMarkSoldService
    private var productMarkUnsoldService : ProductMarkUnsoldService
    private var productFavouriteSaveService: ProductFavouriteSaveService
    private var productFavouriteDeleteService: ProductFavouriteDeleteService
    private var productRetrieveService: ProductRetrieveService
    private var productReportSaveService: ProductReportSaveService
    private var userProductRelationService : UserProductRelationService
    
    private var productFavouriteList: [ProductFavourite]
    
    // MARK: - Lifecycle
    
    public init(productSaveService: ProductSaveService, fileUploadService: FileUploadService, productDeleteService: ProductDeleteService, productMarkSoldService: ProductMarkSoldService, productMarkUnsoldService: ProductMarkUnsoldService, productFavouriteSaveService: ProductFavouriteSaveService, productFavouriteDeleteService: ProductFavouriteDeleteService, productRetrieveService: ProductRetrieveService, productReportSaveService: ProductReportSaveService, userProductRelationService : UserProductRelationService) {
        self.productSaveService = productSaveService
        self.fileUploadService = fileUploadService
        self.productDeleteService = productDeleteService
        self.productMarkSoldService = productMarkSoldService
        self.productMarkUnsoldService = productMarkUnsoldService
        self.productFavouriteSaveService = productFavouriteSaveService
        self.productFavouriteDeleteService = productFavouriteDeleteService
        self.productRetrieveService = productRetrieveService
        self.productReportSaveService = productReportSaveService
        self.userProductRelationService = userProductRelationService
        self.productFavouriteList = []
    }
    
    public convenience init() {
        let productSaveService = LGProductSaveService()
        let fileUploadService = LGFileUploadService()
        let productDeleteService = LGProductDeleteService()
        let productMarkSoldService = LGProductMarkSoldService()
        let productMarkUnsoldService = LGProductMarkUnsoldService()
        let productFavouriteSaveService = LGProductFavouriteSaveService()
        let productFavouriteDeleteService = LGProductFavouriteDeleteService()
        let productRetrieveService = LGProductRetrieveService()
        let productReportSaveService = LGProductReportSaveService()
        let userProductRelationService = LGUserProductRelationService()
        
        self.init(productSaveService: productSaveService, fileUploadService: fileUploadService,productDeleteService: productDeleteService, productMarkSoldService: productMarkSoldService, productMarkUnsoldService: productMarkUnsoldService, productFavouriteSaveService: productFavouriteSaveService, productFavouriteDeleteService: productFavouriteDeleteService, productRetrieveService: productRetrieveService, productReportSaveService: productReportSaveService, userProductRelationService: userProductRelationService)
    }
    
    // MARK: - Public methods
    
    /**
    Factory method. Will build a new empty product.
    */
    public func newProduct() -> Product {
        return LGProduct()
    }
    
    /**
    Factory method. Will return an updated version from the initial product
    */
    public func updateProduct(product: Product, name: String?, price: Float?, description: String?, category: ProductCategory, currency: Currency?) -> Product {
        var product = LGProduct(product: product)
        product.name = name
        product.price = price
        product.descr = description
        product.category = category
        product.currency = currency
        return product
    }
    
    /**
        Retrieves a product with the given id.
    
        - parameter productId: The product identifier.
        - parameter result: The completion closure.
    */
    public func retrieveProductWithId(productId: String, completion: ProductRetrieveServiceCompletion) {
        productRetrieveService.retrieveProductWithId(productId, completion: completion)
    }

    /**
    Saves (new/edit) the product for my user. If it's new, it's responsibility of the user that it has valid coordinates.

    - parameter product: the product
    - parameter images: the product images
    - parameter result: The closure containing the result.
    */
    public func saveProduct(theProduct: Product, withImages images: [UIImage], progress: (Float) -> Void,
        completion: ProductSaveServiceCompletion?) {

            saveProductImages(images, progress: progress) {
                [weak self] (multipleFilesUploadResult: MultipleFilesUploadServiceResult) -> Void in

                    guard let images = multipleFilesUploadResult.value else {

                            let error = multipleFilesUploadResult.error ?? .Internal
                            switch (error) {
                            case .Internal:
                                completion?(ProductSaveServiceResult(error: .Internal))
                            case .Network:
                                completion?(ProductSaveServiceResult(error: .Network))
                            case .Forbidden:
                                completion?(ProductSaveServiceResult(error: .Forbidden))
                            }
                            return
                    }

                    self?.saveProduct(theProduct, imageFiles: images, completion: completion)
            }
    }

    public func saveProduct(theProduct: Product, imageFiles images: [File], completion: ProductSaveServiceCompletion?) {

        guard let myUser = MyUserManager.sharedInstance.myUser(), let sessionToken = myUser.sessionToken else {
            completion?(ProductSaveServiceResult(error: .Internal))
            return
        }

        var product = LGProduct(product: theProduct)
        product.images = images

        if !theProduct.isSaved {
            //New product take address and coordinates info from user
            guard let location = myUser.gpsCoordinates else {
                completion?(ProductSaveServiceResult(error: .Internal))
                return
            }
            product.location = location
            product.postalAddress = myUser.postalAddress
        }

        self.productSaveService.saveProduct(product, forUser: myUser, sessionToken: sessionToken)
            { (saveResult: ProductSaveServiceResult) -> Void in
                guard let savedProduct = saveResult.value, _ = savedProduct.objectId else {
                    let error = saveResult.error ?? .Internal
                    switch (error) {
                    case .Internal:
                        completion?(ProductSaveServiceResult(error: .Internal))
                    case .Network:
                        completion?(ProductSaveServiceResult(error: .Network))
                    case .Forbidden:
                        completion?(ProductSaveServiceResult(error: .Forbidden))
                    case .NoImages, .NoTitle, .NoPrice, .NoDescription, .LongDescription, .NoCategory:
                        completion?(ProductSaveServiceResult(error: .Internal))
                    }
                    return
                }

                completion?(ProductSaveServiceResult(value: savedProduct))
        }
    }

    public func saveProductImages(images: [UIImage], progress: ((Float) -> Void)?,
        completion productImagesCompletion: MultipleFilesUploadServiceCompletion?) {
            guard let user = MyUserManager.sharedInstance.myUser(), let userId = user.objectId,
                let sessionToken = user.sessionToken else {
                    productImagesCompletion?(MultipleFilesUploadServiceResult(error: .Internal))
                    return
            }

            // Prepare images' file name & their data
            var imageNameAndDatas: [(String, NSData)] = []
            for (index, image) in images.enumerate() {
                if let data = resizeImageDataFromImage(image) {
                    let name = NSUUID().UUIDString.stringByReplacingOccurrencesOfString("-", withString: "",
                        options: [], range: nil) + "_\(index).jpg"
                    let imageNameAndData = (name, data)
                    imageNameAndDatas.append(imageNameAndData)
                }
            }

            let totalSteps = Float(images.count)
            uploadImagesWithUserId(userId,
                sessionToken: sessionToken,
                imageNameAndDatas:imageNameAndDatas,
                step: { (imagesUploadStep: Int) -> Void in
                    progress?(Float(imagesUploadStep)/totalSteps)
                },
                completion: {(multipleFilesUploadResult: MultipleFilesUploadServiceResult) -> Void in
                    productImagesCompletion?(multipleFilesUploadResult)
                }
            )
    }
    
    /**
        Delete a product.
    
        - parameter product: the product
        - parameter result: The closure containing the result.
    */
    public func deleteProduct(product: Product, completion: ProductDeleteServiceCompletion?) {
        if let myUserSessionToken = MyUserManager.sharedInstance.myUser()?.sessionToken {
            productDeleteService.deleteProduct(product, sessionToken: myUserSessionToken, completion: completion)
        }
        else {
            completion?(ProductDeleteServiceResult(error: .Internal))
        }
    }
    
    /**
        Mark Product as Sold.
    
        - parameter product: the product
        - parameter result: The closure containing the result.
    */
    public func markProductAsSold(product: Product, completion: ProductMarkSoldServiceCompletion?) {
        
        if let sessionToken = MyUserManager.sharedInstance.myUser()?.sessionToken {
            productMarkSoldService.markAsSoldProduct(product, sessionToken: sessionToken) { (markAsSoldResult: ProductMarkSoldServiceResult) -> Void in
                if let soldProduct = markAsSoldResult.value, let _ = soldProduct.objectId {
                    completion?(ProductMarkSoldServiceResult(value: soldProduct))
                }
                else {
                    let error = markAsSoldResult.error ?? .Internal
                    switch (error) {
                    case .Internal:
                        completion?(ProductMarkSoldServiceResult(error: .Internal))
                    case .Network:
                        completion?(ProductMarkSoldServiceResult(error: .Network))
                    }
                }
            }
        }
    }
    
    /**
        Mark Product as Unsold.
    
        - parameter product: the product
        - parameter result: The closure containing the result.
    */
    public func markProductAsUnsold(product: Product, completion: ProductMarkUnsoldServiceCompletion?) {
        
        if let sessionToken = MyUserManager.sharedInstance.myUser()?.sessionToken {
            productMarkUnsoldService.markAsUnsoldProduct(product, sessionToken: sessionToken) { (markAsUnsoldResult: ProductMarkUnsoldServiceResult) -> Void in
                if let unsoldProduct = markAsUnsoldResult.value, let _ = unsoldProduct.objectId {
                    completion?(ProductMarkUnsoldServiceResult(value: unsoldProduct))
                }
                else {
                    let error = markAsUnsoldResult.error ?? .Internal
                    switch (error) {
                    case .Internal:
                        completion?(ProductMarkUnsoldServiceResult(error: .Internal))
                    case .Network:
                        completion?(ProductMarkUnsoldServiceResult(error: .Network))
                    }
                }
            }
        }
    }
    
    /**
        Retrieves if a product is favourited and reported
    
        - parameter user: The user.
        - parameter product: The product.
        - parameter result: The closure containing the result.
    */
    public func retrieveUserProductRelation(product: Product, completion: UserProductRelationServiceCompletion?) {
        if let myUserId = MyUserManager.sharedInstance.myUser()?.objectId, let productId = product.objectId {
            userProductRelationService.retrieveUserProductRelationWithId(myUserId, productId: productId, completion: completion)
        }
        else {
            completion?(UserProductRelationServiceResult(error: .Internal))
        }
    }
    
    /**
        Adds a product to favourites.
    
        - parameter product: The product.
        - parameter result: The closure containing the result.
    */
    public func saveFavourite(product: Product, completion: ProductFavouriteSaveServiceCompletion?) {
        if let myUser = MyUserManager.sharedInstance.myUser(), let sessionToken = MyUserManager.sharedInstance.myUser()?.sessionToken {
            self.productFavouriteSaveService.saveFavouriteProduct(product, user: myUser, sessionToken: sessionToken, completion: completion)
        }
        else {
            completion?(ProductFavouriteSaveServiceResult(error: .Internal))
        }
    }
    
    /**
        Removes a product from favourites.
    
        - parameter product: The product.
        - parameter result: The closure containing the result.
    */
    public func deleteFavourite(product: Product, completion: ProductFavouriteDeleteServiceCompletion?) {
        if let myUser = MyUserManager.sharedInstance.myUser(), let sessionToken = MyUserManager.sharedInstance.myUser()?.sessionToken {
            let productFavourite = LGProductFavourite(objectId: nil, product: product, user: myUser)
            self.productFavouriteDeleteService.deleteProductFavourite(productFavourite, sessionToken: sessionToken, completion: completion)
        }
        else {
            completion?(ProductFavouriteDeleteServiceResult(error: .Internal))
        }
    }
    
    /**
        Reports a product.
    
        - parameter product: The product.
        - parameter result: The closure containing the result.
    */
    public func saveReport(product: Product, completion: ProductReportSaveServiceCompletion?) {
        if let myUser = MyUserManager.sharedInstance.myUser() {
            if let sessionToken = MyUserManager.sharedInstance.myUser()?.sessionToken {
                self.productReportSaveService.saveReportProduct(product, user: myUser, sessionToken: sessionToken, completion: completion)
            }
        }
        else {
            completion?(ProductReportSaveServiceResult(error: .Internal))
        }
    }
    
    // MARK: - Private methods
    
    /**
        Resizes the given image and returns its data, if possible.
    
        - parameter image: The image.
        :return: The data of the resized image, if possible.
    */
    private func resizeImageDataFromImage(image: UIImage) -> NSData? {
        if let resizedImage = image.resizedImageToMaxSide(LGCoreKitConstants.productImageMaxSide, interpolationQuality:CGInterpolationQuality.Medium) {
            return UIImageJPEGRepresentation(resizedImage, LGCoreKitConstants.productImageJPEGQuality)
        }
        return nil
    }
    
    /**
        Uploads the given images with name and data, notifies about the current step and when finished executes the result closure.
    
        - parameter myUserId: My user id.
        - parameter sessionToken: The user session token.
        - parameter imageNameAndDatas: The images name and data tuples
        - parameter step: The step closure informing about the current upload step
        - parameter result: The result closure
    */
    private func uploadImagesWithUserId(myUserId: String, sessionToken: String, imageNameAndDatas: [(String, NSData)], step: (Int) -> Void, completion: MultipleFilesUploadServiceCompletion?) {
        
        if imageNameAndDatas.isEmpty {
            completion?(MultipleFilesUploadServiceResult(error: .Internal))
            return
        }
        
        let fileUploadQueue = dispatch_queue_create("ProductManager", DISPATCH_QUEUE_SERIAL) // serial upload of images
        dispatch_async(fileUploadQueue, { () -> Void in
            
            // For each image name and data, upload it
            var fileImages: [File] = []
            
            for imageNameAndData in imageNameAndDatas {

                let fileUploadResult = synchronize({ (synchCompletion) -> Void in
                    self.fileUploadService.uploadFileWithUserId(myUserId, sessionToken: sessionToken, data: imageNameAndData.1, completion: { (result) -> Void in
                        synchCompletion(result)
                    })
                }, timeoutWith: FileUploadServiceResult(error: .Internal))
                
                // Succeeded
                if let file = fileUploadResult.value {
                    fileImages.append(file)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        // Notify the current step
                        step(fileImages.count)
                        
                        // If finished, then notify about it
                        if fileImages.count >= imageNameAndDatas.count {
                            completion?(MultipleFilesUploadServiceResult(value: fileImages))
                        }
                    }
                }
                // Error, the overall image upload process is reported as a failure
                else {
                    dispatch_async(dispatch_get_main_queue()) {
                        let error = fileUploadResult.error ?? .Internal
                        completion?(MultipleFilesUploadServiceResult(error: error))
                    }
                    break
                }
            }
        })
    }
}
