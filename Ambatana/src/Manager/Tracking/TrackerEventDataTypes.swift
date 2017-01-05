//
//  TrackerEventDataTypes.swift
//  LetGo
//
//  Created by Albert Hernández López on 06/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

enum EventName: String {
    case Location                           = "location"
    
    case LoginVisit                         = "login-screen"
    case LoginAbandon                       = "login-abandon"
    case LoginFB                            = "login-fb"
    case LoginGoogle                        = "login-google"
    case LoginEmail                         = "login-email"
    case SignupEmail                        = "signup-email"
    case Logout                             = "logout"
    
    case LoginEmailError                    = "login-error"
    case LoginFBError                       = "login-signup-error-facebook"
    case LoginGoogleError                   = "login-signup-error-google"
    case SignupError                        = "signup-error"
    case PasswordResetError                 = "password-reset-error"
    case LoginBlockedAccountStart           = "login-blocked-account-start"
    case LoginBlockedAccountContactUs       = "login-blocked-account-contact-us"
    case LoginBlockedAccountKeepBrowsing    = "login-blocked-account-keep-browsing"

    case ProductList                        = "product-list"
    case ExploreCollection                  = "explore-collection"
    
    case SearchStart                        = "search-start"
    case SearchComplete                     = "search-complete"
    
    case FilterStart                        = "filter-start"
    case FilterComplete                     = "filter-complete"
    
    case ProductDetailVisit                 = "product-detail-visit"
    case ProductDetailVisitMoreInfo         = "product-detail-visit-more-info"
    case MoreInfoRelatedItemsComplete       = "more-info-related-items-complete"
    case MoreInfoRelatedItemsViewMore       = "more-info-related-items-view-more"
    
    case ProductFavorite                    = "product-detail-favorite"
    case ProductShare                       = "product-detail-share"
    case ProductShareCancel                 = "product-detail-share-cancel"
    case ProductShareComplete               = "product-detail-share-complete"
    
    case FirstMessage                       = "product-detail-ask-question"
    case ProductOpenChat                    = "product-detail-open-chat"
    case ProductMarkAsSold                  = "product-detail-sold"
    case ProductMarkAsUnsold                = "product-detail-unsold"
    
    case ProductReport                      = "product-detail-report"
    
    case ProductSellStart                   = "product-sell-start"
    case ProductSellSharedFB                = "product-sell-shared-fb"
    case ProductSellComplete                = "product-sell-complete"
    case ProductSellComplete24h             = "product-sell-complete-24h"
    case ProductSellError                   = "product-sell-error"
    case ProductSellErrorClose              = "product-sell-error-close"
    case ProductSellErrorPost               = "product-sell-error-post"
    case ProductSellErrorData               = "product-sell-error-data"
    case ProductSellConfirmation            = "product-sell-confirmation"
    case ProductSellConfirmationPost        = "product-sell-confirmation-post"
    case ProductSellConfirmationClose       = "product-sell-confirmation-close"
    case ProductSellConfirmationEdit        = "product-sell-confirmation-edit"
    case ProductSellConfirmationShare       = "product-sell-confirmation-share"
    case ProductSellConfirmationShareCancel = "product-sell-confirmation-share-cancel"
    case ProductSellConfirmationShareComplete = "product-sell-confirmation-share-complete"
    
    case ProductEditStart                   = "product-edit-start"
//    case ProductEditEditCurrency            = "product-edit-edit-currency"
    case ProductEditFormValidationFailed    = "product-edit-form-validation-failed"
    case ProductEditSharedFB                = "product-edit-shared-fb"
    case ProductEditComplete                = "product-edit-complete"
    
    case ProductDeleteStart                 = "product-delete-start"
    case ProductDeleteComplete              = "product-delete-complete"
    
    case UserMessageSent                    = "user-sent-message"
    case ChatRelatedItemsStart              = "chat-related-items-start"
    case ChatRelatedItemsComplete           = "chat-related-items-complete"

