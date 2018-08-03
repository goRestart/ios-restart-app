//
//  TrackerEventDataTypes.swift
//  LetGo
//
//  Created by Albert Hernández López on 06/08/15.
//  Copyright © 2018 Ambatana B.V. Holdings. All rights reserved.
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

    case listingList                        = "product-list"
    case listingListVertical                = "product-list-vertical"
    case exploreCollection                  = "explore-collection"
    
    case searchStart                        = "search-start"
    case searchComplete                     = "search-complete"
    
    case filterStart                        = "filter-start"
    case filterComplete                     = "filter-complete"
    case filterLocationStart                = "filter-location-start"

    case listingDetailCall                  = "product-detail-call"
    case listingDetailVisit                 = "product-detail-visit"
    case listingDetailVisitMoreInfo         = "product-detail-visit-more-info"
    case listingNotAvailable                = "product-not-available"
    case listingVisitPhotoViewer            = "product-visit-photo-viewer"
    case listingVisitPhotoChat              = "product-visit-photo-chat"

    case listingFavorite                    = "product-detail-favorite"
    case listingShare                       = "product-detail-share"
    case listingShareCancel                 = "product-detail-share-cancel"
    case listingShareComplete               = "product-detail-share-complete"
    
    case firstMessage                       = "product-detail-ask-question"
    case listingOpenChat                    = "product-detail-open-chat"
    case listingMarkAsSold                  = "product-detail-sold"
    case listingMarkAsSoldAtLetgo           = "product-detail-sold-at-letgo"
    case listingMarkAsSoldOutsideLetgo      = "product-detail-sold-outside-letgo"
    case listingMarkAsUnsold                = "product-detail-unsold"
    case listingReport                      = "product-detail-report"
    case listingReportError                 = "product-detail-report-error"
    
    case listingSellYourStuffButton         = "product-sell-your-stuff-button"
    case listingSellStart                   = "product-sell-start"
    case listingSellComplete                = "product-sell-complete"
    case listingSellComplete24h             = "product-sell-complete-24h"
    case listingSellError                   = "product-sell-error"
    case listingSellErrorClose              = "product-sell-error-close"
    case listingSellErrorPost               = "product-sell-error-post"
    case listingSellErrorData               = "product-sell-error-data"
    case listingSellConfirmation            = "product-sell-confirmation"
    case listingSellConfirmationPost        = "product-sell-confirmation-post"
    case listingSellConfirmationClose       = "product-sell-confirmation-close"
    case listingSellConfirmationEdit        = "product-sell-confirmation-edit"
    case listingSellConfirmationShare       = "product-sell-confirmation-share"
    case listingSellConfirmationShareCancel = "product-sell-confirmation-share-cancel"
    case listingSellConfirmationShareComplete = "product-sell-confirmation-share-complete"
    case listingSellAbandon                 = "product-sell-abandon"
    
    case listingEditStart                   = "product-edit-start"
    case listingEditFormValidationFailed    = "product-edit-form-validation-failed"
    case listingEditSharedFB                = "product-edit-shared-fb"
    case listingEditComplete                = "product-edit-complete"
    
    case listingDeleteStart                 = "product-delete-start"
    case listingDeleteComplete              = "product-delete-complete"
    
    case relatedListings                    = "related-items-list"
    
    case userMessageSent                    = "user-sent-message"
    case userMessageSentError               = "user-sent-message-error"
    case chatRelatedItemsStart              = "chat-related-items-start"
    case chatRelatedItemsComplete           = "chat-related-items-complete"
    case chatDeleteComplete                 = "chat-delete-complete"
    case chatViewInactiveConversations      = "chat-view-inactive-conversations"
    case chatInactiveConversationsShown     = "chat-inactive-conversations-shown"
    case markMessagesAsRead                 = "mark-messages-as-read"

    case profileVisit                       = "profile-visit"
    case profileEditStart                   = "profile-edit-start"
    case profileEditEditName                = "profile-edit-edit-name"
    case profileEditEditLocationStart       = "profile-edit-edit-location-start"
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

    case userRatingStart                    = "user-rating-start"
    case userRatingComplete                 = "user-rating-complete"
    case userRatingReport                   = "user-rating-report"

    case openApp                            = "open-app-external"

    case expressChatStart                   = "express-chat-start"
    case expressChatComplete                = "express-chat-complete"
    case expressChatDontAsk                 = "express-chat-dont-ask"

    case npsStart                           = "nps-start"
    case npsComplete                        = "nps-complete"
    case surveyStart                        = "survey-start"
    case surveyCompleted                    = "survey-completed"

    case verifyAccountStart                 = "verify-account-start"
    case verifyAccountComplete              = "verify-account-complete"

    case inappChatNotificationStart         = "in-app-chat-notification-start"
    case inappChatNotificationComplete      = "in-app-chat-notification-complete"

    case signupCaptcha                      = "signup-captcha"
    case loginCaptcha                       = "login-captcha"

    case notificationCenterStart            = "notification-center-start"
    case notificationCenterComplete         = "notification-center-complete"

    case marketingPushNotifications         = "marketing-push-notifications"

    case bumpBannerShow                     = "bump-banner-show"
    case bumpInfoShown                      = "bump-info-shown"
    case bumpUpStart                        = "bump-up-start"
    case bumpUpComplete                     = "bump-up-complete"
    case bumpUpFail                         = "bump-up-fail"
    case mobilePaymentComplete              = "mobile-payment-complete" // triggered when the payment has been confirmed by Apple/Google. (this event is triggered before the bump-up-complete event)
    case mobilePaymentFail                  = "mobile-payment-fail"
    case bumpNotAllowed                     = "bump-up-not-allowed"
    case bumpNotAllowedContactUs            = "bump-up-not-allowed-contact-us"
    case bumpUpPromo                        = "bump-up-promo"

    case chatWindowVisit                    = "chat-window-open"
    
    case emptyStateError                    = "empty-state-error"
    
    case filterBubble                       = "filter-bubble"
    case onboardingInterestsComplete        = "onboarding-interests-complete"
    case categoriesStart                    = "categories-start"
    case categoriesComplete                 = "categories-complete"

    case adTapped                           = "ad-tapped"
    case featuredMoreInfo                   = "featured-more-info"
    case openOptionOnSummary                = "posting-summary-open"

    case phoneNumberRequest                 = "phone-number-request"
    case phoneNumberSent                    = "phone-number-sent"
    case phoneNumberNotNow                  = "phone-number-not-now"
    
    case tutorialDialogStart                = "onboarding-dialog-start"
    case tutorialDialogComplete             = "onboarding-dialog-complete"
    case tutorialDialogAbandon              = "onboarding-dialog-abandon"

    case predictedPosting                   = "predicted-posting"

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
    case listingId            = "product-id"
    case listingCity          = "product-city"
    case listingCountry       = "product-country"
    case listingZipCode       = "product-zipcode"
    case listingLatitude      = "product-lat"
    case listingLongitude     = "product-lng"
    case listingName          = "product-name"
    case listingPrice         = "product-price"
    case listingCurrency      = "product-currency"
    case listingDescription   = "product-description"
    case listingStatus        = "product-status"
    case listingType          = "item-type"             // real (1) / dummy (0).
    case userId               = "user-id"
    case userToId             = "user-to-id"
    case userEmail            = "user-email"
    case userCity             = "user-city"
    case userCountry          = "user-country"
    case userZipCode          = "user-zipcode"
    case searchString         = "search-keyword"
    case searchSuccess        = "search-success"
    case searchSuggestion     = "search-suggestion"
    case searchSuggestionPosition = "search-suggestion-position"
    case trendingSearch       = "trending-search"
    case description          = "description"           // error description: why form validation failure.
    case loginSource          = "login-type"            // the login source
    case loginRememberedAccount = "existing"
    case locationType         = "location-type"
    case zipCode              = "zipcode"
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
    case userAction           = "user-action"
    case appRatingSource      = "app-rating-source"
    case appRatingReason     = "app-rating-reason"
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
    case listingVisitSource   = "visit-source"
    case numberOfUsers        = "number-of-users"
    case priceFrom            = "price-from"
    case priceTo              = "price-to"
    case npsScore             = "nps-score"
    case accountNetwork       = "account-network"
    case profileType          = "profile-type"
    case notificationClickArea = "notification-click-area"
    case notificationAction   = "notification-action"
    case notificationCampaign = "notification-campaign"
    case shownReason          = "shown-reason"
    case freePosting          = "free-posting"
    case sellButtonPosition   = "sell-button-position"
    case enabled              = "enabled"
    case lastSearch           = "last-search"
    case expressChatTrigger   = "express-chat-trigger"
    case numberPhotosPosting  = "number-photos-posting"
    case bumpUpPrice          = "price"
    case bumpUpType           = "bump-type"
    case paymentId            = "payment-id"
    case retriesNumber        = "retries-number"
    case storeProductId       = "store-productId"
    case passiveConversations = "passive-conversations"
    case feedPosition         = "feed-position"
    case feedSource           = "feed-source"
    case rating               = "rating"
    case userSoldTo           = "user-sold-to"
    case isBumpedUp           = "bump-up"
    case chatEnabled          = "chat-enabled"
    case reason               = "reason"
    case quickAnswerType      = "quick-answer-type"
    case listSuccess          = "list-success"
    case userFromId           = "user-from-id"
    case notAvailableReason   = "not-available-reason"
    case surveyUrl            = "survey-url"
    case blockButtonPosition  = "block-button-position"
    case postingType          = "posting-type"
    case make                 = "product-make"
    case model                = "product-model"
    case year                 = "product-year"
    case yearStart            = "product-year-start"
    case yearEnd              = "product-year-end"
    case verticalKeyword            = "vertical-keyword"
    case verticalMatchingFields     = "vertical-matching-fields"
    case verticalNoMatchingFields   = "vertical-no-matching-fields"
    case verticalFields             = "vertical-fields"
    case bubblePosition       = "bubble-position"
    case bubbleName           = "bubble-name"
    case superKeywordsTotal   = "superkeyword-total"
    case superKeywordsIds     = "superkeyword-ids"
    case keywordName          = "keyword-name"
    case relatedSource        = "related-source"
    case adShown              = "ad-shown"
    case adType               = "ad-type"
    case adQueryType          = "ad-query-type"
    case adQuery              = "ad-query-text"
    case adVisibility         = "ad-visibility"
    case adActionLeftApp      = "left-application"
    case isMine               = "is-mine"
    case numberOfItems        = "number-of-items"
    case transactionStatus    = "transaction-status"
    case promotedBump         = "promoted-bump"
    case propertyType         = "property-type"
    case offerType            = "deal-type"
    case bedrooms             = "bedroom-number"
    case bathrooms            = "bathroom-number"
    case location             = "location"
    case sizeSqrMeters        = "size"
    case sizeSqrMetersMin     = "size-from"
    case sizeSqrMetersMax     = "size-to"
    case rooms                = "room-number"
    case openField            = "open-field"
    case chatsDeleted         = "chats-deleted"
    case chatContainsEmoji    = "contain-emoji"
    case inactiveConversations = "inactive-conversations"
    case mostSearchedButton   = "most-searched-button"
    case photoViewerNumberOfPhotos   = "number-photos"
    case abandonStep          = "abandon-step"
    
    
    // Machine Learning
    case mlPredictiveFlow = "predictive-flow"
    case mlPredictionActive = "prediction-active"
    case mlPredictedTitle = "predicted-title"
    case mlPredictedPrice = "predicted-price"
    case mlPredictedCategory = "predicted-category"
    case mlListingCategory = "product-category"
    
    case typeTutorialDialog   = "type-onboarding-dialog"
    case pageNumber           = "page-number"
}

