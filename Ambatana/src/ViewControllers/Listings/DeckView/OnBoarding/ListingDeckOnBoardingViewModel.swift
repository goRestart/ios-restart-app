import Foundation
import LGComponents

protocol ListingDeckOnBoardingNavigator: class {
    func closeDeckOnboarding()
}

final class ListingDeckOnBoardingViewModel: BaseViewModel, ListingDeckOnBoardingViewModelType {

    weak var navigator: ListingDeckOnBoardingNavigator?
    func close() { navigator?.closeDeckOnboarding() }

}