    case ProfileVisit                       = "profile-visit"
    case ProfileEditStart                   = "profile-edit-start"
    case ProfileEditEditName                = "profile-edit-edit-name"
    case ProfileEditEditLocation            = "profile-edit-edit-location"
    case ProfileEditEditPicture             = "profile-edit-edit-picture"
    case ProfileReport                      = "profile-report"
    case ProfileBlock                       = "profile-block"
    case ProfileUnblock                     = "profile-unblock"
    case ProfileShareStart                  = "profile-share-start"
    case ProfileShareComplete               = "profile-share-complete"

    case AppInviteFriendStart               = "app-invite-friend-start"
    case AppInviteFriend                    = "app-invite-friend"
    case AppInviteFriendCancel              = "app-invite-friend-cancel"
    case AppInviteFriendComplete            = "app-invite-friend-complete"
    case AppInviteFriendDontAsk             = "app-invite-friend-dont-ask"
    
    case AppRatingStart                     = "app-rating-start"
    case AppRatingRate                      = "app-rating-rate"
    case AppRatingSuggest                   = "app-rating-suggest"
    case AppRatingDontAsk                   = "app-rating-dont-ask"
    case AppRatingRemindMeLater             = "app-rating-remind-later"

    case PermissionAlertStart               = "permission-alert-start"
    case PermissionAlertCancel              = "permission-alert-cancel"
    case PermissionAlertComplete            = "permission-alert-complete"
    case PermissionSystemStart              = "permission-system-start"
    case PermissionSystemCancel             = "permission-system-cancel"
    case PermissionSystemComplete           = "permission-system-complete"

    case LocationMap                        = "location-map"

    case CommercializerStart                = "commercializer-start"
    case CommercializerError                = "commercializer-error"
    case CommercializerComplete             = "commercializer-complete"
    case CommercializerOpen                 = "commercializer-open"
    case CommercializerShareStart           = "commercializer-share-start"
    case CommercializerShareComplete        = "commercializer-share-complete"

    case UserRatingStart                    = "user-rating-start"
    case UserRatingComplete                 = "user-rating-complete"

    case OpenApp                            = "open-app-external"

    case ExpressChatStart                   = "express-chat-start"
    case ExpressChatComplete                = "express-chat-complete"
    case ExpressChatDontAsk                 = "express-chat-dont-ask"

    case ProductDetailInterestedUsers       = "product-detail-interested-users"
    
    case NPSStart                           = "nps-start"
    case NPSComplete                        = "nps-complete"

    case VerifyAccountStart                 = "verify-account-start"
    case VerifyAccountComplete              = "verify-account-complete"

    case InappChatNotificationStart         = "in-app-chat-notification-start"
    case InappChatNotificationComplete      = "in-app-chat-notification-complete"

    case SignupCaptcha                      = "signup-captcha"

    case NotificationCenterStart            = "notification-center-start"
    case NotificationCenterComplete         = "notification-center-complete"

