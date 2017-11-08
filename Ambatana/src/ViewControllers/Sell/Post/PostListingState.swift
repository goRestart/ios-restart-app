//
//  PostListingState.swift
//  LetGo
//
//  Created by Albert Hernández López on 21/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

public enum VerticalAttributes {
    case carInfo(CarAttributes)
    case realEstateInfo(RealEstateAttributes)
 
    var carAttributes: CarAttributes? {
        switch self {
        case .carInfo(let attributes):
            return attributes
        case .realEstateInfo:
            return nil
        }
    }
    
    var realEstateAttributes: RealEstateAttributes? {
        switch self {
        case .realEstateInfo(let attributes):
            return attributes
        case .carInfo:
            return nil
        }
    }
}

final class PostListingState {
    let step: PostListingStep
    let previousStep: PostListingStep?
    let category: PostCategory?
    let pendingToUploadImages: [UIImage]?
    let lastImagesUploadResult: FilesResult?
    let price: ListingPrice?
    let verticalAttributes: VerticalAttributes?
    
    
    // MARK: - Lifecycle
    
    convenience init(postCategory: PostCategory?) {
        let step: PostListingStep = .imageSelection
        
        self.init(step: step,
                  previousStep: nil,
                  category: postCategory,
                  pendingToUploadImages: nil,
                  lastImagesUploadResult: nil,
                  price: nil,
                  verticalAttributes: nil)
    }
    
    private init(step: PostListingStep,
                 previousStep: PostListingStep?,
                 category: PostCategory?,
                 pendingToUploadImages: [UIImage]?,
                 lastImagesUploadResult: FilesResult?,
                 price: ListingPrice?,
                 verticalAttributes: VerticalAttributes?) {
        self.step = step
        self.previousStep = previousStep
        self.category = category
        self.pendingToUploadImages = pendingToUploadImages
        self.lastImagesUploadResult = lastImagesUploadResult
        self.price = price
        self.verticalAttributes = verticalAttributes
    }
    
    func updating(category: PostCategory) -> PostListingState {
        guard step == .categorySelection else { return self }
        let newStep: PostListingStep
        switch category {
        case .car:
            newStep = .carDetailsSelection
        case .realEstate:
            newStep = .addingDetails
        case .unassigned, .motorsAndAccessories:
            newStep = .finished
        }
        return PostListingState(step: newStep,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                verticalAttributes: verticalAttributes)
    }
    
    func updatingStepToUploadingImages() -> PostListingState {
        switch step {
        case .imageSelection, .errorUpload:
            break
        case .uploadingImage, .detailsSelection, .categorySelection, .carDetailsSelection, .finished, .uploadSuccess, .addingDetails:
            return self
        }
        return PostListingState(step: .uploadingImage,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                verticalAttributes: verticalAttributes)
    }
    
    func updating(pendingToUploadImages: [UIImage]) -> PostListingState {
        switch step {
        case .imageSelection:
            break
        case .uploadingImage, .errorUpload, .detailsSelection, .categorySelection, .carDetailsSelection, .finished, .uploadSuccess, .addingDetails:
            return self
        }
        let nextStep: PostListingStep
        if let category = category, category == .car {
            nextStep = .carDetailsSelection
        } else {
            nextStep = .detailsSelection
        }
        
        return PostListingState(step: nextStep,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                verticalAttributes: verticalAttributes)
    }
    
    func updatingAfterUploadingSuccess() -> PostListingState {
        guard step == .uploadSuccess else { return self }
        let nextStep: PostListingStep
        if let currentCategory = category, currentCategory == .realEstate {
            nextStep = .addingDetails
        } else {
            nextStep = .detailsSelection
        }
        return PostListingState(step: nextStep,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                verticalAttributes: verticalAttributes)
    }
    
    
    func updatingToSuccessUpload(uploadedImages: [File]) -> PostListingState {
        guard step == .uploadingImage else { return self }
        return PostListingState(step: .uploadSuccess,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: FilesResult(value: uploadedImages),
                                price: price,
                                verticalAttributes: verticalAttributes)
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
                                verticalAttributes: verticalAttributes)
    }
    
    func updating(price: ListingPrice) -> PostListingState {
        guard step == .detailsSelection || step == .addingDetails  else { return self }
        let newStep: PostListingStep
        if let category = category {
            switch category {
            case .car:
                newStep = .carDetailsSelection
            case .realEstate:
                newStep = .addingDetails
            case .unassigned, .motorsAndAccessories:
                newStep = .finished
            }
        } else {
           newStep = .categorySelection
        }
        return PostListingState(step: newStep,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                verticalAttributes: verticalAttributes)
    }

    
    func updating(carInfo: CarAttributes) -> PostListingState {
        guard step == .carDetailsSelection else { return self }
        return PostListingState(step: .finished,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                verticalAttributes: .carInfo(carInfo))
    }
    
    func updating(realEstateInfo: RealEstateAttributes) -> PostListingState {
        guard step == .addingDetails else { return self }
        return PostListingState(step: .addingDetails,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                verticalAttributes: .realEstateInfo(realEstateInfo))
    }
    
    func revertToPreviousStep() -> PostListingState {
        guard let previousStep = previousStep else { return self }
        return PostListingState(step: previousStep,
                                previousStep: nil,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                verticalAttributes: verticalAttributes)
    }
}

enum PostListingStep: Equatable {
    case imageSelection
    case uploadingImage
    case errorUpload(message: String)
    case detailsSelection
    case uploadSuccess
    
    case categorySelection
    case carDetailsSelection
    
    case finished
    case addingDetails
}

func ==(lhs: PostListingStep, rhs: PostListingStep) -> Bool {
    switch (lhs, rhs) {
    case (.imageSelection, .imageSelection), (.uploadingImage, .uploadingImage), (.detailsSelection, .detailsSelection),
         (.categorySelection, .categorySelection), (.finished, .finished), (.uploadSuccess, .uploadSuccess),
         (.carDetailsSelection, .carDetailsSelection), (.addingDetails, .addingDetails):
        return true
    case (let .errorUpload(lMessage), let .errorUpload(rMessage)):
        return lMessage == rMessage
    default:
        return false
    }
}
