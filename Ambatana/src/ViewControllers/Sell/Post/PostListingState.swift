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
    
    func generatedTitle(postingFlowType: PostingFlowType) -> String {
        switch self {
        case .carInfo(let carAttributes):
            return carAttributes.generatedTitle
        case .realEstateInfo(let attributes):
            return attributes.generateTitle(postingFlowType: postingFlowType)
        }
    }
}

class PostListingState {
    let step: PostListingStep
    let previousStep: PostListingStep?
    let category: PostCategory?
    let pendingToUploadImages: [UIImage]?
    let pendingToUploadVideo: RecordedVideo?
    let lastImagesUploadResult: FilesResult?
    let uploadingVideo: VideoUpload?
    let uploadedVideo: Video?
    let price: ListingPrice?
    let verticalAttributes: VerticalAttributes?
    let place: Place?
    let title: String?
    
    var isRealEstate: Bool {
        guard let category = category, category == .realEstate else { return false }
        return true
    }
    
    var sizeSquareMeters: Int? {
        return verticalAttributes?.realEstateAttributes?.sizeSquareMeters
    }
    
    
    // MARK: - Lifecycle
    
    convenience init(postCategory: PostCategory?, title: String?) {
        let step: PostListingStep = .imageSelection
        
        self.init(step: step,
                  previousStep: nil,
                  category: postCategory,
                  pendingToUploadImages: nil,
                  pendingToUploadVideo: nil,
                  lastImagesUploadResult: nil,
                  uploadingVideo: nil,
                  uploadedVideo: nil,
                  price: nil,
                  verticalAttributes: nil,
                  place: nil,
                  title: title)
    }
    
    init(step: PostListingStep,
                 previousStep: PostListingStep?,
                 category: PostCategory?,
                 pendingToUploadImages: [UIImage]?,
                 pendingToUploadVideo: RecordedVideo?,
                 lastImagesUploadResult: FilesResult?,
                 uploadingVideo: VideoUpload?,
                 uploadedVideo: Video?,
                 price: ListingPrice?,
                 verticalAttributes: VerticalAttributes?,
                 place: Place?,
                 title: String?) {
        self.step = step
        self.previousStep = previousStep
        self.category = category
        self.pendingToUploadImages = pendingToUploadImages
        self.pendingToUploadVideo = pendingToUploadVideo
        self.lastImagesUploadResult = lastImagesUploadResult
        self.uploadingVideo = uploadingVideo
        self.uploadedVideo = uploadedVideo
        self.price = price
        self.verticalAttributes = verticalAttributes
        self.place = place
        self.title = title
    }
    
    func updating(category: PostCategory) -> PostListingState {
        guard step == .categorySelection else { return self }
        let newStep: PostListingStep
        switch category {
        case .car:
            newStep = .carDetailsSelection
        case .realEstate:
            newStep = .addingDetails
        case .otherItems, .motorsAndAccessories:
            newStep = .finished
        }
        return PostListingState(step: newStep,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                pendingToUploadVideo: pendingToUploadVideo,
                                lastImagesUploadResult: lastImagesUploadResult,
                                uploadingVideo: uploadingVideo,
                                uploadedVideo: uploadedVideo,
                                price: price,
                                verticalAttributes: verticalAttributes,
                                place: place,
                                title: title)
    }
    
    func removeRealEstateCategory() -> PostListingState {
        guard category == .realEstate else { return self }
        return PostListingState(step: step,
                                previousStep: previousStep,
                                category: .otherItems(listingCategory: nil),
                                pendingToUploadImages: pendingToUploadImages,
                                pendingToUploadVideo: pendingToUploadVideo,
                                lastImagesUploadResult: lastImagesUploadResult,
                                uploadingVideo: uploadingVideo,
                                uploadedVideo: uploadedVideo,
                                price: price,
                                verticalAttributes: nil,
                                place: place,
                                title: nil)
    }
    
    func updatingStepToUploadingImages() -> PostListingState {
        switch step {
        case .imageSelection, .errorUpload:
            break
        case .uploadingImage, .uploadingVideo, .errorVideoUpload, .detailsSelection, .categorySelection, .carDetailsSelection, .finished, .uploadSuccess, .addingDetails:
            return self
        }
        return PostListingState(step: .uploadingImage,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                pendingToUploadVideo: pendingToUploadVideo,
                                lastImagesUploadResult: lastImagesUploadResult,
                                uploadingVideo: uploadingVideo,
                                uploadedVideo: uploadedVideo,
                                price: price,
                                verticalAttributes: verticalAttributes,
                                place: place,
                                title: title)
    }
    