    case MarketingPushNotifications         = "marketing-push-notifications"

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
    case CategoryId           = "category-id"           // 0 if there's no category
    case ProductId            = "product-id"
    case ProductCity          = "product-city"
    case ProductCountry       = "product-country"
    case ProductZipCode       = "product-zipcode"
    case ProductLatitude      = "product-lat"
    case ProductLongitude     = "product-lng"
    case ProductName          = "product-name"
    case ProductPrice         = "product-price"
    case ProductCurrency      = "product-currency"
    case ProductDescription   = "product-description"
    case ProductType          = "item-type"             // real (1) / dummy (0).
    case UserId               = "user-id"
    case UserToId             = "user-to-id"
    case UserEmail            = "user-email"
    case UserCity             = "user-city"
    case UserCountry          = "user-country"
    case UserZipCode          = "user-zipcode"
    case SearchString         = "search-keyword"
    case SearchSuccess        = "search-success"
    case TrendingSearch       = "trending-search"
    case Description          = "description"           // error description: why form validation failure.
    case LoginSource          = "login-type"            // the login source
    case LoginRememberedAccount = "existing"
    case LocationType         = "location-type"
    case ShareNetwork         = "share-network"
    case ButtonPosition       = "button-position"
    case LocationEnabled      = "location-enabled"
    case LocationAllowed      = "location-allowed"
    case ButtonName           = "button-name"
    case ButtonType           = "button-type"
    case FilterLat            = "filter-lat"
    case FilterLng            = "filter-lng"
    case FilterDistanceRadius = "distance-radius"
    case FilterDistanceUnit   = "distance-unit"
    case FilterSortBy         = "sort-by"
    case FilterPostedWithin   = "posted-within"
    case ErrorDescription     = "error-description"
    case ErrorDetails         = "error-details"
    case PermissionType       = "permission-type"
    case TypePage             = "type-page"
    case AlertType            = "alert-type"
    case PermissionGoToSettings = "permission-go-to-settings"
    case NegotiablePrice      = "negotiable-price"
    case PictureSource        = "picture-source"
    case EditedFields         = "edited-fields"
    case Newsletter           = "newsletter"
    case QuickAnswer          = "quick-answer"
    case ReportReason         = "report-reason"
    case Tab                  = "tab"
    case Template             = "template"
    case UserAction           = "user-action"
    case AppRatingSource      = "app-rating-source"
    case MessageType          = "message-type"
    case RatingStars          = "rating-stars"
    case RatingComments       = "rating-comments"
    case SellerUserRating     = "seller-user-rating"
    case Campaign             = "campaign"
    case Medium               = "medium"
    case Source               = "source"
    case ItemPosition         = "item-position"
    case ExpressConversations = "express-conversations"
    case CollectionTitle      = "collection-title"
    case ProductVisitSource   = "visit-source"
    case NumberOfUsers        = "number-of-users"
    case PriceFrom            = "price-from"
    case PriceTo              = "price-to"
    case NPSScore             = "nps-score"
    case AccountNetwork       = "account-network"
    case ProfileType          = "profile-type"
    case NotificationType     = "notification-type"
    case ShownReason          = "shown-reason"
    case FreePosting          = "free-posting"
    case SellButtonPosition   = "sell-button-position"
    case Enabled              = "enabled"
    case LastSearch           = "last-search"
    case ExpressChatTrigger   = "express-chat-trigger"
    case NumberPhotosPosting  = "number-photos-posting"
}

enum EventParameterLoginSourceValue: String {
    case Sell = "posting"
    case Chats = "messages"
    case Profile = "view-profile"
    case Notifications = "notifications"
    case Favourite = "favourite"
    case MarkAsSold = "mark-as-sold"
    case MarkAsUnsold = "mark-as-unsold"
    case AskQuestion = "question"
    case ReportFraud = "report-fraud"
    case Delete = "delete"
    case Install = "install"
    case DirectSticker = "direct-sticker"
}

enum EventParameterSellSourceValue: String {
    case MarkAsSold = "product-detail"
    case Delete = "product-delete"
}

enum EventParameterProductItemType: String {
    case Real = "1"
    case Dummy = "0"
}

enum EventParameterLocationType: String {
    case Manual = "manual"
    case Sensor = "sensor"
    case IPLookUp = "iplookup"
    case Regional = "regional"
}

enum EventParameterButtonNameType: String {
    case Close = "close"
    case Skip = "skip"
    case Done = "done"
    case SellYourStuff = "sell-your-stuff"
    case StartMakingCash = "start-making-cash"
}

enum EventParameterButtonType: String {
    case Button = "button"
    case ItemPicture = "item-picture"
}

enum EventParameterButtonPosition: String {
    case Top = "top"
    case Bottom = "bottom"
    case None = "N/A"
}

enum EventParameterSellButtonPosition: String {
    case TabBar = "tabbar-camera"
    case FloatingButton = "big-button"
    case None = "N/A"
}

enum EventParameterShareNetwork: String {
    case Email = "email"
    case Facebook = "facebook"
    case Whatsapp = "whatsapp"
    case Twitter = "twitter"
    case FBMessenger = "facebook-messenger"
    case Telegram = "telegram"
    case SMS = "sms"
    case CopyLink = "copy_link"
    case Native = "native"
    case NotAvailable = "N/A"
}

