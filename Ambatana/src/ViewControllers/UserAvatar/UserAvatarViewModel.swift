import Foundation
import LGComponents
import LGCoreKit
import RxSwift
import RxCocoa

final class UserAvatarViewModel: BaseViewModel {

    private let myUserRepository: MyUserRepository
    private let tracker: TrackerProxy
    private let user: Variable<User>

    weak var delegate: BaseViewModelDelegate?
    var navigator: PublicProfileNavigator?
    var isPrivate: Bool
    var userAvatarURL: Driver<URL?> { return user.asDriver().map {$0.avatar?.fileURL} }
    var userAvatarPlaceholder: Driver<UIImage?> { return makeUserAvatar() }

    init(isPrivate: Bool,
         user: User,
         myUserRepository: MyUserRepository = Core.myUserRepository,
         tracker: TrackerProxy = TrackerProxy.sharedInstance) {
        self.myUserRepository = myUserRepository
        self.tracker = tracker
        self.isPrivate = isPrivate
        self.user = Variable<User>(user)
    }

    func updateAvatar(with image: UIImage) {
        guard let imageData = image.dataForAvatar() else { return }
        delegate?.vmShowLoading(nil)
        myUserRepository
            .updateAvatar(imageData,
                          progressBlock: nil,
                          completion: { [weak self] result in
                            if let _ = result.value {
                                self?.trackUpdateAvatarComplete()
                                self?.myUserRepository.refresh({ result in
                                    if let value = result.value {
                                        self?.user.value = value
                                    }
                                    self?.delegate?.vmHideLoading(nil, afterMessageCompletion: nil)
                                })
                            } else {
                                self?.delegate?.vmHideLoading(nil, afterMessageCompletion: nil)
                                self?.delegate?
                                    .vmShowAutoFadingMessage(R.Strings.settingsChangeProfilePictureErrorGeneric,
                                                             completion: nil)
                            }
            })
    }

    private func makeUserAvatar() -> Driver<UIImage?> {
        if isPrivate {
            return user.asDriver().map { LetgoAvatar.avatarWithColor(UIColor.defaultAvatarColor, name: $0.name) }
        } else {
            return user.asDriver().map { LetgoAvatar.avatarWithID($0.objectId, name: $0.name) }
        }
    }

    func trackUpdateAvatarComplete() {
        let trackerEvent = TrackerEvent.profileEditEditPicture()
        tracker.trackEvent(trackerEvent)
    }

    func didTapClose() {
        navigator?.closeAvatarDetail()
    }
}
