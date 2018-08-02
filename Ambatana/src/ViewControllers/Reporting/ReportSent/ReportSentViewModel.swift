import Foundation
import LGComponents
import LGCoreKit
import RxSwift

protocol ReportSentViewModelDelegate: BaseViewModelDelegate { }

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
        setupActions()
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
        guard reportSentType.value == .userBlockAndReviewA ||
            reportSentType.value == .userBlockAndReviewB else {
            showReviewAction.value = true
            return
        }

        // Check if current user can leave a review of the reported user
        userRatingRepository.show(reportedObjectId, listingId: nil, type: .conversation) { result in
            print(result)
        }

        //showReviewAction.value = true
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
