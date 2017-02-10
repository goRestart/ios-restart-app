//
//  TrackerEventDataTypes.swift
//  LetGo
//
//  Created by Albert Hernández López on 06/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

enum EventName: String {
    case location                           = "location"
    
    case loginVisit                         = "login-screen"
    case loginAbandon                       = "login-abandon"
    case loginFB                            = "login-fb"
    case loginGoogle                        = "login-google"
    case loginEmail                         = "login-email"
    case signupEmail                        = "signup-email"
    case logout                             = "logout"
    case passwordResetVisit                 = "login-reset-password"
    
    case loginEmailError                    = "login-error"
    case loginFBError                       = "login-signup-error-facebook"
    case loginGoogleError                   = "login-signup-error-google"
    case signupError                        = "signup-error"
    case passwordResetError                 = "password-reset-error"
    case loginBlockedAccountStart           = "login-blocked-account-start"
    case loginBlockedAccountContactUs       = "login-blocked-account-contact-us"
    case loginBlockedAccountKeepBrowsing    = "login-blocked-account-keep-browsing"

    case productList                        = "product-list"
    case exploreCollection                  = "explore-collection"
    
    case searchStart                        = "search-start"
    case searchComplete                     = "search-complete"
    
    case filterStart                        = "filter-start"
    case filterComplete                     = "filter-complete"
    
    case productDetailVisit                 = "product-detail-visit"
    case productDetailVisitMoreInfo         = "product-detail-visit-more-info"
    
    case productFavorite                    = "product-detail-favorite"
    case productShare                       = "product-detail-share"
    case productShareCancel                 = "product-detail-share-cancel"
    case productShareComplete               = "product-detail-share-complete"
    
    case firstMessage                       = "product-detail-ask-question"
    case productOpenChat                    = "product-detail-open-chat"
    case productMarkAsSold                  = "product-detail-sold"
    case productMarkAsUnsold                = "product-detail-unsold"
    
    case productReport                      = "product-detail-report"
    
    case productSellStart                   = "product-sell-start"
    case productSellSharedFB                = "product-sell-shared-fb"
    case productSellComplete                = "product-sell-complete"
    case productSellComplete24h             = "product-sell-complete-24h"
    case productSellError                   = "product-sell-error"
    case productSellErrorClose              = "product-sell-error-close"
    case productSellErrorPost               = "product-sell-error-post"
    case productSellErrorData               = "product-sell-error-data"
    case productSellConfirmation            = "product-sell-confirmation"
    case productSellConfirmationPost        = "product-sell-confirmation-post"
    case productSellConfirmationClose       = "product-sell-confirmation-close"
    case productSellConfirmationEdit        = "product-sell-confirmation-edit"
    case productSellConfirmationShare       = "product-sell-confirmation-share"
    case productSellConfirmationShareCancel = "product-sell-confirmation-share-cancel"
    case productSellConfirmationShareComplete = "product-sell-confirmation-share-complete"
    
    case productEditStart                   = "product-edit-start"
    case productEditFormValidationFailed    = "product-edit-form-validation-failed"
    case productEditSharedFB                = "product-edit-shared-fb"
    case productEditComplete                = "product-edit-complete"
    
    case productDeleteStart                 = "product-delete-start"
    case productDeleteComplete              = "product-delete-complete"
    
    case userMessageSent                    = "user-sent-message"
    case chatRelatedItemsStart              = "chat-related-items-start"
    case chatRelatedItemsComplete           = "chat-related-items-complete"

    case profileVisit                       = "profile-visit"
    case profileEditStart                   = "profile-edit-start"
    case profileEditEditName                = "profile-edit-edit-name"
    case profileEditEditLocation            = "profile-edit-edit-location"
    case profileEditEditPicture             = "profile-edit-edit-picture"
    case profileReport                      = "profile-report"
    case profileBlock                       = "profile-block"
    case profileUnblock                     = "profile-unblock"
    case profileShareStart                  = "profile-share-start"
    case profileShareComplete               = "profile-share-complete"
    case profileEditEmailStart              = "profile-edit-email-start"
    case profileEditEmailComplete           = "profile-edit-email-complete"