public enum EventParameterBoolean: String {
    case trueParameter = "true"
    case falseParameter = "false"
    case notAvailable = "N/A"

    init(bool: Bool?) {
        switch bool {
        case .some(true):
            self = .trueParameter
        case .some(false):
            self = .falseParameter
        case .none:
            self = .notAvailable
        }
    }
}

public enum EventParameterLoginSourceValue: String {
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
    case directChat = "direct-chat"
    case directQuickAnswer = "direct-quick-answer"
    case chatProUser = "chat-pro-user"
}

public enum EventParameterProductItemType: String {
    case real = "1"
    case dummy = "0"
}

public enum EventParameterButtonNameType: String {
    case close = "close"
    case skip = "skip"
    case done = "done"
    case summary = "summary"
    case sellYourStuff = "sell-your-stuff"
    case startMakingCash = "start-making-cash"
    case realEstatePromo = "real-estate-promo"
}

public enum EventParameterButtonType: String {
    case button = "button"
    case itemPicture = "item-picture"
}

public enum EventParameterButtonPosition: String {
    case top = "top"
    case bottom = "bottom"
    case bumpUp = "bump-up"
    case none = "N/A"
}

public enum EventParameterSellButtonPosition: String {
    case tabBar = "tabbar-camera"
    case floatingButton = "big-button"
    case none = "N/A"
    case realEstatePromo = "real-estate-promo"
}

