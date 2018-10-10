import Foundation
import LGComponents
import LGCoreKit
import RxSwift
import RxCocoa

protocol ReportSentViewModelDelegate: BaseViewModelDelegate {}

final class ReportSentViewModel: BaseViewModel {

    var navigator: ReportNavigator?
    weak var delegate: ReportSentViewModelDelegate?

    let title = BehaviorRelay<String>(value: "")
    let message = BehaviorRelay<NSAttributedString>(value: NSAttributedString(string: ""))
    let showBlockAction = BehaviorRelay<Bool>(value: false)
    let showReviewAction = BehaviorRelay<Bool>(value: false)

    private let reportSentType: Variable<ReportSentType>
    private let reportedObjectId: String
    private let username: String
    private let userRepository: UserRepository
    private let userRatingRepository: UserRatingRepository
    private let tracker: Tracker
    private let disposeBag = DisposeBag()

    init(reportSentType: ReportSentType,
         reportedObjectId: String,
         username: String,
         userRepository: UserRepository = Core.userRepository,
         userRatingRepository: UserRatingRepository = Core.userRatingRepository,
         tracker: Tracker = TrackerProxy.sharedInstance) {
        self.reportSentType = Variable<ReportSentType>(reportSentType)
        self.reportedObjectId = reportedObjectId
        self.username = username
        self.userRepository = userRepository
        self.userRatingRepository = userRatingRepository
        self.tracker = tracker
        super.init()
    }

    private func setupActions() {
        setupBlockAction()
        setupReviewAction()
    }

    private func setupBlockAction() {
        reportSentType
            .asObservable()
            .subscribeNext(onNext: { [weak self] type in
                guard let strongSelf = self else { return }
                self?.showBlockAction.accept(type.allowsBlockUser)
                self?.title.accept(type.title)
                self?.message.accept(type.attributedMessage(userName: strongSelf.username))
            })
            .disposed(by: disposeBag)
    }

    private func setupReviewAction() {
        let type = reportSentType.value

        guard type == .userBlockAndReviewA ||
            type == .userBlockAndReviewB else { return }

        delegate?.vmShowLoading(nil)

        // User review action is only available if we haven't reviewed
        // the other user yet with a review of type .report
        userRatingRepository.show(reportedObjectId, listingId: nil, type: .report) { [weak self] result in
            self?.delegate?.vmHideLoading(nil, afterMessageCompletion: nil)

            var canReviewUser = false
            if let _ = result.value {
                canReviewUser = false // A Review for this User already exist
            } else if let error = result.error, error.errorCode == RepositoryError.notFound.errorCode {
                canReviewUser = true // This user was never reviewed in a Report
            } else {
                return
            }

            self?.showReviewAction.accept(canReviewUser)

            if !canReviewUser {
                self?.applyFallbackType()
            }
        }
    }

    func applyFallbackType() {
        if reportSentType.value == .userBlockAndReviewA {
            reportSentType.value = .userBlockA
        } else if reportSentType.value == .userBlockAndReviewB {
            reportSentType.value = .userBlockB
        }
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        setupActions()
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
        navigator?.openReviewUser()
    }

    private func trackBlock(_ userId: String) {
        let event = TrackerEvent.profileBlock(.report, blockedUsersIds: [userId], buttonPosition: .others)
        tracker.trackEvent(event)
    }
}