    case appInviteFriendStart               = "app-invite-friend-start"
    case appInviteFriend                    = "app-invite-friend"
    case appInviteFriendCancel              = "app-invite-friend-cancel"
    case appInviteFriendComplete            = "app-invite-friend-complete"
    case appInviteFriendDontAsk             = "app-invite-friend-dont-ask"
    
    case appRatingStart                     = "app-rating-start"
    case appRatingRate                      = "app-rating-rate"
    case appRatingSuggest                   = "app-rating-suggest"
    case appRatingDontAsk                   = "app-rating-dont-ask"
    case appRatingRemindMeLater             = "app-rating-remind-later"

    case permissionAlertStart               = "permission-alert-start"
    case permissionAlertCancel              = "permission-alert-cancel"
    case permissionAlertComplete            = "permission-alert-complete"
    case permissionSystemStart              = "permission-system-start"
    case permissionSystemCancel             = "permission-system-cancel"
    case permissionSystemComplete           = "permission-system-complete"

    case locationMap                        = "location-map"

    case commercializerStart                = "commercializer-start"
    case commercializerError                = "commercializer-error"
    case commercializerComplete             = "commercializer-complete"
    case commercializerOpen                 = "commercializer-open"
    case commercializerShareStart           = "commercializer-share-start"
    case commercializerShareComplete        = "commercializer-share-complete"

    case userRatingStart                    = "user-rating-start"
    case userRatingComplete                 = "user-rating-complete"

    case openApp                            = "open-app-external"

    case expressChatStart                   = "express-chat-start"
    case expressChatComplete                = "express-chat-complete"
    case expressChatDontAsk                 = "express-chat-dont-ask"

    case npsStart                           = "nps-start"
    case npsComplete                        = "nps-complete"

    case verifyAccountStart                 = "verify-account-start"
    case verifyAccountComplete              = "verify-account-complete"

    case inappChatNotificationStart         = "in-app-chat-notification-start"
    case inappChatNotificationComplete      = "in-app-chat-notification-complete"

    case signupCaptcha                      = "signup-captcha"

    case notificationCenterStart            = "notification-center-start"
    case notificationCenterComplete         = "notification-center-complete"

    case marketingPushNotifications         = "marketing-push-notifications"
    
    case passiveBuyerStart                 = "passive-buyer-start"
    case passiveBuyerComplete              = "passive-buyer-complete"
    case passiveBuyerAbandon               = "passive-buyer-abandon"

    case bumpUpStart                        = "bump-up-start"
    case bumpUpComplete                     = "bump-up-complete"
    case chatWindowVisit                     = "chat-window-open"
    
    // Constants
    private static let eventNameDummyPrefix  = "dummy-"
    
    // Computed iVars
    var actualEventName: String {
        get {
            let eventName: String
            if let isDummyUser = Core.myUserRepository.myUser?.isDummy {
                if isDummyUser {
                    eventName = EventName.eventNameDummyPrefix + rawValue
                }
                else {
                    eventName = rawValue
                }
            }
            else {
                eventName = rawValue
            }
            return eventName
        }
    }
}

