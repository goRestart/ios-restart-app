import LGComponents
import LGCoreKit

final class EmbeddedListingViewModel: BaseViewModel {

    private let interestedStateManager: InterestedStateUpdater
    private let myUserRepository: MyUserRepository
    
    init(interestedStateManager: InterestedStateUpdater = LGInterestedStateUpdater(),
         myUserRepository: MyUserRepository = Core.myUserRepository) {
        self.interestedStateManager = interestedStateManager
        self.myUserRepository = myUserRepository
        super.init()
    }

    func updateFeedData(_ data: FeedListingData) -> FeedListingData {
        let newState = data.listing.interestedState(myUserRepository: myUserRepository,
                                                    listingInterestStates: interestedStateManager.listingInterestStates)
        return FeedListingData.Lenses.interestedState.set(newState, data)
    }
}