public enum EventParameterShareNetwork: String {
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

public enum EventParameterNegotiablePrice: String {
    case yes = "yes"
    case no = "no"
}

public enum EventParameterPictureSource: String {
    case camera = "camera"
    case gallery = "gallery"
}

public enum EventParameterSortBy: String {
    case distance = "distance"
    case creationDate = "creation-date"
    case priceAsc = "price-asc"
    case priceDesc = "price-desc"
}

public enum EventParameterPostedWithin: String {
    case day = "day"
    case week = "week"
    case month = "month"
    case all = ""
}

public enum EventParameterPostingType: String {
    case car = "car"
    case stuff = "stuff"
    case realEstate = "real-estate"
    case service = "service"
    case none = "N/A"
}

public enum EventParameterPostingAbandonStep: String {
    case cameraPermissions = "camera-permissions"
    case retry = "retry"
    case summaryOnboarding = "summary-onboarding"
    case welcomeOnboarding = "welcome-onboarding"
    
    static var allValues: [EventParameterPostingAbandonStep] {
        return [.cameraPermissions, .retry, .summaryOnboarding, .welcomeOnboarding]
    }
}

public enum EventParameterMake {
    case make(name: String?)
    case none

    var name: String {
        switch self {
        case .make(let name):
            guard let name = name, !name.isEmpty else { return Constants.EventValue.notApplicable }
            return name
        case .none:
            return Constants.EventValue.notApplicable
        }
    }
}

public enum EventParameterModel {
    case model(name: String?)
    case none

