import Foundation
import LGComponents

final class ReportSentViewModel: BaseViewModel {

    let type: ReportSentType
    var navigator: ReportNavigator?

    init(type: ReportSentType) {
        self.type = type
        super.init()
    }

    func didTapClose() {
        navigator?.closeReporting()
    }
}
