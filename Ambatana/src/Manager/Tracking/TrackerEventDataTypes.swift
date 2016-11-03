//
//  TrackerEventDataTypes.swift
//  LetGo
//
//  Created by Albert Hernández López on 06/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

public enum EventName: String {
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

    case ProductList                        = "product-list"
    case ExploreCollection                  = "explore-collection"
    
    case SearchStart                        = "search-start"
    case SearchComplete                     = "search-complete"
    
    case FilterStart                        = "filter-start"
    case FilterComplete                     = "filter-complete"
    
    case ProductDetailVisit                 = "product-detail-visit"
    case ProductDetailVisitMoreInfo         = "product-detail-visit-more-info"
    
    case ProductFavorite                    = "product-detail-favorite"
    case ProductShare                       = "product-detail-share"
    case ProductShareCancel                 = "product-detail-share-cancel"
    case ProductShareComplete               = "product-detail-share-complete"
    
    case FirstMessage                 = "product-detail-ask-question"
    case ProductChatButton                  = "product-detail-chat-button"
    case ProductMarkAsSold                  = "product-detail-sold"
    case ProductMarkAsUnsold                = "product-detail-unsold"
    
    case ProductReport                      = "product-detail-report"
    
    case ProductSellStart                   = "product-sell-start"
    case ProductSellFormValidationFailed    = "product-sell-form-validation-failed"
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

public enum EventParameterName: String {
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
    case LocationType         = "location-type"
    case ShareNetwork         = "share-network"
    case ButtonPosition       = "button-position"
    case LocationEnabled      = "location-enabled"
    case LocationAllowed      = "location-allowed"
    case ButtonName           = "button-name"
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
}

public enum EventParameterLoginSourceValue: String {
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

public enum EventParameterSellSourceValue: String {
    case MarkAsSold = "product-detail"
    case Delete = "product-delete"
}

public enum EventParameterProductItemType: String {
    case Real = "1"
    case Dummy = "0"
}

public enum EventParameterLocationType: String {
    case Manual = "manual"
    case Sensor = "sensor"
    case IPLookUp = "iplookup"
    case Regional = "regional"
}

public enum EventParameterButtonNameType: String {
    case Close = "close"
    case Skip = "skip"
    case Done = "done"
    case SellYourStuff = "sell-your-stuff"
    case StartMakingCash = "start-making-cash"
}

public enum EventParameterButtonPosition: String {
    case Top = "top"
    case Bottom = "bottom"
    case None = "N/A"
}

public enum EventParameterShareNetwork: String {
    case Email = "email"
    case Facebook = "facebook"
    case Whatsapp = "whatsapp"
    case Twitter = "twitter"
    case FBMessenger = "facebook-messenger"
    case Telegram = "telegram"
    case SMS = "sms"
    case CopyLink = "copy_link"
}

public enum EventParameterNegotiablePrice: String {
    case Yes = "yes"
    case No = "no"
}

public enum EventParameterPictureSource: String {
    case Camera = "camera"
    case Gallery = "gallery"
}

public enum EventParameterSortBy: String {
    case Distance = "distance"
    case CreationDate = "creation-date"
    case PriceAsc = "price-asc"
    case PriceDesc = "price-desc"
}

public enum EventParameterPostedWithin: String {
    case Day = "day"
    case Week = "week"
    case Month = "month"
    case All = ""
}

public enum EventParameterHasPriceFilter: String {
    case True = "true"
    case False = "false"
}

public enum EventParameterQuickAnswerValue: String {
    case True = "true"
    case False = "false"
    case None = "N/A"
}

public enum EventParameterMessageType: String {
    case Text       = "text"
    case Offer      = "offer"
    case Sticker    = "sticker"
    case Favorite   = "favorite"
}

public enum EventParameterLoginError {
    
    case Network
    case Internal(description: String)
    case Unauthorized
    case NotFound
    case Forbidden
    case InvalidEmail
    case NonExistingEmail
    case InvalidPassword
    case InvalidUsername
    case UserNotFoundOrWrongPassword
    case EmailTaken
    case PasswordMismatch
    case UsernameTaken
    case TermsNotAccepted
    case TooManyRequests
    case Scammer
    case BlacklistedDomain
    case BadRequest

    public var description: String {
        switch self {
        case .Network:
            return "Network"
        case .Internal:
            return "Internal"
        case .Unauthorized:
            return "Unauthorized"
        case .NotFound:
            return "NotFound"
        case .Forbidden:
            return "Forbidden"
        case .InvalidEmail:
            return "InvalidEmail"
        case .NonExistingEmail:
            return "NonExistingEmail"
        case .InvalidPassword:
            return "InvalidPassword"
        case .InvalidUsername:
            return "InvalidUsername"
        case .UserNotFoundOrWrongPassword:
            return "UserNotFoundOrWrongPassword"
        case .EmailTaken:
            return "EmailTaken"
        case .PasswordMismatch:
            return "PasswordMismatch"
        case .UsernameTaken:
            return "UsernameTaken"
        case .TermsNotAccepted:
            return "TermsNotAccepted"
        case .TooManyRequests:
            return "TooManyRequests"
        case .Scammer:
            return "Scammer"
        case .BlacklistedDomain:
            return "BlacklistedDomain"
        case .BadRequest:
            return "BadRequest"
        }

    }

