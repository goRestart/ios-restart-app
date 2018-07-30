import Foundation
import LGComponents
import LGCoreKit
import RxSwift

protocol ReportSentViewModelDelegate: BaseViewModelDelegate { }

final class ReportSentViewModel: BaseViewModel {

    let type: ReportSentType
    var navigator: ReportNavigator?
    weak var delegate: ReportSentViewModelDelegate?

    let showBlockAction = Variable<Bool>(false)
    let showReviewAction = Variable<Bool>(false)

    private let reportedObjectId: String
    private let userRepository: UserRepository
    private let tracker: Tracker

    init(type: ReportSentType,
         reportedObjectId: String,
         userRepository: UserRepository = Core.userRepository,
         tracker: Tracker = TrackerProxy.sharedInstance) {
        self.type = type
        self.reportedObjectId = reportedObjectId
        self.userRepository = userRepository
        self.tracker = tracker
        super.init()
        setupActions()
    }

    private func setupActions() {
        showBlockAction.value = type.allowsBlockUser
        showReviewAction.value = true

        // Check if current user can leave a review of the reported user
    }

    func didTapClose() {
        navigator?.closeReporting()
    }

    func didTapBlock() {
        delegate?.vmShowLoading(R.Strings.commonLoading)
        let userId = reportedObjectId

        userRepository.blockUserWithId(userId) { [weak self] result in
            self?.trackBlock(userId)
            switch result {
            case .success:
                self?.delegate?.vmHideLoading(nil) {
                    self?.navigator?.closeReporting()
                }
            case .failure:
                self?.delegate?.vmHideLoading(nil) {
                    self?.delegate?.vmShowAutoFadingMessage(R.Strings.blockUserErrorGeneric,
                                                            completion: nil)
                }
            }
        }
    }

    func didTapReview() {
        
    }

    private func trackBlock(_ userId: String) {
        let event = TrackerEvent.profileBlock(.profile, blockedUsersIds: [userId], buttonPosition: .others)
        tracker.trackEvent(event)
    }
}
