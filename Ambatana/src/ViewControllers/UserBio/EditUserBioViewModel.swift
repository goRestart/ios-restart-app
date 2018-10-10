import Foundation
import LGCoreKit
import RxSwift
import RxCocoa
import LGComponents

final class EditUserBioViewModel: BaseViewModel {

    private let myUserRepository: MyUserRepository
    private let tracker: Tracker

    var navigator: EditUserBioNavigator?
    weak var delegate: BaseViewModelDelegate?

    var userBio: String? {
        return myUserRepository.myUser?.biography
    }

    init(myUserRepository: MyUserRepository, tracker: Tracker) {
        self.myUserRepository = myUserRepository
        self.tracker = tracker
    }

    convenience override init() {
        self.init(myUserRepository: Core.myUserRepository,
                  tracker: TrackerProxy.sharedInstance)
    }

    func saveBio(text: String) {
        myUserRepository.updateBiography(text) { [weak self] result in
            if let value = result.value {
                self?.navigator?.closeEditUserBio()
                if let userId = value.objectId {
                    self?.trackBioUpdate()
                }
            } else if let _ = result.error {
                self?.delegate?.vmShowAutoFadingMessage(R.Strings.changeBioErrorMessage, completion: nil)
            }
        }
    }
}

extension EditUserBioViewModel {
    func trackBioUpdate() {
        tracker.trackEvent(TrackerEvent.profileEditBioComplete())
    }
}
