import LGComponents

enum TextHiddenTags: String {
    case phone = "[TL_HIDDEN]"
    case email = "[EMAIL_HIDDEN]"

    static let allTags: [TextHiddenTags] = [.phone, .email]

    var localized: String {
        switch self {
        case .phone:
            return R.Strings.hiddenPhoneTag
        case .email:
            return R.Strings.hiddenEmailTag
        }
    }

    var linkURL: URL? {
        return URL(string: linkString)
    }

    var linkString: String {
        switch self {
        case .phone:
            return "hidden-tag://phone"
        case .email:
            return "hidden-tag://email"
        }
    }

    init?(fromURL url: URL) {
        switch url.absoluteString {
        case TextHiddenTags.phone.linkString:
            self = .phone
        case TextHiddenTags.email.linkString:
            self = .email
        default:
            return nil
        }
    }
}
