import Foundation
import LGCoreKit
import LGComponents
import RxSwift
import RxCocoa

final class P2PPaymentsGetPayCodeViewModel: BaseViewModel {
    private static let retryInterval: TimeInterval = 5
    private static let maxRetryAttempts: Int = 4

    var navigator: P2PPaymentsOfferStatusNavigator?
    private let offerId: String
    private var payCode: String?
    private let p2pPaymentsRepository: P2PPaymentsRepository
    private let myUserRepository: MyUserRepository
    private let installationRepository: InstallationRepository
    private let uiStateRelay = BehaviorRelay<UIState>(value: .loading)

    convenience init(offerId: String) {
        self.init(offerId: offerId,
                  p2pPaymentsRepository: Core.p2pPaymentsRepository,
                  myUserRepository: Core.myUserRepository,
                  installationRepository: Core.installationRepository)
    }

    init(offerId: String,
         p2pPaymentsRepository: P2PPaymentsRepository,
         myUserRepository: MyUserRepository,
         installationRepository: InstallationRepository) {
        self.offerId = offerId
        self.p2pPaymentsRepository = p2pPaymentsRepository
        self.myUserRepository = myUserRepository
        self.installationRepository = installationRepository
        super.init()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        if firstTime {
            getPayCode(attempt: 0)
        }
    }

    private func getPayCode(attempt: Int) {
        p2pPaymentsRepository.getPayCode(offerId: offerId) { [weak self] result in
            switch result {
            case .success(let payCode):
                self?.payCode = payCode
                self?.updateUIState()
            case .failure:
                // Fail silently and retry after N seconds
                if attempt < P2PPaymentsGetPayCodeViewModel.maxRetryAttempts {
                    let deadline: DispatchTime = .now() + P2PPaymentsGetPayCodeViewModel.retryInterval
                    DispatchQueue.main.asyncAfter(deadline: deadline) {
                        self?.getPayCode(attempt: attempt + 1)
                    }
                } else {
                    self?.uiStateRelay.accept(.error)
                }
            }
        }
    }

    private func updateUIState() {
        guard let payCode = payCode else {
            uiStateRelay.accept(.loading)
            return
        }
        uiStateRelay.accept(.payCodeLoaded(payCode))
    }
}

// MARK: - UI State

extension P2PPaymentsGetPayCodeViewModel {
    enum UIState {
        case loading
        case payCodeLoaded(String)
        case error

        var showActivityIndicator: Bool {
            switch self {
            case .loading: return true
            case .payCodeLoaded: return false
            case .error: return false
            }
        }

        var payCode: String? {
            switch self {
            case .loading: return nil
            case .payCodeLoaded(let payCode): return payCode
            case .error: return nil
            }
        }

        var hideErrorRetry: Bool {
            switch self {
            case .loading: return true
            case .payCodeLoaded: return true
            case .error: return false
            }
        }
    }
}

// MARK: - UI Actions

extension P2PPaymentsGetPayCodeViewModel {
    func closeButtonPressed() {
        navigator?.close()
    }

    func contactUsActionSelected() {
        guard let email = myUserRepository.myUser?.email,
            let installation = installationRepository.installation,
            let url = LetgoURLHelper.buildContactUsURL(userEmail: email, installation: installation,
                                                       listing: nil, type: .payment) else { return }
        navigator?.openContactUs(url: url)
    }

    func faqsActionSelected() {
        guard let url = LetgoURLHelper.buildPaymentFaqsURL() else { return }
        navigator?.openFaqs(url: url)
    }

    func retryButtonPressed() {
        uiStateRelay.accept(.loading)
        getPayCode(attempt: 0)
    }
}

// MARK: - Rx Outputs

extension P2PPaymentsGetPayCodeViewModel {
    var showActivityIndicator: Driver<Bool> { return uiStateRelay.asDriver().map { $0.showActivityIndicator } }
    var payCodeText: Driver<String?> { return uiStateRelay.asDriver().map { $0.payCode } }
    var hideErrorRetry: Driver<Bool> { return uiStateRelay.asDriver().map { $0.hideErrorRetry } }
    var hidePayCodeLabel: Driver<Bool> { return uiStateRelay.asDriver().map { !$0.hideErrorRetry } }
    var hidePayCodeTitleLabel: Driver<Bool> { return uiStateRelay.asDriver().map { !$0.hideErrorRetry } }
}