enum EventParameterName: String {
    case categoryId           = "category-id"           // 0 if there's no category
    case productId            = "product-id"
    case productCity          = "product-city"
    case productCountry       = "product-country"
    case productZipCode       = "product-zipcode"
    case productLatitude      = "product-lat"
    case productLongitude     = "product-lng"
    case productName          = "product-name"
    case productPrice         = "product-price"
    case productCurrency      = "product-currency"
    case productDescription   = "product-description"
    case productType          = "item-type"             // real (1) / dummy (0).
    case userId               = "user-id"
    case userToId             = "user-to-id"
    case userEmail            = "user-email"
    case userCity             = "user-city"
    case userCountry          = "user-country"
    case userZipCode          = "user-zipcode"
    case searchString         = "search-keyword"
    case searchSuccess        = "search-success"
    case trendingSearch       = "trending-search"
    case description          = "description"           // error description: why form validation failure.
    case loginSource          = "login-type"            // the login source
    case loginRememberedAccount = "existing"
    case locationType         = "location-type"
    case shareNetwork         = "share-network"
    case buttonPosition       = "button-position"
    case locationEnabled      = "location-enabled"
    case locationAllowed      = "location-allowed"
    case buttonName           = "button-name"
    case buttonType           = "button-type"
    case filterLat            = "filter-lat"
    case filterLng            = "filter-lng"
    case filterDistanceRadius = "distance-radius"
    case filterDistanceUnit   = "distance-unit"
    case filterSortBy         = "sort-by"
    case filterPostedWithin   = "posted-within"
    case errorDescription     = "error-description"
    case errorDetails         = "error-details"
    case permissionType       = "permission-type"
    case typePage             = "type-page"
    case alertType            = "alert-type"
    case permissionGoToSettings = "permission-go-to-settings"
    case negotiablePrice      = "negotiable-price"
    case pictureSource        = "picture-source"
    case editedFields         = "edited-fields"
    case newsletter           = "newsletter"
    case quickAnswer          = "quick-answer"
    case reportReason         = "report-reason"
    case tab                  = "tab"
    case template             = "template"
    case userAction           = "user-action"
    case appRatingSource      = "app-rating-source"
    case messageType          = "message-type"
    case ratingStars          = "rating-stars"
    case ratingComments       = "rating-comments"
    case sellerUserRating     = "seller-user-rating"
    case campaign             = "campaign"
    case medium               = "medium"
    case source               = "source"
    case itemPosition         = "item-position"
    case expressConversations = "express-conversations"
    case collectionTitle      = "collection-title"
    case productVisitSource   = "visit-source"
    case numberOfUsers        = "number-of-users"
    case priceFrom            = "price-from"
    case priceTo              = "price-to"
    case npsScore             = "nps-score"
    case accountNetwork       = "account-network"
    case profileType          = "profile-type"
    case notificationType     = "notification-type"
    case shownReason          = "shown-reason"
    case freePosting          = "free-posting"
    case sellButtonPosition   = "sell-button-position"
    case enabled              = "enabled"
    case lastSearch           = "last-search"
    case expressChatTrigger   = "express-chat-trigger"
    case numberPhotosPosting  = "number-photos-posting"
    case bumpUpPrice          = "price"
    case passiveConversations = "passive-conversations"
    case collapsedEmailField  = "collapsed-email-field"
    case feedPosition         = "feed-position"
    case feedSource           = "feed-source"
    case rating               = "rating"
    case userSoldTo           = "user-sold-to"
    case chatEnabled          = "chat-enabled"
}

enum EventParameterLoginSourceValue: String {
    case sell = "posting"
    case chats = "messages"
    case profile = "view-profile"
    case notifications = "notifications"
    case favourite = "favourite"
    case markAsSold = "mark-as-sold"
    case markAsUnsold = "mark-as-unsold"
    case askQuestion = "question"
    case reportFraud = "report-fraud"
    case delete = "delete"
    case install = "install"
    case directSticker = "direct-sticker"
}

enum EventParameterUserSoldTo: String {
    case letgoUser = "true"
    case outsideLetgo = "false"
    case noConversations = "no-conversations"
}

enum EventParameterProductItemType: String {
    case real = "1"
    case dummy = "0"
}

enum EventParameterButtonNameType: String {
    case close = "close"
    case skip = "skip"
    case done = "done"
    case sellYourStuff = "sell-your-stuff"
    case startMakingCash = "start-making-cash"
}

enum EventParameterButtonType: String {
    case button = "button"
    case itemPicture = "item-picture"
}

enum EventParameterButtonPosition: String {
    case top = "top"
    case bottom = "bottom"
    case bumpUp = "bump-up"
    case none = "N/A"
}