enum EventParameterNegotiablePrice: String {
    case Yes = "yes"
    case No = "no"
}

enum EventParameterPictureSource: String {
    case Camera = "camera"
    case Gallery = "gallery"
}

enum EventParameterSortBy: String {
    case Distance = "distance"
    case CreationDate = "creation-date"
    case PriceAsc = "price-asc"
    case PriceDesc = "price-desc"
}

enum EventParameterPostedWithin: String {
    case Day = "day"
    case Week = "week"
    case Month = "month"
    case All = ""
}

enum EventParameterHasPriceFilter: String {
    case True = "true"
    case False = "false"
}

enum EventParameterQuickAnswerValue: String {
    case True = "true"
    case False = "false"
    case None = "N/A"
}

enum EventParameterMessageType: String {
    case Text       = "text"
    case Offer      = "offer"
    case Sticker    = "sticker"
    case Favorite   = "favorite"
    case QuickAnswer = "quick-answer"
    case ExpressChat = "express-chat"
    case PeriscopeDirect = "periscope-direct"
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
        case let .internal(description):
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
    case `internal`
    case serverError(code: Int?)

    var description: String {
        switch self {
        case .network:
            return "product-sell-network"
        case .internal:
            return "product-sell-internal"
        case .serverError:
            return "product-sell-server-error"
        }
    }

    var details: Int? {
        switch self {
        case .network, .internal:
            return nil
        case let .serverError(errorCode):
            return errorCode
        }
    }
}

enum EventParameterEditedFields: String {
    case Picture = "picture"
    case Title = "title"
    case Price = "price"
    case Description = "description"
    case Category = "category"
    case Location = "location"
    case Share = "share"
    case FreePosting = "free-posting"
}

enum EventParameterTypePage: String {
    case ProductList = "product-list"
    case ProductListBanner = "product-list-banner"
    case Chat = "chat"
    case TabBar = "tab-bar"
    case ChatList = "chat-list"
    case Sell = "product-sell"
    case Edit = "product-edit"
    case ProductDetail = "product-detail"
    case ProductDetailMoreInfo = "product-detail-more-info"
    case Settings = "settings"
    case Install = "install"
    case Profile = "profile"
    case CommercializerPlayer = "commercializer-player"
    case CommercializerPreview = "commercializer-preview"
    case PushNotification = "push-notification"
    case Email = "email"
    case Onboarding = "onboarding"
    case External = "external"
    case Notifications = "notifications"
    case OpenApp = "open-app"
    case IncentivizePosting = "incentivize-posting"
    case UserRatingList = "user-rating-list"
    case ExpressChat = "express-chat"
    case ProductDelete = "product-delete"
}

enum EventParameterPermissionType: String {
    case Push = "push-notification"
    case Location = "gps"
    case Camera = "camera"
}

enum EventParameterPermissionAlertType: String {
    case Custom = "custom"
    case NativeLike = "native-alike"
    case FullScreen = "full-screen"
}

enum EventParameterNewsletter: String {
    case True = "true"
    case False = "false"
    case Unset = "N/A"
}

enum EventParameterTab: String {
    case Selling = "selling"
    case Sold = "sold"
    case Favorites = "favorites"
}

enum EventParameterSearchCompleteSuccess: String {
    case Success = "yes"
    case Failed = "no"
}

enum EventParameterReportReason: String {
    case Offensive = "offensive"
    case Scammer = "scammer"
    case Mia = "mia"
    case Suspicious = "suspicious"
    case Inactive = "inactive"
    case ProhibitedItems = "prohibited-items"
    case Spammer = "spammer"
    case CounterfeitItems = "counterfeit-items"
    case Other = "other"
}

enum EventParameterCommercializerError: String {
    case Network = "commercializer-network"
    case Internal = "commercializer-internal"
    case Duplicated = "commercializer-duplicated"
}

enum EventParameterPermissionGoToSettings: String {
    case True = "true"
    case NotAvailable = "N/A"
}

