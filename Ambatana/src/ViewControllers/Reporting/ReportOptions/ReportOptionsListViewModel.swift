import Foundation
import LGCoreKit
import LGComponents

final class ReportOptionsListViewModel: BaseViewModel {
    
    let optionGroup: ReportOptionsGroup
    let title: String
    var navigator: ReportNavigator?

    init(optionGroup: ReportOptionsGroup, title: String) {
        self.optionGroup = optionGroup
        self.title = title
        super.init()
    }

    func didSelect(option: ReportOption) {
        if let child = option.childOptions {
            navigator?.openNextStep(with: child)
        }
    }

    func didTapReport(with option: ReportOption) {
        guard let type = option.type.reportSentType else { return }
        navigator?.openReportSentScreen(type: type)
    }

    func didTapClose() {
        navigator?.closeReporting()
    }
}
