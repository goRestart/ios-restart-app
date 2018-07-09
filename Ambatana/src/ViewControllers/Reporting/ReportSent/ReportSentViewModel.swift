import Foundation

final class ReportSentViewModel: BaseViewModel {

    let type: ReportSentType

    init(type: ReportSentType) {
        self.type = type
        super.init()
    }
}