    var name: String {
        switch self {
        case .model(let name):
            guard let name = name, !name.isEmpty else { return Constants.EventValue.notApplicable }
            return name
        case .none:
            return Constants.EventValue.notApplicable
        }
    }
}

public enum EventParameterYear {
    case year(year: Int?)
    case none

    var year: String {
        switch self {
        case .year(let year):
            guard let year = year, year != 0 else { return Constants.EventValue.notApplicable }
            return String(year)
        case .none:
            return Constants.EventValue.notApplicable
        }
    }
}



public enum EventParameterStringRealEstate {
    case realEstateParam(name: String?)
    case none
    case notApply
    
    var name: String {
        switch self {
        case let .realEstateParam(name):
            return name ?? Constants.EventValue.skip
        case .none:
            return Constants.EventValue.skip
        case .notApply:
            return Constants.EventValue.notApplicable
        }
    }
}

public enum EventParameterBathroomsRealEstate {
    case bathrooms(value: Float?)
    case notApply
    
    var name: String {
        switch self {
        case .bathrooms(let value):
            guard let value = value else { return Constants.EventValue.skip }
            return String(value)
        case .notApply:
            return Constants.EventValue.notApplicable
        }
    }
}

public enum EventParameterBedroomsRealEstate {
    case bedrooms(value: Int?)
    case notApply
    
