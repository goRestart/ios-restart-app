import LGCoreKit
import LGComponents

final class MLPostListingState {
    let step: MLPostListingStep
    let previousStep: MLPostListingStep?
    let category: PostCategory?
    let pendingToUploadImages: [UIImage]?
    let lastImagesUploadResult: FilesResult?
    let price: ListingPrice?
    let verticalAttributes: VerticalAttributes?
    let place: Place?
    let title: String?
    var predictionData: MLPredictionDetailsViewData?
    
    var isRealEstate: Bool {
        guard let category = category, category == .realEstate else { return false }
        return true
    }
    
    var sizeSquareMeters: Int? {
        return verticalAttributes?.realEstateAttributes?.sizeSquareMeters
    }
    
    
    // MARK: - Lifecycle
    
    convenience init(postCategory: PostCategory?, title: String?) {
        let step: MLPostListingStep = .imageSelection
        
        self.init(step: step,
                  previousStep: nil,
                  category: postCategory,
                  pendingToUploadImages: nil,
                  lastImagesUploadResult: nil,
                  price: nil,
                  verticalAttributes: nil,
                  place: nil,
                  title: title,
                  predictionData: nil)
    }
    
    private init(step: MLPostListingStep,
                 previousStep: MLPostListingStep?,
                 category: PostCategory?,
                 pendingToUploadImages: [UIImage]?,
                 lastImagesUploadResult: FilesResult?,
                 price: ListingPrice?,
                 verticalAttributes: VerticalAttributes?,
                 place: Place?,
                 title: String?,
                 predictionData: MLPredictionDetailsViewData?) {
        self.step = step
        self.previousStep = previousStep
        self.category = category
        self.pendingToUploadImages = pendingToUploadImages
        self.lastImagesUploadResult = lastImagesUploadResult
        self.price = price
        self.verticalAttributes = verticalAttributes
        self.place = place
        self.title = title
        self.predictionData = predictionData
    }
    
    func updating(category: PostCategory) -> MLPostListingState {
        guard step == .categorySelection else { return self }
        let newStep: MLPostListingStep
        switch category {
        case .car:
            newStep = .carDetailsSelection
        case .realEstate:
            newStep = .addingDetails
        case .otherItems, .motorsAndAccessories, .services:
            newStep = .finished
        }
        return MLPostListingState(step: newStep,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                verticalAttributes: verticalAttributes,
                                place: place,
                                title: title,
                                predictionData: predictionData)
    }
    
    func removeRealEstateCategory() -> MLPostListingState {
        guard category == .realEstate else { return self }
        return MLPostListingState(step: step,
                                previousStep: previousStep,
                                category: .otherItems(listingCategory: nil),
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                verticalAttributes: nil,
                                place: place,
                                title: nil,
                                predictionData: predictionData)
    }
    
    func updatingStepToUploadingImages() -> MLPostListingState {
        switch step {
        case .imageSelection, .errorUpload:
            break
        case .uploadingImage, .detailsSelection, .categorySelection, .carDetailsSelection, .finished, .uploadSuccess, .addingDetails:
            return self
        }
        return MLPostListingState(step: .uploadingImage,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                verticalAttributes: verticalAttributes,
                                place: place,
                                title: title,
                                predictionData: predictionData)
    }
    
    func updating(pendingToUploadImages: [UIImage]) -> MLPostListingState {
        switch step {
        case .imageSelection:
            break
        case .uploadingImage, .errorUpload, .detailsSelection, .categorySelection, .carDetailsSelection, .finished, .uploadSuccess, .addingDetails:
            return self
        }
        let newStep: MLPostListingStep
        if let currentCategory = category, currentCategory == .realEstate {
            newStep = .addingDetails
        } else {
            newStep = .detailsSelection
        }
        return MLPostListingState(step: newStep,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                verticalAttributes: verticalAttributes,
                                place: place,
                                title: title,
                                predictionData: predictionData)
    }
    