    func updating(pendingToUploadImages: [UIImage]) -> PostListingState {
        switch step {
        case .imageSelection:
            break
        case .uploadingImage, .errorUpload, .uploadingVideo, .errorVideoUpload, .detailsSelection, .categorySelection, .carDetailsSelection, .finished, .uploadSuccess, .addingDetails:
            return self
        }
        let newStep: PostListingStep
        if let currentCategory = category, currentCategory == .realEstate {
            newStep = .addingDetails
        } else {
            newStep = .detailsSelection
        }
        return PostListingState(step: newStep,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                pendingToUploadVideo: pendingToUploadVideo,
                                lastImagesUploadResult: lastImagesUploadResult,
                                uploadingVideo: uploadingVideo,
                                uploadedVideo: uploadedVideo,
                                price: price,
                                verticalAttributes: verticalAttributes,
                                place: place,
                                title: title)
    }

    func updating(pendingToUploadVideo: RecordedVideo) -> PostListingState {
        switch step {
        case .imageSelection:
            break
        case .uploadingImage, .errorUpload, .uploadingVideo, .errorVideoUpload, .detailsSelection, .categorySelection, .carDetailsSelection, .finished, .uploadSuccess, .addingDetails:
            return self
        }
        let newStep: PostListingStep
        if let currentCategory = category, currentCategory == .realEstate {
            newStep = .addingDetails
        } else {
            newStep = .detailsSelection
        }
        return PostListingState(step: newStep,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                pendingToUploadVideo: pendingToUploadVideo,
                                lastImagesUploadResult: lastImagesUploadResult,
                                uploadingVideo: uploadingVideo,
                                uploadedVideo: uploadedVideo,
                                price: price,
                                verticalAttributes: verticalAttributes,
                                place: place,
                                title: title)
    }

    func updatingStepToUploadingVideoSnapshot(uploadingVideo: VideoUpload) -> PostListingState {
        switch step {
        case .imageSelection, .errorVideoUpload, .errorUpload:
            break
        case .uploadingImage, .uploadingVideo, .detailsSelection, .categorySelection, .carDetailsSelection, .finished, .uploadSuccess, .addingDetails:
            return self
        }
        return PostListingState(step: .uploadingVideo(state: .uploadingSnapshot),
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                pendingToUploadVideo: pendingToUploadVideo,
                                lastImagesUploadResult: lastImagesUploadResult,
                                uploadingVideo: uploadingVideo,
                                uploadedVideo: uploadedVideo,
                                price: price,
                                verticalAttributes: verticalAttributes,
                                place: place,
                                title: title)
    }

    func updatingStepToCreatingPreSignedUrl(uploadingVideo: VideoUpload) -> PostListingState {
        switch step {
        case .uploadingVideo, .errorUpload:
            break
        case .imageSelection, .errorVideoUpload, .uploadingImage, .detailsSelection, .categorySelection, .carDetailsSelection, .finished, .uploadSuccess, .addingDetails:
            return self
        }
        return PostListingState(step: .uploadingVideo(state: .creatingPreSignedUploadUrl),
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                pendingToUploadVideo: pendingToUploadVideo,
                                lastImagesUploadResult: lastImagesUploadResult,
                                uploadingVideo: uploadingVideo,
                                uploadedVideo: uploadedVideo,
                                price: price,
                                verticalAttributes: verticalAttributes,
                                place: place,
                                title: title)
    }

    func updatingStepToUploadingVideoFile(uploadingVideo: VideoUpload) -> PostListingState {
        switch step {
        case .uploadingVideo:
            break
        case .imageSelection, .errorVideoUpload, .uploadingImage, .errorUpload, .detailsSelection, .categorySelection, .carDetailsSelection, .finished, .uploadSuccess, .addingDetails:
            return self
        }
        return PostListingState(step: .uploadingVideo(state: .uploadingVideo),
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                pendingToUploadVideo: nil,
                                lastImagesUploadResult: lastImagesUploadResult,
                                uploadingVideo: uploadingVideo,
                                uploadedVideo: uploadedVideo,
                                price: price,
                                verticalAttributes: verticalAttributes,
                                place: place,
                                title: title)
    }

