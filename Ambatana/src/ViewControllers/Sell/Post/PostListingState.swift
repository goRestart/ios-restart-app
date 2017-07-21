//
//  PostListingState.swift
//  LetGo
//
//  Created by Albert Hernández López on 21/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

final class PostListingState {
    let step: PostListingStep
    let previousStep: PostListingStep?
    let category: PostCategory?
    let pendingToUploadImages: [UIImage]?
    let lastImagesUploadResult: FilesResult?
    let price: ListingPrice?
    let carInfo: CarAttributes?
    
    private let featureFlags: FeatureFlaggeable
    
    
    // MARK: - Lifecycle
    
    convenience init(featureFlags: FeatureFlaggeable) {
        let step: PostListingStep
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
                  previousStep: nil,
                  category: nil,
                  pendingToUploadImages: nil,
                  lastImagesUploadResult: nil,
                  price: nil,
                  carInfo: nil,
                  featureFlags: featureFlags)
    }
    
    private init(step: PostListingStep,
                 previousStep: PostListingStep?,
                 category: PostCategory?,
                 pendingToUploadImages: [UIImage]?,
                 lastImagesUploadResult: FilesResult?,
                 price: ListingPrice?,
                 carInfo: CarAttributes?,
                 featureFlags: FeatureFlaggeable) {
        self.step = step
        self.previousStep = previousStep
        self.category = category
        self.pendingToUploadImages = pendingToUploadImages
        self.lastImagesUploadResult = lastImagesUploadResult
        self.price = price
        self.carInfo = carInfo
        self.featureFlags = featureFlags
       
    }
    
    func updating(category: PostCategory) -> PostListingState {
        guard featureFlags.carsVerticalEnabled, step == .categorySelection else { return self }
        let newStep: PostListingStep
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
        return PostListingState(step: newStep,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                carInfo: carInfo,
                                featureFlags: featureFlags)
    }
    
    func updatingStepToUploadingImages() -> PostListingState {
        switch step {
        case .imageSelection, .errorUpload:
            break
        case .uploadingImage, .detailsSelection, .categorySelection, .carDetailsSelection, .finished, .uploadSuccess:
            return self
        }
        return PostListingState(step: .uploadingImage,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                carInfo: carInfo,
                                featureFlags: featureFlags)
    }
    
    func updating(pendingToUploadImages: [UIImage]) -> PostListingState {
        switch step {
        case .imageSelection:
            break
        case .uploadingImage, .errorUpload, .detailsSelection, .categorySelection, .carDetailsSelection, .finished, .uploadSuccess:
            return self
        }
        let nextStep: PostListingStep
        if let category = category, category == .car {
            nextStep = .carDetailsSelection(includePrice: true)
        } else {
            nextStep = .detailsSelection
        }
        
        return PostListingState(step: nextStep,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                carInfo: carInfo,
                                featureFlags: featureFlags)
    }
    
    func updatingAfterUploadingSuccess() -> PostListingState {
        guard step == .uploadSuccess else { return self }
        let nextStep: PostListingStep
        if let category = category, category == .car {
            nextStep = .carDetailsSelection(includePrice: true)
        } else {
            nextStep = .detailsSelection
        }
        
        return PostListingState(step: nextStep,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                carInfo: carInfo,
                                featureFlags: featureFlags)
    }
    
    
    func updatingToSuccessUpload(uploadedImages: [File]) -> PostListingState {
        guard step == .uploadingImage else { return self }
        return PostListingState(step: .uploadSuccess,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: FilesResult(value: uploadedImages),
                                price: price,
                                carInfo: carInfo,
                                featureFlags: featureFlags)
    }
    
    func updating(uploadError: RepositoryError) -> PostListingState {
        guard step == .uploadingImage else { return self }
        let message: String
        switch uploadError {
        case .internalError, .unauthorized, .notFound, .forbidden, .tooManyRequests, .userNotVerified, .serverError, .wsChatError:
            message = LGLocalizedString.productPostGenericError
        case .network:
            message = LGLocalizedString.productPostNetworkError
        }
        
        return PostListingState(step: .errorUpload(message: message),
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: FilesResult(error: uploadError),
                                price: price,
                                carInfo: carInfo,
                                featureFlags: featureFlags)
    }
    
    func updating(price: ListingPrice) -> PostListingState {
        guard step == .detailsSelection else { return self }
        let newStep: PostListingStep
        if featureFlags.carsVerticalEnabled, featureFlags.carsCategoryAfterPicture {
            newStep = .categorySelection
        } else {
            newStep = .finished
        }
        return PostListingState(step: newStep,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                carInfo: carInfo,
                                featureFlags: featureFlags)
    }
    
    func updating(carInfo: CarAttributes) -> PostListingState {
        guard step == .carDetailsSelection(includePrice: false) else { return self }
        return PostListingState(step: .finished,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                carInfo: carInfo,
                                featureFlags: featureFlags)
    }
    
    func updating(price: ListingPrice, carInfo: CarAttributes) -> PostListingState {
        guard step == .carDetailsSelection(includePrice: true) else { return self }
        return PostListingState(step: .finished,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                carInfo: carInfo,
                                featureFlags: featureFlags)
    }
    
    func revertToPreviousStep() -> PostListingState {
        guard let previousStep = previousStep else { return self }
        return PostListingState(step: previousStep,
                                previousStep: nil,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                carInfo: carInfo,
                                featureFlags: featureFlags)
    }
}

enum PostListingStep: Equatable {
    case imageSelection
    case uploadingImage
    case errorUpload(message: String)
    case detailsSelection
    case uploadSuccess
    
    case categorySelection
    case carDetailsSelection(includePrice: Bool)
    
    case finished
}

func ==(lhs: PostListingStep, rhs: PostListingStep) -> Bool {
    switch (lhs, rhs) {
    case (.imageSelection, .imageSelection), (.uploadingImage, .uploadingImage), (.detailsSelection, .detailsSelection),
         (.categorySelection, .categorySelection), (.finished, .finished), (.uploadSuccess, .uploadSuccess):
        return true
    case (let .errorUpload(lMessage), let .errorUpload(rMessage)):
        return lMessage == rMessage
    case (let .carDetailsSelection(lIncludePrice), let .carDetailsSelection(rIncludePrice)):
        return lIncludePrice == rIncludePrice
    default:
        return false
    }
}
