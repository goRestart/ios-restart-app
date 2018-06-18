
import LGCoreKit

struct PostingParamsImageAssigner {
    
    static func assign(images: [File]?,
                       toFirstItemInParams params: [ListingCreationParams]) -> [ListingCreationParams] {
        // There's a product requirement to upload all the images to only the first listing on multiselect.
        guard let uploadedImages = images,
            let firstListing = params.first else {
                return params
        }
        
        var newParams = params
        newParams[0] = firstListing.updating(images: uploadedImages)
        return newParams
    }
}
