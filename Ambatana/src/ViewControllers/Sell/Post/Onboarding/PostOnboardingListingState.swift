//
//  PostOnboardingListingState.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 05/12/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

class PostOnboardingListingState: PostListingState {
    
    let postOnboardingStep: PostOnboardingListingStep
    
    
    // MARK: Lifecycle
    
    convenience init(postListingState: PostListingState) {
        let postOnboardingStep: PostOnboardingListingStep = .imageSelection
        
        self.init(postOnboardingStep: postOnboardingStep,
                  step: postListingState.step,
                  previousStep: postListingState.previousStep,
                  category: postListingState.category,
                  pendingToUploadImages: postListingState.pendingToUploadImages,
                  lastImagesUploadResult: postListingState.lastImagesUploadResult,
                  price: postListingState.price,
                  verticalAttributes: postListingState.verticalAttributes,
                  place: postListingState.place)
    }
    
    required init(postOnboardingStep: PostOnboardingListingStep,
                 step: PostListingStep,
                 previousStep: PostListingStep?,
                 category: PostCategory?,
                 pendingToUploadImages: [UIImage]?,
                 lastImagesUploadResult: FilesResult?,
                 price: ListingPrice?,
                 verticalAttributes: VerticalAttributes?,
                 place: Place?) {
        self.postOnboardingStep = postOnboardingStep
        super.init(step: step,
                   previousStep: previousStep,
                   category: category,
                   pendingToUploadImages: pendingToUploadImages,
                   lastImagesUploadResult: lastImagesUploadResult,
                   price: price,
                   verticalAttributes: verticalAttributes,
                   place: place)
    }
    
    
    // MARK: - Updating
    
    override func updatingStepToUploadingImages() -> PostOnboardingListingState {
        switch postOnboardingStep {
        case .imageSelection, .imageUploadError:
            break
        case .uploadingImage, .imageUploadSuccess, .listingCreationSuccess, .listingCreationError:
            return self
        }
        return PostOnboardingListingState(postOnboardingStep: .uploadingImage,
                                          step: step,
                                          previousStep: previousStep,
                                          category: category,
                                          pendingToUploadImages: pendingToUploadImages,
                                          lastImagesUploadResult: lastImagesUploadResult,
                                          price: price,
                                          verticalAttributes: verticalAttributes,
                                          place: place)
    }
    
    func updatingStepToImageUploadSuccess() -> PostOnboardingListingState {
        switch postOnboardingStep {
        case .uploadingImage:
            break
        case .imageSelection, .imageUploadError, .imageUploadSuccess, .listingCreationSuccess, .listingCreationError:
            return self
        }
        return PostOnboardingListingState(postOnboardingStep: .imageUploadSuccess,
                                          step: step,
                                          previousStep: previousStep,
                                          category: category,
                                          pendingToUploadImages: pendingToUploadImages,
                                          lastImagesUploadResult: lastImagesUploadResult,
                                          price: price,
                                          verticalAttributes: verticalAttributes,
                                          place: place)
    }
    
    func updatingStepToImageUploadError(_ uploadError: RepositoryError) -> PostOnboardingListingState {
        switch postOnboardingStep {
        case .uploadingImage:
            break
        case .imageSelection, .imageUploadError, .imageUploadSuccess, .listingCreationSuccess, .listingCreationError:
            return self
        }
        
        let message: String
        switch uploadError {
        case .internalError, .unauthorized, .notFound, .forbidden, .tooManyRequests, .userNotVerified, .serverError, .wsChatError:
            message = LGLocalizedString.productPostGenericError
        case .network:
            message = LGLocalizedString.productPostNetworkError
        }
        
        return PostOnboardingListingState(postOnboardingStep: .imageUploadError(message: message),
                                          step: step,
                                          previousStep: previousStep,
                                          category: category,
                                          pendingToUploadImages: pendingToUploadImages,
                                          lastImagesUploadResult: lastImagesUploadResult,
                                          price: price,
                                          verticalAttributes: verticalAttributes,
                                          place: place)
    }
    
    func updatingStepToListingCreationSuccess() -> PostOnboardingListingState {
        switch postOnboardingStep {
        case .imageUploadSuccess:
            break
        case .imageSelection, .uploadingImage, .imageUploadError, .listingCreationSuccess, .listingCreationError:
            return self
        }
        return PostOnboardingListingState(postOnboardingStep: .listingCreationSuccess,
                                          step: step,
                                          previousStep: previousStep,
                                          category: category,
                                          pendingToUploadImages: pendingToUploadImages,
                                          lastImagesUploadResult: lastImagesUploadResult,
                                          price: price,
                                          verticalAttributes: verticalAttributes,
                                          place: place)
    }
    
    func updatingStepToListingCreationError(_ uploadError: RepositoryError) -> PostOnboardingListingState {
        switch postOnboardingStep {
        case .imageUploadSuccess:
            break
        case .imageSelection, .uploadingImage, .imageUploadError, .listingCreationSuccess, .listingCreationError:
            return self
        }
        
        let message: String
        switch uploadError {
        case .internalError, .unauthorized, .notFound, .forbidden, .tooManyRequests, .userNotVerified, .serverError, .wsChatError:
            message = LGLocalizedString.productPostGenericError
        case .network:
            message = LGLocalizedString.productPostNetworkError
        }
        
        return PostOnboardingListingState(postOnboardingStep: .listingCreationError(message: message),
                                          step: step,
                                          previousStep: previousStep,
                                          category: category,
                                          pendingToUploadImages: pendingToUploadImages,
                                          lastImagesUploadResult: lastImagesUploadResult,
                                          price: price,
                                          verticalAttributes: verticalAttributes,
                                          place: place)
    }
    
}

enum PostOnboardingListingStep: Equatable {
    case imageSelection
    case uploadingImage
    case imageUploadSuccess
    case imageUploadError(message: String)
    case listingCreationSuccess
    case listingCreationError(message: String)
}

func ==(lhs: PostOnboardingListingStep, rhs: PostOnboardingListingStep) -> Bool {
    switch (lhs, rhs) {
    case (.imageSelection, .imageSelection), (.uploadingImage, .uploadingImage), (.imageUploadSuccess, .imageUploadSuccess),
         (.listingCreationSuccess, .listingCreationSuccess):
        return true
    case (let .imageUploadError(lMessage), let .imageUploadError(rMessage)),
          (let .listingCreationError(lMessage), let .listingCreationError(rMessage)):
        return lMessage == rMessage
    default:
        return false
    }
}
