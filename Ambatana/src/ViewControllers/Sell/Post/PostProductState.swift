//
//  File.swift
//  LetGo
//
//  Created by Albert Hernández López on 21/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

final class PostProductState {
    let step: PostProductStep
    let category: PostCategory?
    let pendingToUploadImages: [UIImage]?
    let lastImagesUploadResult: FilesResult?
    let price: ProductPrice?
    let carInfo: Any?           // TODO: 🚔 Update with actual car info model
    
    private let featureFlags: FeatureFlaggeable
    
    
    // MARK: - Lifecycle
    
    convenience init(featureFlags: FeatureFlaggeable) {
        let step: PostProductStep
        if featureFlags.carsVerticalEnabled {
            if featureFlags.carsCategoryAfterPicture {
                step = .imageSelection
            } else {
                step = .categorySelection
            }
        } else {
            step = .imageSelection
        }
        self.init(step: step,
                  category: nil,
                  pendingToUploadImages: nil,
                  lastImagesUploadResult: nil,
                  price: nil,
                  carInfo: nil,
                  featureFlags: featureFlags)
    }
    
    private init(step: PostProductStep,
                 category: PostCategory?,
                 pendingToUploadImages: [UIImage]?,
                 lastImagesUploadResult: FilesResult?,
                 price: ProductPrice?,
                 carInfo: Any?, // TODO: 🚔 Update with actual car info model
                 featureFlags: FeatureFlaggeable) {
        self.step = step
        self.category = category
        self.pendingToUploadImages = pendingToUploadImages
        self.lastImagesUploadResult = lastImagesUploadResult
        self.price = price
        self.carInfo = carInfo
        self.featureFlags = featureFlags
    }
    
    func updating(category: PostCategory) -> PostProductState {
        guard featureFlags.carsVerticalEnabled, step == .categorySelection else { return self }
    
        let newStep: PostProductStep
        if featureFlags.carsCategoryAfterPicture {
            switch category {
            case .car:
                newStep = .carDetailsSelection(includePrice: false)
            case .other:
                newStep = .finished
            }
        } else {
            newStep = .imageSelection
        }
        return PostProductState(step: newStep,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                carInfo: carInfo,
                                featureFlags: featureFlags)
    }
    
    func updatingStepToUploadingImages() -> PostProductState {
        switch step {
        case .imageSelection, .errorUpload:
            break
        case .uploadingImage, .detailsSelection, .categorySelection, .carDetailsSelection, .finished:
            return self
        }
        
        return PostProductState(step: .uploadingImage,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                carInfo: carInfo,
                                featureFlags: featureFlags)
    }
    
    func updating(pendingToUploadImages: [UIImage]) -> PostProductState {
        switch step {
        case .imageSelection:
            break
        case .uploadingImage, .errorUpload, .detailsSelection, .categorySelection, .carDetailsSelection, .finished:
            return self
        }
        
        let nextStep: PostProductStep
        if let category = category, category == .car {
            nextStep = .carDetailsSelection(includePrice: true)
        } else {
            nextStep = .detailsSelection
        }
        
        return PostProductState(step: nextStep,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                carInfo: carInfo,
                                featureFlags: featureFlags)
    }
    
    func updating(uploadedImages: [File]) -> PostProductState {
        guard step == .uploadingImage else { return self }
        
        let nextStep: PostProductStep
        if let category = category, category == .car {
            nextStep = .carDetailsSelection(includePrice: true)
        } else {
            nextStep = .detailsSelection
        }
        
        return PostProductState(step: nextStep,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: FilesResult(value: uploadedImages),
                                price: price,
                                carInfo: carInfo,
                                featureFlags: featureFlags)
    }
    
    func updating(uploadError: RepositoryError) -> PostProductState {
        guard step == .uploadingImage else { return self }
        
        let message: String
        switch uploadError {
        case .internalError, .unauthorized, .notFound, .forbidden, .tooManyRequests, .userNotVerified, .serverError:
            message = LGLocalizedString.productPostGenericError
        case .network:
            message = LGLocalizedString.productPostNetworkError
        }
        
        return PostProductState(step: .errorUpload(message: message),
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: FilesResult(error: uploadError),
                                price: price,
                                carInfo: carInfo,
                                featureFlags: featureFlags)
    }
    
    func updating(price: ProductPrice) -> PostProductState {
        guard step == .detailsSelection else { return self }
        
        let newStep: PostProductStep
        if featureFlags.carsVerticalEnabled, featureFlags.carsCategoryAfterPicture {
            newStep = .categorySelection
        } else {
            newStep = .finished
        }
        return PostProductState(step: newStep,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                carInfo: carInfo,
                                featureFlags: featureFlags)
    }
    
    func updating(carInfo: Any) -> PostProductState {   // TODO: 🚔 Update with actual car info model
        guard step == .carDetailsSelection(includePrice: false) else { return self }
        
        return PostProductState(step: .finished,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                carInfo: carInfo,
                                featureFlags: featureFlags)
    }
    
    func updating(price: ProductPrice, carInfo: Any) -> PostProductState {  // TODO: 🚔 Update with actual car info model
        guard step == .carDetailsSelection(includePrice: true) else { return self }
        
        return PostProductState(step: .finished,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                carInfo: carInfo,
                                featureFlags: featureFlags)
    }
}

enum PostProductStep: Equatable {
    case imageSelection
    case uploadingImage
    case errorUpload(message: String)
    case detailsSelection
    
    case categorySelection
    case carDetailsSelection(includePrice: Bool)
    
    case finished
}

func ==(lhs: PostProductStep, rhs: PostProductStep) -> Bool {
    switch (lhs, rhs) {
    case (.imageSelection, .imageSelection), (.uploadingImage, .uploadingImage), (.detailsSelection, .detailsSelection),
         (.categorySelection, .categorySelection), (.finished, .finished):
        return true
    case (let .errorUpload(lMessage), let .errorUpload(rMessage)):
        return lMessage == rMessage
    case (let .carDetailsSelection(lIncludePrice), let .carDetailsSelection(rIncludePrice)):
        return lIncludePrice == rIncludePrice
    default:
        return false
    }
}
