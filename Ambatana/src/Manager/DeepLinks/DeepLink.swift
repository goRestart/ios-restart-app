import Foundation
import LGCoreKit

struct DeepLink {
    let action: DeepLinkAction
    let origin: DeepLinkOrigin
    let campaign: String?
    let medium: String?
    let source: DeepLinkSource
    let cardActionParameter: String?

    static func push(_ action: DeepLinkAction, origin: DeepLinkOrigin, campaign: String?, medium: String?,
                     source: DeepLinkSource, cardActionParameter: String?) -> DeepLink {
        return DeepLink(action: action, origin: origin, campaign: campaign, medium: medium,
                        source: source, cardActionParameter: cardActionParameter)
    }

    static func link(_ action: DeepLinkAction, campaign: String?, medium: String?,
                     source: DeepLinkSource, cardActionParameter: String?) -> DeepLink {
        return DeepLink(action: action, origin: .link, campaign: campaign, medium: medium,
                        source: source, cardActionParameter: cardActionParameter)
    }

    static func shortCut(_ action: DeepLinkAction) -> DeepLink {
        return DeepLink(action: action, origin: .shortCut, campaign: nil, medium: nil,
                        source: .none, cardActionParameter: nil)
    }

    static func appInstall(_ action: DeepLinkAction, source: DeepLinkSource) -> DeepLink {
        return DeepLink(action: action, origin: .appInstall, campaign: nil, medium: nil,
                        source: source, cardActionParameter: nil)
    }

}

enum DeepLinkAction: Equatable {
    case appRating(source: String)
    case home
    case sell(source: String?, category: String?, title: String?)
    case listing(listingId: String)
    case listingShare(listingId: String)
    case listingBumpUp(listingId: String)
    case listingMarkAsSold(listingId: String)
    case listingEdit(listingId: String)
    case user(userId: String)
    case conversations
    case conversation(conversationId: String)
    case conversationWithMessage(conversationId: String, message: String)
    case message(messageType: DeepLinkMessageType, conversationId: String)
    case search(query: String?,
        categories: String?,
        distanceRadius: String?,
        sortCriteria: String?,
        priceFlag: String?,
        minPrice: String?,
        maxPrice: String?)
    case resetPassword(token: String)
    case userRatings
    case userRating(ratingId: String)
    case notificationCenter
    case appStore
    case passwordlessSignup(token: String)
    case passwordlessLogin(token: String)
    case webView(url: URL)
    case invite(userid: String, username: String)
    