    var name: String {
        switch self {
        case .bedrooms(let value):
            guard let value = value else { return Constants.EventValue.skip }
            return String(value)
        case .notApply:
            return Constants.EventValue.notApplicable
        }
    }
}

public enum EventParameterRoomsRealEstate {
    case rooms(bedrooms: Int?, livingRooms: Int?)
    case notApply
    
    var name: String {
        switch self {
        case .rooms(let bedrooms, let livingRooms):
            guard let bedrooms = bedrooms, let livingRooms = livingRooms else { return Constants.EventValue.skip }
            return NumberOfRooms(numberOfBedrooms: bedrooms, numberOfLivingRooms: livingRooms).trackingString
        case .notApply:
            return Constants.EventValue.notApplicable
        }
    }
}

public enum EventParameterSizeRealEstate {
    case size(value: Int?)
    case notApply
    
    var name: String {
        switch self {
        case .size(let value):
            guard let value = value else { return Constants.EventValue.skip }
            return String(value)
        case .notApply:
            return Constants.EventValue.notApplicable
        }
    }
}


public enum EventParameterMessageType: String {
    case text       = "text"
    case offer      = "offer"
    case sticker    = "sticker"
    case favorite   = "favorite"
    case quickAnswer = "quick-answer"
    case expressChat = "express-chat"
    case periscopeDirect = "periscope-direct"
    case phone      = "phone"
}

public enum EventParameterLoginError {
    
    case network
    case internalError(description: String)
    case unauthorized
    case notFound
    case forbidden
    case invalidEmail
    case nonExistingEmail
    case deviceNotAllowed
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
        case .deviceNotAllowed:
            return "DeviceNotAllowed"
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
             .termsNotAccepted, .tooManyRequests, .scammer, .blacklistedDomain, .badRequest, .deviceNotAllowed:
            return nil
        }
    }
}

public enum EventParameterPostListingError {
    case network
    case internalError
    case forbidden(cause: ForbiddenCause)
    case serverError(code: Int?)

    var description: String {
        switch self {
        case .network:
            return "product-sell-network"
        case .internalError:
            return "product-sell-internal"
        case let .forbidden(cause):
            return  cause == .differentCountry ? "product-sell-different-country-error" : "product-sell-server-error"
        case .serverError:
            return "product-sell-server-error"
        }
    }

    var details: Int? {
        switch self {
        case .network, .internalError, .forbidden:
            return nil
        case let .serverError(errorCode):
            return errorCode
        }
    }
}

public enum EventParameterProductReportError {
    case network
    case internalError
    case serverError
    
    var description: String {
        switch self {
        case .network:
            return "report-network"
        case .internalError:
            return "report-internal"
        case .serverError:
            return "report-server"
        }
    }
    
}

public enum EventParameterChatError {
    case network(code: Int?)
    case internalError(description: String?)
    case serverError(code: Int?)

    var description: String {
        switch self {
        case .network:
            return "chat-network"
        case .internalError:
            return "chat-internal"
        case .serverError:
            return "chat-server"
        }
    }

    var details: String? {
        switch self {
        case let .network(errorCode):
            if let errorCode = errorCode {
                return String(errorCode)
            }
        case let .internalError(description):
            return description
        case let .serverError(errorCode):
            if let errorCode = errorCode {
                return String(errorCode)
            }
        }
        return nil
    }
}

