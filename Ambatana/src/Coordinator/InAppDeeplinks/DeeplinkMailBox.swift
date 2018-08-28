import Foundation
import RxSwift
import RxCocoa
import LGComponents
import LGCoreKit

protocol DeepLinkMailBox {
    func push(convertible: DeepLinkConvertible)
    var deeplinks: Observable<DeepLink> { get }
}

protocol DeepLinkNavigator {
    func navigate(with convertible: DeepLinkConvertible)
}

protocol DeepLinkConvertible: CustomDebugStringConvertible {
    var deeplink: DeepLink? { get }
}

extension DeepLink: DeepLinkConvertible {
    var debugDescription: String { return "Deeplink" }
    var deeplink: DeepLink? { return self }
}

extension URL: DeepLinkConvertible {
    var deeplink: DeepLink? { return UriScheme.buildFromUrl(self)?.deepLink }
}

extension URL {
    static func makeAppRatingDeeplink(with source: EventParameterRatingSource) -> URL? {
        return URL(string: String(format: "letgo://app_rating?rating-source=%@", source.rawValue))
    }

    static func makeSellDeeplink(with source: PostingSource?, category: PostCategory?, title: String?) -> URL? {
        var params: [String] = []
        var deeplink = "letgo://sell"
        if let source = source {
            params.append("source=\(source.rawValue)")
        }
        if let category = category {
            params.append("category=\(category.description)")
        }
        if let title = title {
            params.append("title=\(title)")
        }
        if params.count > 0 {
            deeplink += "?\(params.joined(separator: "&"))"
        }
        return URL(string: deeplink)
    }
    
    static func makeInvitationDeepLink(withUsername username: String, andUserId userid: String) -> URL? {
        guard let encodedUsername = username.addingPercentEncoding(
            withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return nil
        }
        return URL(string: String(
            format: "letgo://app_invite?user-name=%@&user-id=%@",
            encodedUsername,
            userid
        ))
    }
}

final class LGDeepLinkMailBox: DeepLinkMailBox {
    private let rx_deeplinks = PublishSubject<DeepLink>()
    static let sharedInstance = LGDeepLinkMailBox()

    private init() {}

    func push(convertible: DeepLinkConvertible) {
        guard let deeplink = convertible.deeplink else {
            // TODO: Improve deeplinking log https://ambatana.atlassian.net/browse/ABIOS-4697
            report(AppReport.navigation(error: .mailBoxInvalidDeeplink),
                   message: "Could not open \(convertible.debugDescription)")
            return
        }
        rx_deeplinks.onNext(deeplink)
    }

    var deeplinks: Observable<DeepLink> { return rx_deeplinks.asObservable() }
}
