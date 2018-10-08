import LGCoreKit
import LGComponents

public enum VerticalAttributes {
    case carInfo(CarAttributes)
    case realEstateInfo(RealEstateAttributes)
    case serviceInfo(ServiceAttributes)
 
    var carAttributes: CarAttributes? {
        switch self {
        case .carInfo(let attributes):
            return attributes
        case .realEstateInfo, .serviceInfo:
            return nil
        }
    }
    
    var realEstateAttributes: RealEstateAttributes? {
        switch self {
        case .realEstateInfo(let attributes):
            return attributes
        case .carInfo, .serviceInfo:
            return nil
        }
    }
    
    var serviceAttributes: ServiceAttributes? {
        switch self {
        case .serviceInfo(let attributes):
            return attributes
        case .carInfo, .realEstateInfo:
            return nil
        }
    }
    
    func generatedTitle(postingFlowType: PostingFlowType) -> String {
        switch self {
        case .carInfo(let carAttributes):
            return carAttributes.generatedTitle
        case .realEstateInfo(let attributes):
            return attributes.generateTitle(postingFlowType: postingFlowType)
        case .serviceInfo(_):
            return ""
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
    let predictionData: MLPredictionDetailsViewData?
    let shareAfterPost: Bool?

    var isRealEstate: Bool {
        guard let category = category, category == .realEstate else { return false }
        return true
    }
    
    var isService: Bool {
        return category?.isService ?? false
    }
    
    var sizeSquareMeters: Int? {
        return verticalAttributes?.realEstateAttributes?.sizeSquareMeters
    }

    var pendingToUploadMedia: Bool {
        let pendingImages = pendingToUploadImages?.count ?? 0
        return pendingImages > 0 || pendingToUploadVideo != nil
    }

    var didUploadMedia: Bool {
        return lastImagesUploadResult?.value != nil || uploadedVideo != nil
    }

    var serviceAttributes: ServiceAttributes {
        return verticalAttributes?.serviceAttributes ?? ServiceAttributes.emptyServicesAttributes()
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
                  title: title,
                  predictionData: nil,
                  shareAfterPost: nil)
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
                 title: String?,
                 predictionData: MLPredictionDetailsViewData?,
                 shareAfterPost: Bool?) {
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
        self.predictionData = predictionData
        self.shareAfterPost = shareAfterPost
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
        case .services:
            newStep = .addingDetails
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
                                title: title,
                                predictionData: predictionData,
                                shareAfterPost: shareAfterPost)
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
                                title: nil,
                                predictionData: predictionData,
                                shareAfterPost: shareAfterPost)
    }
    
    func updatingStepToUploadingImages() -> PostListingState {
        switch step {
        case .imageSelection, .errorUpload:
            break
        case .uploadingImage, .uploadingVideo, .errorVideoUpload, .detailsSelection,
             .categorySelection, .carDetailsSelection, .finished, .uploadSuccess, .addingDetails, .postingListing,
             .postingError:
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
                                title: title,
                                predictionData: predictionData,
                                shareAfterPost: shareAfterPost)
    }
    
    func updating(pendingToUploadImages: [UIImage], predictionData: MLPredictionDetailsViewData?) -> PostListingState {
        switch step {
        case .imageSelection:
            break
        case .uploadingImage, .errorUpload, .uploadingVideo, .errorVideoUpload, .detailsSelection, .categorySelection,
             .carDetailsSelection, .finished, .uploadSuccess, .addingDetails, .postingListing,
             .postingError:
            return self
        }
        let newStep: PostListingStep
        if let currentCategory = category, currentCategory.hasAddingDetailsScreen {
            newStep = .addingDetails
        } else if let predictionData = predictionData, !predictionData.isEmpty {
            newStep = .finished
        } else {
            newStep = .detailsSelection
        }

        let newState = PostListingState(step: newStep,
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
                                        title: title,
                                        predictionData: predictionData,
                                        shareAfterPost: shareAfterPost)

        if let predictionData = predictionData, !predictionData.isEmpty {
            return newState.updatingDetailsFromPredictionData()
        } else {
            return newState
        }
    }

    func updating(pendingToUploadVideo: RecordedVideo) -> PostListingState {
        switch step {
        case .imageSelection:
            break
        case .uploadingImage, .errorUpload, .uploadingVideo, .errorVideoUpload, .detailsSelection, .categorySelection,
             .carDetailsSelection, .finished, .uploadSuccess, .addingDetails, .postingListing,
             .postingError:
            return self
        }
        let newStep: PostListingStep
        if let currentCategory = category, currentCategory.hasAddingDetailsScreen  {
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
                                title: title,
                                predictionData: predictionData,
                                shareAfterPost: shareAfterPost)
    }

    func updatingStepToUploadingVideoSnapshot(uploadingVideo: VideoUpload) -> PostListingState {
        switch step {
        case .imageSelection, .errorVideoUpload, .errorUpload:
            break
        case .uploadingImage, .uploadingVideo, .detailsSelection, .categorySelection, .carDetailsSelection, .finished,
             .uploadSuccess, .addingDetails, .postingListing, .postingError:
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
                                title: title,
                                predictionData: predictionData,
                                shareAfterPost: shareAfterPost)
    }

    func updatingStepToCreatingPreSignedUrl(uploadingVideo: VideoUpload) -> PostListingState {
        switch step {
        case .uploadingVideo, .errorUpload:
            break
        case .imageSelection, .errorVideoUpload, .uploadingImage, .detailsSelection, .categorySelection,
             .carDetailsSelection, .finished, .uploadSuccess, .addingDetails, .postingListing,
             .postingError:
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
                                title: title,
                                predictionData: predictionData,
                                shareAfterPost: shareAfterPost)
    }

    func updatingStepToUploadingVideoFile(uploadingVideo: VideoUpload) -> PostListingState {
        switch step {
        case .uploadingVideo:
            break
        case .imageSelection, .errorVideoUpload, .uploadingImage, .errorUpload, .detailsSelection, .categorySelection,
             .carDetailsSelection, .finished, .uploadSuccess, .addingDetails, .postingListing,
             .postingError:
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
                                title: title,
                                predictionData: predictionData,
                                shareAfterPost: shareAfterPost)
    }

    func updatingToSuccessUpload(uploadedVideo: Video) -> PostListingState {
        switch step {
        case .uploadingVideo:
            break
        case .imageSelection, .errorVideoUpload, .uploadingImage, .errorUpload, .detailsSelection, .categorySelection,
             .carDetailsSelection, .finished, .uploadSuccess, .addingDetails, .postingListing,
             .postingError:
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
                                title: title,
                                predictionData: predictionData,
                                shareAfterPost: shareAfterPost)
    }


    func updatingAfterUploadingSuccess(predictionData: MLPredictionDetailsViewData?) -> PostListingState {
        guard step == .uploadSuccess else { return self }
        let nextStep: PostListingStep
        if let currentCategory = category, currentCategory.hasAddingDetailsScreen {
            nextStep = .addingDetails
        } else if let predictionData = predictionData, !predictionData.isEmpty {
            nextStep = .finished
        } else {
            nextStep = .detailsSelection
        }

        let newState = PostListingState(step: nextStep,
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
                                title: title,
                                predictionData: predictionData,
                                shareAfterPost: shareAfterPost)

        if let predictionData = predictionData, !predictionData.isEmpty {
            return newState.updatingDetailsFromPredictionData()
        } else {
            return newState
        }
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
                                title: title,
                                predictionData: predictionData,
                                shareAfterPost: shareAfterPost)
    }

    func updatingToPosting() -> PostListingState {
        guard step == .finished else { return self }
        return PostListingState(step: .postingListing,
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
                                title: title,
                                predictionData: predictionData,
                                shareAfterPost: shareAfterPost)
    }

    func updatingToPostingError(error: RepositoryError) -> PostListingState {
        guard step == .postingListing else { return self }
        let message: String
        switch error {
        case .internalError, .unauthorized, .notFound, .forbidden, .tooManyRequests, .userNotVerified, .serverError,
             .wsChatError, .searchAlertError:
            message = R.Strings.productPostGenericError
        case .network:
            message = R.Strings.productPostNetworkError
        }
        return PostListingState(step: .postingError(message: message),
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
                                title: title,
                                predictionData: predictionData,
                                shareAfterPost: shareAfterPost)
    }
    
    func updating(uploadError: RepositoryError) -> PostListingState {
        guard step.isUploadingResource() else { return self }
        let message: String
        switch uploadError {
        case .internalError, .unauthorized, .notFound, .forbidden, .tooManyRequests, .userNotVerified, .serverError,
             .wsChatError, .searchAlertError:
            message = R.Strings.productPostGenericError
        case .network:
            message = R.Strings.productPostNetworkError
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
                                title: title,
                                predictionData: predictionData,
                                shareAfterPost: shareAfterPost)
    }
    
    func updating(price: ListingPrice, shareAfterPost: Bool? = nil) -> PostListingState {
        guard step == .detailsSelection || step == .addingDetails  else { return self }
        let newStep: PostListingStep
        if let category = category {
            switch category {
            case .car:
                newStep = .carDetailsSelection
            case .realEstate, .services:
                newStep = .addingDetails
            case .otherItems, .motorsAndAccessories:
                newStep = .finished
            }
        } else {
           newStep = .categorySelection
        }
        let shareAfterPost: Bool? = shareAfterPost ?? self.shareAfterPost
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
                                title: title,
                                predictionData: predictionData,
                                shareAfterPost: shareAfterPost)
    }

    func updatingDetailsFromPredictionData() -> PostListingState {
        guard let predictionData = predictionData else { return self }
        let finalTitle: String? = predictionData.finalTitle
        let finalPrice: Double? = predictionData.finalPrice
        let finalCategory: ListingCategory? = predictionData.finalCategory

        let finalPostCategory: PostCategory?
        if let finalCategoryValue = finalCategory {
            finalPostCategory = PostCategory.otherItems(listingCategory: finalCategoryValue)
        } else {
            finalPostCategory = nil
        }
        let finalListingPrice: ListingPrice?
        if let finalPriceValue = finalPrice {
            finalListingPrice = ListingPrice.normal(finalPriceValue)
        } else {
            finalListingPrice = nil
        }
        return PostListingState(step: step,
                                previousStep: previousStep,
                                category: finalPostCategory ?? category,
                                pendingToUploadImages: pendingToUploadImages,
                                pendingToUploadVideo: pendingToUploadVideo,
                                lastImagesUploadResult: lastImagesUploadResult,
                                uploadingVideo: uploadingVideo,
                                uploadedVideo: uploadedVideo,
                                price: finalListingPrice ?? price,
                                verticalAttributes: verticalAttributes,
                                place: place,
                                title: finalTitle ?? title,
                                predictionData: predictionData,
                                shareAfterPost: shareAfterPost)
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
                                title: title,
                                predictionData: predictionData,
                                shareAfterPost: shareAfterPost)
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
                                title: title,
                                predictionData: predictionData,
                                shareAfterPost: shareAfterPost)
    }
    
    func updating(uploadedImages: [File]) -> PostListingState {
        guard step == .addingDetails else { return self }
        return PostListingState(step: .addingDetails,
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
                                title: title,
                                predictionData: predictionData,
                                shareAfterPost: shareAfterPost)
    }
    
    func updating(servicesInfo: ServiceAttributes,
                  uploadedImages: [File]) -> PostListingState {
        guard step == .addingDetails else { return self }
        return PostListingState(step: .addingDetails,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                pendingToUploadVideo: pendingToUploadVideo,
                                lastImagesUploadResult: FilesResult(value: uploadedImages),
                                uploadingVideo: uploadingVideo,
                                uploadedVideo: uploadedVideo,
                                price: price,
                                verticalAttributes: .serviceInfo(servicesInfo),
                                place: place,
                                title: title,
                                predictionData: predictionData,
                                shareAfterPost: shareAfterPost)
    }
    
    func updating(servicesInfo: ServiceAttributes) -> PostListingState {
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
                                verticalAttributes: .serviceInfo(servicesInfo),
                                place: place,
                                title: title,
                                predictionData: predictionData,
                                shareAfterPost: shareAfterPost)
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
                                title: title,
                                predictionData: predictionData,
                                shareAfterPost: shareAfterPost)
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
                                title: title,
                                predictionData: predictionData,
                                shareAfterPost: shareAfterPost)
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

    // Bulk listing
    case postingListing
    case postingError(message: String)
    
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
         (.carDetailsSelection, .carDetailsSelection), (.addingDetails, .addingDetails), (.postingListing, .postingListing):
        return true
    case (let .errorUpload(lMessage), let .errorUpload(rMessage)):
        return lMessage == rMessage
    case (let .uploadingVideo(lState), let .uploadingVideo(rState)):
        return lState == rState
    case (let .errorVideoUpload(lMessage), let .errorVideoUpload(rMessage)):
        return lMessage == rMessage
    case (let .postingError(lMessage), let .postingError(rMessage)):
        return lMessage == rMessage
    default:
        return false
    }
}