public enum EventParameterEditedFields: String {
    case picture = "picture"
    case title = "title"
    case price = "price"
    case description = "description"
    case category = "category"
    case location = "location"
    case share = "share"
    case freePosting = "free-posting"
    case make = "make"
    case model = "model"
    case year = "year"
}

public enum EventParameterTypePage: String {
    case listingList = "product-list"
    case listingListBanner = "product-list-banner"
    case listingListFeatured = "product-list-featured"
    case chat = "chat"
    case tabBar = "tab-bar"
    case chatList = "chat-list"
    case sell = "product-sell"
    case edit = "product-edit"
    case listingDetail = "product-detail"
    case listingDetailMoreInfo = "product-detail-more-info"
    case settings = "settings"
    case install = "install"
    case profile = "profile"
    case pushNotification = "push-notification"
    case email = "email"
    case onboarding = "onboarding"
    case external = "external"
    case notifications = "notifications"
    case openApp = "open-app"
    case incentivizePosting = "incentivize-posting"
    case userRatingList = "user-rating-list"
    case expressChat = "express-chat"
    case listingDelete = "product-delete"
    case listingSold = "product-sold"
    case inAppNotification = "in-app-notification"
    case filter = "filter"
    case realEstatePromo = "real-estate-promo"
    case mostSearched = "most-searched"
    case filterBubble = "filter-bubble"
    case postingIconInfo = "posting-icon-information"
    case postingLearnMore = "posting-learn-more-button"
    case sellStart = "product-sell-start"
}

public enum EventParameterPermissionType: String {
    case push = "push-notification"
    case location = "gps"
    case camera = "camera"
}

public enum EventParameterPermissionAlertType: String {
    case custom = "custom"
    case nativeLike = "native-alike"
    case fullScreen = "full-screen"
}

public enum EventParameterTab: String {
    case selling = "selling"
    case sold = "sold"
    case favorites = "favorites"
}

public enum EventParameterSearchCompleteSuccess: String {
    case success = "yes"
    case fail = "no"
}

