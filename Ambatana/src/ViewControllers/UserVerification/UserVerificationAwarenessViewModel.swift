import Foundation
import LGComponents
import LGCoreKit

final class UserVerificationAwarenessViewModel: BaseViewModel {

    var avatarURL: URL? {
        return user?.avatar?.fileURL
    }

    var placeholder: UIImage? {
        return LetgoAvatar.avatarWithColor(UIColor.defaultAvatarColor, name: user?.name)
    }

    private var user: User?
    private let myUserRepository: MyUserRepository

    init(myUserRepository: MyUserRepository = Core.myUserRepository) {
        self.myUserRepository = myUserRepository
        self.user = myUserRepository.myUser
    }

    func openVerifications() {
        // TODO: Navigate to verifications
    }
}