enum EventParameterSellButtonPosition: String {
    case tabBar = "tabbar-camera"
    case floatingButton = "big-button"
    case none = "N/A"
}

enum EventParameterShareNetwork: String {
    case email = "email"
    case facebook = "facebook"
    case whatsapp = "whatsapp"
    case twitter = "twitter"
    case fbMessenger = "facebook-messenger"
    case telegram = "telegram"
    case sms = "sms"
    case copyLink = "copy_link"
    case native = "native"
    case notAvailable = "N/A"
}

enum EventParameterNegotiablePrice: String {
    case yes = "yes"
    case no = "no"
}

enum EventParameterPictureSource: String {
    case camera = "camera"
    case gallery = "gallery"
}

enum EventParameterSortBy: String {
    case distance = "distance"
    case creationDate = "creation-date"
    case priceAsc = "price-asc"
    case priceDesc = "price-desc"
}

enum EventParameterPostedWithin: String {
    case day = "day"
    case week = "week"
    case month = "month"
    case all = ""
}

enum EventParameterHasPriceFilter: String {
    case trueParameter = "true"
    case falseParameter = "false"
}

enum EventParameterQuickAnswerValue: String {
    case trueParameter = "true"
    case falseParameter = "false"
    case none = "N/A"
}

enum EventParameterMessageType: String {
    case text       = "text"
    case offer      = "offer"
    case sticker    = "sticker"
    case favorite   = "favorite"
    case quickAnswer = "quick-answer"
    case expressChat = "express-chat"
    case periscopeDirect = "periscope-direct"
}

enum EventParameterLoginError {
    
    case network
    case internalError(description: String)
    case unauthorized
    case notFound
    case forbidden
    case invalidEmail
    case nonExistingEmail
    case invalidPassword
    case invalidUsername
    case userNotFoundOrWrongPassword
    case emailTaken
    case passwordMismatch
    case usernameTaken
    case termsNotAccepted
    case tooManyRequests
    case scammer
    case blacklistedDomain
    case badRequest

    var description: String {
        switch self {
        case .network:
            return "Network"
        case .internalError:
            return "Internal"
        case .unauthorized:
            return "Unauthorized"
        case .notFound:
            return "NotFound"
        case .forbidden:
            return "Forbidden"
        case .invalidEmail:
            return "InvalidEmail"
        case .nonExistingEmail:
            return "NonExistingEmail"
        case .invalidPassword:
            return "InvalidPassword"
        case .invalidUsername:
            return "InvalidUsername"
        case .userNotFoundOrWrongPassword:
            return "UserNotFoundOrWrongPassword"
        case .emailTaken:
            return "EmailTaken"
        case .passwordMismatch:
            return "PasswordMismatch"
        case .usernameTaken:
            return "UsernameTaken"
        case .termsNotAccepted:
            return "TermsNotAccepted"
        case .tooManyRequests:
            return "TooManyRequests"
        case .scammer:
            return "Scammer"
        case .blacklistedDomain:
            return "BlacklistedDomain"
        case .badRequest:
            return "BadRequest"
        }

    }

    var details: String? {
        switch self {
        case let .internalError(description):
            return description
        case .network, .unauthorized, .notFound, .forbidden, .invalidEmail, .nonExistingEmail, .invalidPassword,
             .invalidUsername, .userNotFoundOrWrongPassword, .emailTaken, .passwordMismatch, .usernameTaken,
             .termsNotAccepted, .tooManyRequests, .scammer, .blacklistedDomain, .badRequest:
            return nil
        }
    }
}

enum EventParameterPostProductError {
    case network
    case internalError
    case serverError(code: Int?)

    var description: String {
        switch self {
        case .network:
            return "product-sell-network"
        case .internalError:
            return "product-sell-internal"
        case .serverError:
            return "product-sell-server-error"
        }
    }

    var details: Int? {
        switch self {
        case .network, .internalError:
            return nil
        case let .serverError(errorCode):
            return errorCode
        }
    }
}