public enum EventParameterReportReason: String {
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

public enum ListingVisitUserAction: String {
    case tap = "tap"
    case swipeLeft = "swipe-left"
    case swipeRight = "swipe-right"
    case none = "N/A"
}

public enum EventParameterRatingSource: String {
    case chat = "chat"
    case listingSellComplete = "product-sell-complete"
    case markedSold = "marked-sold"
    case favorite = "favorite"
}

public enum EventParameterUserDidRateReason: String {
    case happy = "happy"
    case sad = "sad"
}

public enum EventParameterListingVisitSource: String {
    case listingList = "product-list"
    case moreInfoRelated = "more-info-related"
    case collection = "collection"
    case search = "search"
    case filter = "filter"
    case searchAndFilter = "search & filter"
    case category = "category"
    case profile = "profile"
    case favourite = "favourite"
    case nextFavourite = "next-favourite"
    case previousFavourite = "previous-favourite"
    case chat = "chat"
    case openApp = "open-app"
    case notifications = "notifications"
    case relatedListings = "related-items-list"
    case next = "next-related-items-list"
    case previous = "previous-related-items-list"
    case promoteBump = "promote-bump-up"
    case unknown = "N/A"
}

public enum EventParameterRelatedListingsVisitSource: String {
    case notFound = "product-not-found"
}


public enum EventParameterFeedPosition {
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

public enum EventParameterFeedSource: String {
    case home = "home"
    case search = "search"
    case filter = "filter"
    case searchAndFilter = "search&filter"
    case collection = "collection"
}

public enum EventParameterAccountNetwork: String {
    case facebook = "facebook"
    case google = "google"
    case email = "email"
    case passwordless = "passwordless"
}

public enum EventParameterBlockedAccountReason: String {
    case secondDevice = "second-device"
    case accountUnderReview = "account-under-review"
}

public enum EventParameterProfileType: String {
    case publicParameter = "public"
    case privateParameter = "private"
}

public enum EventParameterNotificationClickArea: String {
    case basicImage = "basic-image"
    case heroImage = "hero-image"
    case text = "text"
    case thumbnail1 = "thumbnail-1"
    case thumbnail2 = "thumbnail-2"
    case thumbnail3 = "thumbnail-3"
    case thumbnail4 = "thumbnail-4"
    case cta1 = "cta-1"
    case cta2 = "cta-2"
    case cta3 = "cta-3"
    case main = "main"
    case unknown = "N/A"
}

public enum EventParameterNotificationAction: String {
    case home = "product-list"
    case sell = "product-sell-start"
    case listing = "product-detail-visit"
    case user = "profile-visit"
    case conversations = "conversations"
    case conversation = "conversation"
    case message = "message"
    case search = "search"
    case resetPassword = "reset-password"
    case userRatings = "user-ratings"
    case userRating = "user-rating"
    case passiveBuyers = "passive-buyers"
    case unknown = "N/A"
}

public enum EventParameterRelatedShownReason: String {
    case listingSold = "product-sold"
    case listingDeleted = "product-deleted"
    case userDeleted = "user-deleted"
    case unanswered48h = "unanswered-48h"
    case forbidden = "forbidden"
}

public enum EventParameterExpressChatTrigger: String {
    case automatic = "automatic"
    case manual = "manual"
}

public enum EventParameterBumpUpPrice {
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

public enum EventParameterBumpUpType: String {
    case free = "free"
    case paid = "paid"
    case retry = "retry"
}

public enum EventParameterTransactionStatus: String {
    case purchasingPurchased = "purchasing-purchased"
    case purchasingDeferred = "purchasing-deferred"
    case purchasingRestored = "purchasing-restored"
    case purchasingFailed = "purchasing-failed"
    case purchasingUnknown = "purchasing-unknown"

    case restoringPurchased = "restoring-purchased"
    case restoringDeferred = "restoring-deferred"
    case restoringRestored = "restoring-restored"
    case restoringFailed = "restoring-failed"
    case restoringUnknown = "restoring-unknown"
}

public enum EventParameterBumpUpNotAllowedReason: String {
    case notAllowedInternal = "internal"
}

public enum EventParameterEmptyReason: String {
    case noInternetConection = "no-internet-connection"
    case serverError         = "server-error"
    case emptyResults        = "empty-results"
    case verification        = "verification"
    case userNotVerified     = "user-not-verified"
    case notFound            = "not-found"
    case unauthorized        = "unauthorized"
    case forbidden           = "forbidden"
    case tooManyRequests     = "too-many-requests"
    case chatServerError     = "chat-server-error"
    case internalError       = "internal-error"
    case wsInternalError     = "ws-internal-error"
    case chatUserBlocked     = "chat-user-blocked"
    case notAuthenticated    = "not-authenticated"
    case differentCountry    = "different-country"
}

public enum EventParameterQuickAnswerType: String {
    case interested = "interested"
    case notInterested = "not-interested"
    case meetUp = "meet-up"
    case stillAvailable = "still-available"
    case isNegotiable = "is-negotiable"
    case likeToBuy = "like-to-buy"
    case listingCondition = "condition"
    case listingStillForSale = "still-for-sale"
    case listingSold = "sold"
    case whatsOffer = "whats-offer"
    case negotiableYes = "negotiable-yes"
    case negotiableNo = "negotiable-no"
    case freeStillHave = "free-still-have"
    case freeYours = "free-yours"
    case freeAvailable = "free-available"
    case freeNotAvailable = "free-not-available"
}

public enum EventParameterNotAvailableReason: String {
    
