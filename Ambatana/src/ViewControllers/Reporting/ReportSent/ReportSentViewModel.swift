import Foundation
import LGComponents
import RxSwift

final class ReportSentViewModel: BaseViewModel {

    let type: ReportSentType
    var navigator: ReportNavigator?

    let showBlockAction = Variable<Bool>(false)
    let showReviewAction = Variable<Bool>(false)

    init(type: ReportSentType) {
        self.type = type
        super.init()
        setupActions()
    }

    private func setupActions() {
        showBlockAction.value = type.allowsBlockUser
        showReviewAction.value = true
    }

    func didTapClose() {
        navigator?.closeReporting()
    }

    func didTapBlock() {

    }

    func didTapReview() {
        
    }
}