    public var details: String? {
        switch self {
        case let .Internal(description):
            return description
        case .Network, .Unauthorized, .NotFound, .Forbidden, .InvalidEmail, .NonExistingEmail, .InvalidPassword,
             .InvalidUsername, .UserNotFoundOrWrongPassword, .EmailTaken, .PasswordMismatch, .UsernameTaken,
             .TermsNotAccepted, .TooManyRequests, .Scammer, BlacklistedDomain, .BadRequest:
            return nil
        }
    }
}

public enum EventParameterPostProductError {
    case Network
    case Internal
    case ServerError(code: Int?)

    var description: String {
        switch self {
        case .Network:
            return "product-sell-network"
        case .Internal:
            return "product-sell-internal"
        case .ServerError:
            return "product-sell-server-error"
        }
    }

    var details: Int? {
        switch self {
        case .Network, .Internal:
            return nil
        case let .ServerError(errorCode):
            return errorCode
        }
    }
}

public enum EventParameterEditedFields: String {
    case Picture = "picture"
    case Title = "title"
    case Price = "price"
    case Description = "description"
    case Category = "category"
    case Location = "location"
    case Share = "share"
    case FreePosting = "free-posting"
}

public enum EventParameterTypePage: String {
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
}

public enum EventParameterPermissionType: String {
    case Push = "push-notification"
    case Location = "gps"
    case Camera = "camera"
}

public enum EventParameterPermissionAlertType: String {
    case Custom = "custom"
    case NativeLike = "native-alike"
    case FullScreen = "full-screen"
}

public enum EventParameterNewsletter: String {
    case True = "true"
    case False = "false"
    case Unset = "N/A"
}

public enum EventParameterTab: String {
    case Selling = "selling"
    case Sold = "sold"
    case Favorites = "favorites"
}

public enum EventParameterSearchCompleteSuccess: String {
    case Success = "yes"
    case Failed = "no"
}

public enum EventParameterReportReason: String {
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

public enum EventParameterCommercializerError: String {
    case Network = "commercializer-network"
    case Internal = "commercializer-internal"
    case Duplicated = "commercializer-duplicated"
}

public enum EventParameterPermissionGoToSettings: String {
    case True = "true"
    case NotAvailable = "N/A"
}

public enum ProductVisitUserAction: String {
    case Tap = "tap"
    case SwipeLeft = "swipe-left"
    case SwipeRight = "swipe-right"
    case None = "N/A"
}

public enum EventParameterRatingSource: String {
    case Chat = "chat"
    case ProductSellComplete = "product-sell-complete"
    case MarkedSold = "marked-sold"
}

public enum EventParameterProductVisitSource: String {
    case ProductList = "product-list"
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

public enum EventParameterAccountNetwork: String {
    case Facebook = "facebook"
    case Google = "google"
    case Email = "email"
}

public enum EventParameterProfileType: String {
    case Public = "public"
    case Private = "private"
}

public enum EventParameterNotificationType: String {
    case Welcome = "welcome"
    case Favorite = "favorite"
    case ProductSold = "favorite-sold"
    case Rating = "rating"
    case RatingUpdated = "rating-updated"
}

public enum EventParameterRelatedShownReason: String {
    case ProductSold = "product-sold"
    case ProductDeleted = "product-deleted"
    case UserDeleted = "user-deleted"
    case Unanswered48h = "unanswered-48h"
    case Forbidden = "forbidden"

    init(chatInfoStatus: ChatInfoViewStatus) {
        switch chatInfoStatus {
        case .Forbidden:
            self = .Forbidden
        case .Blocked, .BlockedBy:
            self = .Unanswered48h
        case .ProductDeleted:
            self = .ProductDeleted
        case .ProductSold:
            self = .ProductSold
        case .UserPendingDelete, .UserDeleted:
            self = .UserDeleted
        case .Available:
            self = .Unanswered48h
        }
    }
}

public enum EventParameterFreePosting: String {
    case True = "true"
    case False = "false"
    case Unset = "N/A"
}

public struct EventParameters {
    private var params: [EventParameterName : AnyObject] = [:]
    
    // transforms the params to [String: AnyObject]
    public var stringKeyParams: [String: AnyObject] {
        get {
            var res = [String: AnyObject]()
            for (paramName, value) in params {
                res[paramName.rawValue] = value
            }
            return res
        }
    }
    
    internal mutating func addLoginParams(source: EventParameterLoginSourceValue) {
        params[.LoginSource] = source.rawValue
    }
    
    internal mutating func addProductParams(product: Product) {
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
    
    internal mutating func addChatProductParams(product: ChatProduct) {
        params[.ProductId] = product.objectId
        params[.ProductPrice] = product.price.value
        params[.ProductCurrency] = product.currency.code
        params[.ProductType] = EventParameterProductItemType.Real.rawValue
    }
    
    internal mutating func addUserParams(user: User?) {
        params[.UserToId] = user?.objectId
    }

    internal subscript(paramName: EventParameterName) -> AnyObject? {
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
    var imageSource: EventParameterPictureSource
    var negotiablePrice: EventParameterNegotiablePrice

    init(buttonName: EventParameterButtonNameType, imageSource: EventParameterPictureSource?, price: String?) {
        self.buttonName = buttonName
        self.imageSource = imageSource ?? .Camera
        if let price = price, let doublePrice = Double(price) {
            negotiablePrice = doublePrice > 0 ? .No : .Yes
        } else {
            negotiablePrice = .Yes
        }
    }
}