enum EventParameterEditedFields: String {
    case picture = "picture"
    case title = "title"
    case price = "price"
    case description = "description"
    case category = "category"
    case location = "location"
    case share = "share"
    case freePosting = "free-posting"
}

enum EventParameterTypePage: String {
    case productList = "product-list"
    case productListBanner = "product-list-banner"
    case chat = "chat"
    case tabBar = "tab-bar"
    case chatList = "chat-list"
    case sell = "product-sell"
    case edit = "product-edit"
    case productDetail = "product-detail"
    case productDetailMoreInfo = "product-detail-more-info"
    case settings = "settings"
    case install = "install"
    case profile = "profile"
    case commercializerPlayer = "commercializer-player"
    case commercializerPreview = "commercializer-preview"
    case pushNotification = "push-notification"
    case email = "email"
    case onboarding = "onboarding"
    case external = "external"
    case notifications = "notifications"
    case openApp = "open-app"
    case incentivizePosting = "incentivize-posting"
    case userRatingList = "user-rating-list"
    case expressChat = "express-chat"
    case productDelete = "product-delete"
    case productSold = "product-sold"
    case inAppNotification = "in-app-notification"
}

enum EventParameterPermissionType: String {
    case push = "push-notification"
    case location = "gps"
    case camera = "camera"
}

enum EventParameterPermissionAlertType: String {
    case custom = "custom"
    case nativeLike = "native-alike"
    case fullScreen = "full-screen"
}

enum EventParameterNewsletter: String {
    case trueParameter = "true"
    case falseParameter = "false"
    case unset = "N/A"
}

enum EventParameterTab: String {
    case selling = "selling"
    case sold = "sold"
    case favorites = "favorites"
}

enum EventParameterSearchCompleteSuccess: String {
    case success = "yes"
    case fail = "no"
}

enum EventParameterReportReason: String {
    case offensive = "offensive"
    case scammer = "scammer"
    case mia = "mia"
    case suspicious = "suspicious"
    case inactive = "inactive"
    case prohibitedItems = "prohibited-items"
    case spammer = "spammer"
    case counterfeitItems = "counterfeit-items"
    case other = "other"
}

enum EventParameterCommercializerError: String {
    case network = "commercializer-network"
    case internalError = "commercializer-internal"
    case duplicated = "commercializer-duplicated"
}

enum EventParameterPermissionGoToSettings: String {
    case trueParameter = "true"
    case notAvailable = "N/A"
}

enum ProductVisitUserAction: String {
    case tap = "tap"
    case swipeLeft = "swipe-left"
    case swipeRight = "swipe-right"
    case none = "N/A"
}

enum EventParameterRatingSource: String {
    case chat = "chat"
    case productSellComplete = "product-sell-complete"
    case markedSold = "marked-sold"
}

enum EventParameterProductVisitSource: String {
    case productList = "product-list"
    case moreInfoRelated = "more-info-related"
    case collection = "collection"
    case search = "search"
    case filter = "filter"
    case searchAndFilter = "search & filter"
    case category = "category"
    case profile = "profile"
    case chat = "chat"
    case openApp = "open-app"
    case notifications = "notifications"
}

enum EventParameterFeedPosition {
    case position(index: Int)
    case none
    
    var value: String {
        switch self {
        case let .position(index):
            let value = index + 1
            return String(value)
        case .none:
            return "N/A"
        }
    }
}

enum EventParameterFeedSource: String {
    case home = "home"
    case search = "search"
    case filter = "filter"
    case searchAndFilter = "search&filter"
    case collection = "collection"
}

enum EventParameterAccountNetwork: String {
    case facebook = "facebook"
    case google = "google"
    case email = "email"
}

enum EventParameterProfileType: String {
    case publicParameter = "public"
    case privateParameter = "private"
}

enum EventParameterNotificationType: String {
    case welcome = "welcome"
    case favorite = "favorite"
    case productSold = "favorite-sold"
    case rating = "rating"
    case ratingUpdated = "rating-updated"
    case buyersInterested = "passive-buyer-seller"
    case productSuggested = "passive-buyer-make-offer"
    case facebookFriendshipCreated = "facebook-friendship-created"
}

