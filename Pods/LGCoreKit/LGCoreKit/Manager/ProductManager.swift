//
//  ProductManager.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 04/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse
import Result

public class ProductManager {
    
    private var productSaveService: ProductSaveService
    private var fileUploadService: FileUploadService
    private var productSynchronizeService: ProductSynchronizeService
    private var productDeleteService: ProductDeleteService
    private var productMarkSoldService : ProductMarkSoldService
    private var productFavouriteRetrieveService: ProductFavouriteRetrieveService
    private var productFavouriteSaveService: ProductFavouriteSaveService
    private var productFavouriteDeleteService: ProductFavouriteDeleteService
    private var productReportRetrieveService: ProductReportRetrieveService
    private var productReportSaveService: ProductReportSaveService
    
    // MARK: - Lifecycle
    
    public init(productSaveService: ProductSaveService, fileUploadService: FileUploadService, productSynchronizeService: ProductSynchronizeService, productDeleteService: ProductDeleteService, productMarkSoldService: ProductMarkSoldService, productFavouriteRetrieveService: ProductFavouriteRetrieveService, productFavouriteSaveService: ProductFavouriteSaveService, productFavouriteDeleteService: ProductFavouriteDeleteService, productReportRetrieveService: ProductReportRetrieveService, productReportSaveService: ProductReportSaveService) {
        self.productSaveService = productSaveService
        self.fileUploadService = fileUploadService
        self.productSynchronizeService = productSynchronizeService
        self.productDeleteService = productDeleteService
        self.productMarkSoldService = productMarkSoldService
        self.productFavouriteRetrieveService = productFavouriteRetrieveService
        self.productFavouriteSaveService = productFavouriteSaveService
        self.productFavouriteDeleteService = productFavouriteDeleteService
        self.productReportRetrieveService = productReportRetrieveService
        self.productReportSaveService = productReportSaveService
    }
    
    // MARK: - Public methods
    