    func updatingAfterUploadingSuccess() -> MLPostListingState {
        guard step == .uploadSuccess else { return self }
        let nextStep: MLPostListingStep
        if let currentCategory = category, currentCategory == .realEstate {
            nextStep = .addingDetails
        } else if let predictionData = predictionData, !predictionData.isEmpty {
            return updating(machineLearningData: predictionData, nextStep: .finished)
        } else {
            nextStep = .detailsSelection
        }
        return MLPostListingState(step: nextStep,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                verticalAttributes: verticalAttributes,
                                place: place,
                                title: title,
                                predictionData: predictionData)
    }
    
    
    func updatingToSuccessUpload(uploadedImages: [File]) -> MLPostListingState {
        guard step == .uploadingImage else { return self }
        return MLPostListingState(step: .uploadSuccess,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: FilesResult(value: uploadedImages),
                                price: price,
                                verticalAttributes: verticalAttributes,
                                place: place,
                                title: title,
                                predictionData: predictionData)
    }
    
    func updating(uploadError: RepositoryError) -> MLPostListingState {
        guard step == .uploadingImage else { return self }
        let message: String
        switch uploadError {
        case .internalError, .unauthorized, .notFound, .forbidden, .tooManyRequests, .userNotVerified, .serverError,
             .wsChatError, .searchAlertError:
            message = R.Strings.productPostGenericError
        case .network:
            message = R.Strings.productPostNetworkError
        }
        
        return MLPostListingState(step: .errorUpload(message: message),
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: FilesResult(error: uploadError),
                                price: price,
                                verticalAttributes: verticalAttributes,
                                place: place,
                                title: title,
                                predictionData: predictionData)
    }
    
    func updating(price: ListingPrice) -> MLPostListingState {
        guard step == .detailsSelection || step == .addingDetails  else { return self }
        let newStep: MLPostListingStep
        if let category = category {
            switch category {
            case .car:
                newStep = .carDetailsSelection
            case .realEstate:
                newStep = .addingDetails
            case .otherItems, .motorsAndAccessories, .services:
                newStep = .finished
            }
        } else {
           newStep = .categorySelection
        }
        return MLPostListingState(step: newStep,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                verticalAttributes: verticalAttributes,
                                place: place,
                                title: title,
                                predictionData: predictionData)
    }
    
    func updating(machineLearningData: MLPredictionDetailsViewData, nextStep: MLPostListingStep) -> MLPostListingState {
        let finalTitle: String? =
            machineLearningData.userChangedPredictedTitle ? machineLearningData.title : nil
        let finalPrice: Double? =
            machineLearningData.userChangedPredictedPrice ? machineLearningData.price : machineLearningData.predictedPrice
        let finalCategory: ListingCategory? =
            machineLearningData.userChangedPredictedCategory ? machineLearningData.category : machineLearningData.predictedCategory
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
        return MLPostListingState(step: nextStep,
                                  previousStep: step,
                                  category: finalPostCategory ?? category,
                                  pendingToUploadImages: pendingToUploadImages,
                                  lastImagesUploadResult: lastImagesUploadResult,
                                  price: finalListingPrice ?? price,
                                  verticalAttributes: verticalAttributes,
                                  place: place,
                                  title: finalTitle ?? title,
                                  predictionData: predictionData)
    }

    
    func updating(carInfo: CarAttributes) -> MLPostListingState {
        guard step == .carDetailsSelection else { return self }
        return MLPostListingState(step: .finished,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                verticalAttributes: .carInfo(carInfo),
                                place: place,
                                title: title,
                                predictionData: predictionData)
    }
    
    func updating(realEstateInfo: RealEstateAttributes) -> MLPostListingState {
        guard step == .addingDetails else { return self }
        return MLPostListingState(step: .addingDetails,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                verticalAttributes: .realEstateInfo(realEstateInfo),
                                place: place,
                                title: title,
                                predictionData: predictionData)
    }
    
    func revertToPreviousStep() -> MLPostListingState {
        guard let previousStep = previousStep else { return self }
        return MLPostListingState(step: previousStep,
                                previousStep: nil,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                verticalAttributes: verticalAttributes,
                                place: place,
                                title: title,
                                predictionData: predictionData)
    }
    
    func updating(place: Place) -> MLPostListingState {
        guard step == .addingDetails else { return self }
        return MLPostListingState(step: .addingDetails,
                                previousStep: step,
                                category: category,
                                pendingToUploadImages: pendingToUploadImages,
                                lastImagesUploadResult: lastImagesUploadResult,
                                price: price,
                                verticalAttributes: verticalAttributes,
                                place: place,
                                title: title,
                                predictionData: predictionData)
    }
}

enum MLPostListingStep: Equatable {
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

func ==(lhs: MLPostListingStep, rhs: MLPostListingStep) -> Bool {
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
