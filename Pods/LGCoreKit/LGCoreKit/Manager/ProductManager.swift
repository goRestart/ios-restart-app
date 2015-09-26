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
    private var productFavouriteSaveService: ProductFavouriteSaveService
    private var productFavouriteDeleteService: ProductFavouriteDeleteService
    private var productRetrieveService: ProductRetrieveService
    private var productReportSaveService: ProductReportSaveService
    private var userProductRelationService : UserProductRelationService
    
    private var productFavouriteList: [ProductFavourite]
    
    // MARK: - Lifecycle
    
    public init(productSaveService: ProductSaveService, fileUploadService: FileUploadService, productDeleteService: ProductDeleteService, productMarkSoldService: ProductMarkSoldService, productFavouriteSaveService: ProductFavouriteSaveService, productFavouriteDeleteService: ProductFavouriteDeleteService, productRetrieveService: ProductRetrieveService, productReportSaveService: ProductReportSaveService, userProductRelationService : UserProductRelationService) {
        self.productSaveService = productSaveService
        self.fileUploadService = fileUploadService
        self.productDeleteService = productDeleteService
        self.productMarkSoldService = productMarkSoldService
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
        let productFavouriteSaveService = LGProductFavouriteSaveService()
        let productFavouriteDeleteService = LGProductFavouriteDeleteService()
        let productRetrieveService = LGProductRetrieveService()
        let productReportSaveService = LGProductReportSaveService()
        let userProductRelationService = LGUserProductRelationService()
        
        self.init(productSaveService: productSaveService, fileUploadService: fileUploadService,productDeleteService: productDeleteService, productMarkSoldService: productMarkSoldService, productFavouriteSaveService: productFavouriteSaveService, productFavouriteDeleteService: productFavouriteDeleteService, productRetrieveService: productRetrieveService, productReportSaveService: productReportSaveService, userProductRelationService: userProductRelationService)
    }
    
    // MARK: - Public methods
    
    /**
        Retrieves a product with the given id.
    
        :param: productId The product identifier.
        :param: result The completion closure.
    */
    public func retrieveProductWithId(productId: String, result: ProductRetrieveServiceResult) {
        productRetrieveService.retrieveProductWithId(productId, result: result)
    }
    
    /**
        Saves (new/edit) the product for my user. If it's new, it's responsibility of the user that it has valid coordinates.
    
        :param: product the product
        :param: images the product images
        :param: result The closure containing the result.
    */
    public func saveProduct(product: Product, withImages images: [UIImage], progress: (Float) -> Void, result: ProductSaveServiceResult?) {

        /* If we don't have a user (with id & session token), or it's a new product and the user doesn't have coordinates, then it's an error */
        let user = MyUserManager.sharedInstance.myUser()
        if  (user == nil && user!.objectId != nil && user!.sessionToken == nil) ||
            (!product.isSaved && user?.gpsCoordinates == nil) {
            result?(Result<Product, ProductSaveServiceError>.failure(.Internal))
            return
        }
        
        // Prepare images' file name & their data
        var imageNameAndDatas: [(String, NSData)] = []
        for (index, image) in enumerate(images) {
            if let data = resizeImageDataFromImage(image) {
                let name = NSUUID().UUIDString.stringByReplacingOccurrencesOfString("-", withString: "", options: nil, range: nil) + "_\(index).jpg"
                let imageNameAndData = (name, data)
                imageNameAndDatas.append(imageNameAndData)
            }
        }
        
        // 1. Upload them
        let totalSteps = Float(images.count)    // #images + product save
        uploadImagesWithUserId(user!.objectId!, sessionToken: user!.sessionToken!, imageNameAndDatas:imageNameAndDatas, step: { (imagesUploadStep: Int) -> Void in

            // Notify about the progress
            progress(Float(imagesUploadStep)/totalSteps)
            
        }) { [weak self] (multipleFilesUploadResult: Result<[File], FileUploadServiceError>) -> Void in
            // Success and we have my user, and it has coordinates
            if let images = multipleFilesUploadResult.value, let myUser = user, let location = myUser.gpsCoordinates, let myUserSessionToken = MyUserManager.sharedInstance.myUser()?.sessionToken {
                product.images = images
                
                // If it's a new product, then set the location
                let isNew = !product.isSaved
                if isNew {
                    product.location = location
                    product.postalAddress = myUser.postalAddress
                }
              
                // 2. Save
                self?.productSaveService.saveProduct(product, forUser: myUser, sessionToken: myUserSessionToken) { [weak self] (saveResult: Result<Product, ProductSaveServiceError>) -> Void in

                    // Success
                    if let savedProduct = saveResult.value, productId = savedProduct.objectId {
                        
                        result?(Result<Product, ProductSaveServiceError>.success(savedProduct))
                    }
                    // Error
                    else {
                        let error = multipleFilesUploadResult.error ?? .Internal
                        switch (error) {
                        case .Internal:
                            result?(Result<Product, ProductSaveServiceError>.failure(.Internal))
                        case .Network:
                            result?(Result<Product, ProductSaveServiceError>.failure(.Network))
                        }
                    }
                }
                
            }
            // Error
            else {
                let error = multipleFilesUploadResult.error ?? .Internal
                switch (error) {
                case .Internal:
                    result?(Result<Product, ProductSaveServiceError>.failure(.Internal))
                case .Network:
                    result?(Result<Product, ProductSaveServiceError>.failure(.Network))
                }
            }
        }
    }
    
    /**
        Delete a product.
    
        :param: product the product
        :param: result The closure containing the result.
    */
    public func deleteProduct(product: Product, result: ProductDeleteServiceResult?) {
        if let productId = product.objectId, let myUserSessionToken = MyUserManager.sharedInstance.myUser()?.sessionToken {
            productDeleteService.deleteProductWithId(productId, sessionToken: myUserSessionToken, result: result)
        }
        else {
            result?(Result<Nil, ProductDeleteServiceError>.failure(.Internal))
        }
    }
    
    /**
        Mark Product as Sold.
    
        :param: product the product
        :param: result The closure containing the result.
    */
    public func markProductAsSold(product: Product, result: ProductMarkSoldServiceResult?) {
        
        if let sessionToken = MyUserManager.sharedInstance.myUser()?.sessionToken {
            productMarkSoldService.markAsSoldProduct(product, sessionToken: sessionToken) { [weak self] (markAsSoldResult: Result<Product, ProductMarkSoldServiceError>) -> Void in
                if let soldProduct = markAsSoldResult.value, let productId = soldProduct.objectId {
                    result?(Result<Product, ProductMarkSoldServiceError>.success(soldProduct))
                }
                else {
                    let error = markAsSoldResult.error ?? .Internal
                    switch (error) {
                    case .Internal:
                        result?(Result<Product, ProductMarkSoldServiceError>.failure(.Internal))
                    case .Network:
                        result?(Result<Product, ProductMarkSoldServiceError>.failure(.Network))
                    }
                }
            }
        }
    }
    
    /**
        Retrieves if a product is favourited and reported
    
        :param: user The user.
        :param: product The product.
        :param: result The closure containing the result.
    */
    public func retrieveUserProductRelation(product: Product, result: UserProductRelationServiceResult?) {
        if let myUser = MyUserManager.sharedInstance.myUser() {
            userProductRelationService.retrieveUserProductRelationWithId(myUser.objectId, productId: product.objectId, result: result)
        }
        else {
            result?(Result<UserProductRelation, UserProductRelationServiceError>.failure(.Internal))
        }
    }
    
    /**
        Adds a product to favourites.
    
        :param: product The product.
        :param: result The closure containing the result.
    */
    public func saveFavourite(product: Product, result: ProductFavouriteSaveServiceResult?) {
        if let myUser = MyUserManager.sharedInstance.myUser() {
            if product.favorited == NSNumber(bool: false) {
                if let sessionToken = MyUserManager.sharedInstance.myUser()?.sessionToken {
                    self.productFavouriteSaveService.saveFavouriteProduct(product, user: myUser, sessionToken: sessionToken, result: result)
                }
            } else {
                result?(Result<ProductFavourite, ProductFavouriteSaveServiceError>.failure(.AlreadyExists))
            }
        }
        else {
            result?(Result<ProductFavourite, ProductFavouriteSaveServiceError>.failure(.Internal))
        }
    }
    
    /**
        Removes a product from favourites.
    
        :param: product The product.
        :param: result The closure containing the result.
    */
    public func deleteFavourite(product: Product, result: ProductFavouriteDeleteServiceResult?) {
        if let myUser = MyUserManager.sharedInstance.myUser() {
            if product.favorited == NSNumber(bool: true) {
                if let sessionToken = MyUserManager.sharedInstance.myUser()?.sessionToken {
                    var productFavourite = LGProductFavourite()
                    productFavourite.product = product
                    productFavourite.user = myUser
                    self.productFavouriteDeleteService.deleteProductFavourite(productFavourite, sessionToken: sessionToken, result: result)
                }
            }
        }
        else {
            result?(Result<Nil, ProductFavouriteDeleteServiceError>.failure(.Internal))
        }
    }
    
    /**
        Reports a product.
    
        :param: product The product.
        :param: result The closure containing the result.
    */
    public func saveReport(product: Product, result: ProductReportSaveServiceResult?) {
        if let myUser = MyUserManager.sharedInstance.myUser() {
            if product.reported == NSNumber(bool: false) {
                if let sessionToken = MyUserManager.sharedInstance.myUser()?.sessionToken {
                    self.productReportSaveService.saveReportProduct(product, user: myUser, sessionToken: sessionToken, result: result)
                }
            } else {
                result?(Result<Nil, ProductReportSaveServiceError>.failure(.AlreadyExists))
            }
        }
        else {
            result?(Result<Nil, ProductReportSaveServiceError>.failure(.Internal))
        }
    }
    
    // MARK: - Private methods
    
    /**
        Resizes the given image and returns its data, if possible.
    
        :param: image The image.
        :return: The data of the resized image, if possible.
    */
    private func resizeImageDataFromImage(image: UIImage) -> NSData? {
        if let resizedImage = image.resizedImageToMaxSide(LGCoreKitConstants.productImageMaxSide, interpolationQuality:kCGInterpolationMedium) {
            return UIImageJPEGRepresentation(resizedImage, LGCoreKitConstants.productImageJPEGQuality)
        }
        return nil
    }
    
    /**
        Uploads the given images with name and data, notifies about the current step and when finished executes the result closure.
    
        :param: myUserId My user id.
        :param: sessionToken The user session token.
        :param: imageNameAndDatas The images name and data tuples
        :param: step The step closure informing about the current upload step
        :param: result The result closure
    */
    private func uploadImagesWithUserId(myUserId: String, sessionToken: String, imageNameAndDatas: [(String, NSData)], step: (Int) -> Void, result: MultipleFilesUploadServiceResult?) {
        
        if imageNameAndDatas.isEmpty {
            result?(Result<[File], FileUploadServiceError>.failure(.Internal))
            return
        }
        
        let fileUploadQueue = dispatch_queue_create("ProductManager", DISPATCH_QUEUE_SERIAL) // serial upload of images
        dispatch_async(fileUploadQueue, { () -> Void in
            
            // For each image name and data, upload it
            var fileImages: [File] = []
            
            for imageNameAndData in imageNameAndDatas {
                let fileUploadResult = self.fileUploadService.synchUploadFileWithUserId(myUserId, sessionToken: sessionToken, data: imageNameAndData.1)
                
                // Succeeded
                if let file = fileUploadResult.value {
                    fileImages.append(file)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        // Notify the current step
                        step(fileImages.count)
                        
                        // If finished, then notify about it
                        if fileImages.count >= imageNameAndDatas.count {
                            result?(Result<[File], FileUploadServiceError>.success(fileImages))
                        }
                    }
                }
                // Error, the overall image upload process is reported as a failure
                else {
                    dispatch_async(dispatch_get_main_queue()) {
                        let error = fileUploadResult.error ?? .Internal
                        result?(Result<[File], FileUploadServiceError>.failure(error))
                    }
                    break
                }
            }
        })
    }
}
