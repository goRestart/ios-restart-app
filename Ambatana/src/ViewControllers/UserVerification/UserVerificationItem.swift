import Foundation
import LGComponents

enum UserVerificationItem {
    case facebook(completed: Bool)
    case google(completed: Bool)
    case email(completed: Bool)
    case phoneNumber(completed: Bool)
    case photoID(completed: Bool)
    case profilePicture(completed: Bool)
    case bio(completed: Bool)
    case markAsSold(completed: Bool, total: Int)

    var title: String {
        switch self {
        case .facebook: return R.Strings.profileVerificationsViewFacebookTitle
        case .google: return R.Strings.profileVerificationsViewGoogleTitle
        case .email: return R.Strings.profileVerificationsViewEmailTitle
        case .phoneNumber: return R.Strings.profileVerificationsViewPhoneNumberTitle
        case .photoID: return R.Strings.profileVerificationsViewPhotoIdTitle
        case .profilePicture: return R.Strings.profileVerificationsViewProfilePictureTitle
        case .bio: return R.Strings.profileVerificationsViewBioTitle
        case .markAsSold: return R.Strings.profileVerificationsViewMarkAsSoldTitle
        }
    }

    var subtitle: String? {
        switch self {
        case .facebook, .google, .email, .phoneNumber, .photoID, .profilePicture, .bio: return nil
        case .markAsSold: return R.Strings.profileVerificationsViewMarkAsSoldSubtitle
        }
    }

    var image: UIImage? {
        switch self {
        case .facebook: return R.Asset.IconsButtons.verifyFacebook.image
        case .google: return R.Asset.IconsButtons.verifyGoogle.image
        case .email: return R.Asset.IconsButtons.verifyMail.image
        case .phoneNumber: return R.Asset.IconsButtons.verifyPhone.image
        case .photoID: return R.Asset.IconsButtons.verifyId.image
        case .profilePicture: return R.Asset.IconsButtons.verifyPhoto.image
        case .bio: return R.Asset.IconsButtons.verifyBio.image
        case .markAsSold: return R.Asset.IconsButtons.verifySold.image
        }
    }

    var pointsValue: String {
        switch self {
        case .facebook: return "+25"
        case .google: return "+10"
        case .email: return "+5"
        case .phoneNumber: return "+15"
        case .photoID: return "+40"
        case .profilePicture: return "+10"
        case .bio: return "+5"
        case .markAsSold: return "+2"
        }
    }

    var eventCountString: String? {
        switch self {
        case .facebook, .google, .email, .phoneNumber, .photoID, .profilePicture, .bio: return nil
        case .markAsSold(_, let totalCount): return "\(totalCount)/5"
        }
    }

    var showsAccessoryView: Bool {
        switch self {
        case .facebook, .google, .email, .phoneNumber, .photoID, .profilePicture, .bio: return true
        case .markAsSold: return false
        }
    }

    var completed: Bool {
        switch self {
        case .facebook(let completed): return completed
        case .google(let completed): return completed
        case .email(let completed): return completed
        case .phoneNumber(let completed): return completed
        case .photoID(let completed): return completed
        case .profilePicture(let completed): return completed
        case .bio(let completed): return completed
        case .markAsSold(let completed, _): return completed
        }
    }

    var canBeSelected: Bool {
        return !completed && showsAccessoryView
    }
}
