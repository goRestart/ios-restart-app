//
//  TextHiddenTags.swift
//  LetGo
//
//  Created by Eli Kohen on 06/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

enum TextHiddenTags: String {
    case phone = "[TL_HIDDEN]"
    case email = "[EMAIL_HIDDEN]"

    static let allTags: [TextHiddenTags] = [.phone, .email]

    var localized: String {
        switch self {
        case .phone:
            return LGLocalizedString.hiddenPhoneTag
        case .email:
            return LGLocalizedString.hiddenEmailTag
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
