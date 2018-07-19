import Foundation
import LGCoreKit
import RxSwift
import RxCocoa
import LGComponents

protocol ListingCardDetailsViewModel: class {
    var cardProductInfo: Observable<ListingVMProductInfo?> { get }
}

protocol ListingCardViewCellModel: ListingCardDetailsViewModel {
    var cardListingObs: Observable<Listing> { get }

    var cardStatus: Observable<ListingViewModelStatus> { get }
    var cardActionButtons: Observable<[UIAction]> { get }

    var cardIsFavoritable: Bool { get }
    var cardIsFeatured: Observable<Bool> { get  }

    var productIsFavorite: Observable<Bool> { get }

    var cardQuickAnswers: [QuickAnswer] { get }
    var cardDirectChatEnabled: Observable<Bool> { get }
    var cardDirectChatMessages: Observable<CollectionChange<ChatViewMessage>> { get }
    var cardBumpUpBannerInfo: Observable<BumpUpInfo?> { get }
}

extension ListingViewModel: ListingCardViewCellModel {

    // MARK: ListingCardDetailsViewModel
    var cardProductInfo: Observable<ListingVMProductInfo?> { return productInfo.asObservable() }

    // MARK: ListingCardViewCellModel
    var cardListingObs: Observable<Listing> { return listing.asObservable() }
    var cardStatus: Observable<ListingViewModelStatus>  { return status.asObservable() }
    var cardActionButtons: Observable<[UIAction]> { return actionButtons.asObservable() }

    var cardIsFavoritable: Bool { return !isMine }
    var cardIsFeatured: Observable<Bool> { return isShowingFeaturedStripe.asObservable() }
    var productIsFavorite: Observable<Bool> { return isFavorite.asObservable() }

    var cardQuickAnswers: [QuickAnswer] { return quickAnswers }
    var cardDirectChatEnabled: Observable<Bool> { return directChatEnabled.asObservable() }
    var cardDirectChatMessages: Observable<CollectionChange<ChatViewMessage>> { return directChatMessages.changesObservable }

    var cardBumpUpBannerInfo: Observable<BumpUpInfo?> { return bumpUpBannerInfo.asObservable() }
}