enum ProductVisitUserAction: String {
    case Tap = "tap"
    case SwipeLeft = "swipe-left"
    case SwipeRight = "swipe-right"
    case None = "N/A"
}

enum EventParameterRatingSource: String {
    case Chat = "chat"
    case ProductSellComplete = "product-sell-complete"
    case MarkedSold = "marked-sold"
}

enum EventParameterProductVisitSource: String {
    case ProductList = "product-list"
    case MoreInfoRelated = "more-info-related"
    case Collection = "collection"
    case Search = "search"
    case Filter = "filter"
    case SearchAndFilter = "search & filter"
    case Category = "category"
    case Profile = "profile"
    case Chat = "chat"
    case OpenApp = "open-app"
    case Notifications = "notifications"
}

enum EventParameterAccountNetwork: String {
    case Facebook = "facebook"
    case Google = "google"
    case Email = "email"
}

enum EventParameterProfileType: String {
    case Public = "public"
    case Private = "private"
}

enum EventParameterNotificationType: String {
    case Welcome = "welcome"
    case Favorite = "favorite"
    case ProductSold = "favorite-sold"
    case Rating = "rating"
    case RatingUpdated = "rating-updated"
    case BuyersInterested = "buyers-interested"
    case ProductSuggested = "product-suggested"
}

enum EventParameterRelatedShownReason: String {
    case ProductSold = "product-sold"
    case ProductDeleted = "product-deleted"
    case UserDeleted = "user-deleted"
    case Unanswered48h = "unanswered-48h"
    case Forbidden = "forbidden"

    init(chatInfoStatus: ChatInfoViewStatus) {
        switch chatInfoStatus {
        case .forbidden:
            self = .Forbidden
        case .blocked, .blockedBy:
            self = .Unanswered48h
        case .productDeleted:
            self = .ProductDeleted
        case .productSold:
            self = .ProductSold
        case .userPendingDelete, .userDeleted:
            self = .UserDeleted
        case .available:
            self = .Unanswered48h
        }
    }
}

enum EventParameterFreePosting: String {
    case True = "true"
    case False = "false"
    case Unset = "N/A"
}

enum EventParameterExpressChatTrigger: String {
    case Automatic = "automatic"
    case Manual = "manual"
}

struct EventParameters {
    private var params: [EventParameterName : Any] = [:]
    
    // transforms the params to [String: AnyObject]
    var stringKeyParams: [String: Any] {
        get {
            var res = [String: Any]()
            for (paramName, value) in params {
                res[paramName.rawValue] = value
            }
            return res
        }
    }
    
    internal mutating func addLoginParams(_ source: EventParameterLoginSourceValue, rememberedAccount: Bool? = nil) {
        params[.LoginSource] = source.rawValue
        if let rememberedAccount = rememberedAccount {
            params[.LoginRememberedAccount] = rememberedAccount
        }
    }
    
    internal mutating func addProductParams(_ product: Product) {
        params[.ProductId] = product.objectId
        params[.ProductLatitude] = product.location.latitude
        params[.ProductLongitude] = product.location.longitude
        params[.ProductPrice] = product.price.value
        params[.ProductCurrency] = product.currency.code
        params[.CategoryId] = product.category.rawValue
        params[.ProductType] = product.user.isDummy ?
            EventParameterProductItemType.Dummy.rawValue : EventParameterProductItemType.Real.rawValue
        params[.UserToId] = product.user.objectId
    }
    
    internal mutating func addChatProductParams(_ product: ChatProduct) {
        params[.ProductId] = product.objectId
        params[.ProductPrice] = product.price.value
        params[.ProductCurrency] = product.currency.code
        params[.ProductType] = EventParameterProductItemType.Real.rawValue
    }
    
    internal mutating func addUserParams(_ user: User?) {
        params[.UserToId] = user?.objectId
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
        self.imageSource = imageSource ?? .Camera
        if let price = price, let doublePrice = Double(price) {
            negotiablePrice = doublePrice > 0 ? .No : .Yes
        } else {
            negotiablePrice = .Yes
        }
    }
}