enum EventParameterRelatedShownReason: String {
    case productSold = "product-sold"
    case productDeleted = "product-deleted"
    case userDeleted = "user-deleted"
    case unanswered48h = "unanswered-48h"
    case forbidden = "forbidden"

    init(chatInfoStatus: ChatInfoViewStatus) {
        switch chatInfoStatus {
        case .forbidden:
            self = .forbidden
        case .blocked, .blockedBy:
            self = .unanswered48h
        case .productDeleted:
            self = .productDeleted
        case .productSold:
            self = .productSold
        case .userPendingDelete, .userDeleted:
            self = .userDeleted
        case .available:
            self = .unanswered48h
        }
    }
}

enum EventParameterFreePosting: String {
    case trueParameter = "true"
    case falseParameter = "false"
    case unset = "N/A"
}

enum EventParameterExpressChatTrigger: String {
    case automatic = "automatic"
    case manual = "manual"
}

enum EventParameterBumpUpPrice {
    case free
    case pay(price: String)

    var description: String {
        switch self {
        case .free:
            return "free"
        case let .pay(price):
            return price
        }
    }
}

enum EventParameterCollapsedEmailField: String {
    case trueParameter = "true"
    case falseParameter = "false"
    case unset = "N/A"
}

struct EventParameters {
    private var params: [EventParameterName : Any] = [:]
    
    // transforms the params to [String: Any]
    var stringKeyParams: [String: Any] {
        get {
            var res = [String: Any]()
            for (paramName, value) in params {
                res[paramName.rawValue] = value
            }
            return res
        }
    }
    
    internal mutating func addLoginParams(_ source: EventParameterLoginSourceValue, rememberedAccount: Bool? = nil,
                                          collapsedEmail: EventParameterCollapsedEmailField? = nil) {
        params[.loginSource] = source.rawValue
        params[.loginRememberedAccount] = rememberedAccount
        params[.collapsedEmailField] = collapsedEmail?.rawValue
    }
    
    internal mutating func addProductParams(_ product: Product) {
        params[.productId] = product.objectId
        params[.productLatitude] = product.location.latitude
        params[.productLongitude] = product.location.longitude
        params[.productPrice] = product.price.value
        params[.productCurrency] = product.currency.code
        params[.categoryId] = product.category.rawValue
        params[.productType] = product.user.isDummy ?
            EventParameterProductItemType.dummy.rawValue : EventParameterProductItemType.real.rawValue
        params[.userToId] = product.user.objectId
    }
    
    internal mutating func addChatProductParams(_ product: ChatProduct) {
        params[.productId] = product.objectId
        params[.productPrice] = product.price.value
        params[.productCurrency] = product.currency.code
        params[.productType] = EventParameterProductItemType.real.rawValue
    }
    
    internal mutating func addUserParams(_ user: UserProduct?) {
        params[.userToId] = user?.objectId
    }

    internal subscript(paramName: EventParameterName) -> Any? {
        get {
            return params[paramName]
        }
        set(newValue) {
            params[paramName] = newValue
        }
    }
}

struct PostProductTrackingInfo {
    var buttonName: EventParameterButtonNameType
    var sellButtonPosition: EventParameterSellButtonPosition
    var imageSource: EventParameterPictureSource
    var negotiablePrice: EventParameterNegotiablePrice

    init(buttonName: EventParameterButtonNameType, sellButtonPosition: EventParameterSellButtonPosition,
         imageSource: EventParameterPictureSource?, price: String?) {
        self.buttonName = buttonName
        self.sellButtonPosition = sellButtonPosition
        self.imageSource = imageSource ?? .camera
        if let price = price, let doublePrice = Double(price) {
            negotiablePrice = doublePrice > 0 ? .no : .yes
        } else {
            negotiablePrice = .yes
        }
    }
}