    /**
        Saves (new/edit) the product for my user. If it's new, it's responsibility of the user that it has valid coordinates.
    
        :param: product the product
        :param: images the product images
        :param: result The closure containing the result.
    */
    public func saveProduct(product: Product, withImages images: [UIImage], progress: (Float) -> Void, result: ProductSaveServiceResult?) {

        // If we don't have a user, or it's a new product and the user doesn't have coordinates, then it's an error
        let user = MyUserManager.sharedInstance.myUser()
        if user == nil || (!product.isSaved && user?.gpsCoordinates == nil) {
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
        uploadImagesWithNameAndData(imageNameAndDatas, step: { (imagesUploadStep: Int) -> Void in

            // Notify about the progress
            progress(Float(imagesUploadStep)/totalSteps)
            
        }) { [weak self] (multipleFilesUploadResult: Result<[File], FileUploadServiceError>) -> Void in
            // Success and we have my user, and it has coordinates
            if let images = multipleFilesUploadResult.value, let myUser = user, let location = myUser.gpsCoordinates {
                product.images = images
                
                // If it's a new product, then set the location
                let isNew = !product.isSaved
                if isNew {
                    product.location = location
                    product.postalAddress = myUser.postalAddress
                }
              
                // 2. Save
                self?.productSaveService.saveProduct(product, forUser: myUser) { [weak self] (saveResult: Result<Product, ProductSaveServiceError>) -> Void in

                    // Success
                    if let savedProduct = saveResult.value, productId = savedProduct.objectId {
                        
                        // 3. Synchronize
                        self?.productSynchronizeService.synchronizeProductWithId(productId) { () -> Void in
                            
                            // Notify the sender, we do not care about synch result
                            result?(Result<Product, ProductSaveServiceError>.success(savedProduct))
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
        productMarkSoldService.markAsSoldProduct(product) { [weak self] (markAsSoldResult: Result<Product, ProductMarkSoldServiceError>) -> Void in
            if let soldProduct = markAsSoldResult.value, let productId = soldProduct.objectId {
                // synchronize
                self?.productSynchronizeService.synchronizeProductWithId(productId) { () -> Void in
                    // Notify the sender, we do not care about synch result
                    result?(Result<Product, ProductMarkSoldServiceError>.success(soldProduct))
                }
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
    
    /**
        Retrieves if a product is favourited.
    
        :param: product The product.
        :param: result The closure containing the result.
    */
    public func retrieveFavourite(product: Product, result: ProductFavouriteRetrieveServiceResult?) {
        if let myUser = MyUserManager.sharedInstance.myUser() {
            productFavouriteRetrieveService.retrieveProductFavourite(product, user: myUser, result: result)
        }
        else {
            result?(Result<ProductFavourite, ProductFavouriteRetrieveServiceError>.failure(.Internal))
        }
    }
    
    /**
        Adds a product to favourites.
    
        :param: product The product.
        :param: result The closure containing the result.
    */
    public func saveFavourite(product: Product, result: ProductFavouriteSaveServiceResult?) {
        if let myUser = MyUserManager.sharedInstance.myUser() {
            let myResult: ProductFavouriteRetrieveServiceResult = { [weak self] (retrieveResult: Result<ProductFavourite, ProductFavouriteRetrieveServiceError>) -> Void in
                if let error = retrieveResult.error {
                    switch (error) {
                    // If does not exist, then save
                    case .DoesNotExist:
                        self?.productFavouriteSaveService.saveFavouriteProduct(product, user: myUser, result: result)
                    case .Internal:
                        result?(Result<ProductFavourite, ProductFavouriteSaveServiceError>.failure(.Internal))
                    case .Network:
                        result?(Result<ProductFavourite, ProductFavouriteSaveServiceError>.failure(.Network))
                    }
                }
                else {
                    result?(Result<ProductFavourite, ProductFavouriteSaveServiceError>.failure(.Internal))
                }
            }
            
            // Retrieve & then, if possible, save
            retrieveFavourite(product, result: myResult)
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
            let myResult: ProductFavouriteRetrieveServiceResult = { [weak self] (retrieveResult: Result<ProductFavourite, ProductFavouriteRetrieveServiceError>) -> Void in
                
                // Success
                if let productFavourite = retrieveResult.value {
                    // Then delete
                    self?.productFavouriteDeleteService.deleteProductFavourite(productFavourite, result: result)
                }
                // Error
                else {
                    let error = retrieveResult.error ?? .Internal
                    switch (error) {
                    case .DoesNotExist, .Internal:
                        result?(Result<Nil, ProductFavouriteDeleteServiceError>.failure(.Internal))
                    case .Network:
                        result?(Result<Nil, ProductFavouriteDeleteServiceError>.failure(.Network))
                    }
                }
            }
            
            // Retrieve & then, if possible, delete
            retrieveFavourite(product, result: myResult)
        }
        else {
            result?(Result<Nil, ProductFavouriteDeleteServiceError>.failure(.Internal))
        }
    }
    
    /**
        Retrieves if a product is reported.
    
        :param: product The product.
        :param: result The closure containing the result.
    */
    public func retrieveReport(product: Product, result: ProductReportRetrieveServiceResult?) {
        if let myUser = MyUserManager.sharedInstance.myUser() {
            productReportRetrieveService.retrieveReportForProduct(product, user: myUser, result: result)
        }
        else {
            result?(Result<ProductReport, ProductReportRetrieveServiceError>.failure(.Internal))
        }
    }
    
    /**
        Reports a product.
    
        :param: product The product.
        :param: result The closure containing the result.
    */
    public func saveReport(product: Product, result: ProductReportSaveServiceResult?) {
        if let myUser = MyUserManager.sharedInstance.myUser() {
            let myResult: ProductReportRetrieveServiceResult = { [weak self] (retrieveResult: Result<ProductReport, ProductReportRetrieveServiceError>) -> Void in
                if let productReport = retrieveResult.value {
                    result?(Result<Nil, ProductReportSaveServiceError>.failure(.AlreadyExists))
                }
                else if let error = retrieveResult.error {
                    switch (error) {
                    // If does not exist, then save
                    case .DoesNotExist:
                        self?.productReportSaveService.saveReportProduct(product, user: myUser, result: result)
                    case .Internal:
                        result?(Result<Nil, ProductReportSaveServiceError>.failure(.Internal))
                    case .Network:
                        result?(Result<Nil, ProductReportSaveServiceError>.failure(.Network))
                    }
                }
                else {
                    result?(Result<Nil, ProductReportSaveServiceError>.failure(.Internal))
                }
            }
            
            // Retrieve & then, if possible, save
            retrieveReport(product, result: myResult)
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
    
        :param: imageNameAndDatas The images name and data tuples
        :param: step The step closure informing about the current upload step
        :param: result The result closure
    */
    private func uploadImagesWithNameAndData(imageNameAndDatas: [(String, NSData)], step: (Int) -> Void, result: MultipleFilesUploadServiceResult?) {
        
        if imageNameAndDatas.isEmpty {
            result?(Result<[File], FileUploadServiceError>.failure(.Internal))
            return
        }
        
        let fileUploadQueue = dispatch_queue_create("ProductManager", DISPATCH_QUEUE_SERIAL) // serial upload of images
        dispatch_async(fileUploadQueue, { () -> Void in

            // For each image name and data, upload it
            var fileImages: [File] = []
            
            for imageNameAndData in imageNameAndDatas {
                let fileUploadServiceResult = self.fileUploadService.synchUploadFile(imageNameAndData.0, data: imageNameAndData.1)
                
                // Success
                if let file = fileUploadServiceResult.value {
                    fileImages.append(file)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        // Notify the current step
                        step(fileImages.count)
                        
                        // If finished, then notify about it
                        if fileImages.count >= imageNameAndDatas.count {
                            result?(Result<[File], FileUploadServiceError>.success(fileImages))
                        }
                    })
                }
                // Error, the overall image upload process is reported as a failure
                else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let error = fileUploadServiceResult.error ?? .Internal
                        result?(Result<[File], FileUploadServiceError>.failure(error))
                    })
                    break
                }
            }
        })
    }
}
