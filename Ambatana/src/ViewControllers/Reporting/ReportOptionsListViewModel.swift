import Foundation
import LGCoreKit

final class ReportOptionsListViewModel: BaseViewModel {
    
    let optionGroup: ReportOptionsGroup
    var navigator: ReportNavigator?

    init(optionGroup: ReportOptionsGroup) {
        self.optionGroup = optionGroup
        super.init()
    }

    func didSelect(option: ReportOption) {
        if let child = option.childOptions {
            navigator?.openNextStep(with: child)
        }
    }

    func didTapReport(with option: ReportOption) {
        navigator?.openThankYouScreen()
        // TODO: Report to backend
    }
}