    func updatingToSuccessUpload(uploadedVideo: Video) -> PostListingState {
        switch step {
        case .uploadingVideo:
            break
        case .imageSelection, .errorVideoUpload, .uploadingImage, .errorUpload, .detailsSelection, .categorySelection, .carDetailsSelection, .finished, .uploadSuccess, .addingDetails:
            return self
        }
        return PostListingState(step: .uploadSuccess,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: nil,
                                pendingToUploadVideo: nil,
                                lastImagesUploadResult: nil,
                                uploadingVideo: nil,
                                uploadedVideo: uploadedVideo,
                                price: price,
                                verticalAttributes: verticalAttributes,
                                place: place,
                                title: title)
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
                                pendingToUploadVideo: pendingToUploadVideo,
                                lastImagesUploadResult: lastImagesUploadResult,
                                uploadingVideo: uploadingVideo,
                                uploadedVideo: uploadedVideo,
                                price: price,
                                verticalAttributes: verticalAttributes,
                                place: place,
                                title: title)
    }
    
    
    func updatingToSuccessUpload(uploadedImages: [File]) -> PostListingState {
        guard step == .uploadingImage else { return self }
        return PostListingState(step: .uploadSuccess,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                pendingToUploadVideo: pendingToUploadVideo,
                                lastImagesUploadResult: FilesResult(value: uploadedImages),
                                uploadingVideo: uploadingVideo,
                                uploadedVideo: uploadedVideo,
                                price: price,
                                verticalAttributes: verticalAttributes,
                                place: place,
                                title: title)
    }

    
    func updating(uploadError: RepositoryError) -> PostListingState {
        guard step.isUploadingResource() else { return self }
        let message: String
        switch uploadError {
        case .internalError, .unauthorized, .notFound, .forbidden, .tooManyRequests, .userNotVerified, .serverError,
             .wsChatError, .searchAlertError:
            message = LGLocalizedString.productPostGenericError
        case .network:
            message = LGLocalizedString.productPostNetworkError
        }
        
        return PostListingState(step: .errorUpload(message: message),
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                pendingToUploadVideo: pendingToUploadVideo,
                                lastImagesUploadResult: FilesResult(error: uploadError),
                                uploadingVideo: uploadingVideo,
                                uploadedVideo: uploadedVideo,
                                price: price,
                                verticalAttributes: verticalAttributes,
                                place: place,
                                title: title)
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
            case .otherItems, .motorsAndAccessories:
                newStep = .finished
            }
        } else {
           newStep = .categorySelection
        }
        return PostListingState(step: newStep,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                pendingToUploadVideo: pendingToUploadVideo,
                                lastImagesUploadResult: lastImagesUploadResult,
                                uploadingVideo: uploadingVideo,
                                uploadedVideo: uploadedVideo,
                                price: price,
                                verticalAttributes: verticalAttributes,
                                place: place,
                                title: title)
    }

    
    func updating(carInfo: CarAttributes) -> PostListingState {
        guard step == .carDetailsSelection else { return self }
        return PostListingState(step: .finished,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                pendingToUploadVideo: pendingToUploadVideo,
                                lastImagesUploadResult: lastImagesUploadResult,
                                uploadingVideo: uploadingVideo,
                                uploadedVideo: uploadedVideo,
                                price: price,
                                verticalAttributes: .carInfo(carInfo),
                                place: place,
                                title: title)
    }
    
    func updating(realEstateInfo: RealEstateAttributes) -> PostListingState {
        guard step == .addingDetails else { return self }
        return PostListingState(step: .addingDetails,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                pendingToUploadVideo: pendingToUploadVideo,
                                lastImagesUploadResult: lastImagesUploadResult,
                                uploadingVideo: uploadingVideo,
                                uploadedVideo: uploadedVideo,
                                price: price,
                                verticalAttributes: .realEstateInfo(realEstateInfo),
                                place: place,
                                title: title)
    }
    
    func revertToPreviousStep() -> PostListingState {
        guard let previousStep = previousStep else { return self }
        return PostListingState(step: previousStep,
                                previousStep: nil,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                pendingToUploadVideo: pendingToUploadVideo,
                                lastImagesUploadResult: lastImagesUploadResult,
                                uploadingVideo: uploadingVideo,
                                uploadedVideo: uploadedVideo,
                                price: price,
                                verticalAttributes: verticalAttributes,
                                place: place,
                                title: title)
    }
    
    func updating(place: Place) -> PostListingState {
        guard step == .addingDetails else { return self }
        return PostListingState(step: .addingDetails,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                pendingToUploadVideo: pendingToUploadVideo,
                                lastImagesUploadResult: lastImagesUploadResult,
                                uploadingVideo: uploadingVideo,
                                uploadedVideo: uploadedVideo,
                                price: price,
                                verticalAttributes: verticalAttributes,
                                place: place,
                                title: title)
    }
}

enum VideoUploadState {
    case uploadingSnapshot
    case creatingPreSignedUploadUrl
    case uploadingVideo
}

enum PostListingStep: Equatable {
    case imageSelection
    case uploadingImage
    case errorUpload(message: String)
    case uploadingVideo(state: VideoUploadState)
    case errorVideoUpload(message: String)
    case detailsSelection
    case uploadSuccess
    
    case categorySelection
    case carDetailsSelection
    
    case finished
    case addingDetails
    
    func isUploadingResource() -> Bool {
        if case .uploadingVideo = self {
            return true
        } else if case .uploadingImage = self {
            return true
        }
        return  false
    }
}

func ==(lhs: PostListingStep, rhs: PostListingStep) -> Bool {
    switch (lhs, rhs) {
    case (.imageSelection, .imageSelection), (.uploadingImage, .uploadingImage), (.detailsSelection, .detailsSelection),
         (.categorySelection, .categorySelection), (.finished, .finished), (.uploadSuccess, .uploadSuccess),
         (.carDetailsSelection, .carDetailsSelection), (.addingDetails, .addingDetails):
        return true
    case (let .errorUpload(lMessage), let .errorUpload(rMessage)):
        return lMessage == rMessage
    case (let .uploadingVideo(lState), let .uploadingVideo(rState)):
        return lState == rState
    default:
        return false
    }
}
