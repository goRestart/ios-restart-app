import Foundation
import LGComponents

final class EmptyViewModelBuilder {
    
    private enum EmptyType {
        case emptySearch
        case emptyListing
        case emptySearchFlagOn
    }
    
    private let emptyType: EmptyType
    private let isRealEstateSearch: Bool
    private let hasPerformedSearch: Bool
    
    init(hasPerformedSearch: Bool, isRealEstateSearch: Bool) {
        self.isRealEstateSearch = isRealEstateSearch
        self.hasPerformedSearch = hasPerformedSearch
        self.emptyType = hasPerformedSearch ? .emptySearch : .emptyListing
    }
    
    func build() -> LGEmptyViewModel {
        let errImage: UIImage?
        let errTitle: String?
        let errBody: String?
        
        switch emptyType {
        case .emptyListing:
            errImage = R.Asset.Errors.errListNoProducts.image
            errTitle = R.Strings.productListNoProductsTitle
            errBody = R.Strings.productListNoProductsBody
        case .emptySearch, .emptySearchFlagOn:
            errImage = R.Asset.Errors.errSearchNoProducts.image
            errTitle = isRealEstateSearch ? R.Strings.realEstateEmptyStateSearchTitle : R.Strings.productSearchNoProductsTitle
            errBody = isRealEstateSearch ? R.Strings.realEstateEmptyStateSearchSubtitle : R.Strings.productSearchNoProductsBody
        }
        
        return LGEmptyViewModel(icon: errImage,
                                title: errTitle,
                                body: errBody,
                                buttonTitle: nil,
                                action: nil,
                                secondaryButtonTitle: nil,
                                secondaryAction: nil,
                                emptyReason: nil,
                                errorCode: nil,
                                errorDescription: nil,
                                errorRequestHost: nil)
    }
}
