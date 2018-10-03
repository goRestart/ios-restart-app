import Foundation
import LGComponents

final class ListingDeckOnBoardingViewModel: BaseViewModel, ListingDeckOnBoardingViewModelType {
    var navigator: ListingDeckOnBoardingNavigator?
    func close() { navigator?.close() }
}
