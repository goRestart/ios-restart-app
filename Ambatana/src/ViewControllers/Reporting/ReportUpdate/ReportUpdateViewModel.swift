import Foundation
import LGComponents

final class ReportUpdateViewModel: BaseViewModel {

    let type: ReportUpdateType
    var navigator: ReportNavigator?

    init(type: ReportUpdateType) {
        self.type = type
        super.init()
    }

    func didTapClose() {
        navigator?.closeReporting()
    }
}
