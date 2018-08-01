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
