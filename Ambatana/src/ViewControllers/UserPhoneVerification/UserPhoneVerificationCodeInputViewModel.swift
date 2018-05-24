import LGCoreKit
import RxSwift
import LGComponents

final class UserPhoneVerificationCodeInputViewModel: BaseViewModel {

    weak var navigator: UserPhoneVerificationNavigator?
    weak var delegate: BaseViewModelDelegate?

    private let callingCode: String
    private let phoneNumber: String
    private let myUserRepository: MyUserRepository
    private let tracker: Tracker
    private var timer: Timer?
    private let countdown = 50

    enum ValidationState {
        case none
        case validating
        case success
        case failure(message: String)
    }

    var fullPhoneNumber: String { return "+\(callingCode) \(phoneNumber)" }
    let showResendCodeOption = Variable<Bool>(false)
    let validationState = Variable<ValidationState>(.none)
    let resendCodeCountdown = Variable<Int>(0)

    init(callingCode: String,
         phoneNumber: String,
         myUserRepository: MyUserRepository = Core.myUserRepository,
         tracker: Tracker = TrackerProxy.sharedInstance) {
        self.callingCode = callingCode
        self.phoneNumber = phoneNumber
        self.myUserRepository = myUserRepository
        self.tracker = tracker
        super.init()
        setupResendCodeTimer()
    }

    deinit {
        timer?.invalidate()
    }

    func viewWillDisappear() {
        timer?.invalidate()
    }

    // MARK: Resend Code Timer

    private func setupResendCodeTimer() {
        showResendCodeOption.value = false
        resendCodeCountdown.value = countdown
        timer?.invalidate()
        timer = Timer
            .scheduledTimer(timeInterval: 1,
                            target: self,
                            selector: #selector(resendCodeTimerDidChange),
                            userInfo: nil,
                            repeats: true)

    }

    @objc private func resendCodeTimerDidChange() {
        guard resendCodeCountdown.value > 0 else {
            timer?.invalidate()
            showResendCodeOption.value = true
            return
        }

        resendCodeCountdown.value -= 1
    }

    func resendCode() {
        requestCode { [weak self] in
            self?.setupResendCodeTimer()
        }
    }

    // MARK: - Resend code
    
    private func requestCode(completion: (()->())?) {
        delegate?.vmShowLoading(R.Strings.phoneVerificationNumberInputViewSendingMessage)
        myUserRepository.requestSMSCode(prefix: callingCode, phone: phoneNumber) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success:
                let title = R.Strings.phoneVerificationNumberInputViewConfirmationTitle
                let message = R.Strings.phoneVerificationNumberInputViewConfirmationMessage(strongSelf.callingCode,
                                                                                                    strongSelf.phoneNumber)
                strongSelf.delegate?.vmHideLoading(nil) {
                    strongSelf.delegate?.vmShowAutoFadingMessage(title: title,
                                                                 message: message,
                                                                 time: 5,
                                                                 completion: completion)
                }
            case .failure(_):
                strongSelf.delegate?.vmHideLoading(R.Strings.phoneVerificationNumberInputViewErrorMessage,
                                                   afterMessageCompletion: nil)
            }
            
        }
    }

    // MARK: Code validation

    func validate(code: String) {
        validationState.value = .validating
        myUserRepository.validateSMSCode(code) { [weak self] result in
            switch result {
            case .success:
                self?.validationState.value = .success
                self?.tracker.trackEvent(.verifyAccountComplete(.smsVerification, network: .sms))
            case .failure:
                self?.validationState.value = .failure(message: R.Strings.phoneVerificationCodeInputViewErrorMessage)
            }
        }
    }

    func didFinishVerification() {
        navigator?.closePhoneVerificaction()
    }
}
