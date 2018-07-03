import Foundation
import LGCoreKit

final class ReportOptionsListViewModel: BaseViewModel {
    
    let optionGroup: ReportOptionsGroup
    var navigator: ReportProductNavigator?

    init(optionGroup: ReportOptionsGroup) {
        self.optionGroup = optionGroup
        super.init()
    }

    func didSelect(option: ReportOption) {
        if let child = option.childOptions {
            navigator?.openNextStep(with: child)
        }
    }
}