    case internalError       = "internal-error"
    case notFound            = "not-found"
    case unauthorized        = "unauthorized"
    case forbidden           = "forbidden"
    case tooManyRequests     = "too-many-requests"
    case userNotVerified     = "user-not-verified"
    case serverError         = "server-error"
    case network             = "network"
    
}

public enum EventParameterBlockButtonPosition: String {
    case threeDots          = "three-dots"
    case safetyPopup        = "safety-popup"
    case others             = "N/A"
}

public enum EventParamenterLocationTypePage: String {
    case filter     = "filter"
    case profile    = "profile"
    case feedBubble = "feed-bubble"
    case automatic  = "automatic"
}

public enum EventParameterAdType: String {
    case dfp = "dfp"
}

public enum EventParameterAdQueryType: String {
    case title = "title"
    case cloudsight = "cloudsight"
    case category = "category"
    case hardcoded = "hardcoded"
}

public enum EventParameterAdVisibility: String {
    case full = "full"
    case partial = "partial"
    case notVisible = "not-visible"

    init(bannerTopPosition: CGFloat, bannerBottomPosition: CGFloat, screenHeight: CGFloat) {
        if bannerBottomPosition <= screenHeight {
            self = .full
        } else if bannerTopPosition >= screenHeight {
            self = .notVisible
        } else {
            self = .partial
        }
    }
}

public enum EventParameterAdSenseRequestErrorReason: String {
    case invalidRequest = "invalid-request"
    case noAdsToShow = "no-fill"
    case networkError = "network"
    case internalError = "internal"
}

public enum EventParameterOptionSummary: String {
    case price = "price"
    case propertyType = "property-type"
    case offerType = "deal-type"
    case bedrooms = "bedroom-number"
    case rooms = "rooms-number"
    case sizeSquareMeters = "size"
    case bathrooms = "bathroom-number"
    case location = "location"
    case make = "make"
    case model = "model"
    case year = "year"
}

public enum EventParameterMostSearched: String {
    case notApply                   = "N/A"
    case tabBarCamera               = "tabbar-camera"
    case trendingExpandableButton   = "trending-salchicha"
    case postingTags                = "posting-tags"
    case feedBubble                 = "feed-bubble"
    case feedCard                   = "feed-card"
    case userProfile                = "user-profile"
    
    static var allValues: [EventParameterMostSearched] {
        return [.notApply, .tabBarCamera, .trendingExpandableButton, .postingTags, .feedBubble, .feedCard, .userProfile]
    }
}

public enum EventParameterTutorialType: String {
    case realEstate = "real-estate"
}

struct EventParameters {
    var params: [EventParameterName : Any] = [:]
    
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
    
    internal mutating func addLoginParams(_ source: EventParameterLoginSourceValue, rememberedAccount: Bool? = nil) {
        params[.loginSource] = source.rawValue
        params[.loginRememberedAccount] = rememberedAccount
    }
    
    internal mutating func addRepositoryErrorParams(_ repositoryError: EventParameterProductReportError) {
        params[.errorDescription] = repositoryError.description
    }
    
    internal mutating func addListingParams(_ listing: Listing) {
        params[.listingId] = listing.objectId
        params[.listingLatitude] = listing.location.latitude
        params[.listingLongitude] = listing.location.longitude
        params[.listingPrice] = listing.price.value
        params[.listingCurrency] = listing.currency.code
        params[.categoryId] = listing.category.rawValue
        params[.listingType] = listing.user.isDummy ?
            EventParameterProductItemType.dummy.rawValue : EventParameterProductItemType.real.rawValue
        params[.userToId] = listing.user.objectId
        params[.listingStatus] = listing.status.string
    }

    internal mutating func addChatListingParams(_ listing: ChatListing) {
        params[.listingId] = listing.objectId
        params[.listingPrice] = listing.price.value
        params[.listingCurrency] = listing.currency.code
        params[.listingType] = EventParameterProductItemType.real.rawValue
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