    static public func ==(lhs: DeepLinkAction, rhs: DeepLinkAction) -> Bool {
        switch (lhs, rhs) {
        case (.appRating(let sourceLhs), .appRating(let sourceRhs)):
            return sourceLhs == sourceRhs
        case (.home, .home):
            return true
        case (.sell(let lhsSource, let lhsCategory, let lhsTitle),
              .sell(let rhsSource, let rhsCategory, let rhsTitle)):
            return lhsSource == rhsSource && lhsCategory == rhsCategory && lhsTitle == rhsTitle
        case (.listing(let lhsDetail), .listing(let rhsDetail)):
            return lhsDetail == rhsDetail
        case (.listingShare(let lhsDetail), .listingShare(let rhsDetail)):
            return lhsDetail == rhsDetail
        case (.listingBumpUp(let lhsDetail), .listingBumpUp(let rhsDetail)):
            return lhsDetail == rhsDetail
        case (.listingMarkAsSold(let lhsDetail), .listingMarkAsSold(let rhsDetail)):
            return lhsDetail == rhsDetail
        case (.listingEdit(let lhsDetail), .listingEdit(let rhsDetail)):
            return lhsDetail == rhsDetail
        case (.user(let lhsUser), .user(let rhsUser)):
            return lhsUser == rhsUser
        case (.conversations, .conversations):
            return true
        case (.conversation(let lhsData), .conversation(let rhsData)):
            return lhsData == rhsData
        case (.conversationWithMessage(let lhsData, let lhsMessage), .conversationWithMessage(let rhsData, let rhsMessage)):
            return lhsData == rhsData && lhsMessage == rhsMessage
        case (.message(let lhsMessageType, let lhsData), .message(let rhsMessageType, let rhsData)):
            return lhsMessageType == rhsMessageType && lhsData == rhsData
        case (.search(let lhsQuery, let lhsCategories, let lhsDistanceRadius, let lhsSortCriteria,
                      let lhsPriceFlag, let lhsMinPrice, let lhsMaxPrice),
              .search(let rhsQuery, let rhsCategories, let rhsDistanceRadius, let rhsSortCriteria,
                      let rhsPriceFlag, let rhsMinPrice, let rhsMaxPrice)):
            return lhsQuery == rhsQuery &&
                lhsCategories == rhsCategories &&
                lhsSortCriteria == rhsSortCriteria &&
                lhsDistanceRadius == rhsDistanceRadius &&
                lhsPriceFlag == rhsPriceFlag &&
                lhsMinPrice == rhsMinPrice &&
                lhsMaxPrice == rhsMaxPrice
        case (.resetPassword(let lhsToken), .resetPassword(let rhsToken)):
            return lhsToken == rhsToken
        case (.userRatings, .userRatings):
            return true
        case (.userRating(let lhsRatingId), .userRating(let rhsRatingId)):
            return lhsRatingId == rhsRatingId
        case (.notificationCenter, .notificationCenter):
            return true
        case (.appStore, .appStore):
            return true
        case (.webView(let lhsUrl), .webView(let rhsUrl)):
            return lhsUrl == rhsUrl
        case (.invite(let lhsuserid, let lhsusername), .invite(let rhslhsuserid, let rhssername)):
            return lhsuserid == rhslhsuserid && lhsusername == rhssername
        default:
            return false
        }
    }
    
    enum SearchDeepLinkQueryParameters: String {
        case query = "query"
        case categories = "categories"
        case distanceRadius = "distance_radius"
        case sortCriteria = "sort"
        case priceFlag = "price_flag"
        case minPrice = "min_price"
        case maxPrice = "max_price"
    }
}

enum DeepLinkOrigin {
    case push(appActive: Bool, alert: String)
    case link
    case shortCut
    case appInstall

    var appActive: Bool {
        switch self {
        case .link, .shortCut:
            return false
        case let .push(appActive, _):
            return appActive
        case .appInstall:
            return true
        }
    }

    var message: String {
        switch self {
        case .link, .shortCut, .appInstall:
            return ""
        case let .push(_, message):
            return message
        }
    }
}

enum DeepLinkSource: Equatable {
    case external(source: String)
    case push
    case none

    init(string: String?) {
        guard let string = string else {
            self = .none
            return
        }
        self = .external(source: string)
    }
    
    static public func ==(lhs: DeepLinkSource, rhs: DeepLinkSource) -> Bool {
        switch (lhs, rhs) {
        case (.push, .push):
            return true
        case (.none, .none):
            return true
        case (.external(let lhsSource), .external(let rhsSource)):
            return lhsSource == rhsSource
        default:
            return false
        }
    }
}

protocol ConversationIdDisplayer {
    func isDisplayingConversationId(_ conversationId: String) -> Bool
}

/**
 Message type enum

 - Message: Typical message
 - Offer:   Message from an offer
 */
enum DeepLinkMessageType: Int {
    case message = 0
    case offer = 1
    case sticker = 2
}

enum DeepLinkSortCriteria: String {
    case distance = "distance"
    case priceAsc = "price_asc"
    case priceDesc = "price_desc"
    case recent = "recent"
    
    var intValue: Int {
        switch self {
        case .distance:
            return 1
        case .priceAsc:
            return 2
        case .priceDesc:
            return 3
        case .recent:
            return 4
        }
    }
}

enum DeepLinkPriceFlag: Int {
    case normal = 0
    case free = 1
    case negotiable = 2
    case firm = 3
    
    var isFree: Bool {
        return self == .free
    }
}
