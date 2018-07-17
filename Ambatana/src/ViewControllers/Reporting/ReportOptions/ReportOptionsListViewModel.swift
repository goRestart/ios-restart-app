import Foundation
import LGCoreKit
import RxSwift

final class ReportOptionsListViewModel: BaseViewModel {
    
    let title: String
    let optionGroup: ReportOptionsGroup
    let showReportButtonActive = Variable<Bool>(false)
    let showAdditionalNotes = Variable<Bool>(false)

    var navigator: ReportNavigator?
    private var selectedOption: ReportOption?

    init(optionGroup: ReportOptionsGroup, title: String) {
        self.optionGroup = optionGroup
        self.title = title
        super.init()
    }

    func didSelect(option: ReportOption) {
        if let child = option.childOptions {
            navigator?.openNextStep(with: child)
        } else {
            showAdditionalNotes.value = option.type.allowsAdditionalNotes
            showReportButtonActive.value = true
        }

        selectedOption = option
    }

    func didTapReport(withAdditionalNotes: String?) {
        guard let type = selectedOption?.type.reportSentType else { return }
        navigator?.openReportSentScreen(type: type)
    }

    func didTapClose() {
        navigator?.closeReporting()
    }
}
