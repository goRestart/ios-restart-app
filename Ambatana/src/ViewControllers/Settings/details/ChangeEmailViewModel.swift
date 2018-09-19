import LGCoreKit
import Foundation
import Result
import RxSwift
import LGComponents

protocol ChangeEmailViewModelDelegate: BaseViewModelDelegate {}

class ChangeEmailViewModel: BaseViewModel {

    weak var delegate: ChangeEmailViewModelDelegate?
    var navigator: EditEmailNavigator?
    
    private let myUserRepository: MyUserRepository
    private let tracker: Tracker
    
    let currentEmail: String
    let newEmail = Variable<String?>(nil)
    var shouldAllowToContinue: Observable<Bool> {
        return newEmail.asObservable().map { [weak self] string in
            guard let strongSelf = self else { return false }
            return strongSelf.isValidEmail(string)
        }
    }
    
    // MARK: - Lifecycle
    
    init(myUserRepository: MyUserRepository, tracker: Tracker) {
        self.myUserRepository = myUserRepository
        self.tracker = tracker
        currentEmail =  myUserRepository.myUser?.email ?? ""
        super.init()
    }
    
    override convenience init() {
        let myUserRepository = Core.myUserRepository
        let tracker = TrackerProxy.sharedInstance
        self.init(myUserRepository: myUserRepository, tracker: tracker)
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
     
        if firstTime {
            trackVisit()
        }
    }
    
    // MARK: - Navigation
    
    override func backButtonPressed() -> Bool {
        navigator?.closeEditEmail()
        return true
    }
    
    // MARK: - Validation
    
    private func isValidEmail(_ emailAddress: String?) -> Bool {
        guard let emailAddress = emailAddress else { return false }
        return emailAddress.isEmail() && emailAddress != currentEmail
    }
    
    // MARK: - Request
    
    func updateEmail() {
        guard let emailAddress = newEmail.value else { return }
        guard isValidEmail(emailAddress) else {
            delegate?.vmShowAutoFadingMessage(R.Strings.changeEmailErrorInvalidEmail, completion: nil)
            return
        }
        delegate?.vmShowLoading(R.Strings.changeEmailLoading)
        myUserRepository.updateEmail(emailAddress) { [weak self] (updateResult) in
            guard let strongSelf = self else { return }
            switch (updateResult) {
            case .success:
                strongSelf.updateEmailDidSuccess(with: emailAddress)
            case .failure(let error):
                strongSelf.updateEmailDidFail(with: error)
            }
        }
    }
    
    private func updateEmailDidFail(with error: RepositoryError) {
        let message: String
        switch error {
        case .network:
            message = R.Strings.commonErrorConnectionFailed
        case .forbidden(cause: .emailTaken):
            message = R.Strings.changeEmailErrorAlreadyRegistered
        case .internalError, .forbidden, .tooManyRequests, .userNotVerified, .serverError, .notFound, .unauthorized,
             .wsChatError, .searchAlertError:
            message = R.Strings.commonErrorGenericBody
        }
        delegate?.vmHideLoading(message, afterMessageCompletion: nil)
    }
    
    private func updateEmailDidSuccess(with address: String) {
        trackEditEmailComplete()
        delegate?.vmHideLoading(R.Strings.changeEmailSendOk(address), afterMessageCompletion: { [weak self] in
            self?.navigator?.closeEditEmail()
        })
    }
    
    // MARK: Tracking
    
    private func trackVisit() {
        let userId = myUserRepository.myUser?.objectId ?? ""
        let event = TrackerEvent.profileEditEmailStart(withUserId: userId)
        tracker.trackEvent(event)
    }
    
    private func trackEditEmailComplete() {
        let userId = myUserRepository.myUser?.objectId ?? ""
        let event = TrackerEvent.profileEditEmailComplete(withUserId: userId)
        tracker.trackEvent(event)
    }
}
