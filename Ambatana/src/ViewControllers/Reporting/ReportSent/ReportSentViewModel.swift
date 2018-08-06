import Foundation
import LGComponents
import LGCoreKit
import RxSwift

protocol ReportSentViewModelDelegate: BaseViewModelDelegate {}

final class ReportSentViewModel: BaseViewModel {

    var navigator: ReportNavigator?
    weak var delegate: ReportSentViewModelDelegate?

    let title = Variable<String>("")
    let message = Variable<NSAttributedString>(NSAttributedString(string: ""))
    let showBlockAction = Variable<Bool>(false)
    let showReviewAction = Variable<Bool>(false)

    private let reportSentType: Variable<ReportSentType>
    private let reportedObjectId: String
    private let userRepository: UserRepository
    private let userRatingRepository: UserRatingRepository
    private let tracker: Tracker
    private let disposeBag = DisposeBag()

    init(reportSentType: ReportSentType,
         reportedObjectId: String,
         userRepository: UserRepository = Core.userRepository,
         userRatingRepository: UserRatingRepository = Core.userRatingRepository,
         tracker: Tracker = TrackerProxy.sharedInstance) {
        self.reportSentType = Variable<ReportSentType>(reportSentType)
        self.reportedObjectId = reportedObjectId
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
                self?.showBlockAction.value = type.allowsBlockUser
                self?.title.value = type.title
                self?.message.value = type.attributedMessage(userName: "Fuuu") // FIXME: fix user name
            })
            .disposed(by: disposeBag)
    }

    private func setupReviewAction() {
        let type = reportSentType.value

        guard type == .userBlockAndReviewA ||
            type == .userBlockAndReviewB else { return }

        delegate?.vmShowLoading(nil)

        // User review action is only available if a review between
        // reported and current users exists without listing id.
        userRatingRepository.show(reportedObjectId, listingId: nil, type: .buyer) { [weak self] result in
            self?.delegate?.vmHideLoading(nil, afterMessageCompletion: nil)

            var canReviewUser = false
            if let _ = result.value {
                canReviewUser = false
            } else if let error = result.error, error.errorCode == RepositoryError.notFound.errorCode {
                canReviewUser = true
            } else {
                return
            }

            self?.showReviewAction.value = canReviewUser

            // Fallback to different ReportSentType to show different info
            if !canReviewUser, type == .userBlockAndReviewA {
                self?.reportSentType.value = .userBlockA
            } else if !canReviewUser, type == .userBlockAndReviewB {
                self?.reportSentType.value = .userBlockB
            }
        }
    }

    func viewWillAppear() {
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
        
    }

    private func trackBlock(_ userId: String) {
        let event = TrackerEvent.profileBlock(.profile, blockedUsersIds: [userId], buttonPosition: .others)
        tracker.trackEvent(event)
    }
}
