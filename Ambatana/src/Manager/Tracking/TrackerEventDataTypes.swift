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
    
    case LoginError                         = "login-error"
    case SignupError                        = "signup-error"
    case PasswordResetError                 = "password-reset-error"

    case ProductList                        = "product-list"
    
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
    
    case ProductAskQuestion                 = "product-detail-ask-question"
    case ProductContinueChatting            = "product-detail-continue-chatting"
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

    case ProfileVisit                       = "profile-visit"
    case ProfileEditStart                   = "profile-edit-start"
    case ProfileEditEditName                = "profile-edit-edit-name"
    case ProfileEditEditLocation            = "profile-edit-edit-location"
    case ProfileEditEditPicture             = "profile-edit-edit-picture"

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
    case AppRatingBannerOpen                = "app-rating-banner-open"
    case AppRatingBannerClose               = "app-rating-banner-close"

    case PermissionAlertStart               = "permission-alert-start"
    case PermissionAlertCancel              = "permission-alert-cancel"
    case PermissionAlertComplete            = "permission-alert-complete"
    case PermissionSystemStart              = "permission-system-start"
    case PermissionSystemCancel             = "permission-system-cancel"
    case PermissionSystemComplete           = "permission-system-complete"

    case ProfileReport                      = "profile-report"
    case ProfileBlock                       = "profile-block"
    case ProfileUnblock                     = "profile-unblock"

    case LocationMap                        = "location-map"

    case CommercializerStart                = "commercializer-start"
    case CommercializerError                = "commercializer-error"
    case CommercializerComplete             = "commercializer-complete"
    case CommercializerOpen                 = "commercializer-open"
    case CommercializerShareStart           = "commercializer-share-start"
    case CommercializerShareComplete        = "commercializer-share-complete"

    case UserRatingStart                    = "user-rating-start"
    case UserRatingComplete                 = "user-rating-complete"


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
    case ProductType          = "item-type"             // real (1) / dummy (0).
    case UserToId             = "user-to-id"
    case UserEmail            = "user-email"
    case UserCity             = "user-city"
    case UserCountry          = "user-country"
    case UserZipCode          = "user-zipcode"
    case SearchString         = "search-keyword"
    case SearchSuccess        = "search-success"
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
    case ErrorDescription     = "error-description"
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
    case DesignType           = "design-type"
    case RatingStars          = "rating-stars"
    case RatingComments       = "rating-comments"
    case SellerUserRating     = "seller-user-rating"
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

public enum EventParameterQuickAnswerValue: String {
    case True = "true"
    case False = "false"
    case None = "N/A"
}

public enum EventParameterMessageType: String {
    case Text       = "text"
    case Offer      = "offer"
    case Sticker    = "sticker"
}

public enum EventParameterLoginError: String {
    
    case Network
    case Internal
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


    public var description: String {
        switch (self) {
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
        }
    }
}

public enum EventParameterPostProductError: String {
    case Network = "product-sell-network"
    case Internal = "product-sell-internal"
}

public enum EventParameterEditedFields: String {
    case Picture
    case Title
    case Price
    case Description
    case Category
    case Location
    case Share

    public var value: String {
        return self.rawValue.lowercaseString
    }
}

public enum EventParameterTypePage: String {
    case ProductList = "product-list"
    case Chat = "chat"
    case ChatList = "chat-list"
    case Sell = "product-sell"
    case Edit = "product-edit"
    case ProductDetail = "product-detail"
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
    case Banner = "banner-rating"
    case Chat = "chat"
    case ProductSellComplete = "product-sell-complete"
    case MarkedSold = "marked-sold"
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
        params[.ProductPrice] = product.price
        params[.ProductCurrency] = product.currency.code
        params[.CategoryId] = product.category.rawValue
        params[.ProductType] = product.user.isDummy ?
            EventParameterProductItemType.Dummy.rawValue : EventParameterProductItemType.Real.rawValue
        params[.UserToId] = product.user.objectId
    }
    
    internal mutating func addChatProductParams(product: ChatProduct) {
        params[.ProductId] = product.objectId
        params[.ProductPrice] = product.price
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
