import LGComponents
import LGCoreKit

enum UserReputationBadge: String {
    case noBadge = ""
    case silver = "silver"
    case gold = "gold"
}

struct UserAvatarInfo {
    let avatarURL: URL?
    let placeholder: UIImage?
}

extension User {
    var facebookAccount: Account? {
        return accountWithProvider(.facebook)
    }
    var googleAccount: Account? {
        return accountWithProvider(.google)
    }
    var emailAccount: Account? {
        return accountWithProvider(.email)
    }
    private func accountWithProvider(_ provider: AccountProvider) -> Account? {
        return accounts.filter { $0.provider == provider }.first
    }
    var isVerified: Bool {
        return accounts.filter { $0.verified }.count > 0
    }
    var reputationBadge: UserReputationBadge {
        return reputationPoints >= SharedConstants.Reputation.minScore ? .silver : .noBadge
    }
    var hasBadge: Bool {
        return reputationBadge != .noBadge
    }
}

//  MARK: - Avatar

extension User {
    func makeAvatarPlaceholder(isPrivateProfile: Bool) -> UIImage? {
        if isPrivateProfile {
            return LetgoAvatar.avatarWithColor(.defaultAvatarColor, name: name)
        } else {
            return LetgoAvatar.avatarWithID(objectId, name: name)
        }
    }
}

extension User {
    var shortName: String? {
        return name?.trunc(18)
    }
}

extension User {
    var isProfessional: Bool {
        switch self.type {
        case .dummy, .user, .unknown:
            return false
        case .pro:
            return true
        }
    }
}
