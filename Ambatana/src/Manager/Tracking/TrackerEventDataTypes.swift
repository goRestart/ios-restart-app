import LGComponents
import LGCoreKit
import GoogleMobileAds

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
    case loginEmailStart                    = "login-email-start"
    case loginEmailSubmit                   = "login-email-submit"

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

    case productDetailPlayVideo             = "product-detail-play-video"
    
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
    case listingSellCategorySelect          = "product-sell-type-select"
    case listingSellPermissionsGrant        = "product-sell-permissions-grant"
    case listingSellMediaSource             = "product-sell-media-source"
    case listingSellMediaCapture            = "product-sell-media-capture"
    case listingSellMediaChange             = "product-sell-media-change"
    case listingSellMediaPublish            = "product-sell-media-publish"
    
    case listingEditStart                   = "product-edit-start"
    case listingEditFormValidationFailed    = "product-edit-form-validation-failed"
    case listingEditSharedFB                = "product-edit-shared-fb"
    case listingEditComplete                = "product-edit-complete"
    case listingEditError                   = "product-edit-error"
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
    case undoMessageSent                    = "undo-sent-message"
    case chatUpdateAppWarningShow           = "chat-update-app-warning-show"
    case chatLetgoServiceQuestionReceived   = "chat-letgo-service-question-received"
    case chatLetgoServiceCTAReceived        = "chat-letgo-service-call-to-action-received"

    case profileVisit                       = "profile-visit"
    case profileEditStart                   = "profile-edit-start"
    case profileEditEditName                = "profile-edit-edit-name"
    case profileEditEditLocationStart       = "profile-edit-edit-location-start"
    case profileEditEditPicture             = "profile-edit-edit-picture"
    case profileOpenUserPicture             = "profile-photo-tapped"
    case profileReport                      = "profile-report"
    case profileBlock                       = "profile-block"
    case profileUnblock                     = "profile-unblock"
    case profileShareStart                  = "profile-share-start"
    case profileShareComplete               = "profile-share-complete"
    case profileEditEmailStart              = "profile-edit-email-start"
    case profileEditEmailComplete           = "profile-edit-email-complete"
    case profileEditBioComplete             = "profile-edit-bio"

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

    case verifyAccountStart                 = "verify-account-start"
    case verifyAccountSelectNetwork         = "verify-account-select-network"
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
    case adShown                            = "ad-shown"
    case adError                            = "ad-error"
    case featuredMoreInfo                   = "featured-more-info"
    case openOptionOnSummary                = "posting-summary-open"

    case phoneNumberRequest                 = "phone-number-request"
    case phoneNumberSent                    = "phone-number-sent"
    case phoneNumberNotNow                  = "phone-number-not-now"
    case phoneNumberEditStart               = "profile-edit-edit-sms-start"
    case phoneNumberEditComplete            = "profile-edit-edit-sms-complete"
    
    case tutorialDialogStart                = "onboarding-dialog-start"
    case tutorialDialogComplete             = "onboarding-dialog-complete"
    case tutorialDialogAbandon              = "onboarding-dialog-abandon"

    case predictedPosting                   = "predicted-posting"

    case assistantMeetingStart              = "assistant-meeting-start"

    case searchAlertSwitchChanged           = "search-alert"
    
    case productListMapShow                 = "product-list-map-show"
    case productDetailPreview               = "product-detail-preview"

    case screenshot                         = "os-screenshot"

    case sessionOneMinuteFirstWeek          = "session-one-minute-first-week"
    
    case notificationsEditStart             = "notifications-edit-start"
    case pushNotificationsEditStart         = "push-notifications-edit-start"
    case emailNotificationsEditStart        = "email-notifications-edit-start"

    case chatTabOpen                        = "chat-tab-open"
    case chatCallToActionTapped             = "chat-call-to-action-tapped"

    case openCommunity                      = "open-community"

    case showNewItemsBadge                  = "show-new-items-badge"
    case duplicatedItemsInFeed              = "duplicated-items-hidden"

    case verificationModalShown             = "verification-modal-shown"

    case p2pPaymentsBuyerOfferStart         = "p2p-buyer-offer-start"
    case p2pPaymentsBuyerOfferOnboardStart  = "p2p-buyer-offer-onboard-start"
    case p2pPaymentsBuyerOfferAbandon       = "p2p-buyer-offer-abandon"
    case p2pPaymentsBuyerOfferReview        = "p2p-buyer-offer-review"
    case p2pPaymentsBuyerOfferEditStart     = "p2p-buyer-offer-edit-start"
    case p2pPaymentsBuyerOfferEditComplete  = "p2p-buyer-offer-edit-complete"
    case p2pPaymentsBuyerOfferEditCancel    = "p2p-buyer-offer-edit-cancel"
    case p2pPaymentsBuyerPaymentProcess     = "p2p-buyer-payment-confirmation"
    case p2pPaymentsBuyerApplePayStart      = "p2p-buyer-applepay-start"
    case p2pPaymentsBuyerOfferWithdraw      = "p2p-buyer-offer-withdraw"
    case p2pPaymentsBuyerCodeView           = "p2p-buyer-code-view"
    case p2pPaymentsSellerOfferDetail       = "p2p-seller-offer-detail"
    case p2pPaymentsSellerOfferDecide       = "p2p-seller-offer-decide"
    case p2pPaymentsSellerPayoutStart       = "p2p-seller-payout-start"
    case p2pPaymentsSellerPayout            = "p2p-seller-payout"
    case p2pPaymentsSellerPayoutError       = "p2p-seller-payout-error"
    case p2pPaymentsSellerPayoutSignup      = "p2p-seller-payout-signup"
    case p2pPaymentsSellerPayoutSignupError = "p2p-seller-payout-signup-error"
    
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
    case searchRelatedItems   = "search-related-items"
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
    case videoLength          = "video-length"
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
    case previousSource       = "previous-source"
    case itemPosition         = "item-position"
    case expressConversations = "express-conversations"
    case collectionTitle      = "collection-title"
    case listingVisitSource   = "visit-source"
    case numberOfUsers        = "number-of-users"
    case priceFrom            = "price-from"
    case priceTo              = "price-to"
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
    case purchaseType         = "purchase-type"
    case paymentEnabled       = "payment-enabled"
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
    case blockButtonPosition  = "block-button-position"
    case postingType          = "posting-type"
    case carSellerType        = "seller-type"
    case make                 = "product-make"
    case model                = "product-model"
    case year                 = "product-year"
    case yearStart            = "product-year-start"
    case yearEnd              = "product-year-end"
    case mileage              = "mileage"
    case mileageFrom          = "mileage-from"
    case mileageTo            = "mileage-to"
    case bodyType             = "body-type"
    case transmission         = "transmission"
    case fuelType             = "fuel-type"
    case drivetrain           = "drivetrain"
    case seats                = "seats"
    case seatsFrom            = "seats-from"
    case seatsTo              = "seats-to"
    case serviceType          = "service-type"
    case serviceSubtype       = "service-subtype"
    case serviceListingType   = "service-listing-type"
    case paymentFrequency     = "payment-frequency"
    case verticalKeyword            = "vertical-keyword"
    case verticalMatchingFields     = "vertical-matching-fields"
    case verticalFields             = "vertical-fields"
    case bubblePosition       = "bubble-position"
    case bubbleName           = "bubble-name"
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
    case abandonStep          = "abandon-step"
    case searchAlertSource    = "alert-source"
    case sellerReputationBadge = "seller-reputation-badge"
    case isVideo              = "is-video"
    case messageGoal          = "message-goal"
    case productCounter       = "product-counter"
    case pictureUploaded      = "picture-uploaded"
    case loggedUser           = "logged-user"
    case mediaType            = "media-type"
    case originalFileSize     = "original-file-size"    
    case cameraSide           = "camera-side"
    case hasError             = "has-error"
    case fileCount            = "file-count"
    case conversationId       = "conversation-id"
    case buyerId              = "buyer-id"
    case sellerId             = "seller-id"
    case offerId              = "offer-id"
    case offerPrice           = "offer-price"
    case offerCurrency        = "offer-currency"
    case offerFee             = "offer-seller-fee"
    case offerSellerChoice    = "choice"
    case step                 = "step"
    
    case marketingNotificationsEnabled  = "marketing-notifications-enabled"

    case chatTabName          = "tab-name"

    case messageActionKey     = "action-key"
    case isLetgoAssistant     = "is-letgo-assistant"

    
    // Machine Learning
    case mlPredictiveFlow = "predictive-flow"
    case mlPredictionActive = "prediction-active"
    case mlPredictedTitle = "predicted-title"
    case mlPredictedPrice = "predicted-price"
    case mlPredictedCategory = "predicted-category"
    case mlListingCategory = "product-category"
    
    case typeTutorialDialog   = "type-onboarding-dialog"
    case pageNumber           = "page-number"

    case meetingMessageType  = "assistant-meeting-type"
    case meetingDate         = "assistant-meeting-date"
    case meetingLocation     = "assistant-meeting-location"
    case suggestedLocation   = "assistant-location-suggested"

    case boost                = "boost"
    
    case returnedResults    = "returned-results"
    case featuredResults    = "featured-results"
    case action             = "action"

    // Community
    case showingBanner      = "showing-banner"
    case bannerType         = "banner-type"
    
    // Sectioned Feed
    case sectionShown = "sections-shown" // lists the sections shown in the sectioned feed
    case sectionIdentifier = "section-identifier" // section identifier
    case itemPositionInSection = "item-position-in-section" // Position of the section in the feed
    case sectionPosition = "section-number"
    case numberOfItemsInSection = "number-of-items-section"

    // Engagement badging
    case recentItems        = "recent-items"
}

enum EventParameterBoolean: String {
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
    case directChat = "direct-chat"
    case directQuickAnswer = "direct-quick-answer"
    case chatProUser = "chat-pro-user"
    case community = "community"
    case feed = "feed"
}

enum EventParameterProductItemType: String {
    case real = "1"
    case dummy = "0"
    case professional = "2"
    case privateOrProfessional = "3"
}

enum EventParameterButtonNameType: String {
    case close = "close"
    case skip = "skip"
    case done = "done"
    case summary = "summary"
    case sellYourStuff = "sell-your-stuff"
    case startMakingCash = "start-making-cash"
    case realEstatePromo = "real-estate-promo"
    case carPromo = "car-promo"
    case servicesPromo = "services-promo"
    case cancelSelectType = "cancel-select-type"
    case tapOutside = "tap-outside"
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
    case realEstatePromo = "real-estate-promo"
    case carPromo = "car-promo"
    case servicesPromo = "services-promo"
    case referralNotAvailable = "referral-not-available"
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

enum EventParameterMediaSource: String {
    case camera = "camera"
    case gallery = "gallery"
    case videoCamera = "video-camera"
}

enum EventParameterCameraSide: String {
    case front = "front"
    case back = "back"
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

enum EventParameterPostingType: String {
    case car = "car"
    case stuff = "stuff"
    case realEstate = "real-estate"
    case service = "service"
    case none = "N/A"
    
    init(category: PostCategory) {
        switch category {
        case .otherItems, .motorsAndAccessories:
            self = .stuff
        case .car:
            self = .car
        case .realEstate:
            self = .realEstate
        case .services:
            self = .service
        }
    }
}

enum EventParameterPostingAbandonStep: String {
    case cameraPermissions = "camera-permissions"
    case retry = "retry"
    case summaryOnboarding = "summary-onboarding"
    case welcomeOnboarding = "welcome-onboarding"
    case mostSearchItems = "most-search-items"
    case productSellTypeSelect = "product-sell-type-select"

    case capturePhoto = "capture-photo"
    case imagePreview = "image-preview"
    case uploadingImage = "uploading-image"
    case uploadingVideo = "uploading-video"
    case addingDetails = "adding-details"
    case errorUpload = "error-upload"
    case none = "N/A"
    
    static var allValues: [EventParameterPostingAbandonStep] {
        return [.cameraPermissions, .retry, .summaryOnboarding, .welcomeOnboarding, .mostSearchItems,
                .productSellTypeSelect]
    }
}

enum EventParameterMake {
    case make(name: String?)
    case none

    var name: String {
        switch self {
        case .make(let name):
            guard let name = name, !name.isEmpty else { return SharedConstants.parameterNotApply }
            return name
        case .none:
            return SharedConstants.parameterNotApply
        }
    }
}

enum EventParameterModel {
    case model(name: String?)
    case none

    var name: String {
        switch self {
        case .model(let name):
            guard let name = name, !name.isEmpty else { return SharedConstants.parameterNotApply }
            return name
        case .none:
            return SharedConstants.parameterNotApply
        }
    }
}

enum EventParameterYear {
    case year(year: Int?)
    case none

    var year: String {
        switch self {
        case .year(let year):
            guard let year = year, year != 0 else { return SharedConstants.parameterNotApply }
            return String(year)
        case .none:
            return SharedConstants.parameterNotApply
        }
    }
}



enum EventParameterStringRealEstate {
    
    case realEstateParam(name: String?)
    case none
    case notApply
    
    var name: String {
        switch self {
        case .realEstateParam(let name):
            return name ?? SharedConstants.parameterSkipValue
        case .none:
            return SharedConstants.parameterSkipValue
        case .notApply:
            return SharedConstants.parameterNotApply
        }
    }
}

enum EventParameterBathroomsRealEstate {
    case bathrooms(value: Float?)
    case notApply
    
    var name: String {
        switch self {
        case .bathrooms(let value):
            guard let value = value else { return SharedConstants.parameterSkipValue }
            return String(value)
        case .notApply:
            return SharedConstants.parameterNotApply
        }
    }
}

enum EventParameterBedroomsRealEstate {
    case bedrooms(value: Int?)
    case notApply
    
    var name: String {
        switch self {
        case .bedrooms(let value):
            guard let value = value else { return SharedConstants.parameterSkipValue }
            return String(value)
        case .notApply:
            return SharedConstants.parameterNotApply
        }
    }
}

enum EventParameterRoomsRealEstate {
    case rooms(bedrooms: Int?, livingRooms: Int?)
    case notApply
    
    var name: String {
        switch self {
        case .rooms(let bedrooms, let livingRooms):
            guard let bedrooms = bedrooms, let livingRooms = livingRooms else { return SharedConstants.parameterSkipValue }
            return NumberOfRooms(numberOfBedrooms: bedrooms, numberOfLivingRooms: livingRooms).trackingString
        case .notApply:
            return SharedConstants.parameterNotApply
        }
    }
}

enum EventParameterSizeRealEstate {
    case size(value: Int?)
    case notApply
    
    var name: String {
        switch self {
        case .size(let value):
            guard let value = value else { return SharedConstants.parameterSkipValue }
            return String(value)
        case .notApply:
            return SharedConstants.parameterNotApply
        }
    }
}


enum EventParameterMessageType: String {
    case text       = "text"
    case offer      = "offer"
    case sticker    = "sticker"
    case favorite   = "favorite"
    case quickAnswer = "quick-answer"
    case expressChat = "express-chat"
    case periscopeDirect = "periscope-direct"
    case interested = "interested"
    case phone      = "phone"
    case meeting = "assistant-meeting"
}

enum EventParameterLoginError {
    
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

enum EventParameterPostListingError {
    case network
    case internalError(description: String?)
    case forbidden(cause: ForbiddenCause)
    case serverError(code: Int?)

    var description: String {
        switch self {
        case .network:
            return "product-sell-network"
        case .internalError(let description):
            return "product-sell-internal" + "-\(String(describing: description))"
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

enum EventParameterProductReportError {
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

enum EventParameterChatError {
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

enum EventParameterChatTabName: String {
    case all
    case selling
    case buying
    case blocked
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
    case make = "make"
    case model = "model"
    case year = "year"
    case mileage              = "mileage"
    case bodyType             = "body-type"
    case transmission         = "transmission"
    case fuelType             = "fuel-type"
    case drivetrain           = "drivetrain"
    case seats                = "seats"
    case serviceType          = "service-type"
    case serviceSubtype       = "service-subtype"
    case serviceListingType   = "service-listing-type"
    case paymentFrequency     = "payment-frequency"
}

enum EventParameterTypePage: String {
    case listingList = "product-list"
    case listingListBanner = "product-list-banner"
    case listingListFeatured = "product-list-featured"
    case chat = "chat"
    case tabBar = "tab-bar"
    case chatList = "chat-list"
    case sell = "product-sell"
    case edit = "product-edit"
    case sellEdit = "product-sell-edit"
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
    case carPromo = "car-promo"
    case servicesPromo = "services-promo"
    case filterBubble = "filter-bubble"
    case postingIconInfo = "posting-icon-information"
    case postingLearnMore = "posting-learn-more-button"
    case sellStart = "product-sell-start"
    case userVerifications = "user-verifications"
    case smsVerification = "sms-verification"
    case nextItem = "next-item"
    case feed = "feed"
    case notificationCenter = "notification-center"
    case rewardCenter = "reward-center"
    case referralNotAvailable = "referral-not-available"
}

enum EventParameterPermissionType: String {
    case push = "push-notification"
    case location = "gps"
    case camera = "camera"
    case gallery = "gallery"
}

enum EventParameterPermissionAlertType: String {
    case custom = "custom"
    case nativeLike = "native-alike"
    case fullScreen = "full-screen"
}

enum EventParameterTab: String {
    case selling = "selling"
    case sold = "sold"
    case favorites = "favorites"
    case reviews = "reviews"
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

enum ListingVisitUserAction: String {
    case tap = "tap"
    case swipeLeft = "swipe-left"
    case swipeRight = "swipe-right"
    case none = "N/A"
}

enum EventParameterRatingSource: String {
    case chat = "chat"
    case listingSellComplete = "product-sell-complete"
    case markedSold = "marked-sold"
    case favorite = "favorite"
}

enum EventParameterUserDidRateReason: String {
    case happy = "happy"
    case sad = "sad"
}

enum EventParameterSearchAlertSource: String {
    case search = "search"
    case settings = "settings"
}

enum EventParameterMapUserAction: String {
    case showMap = "show-map"
    case filterComplete = "filter-complete"
    case redo = "redo"
}


enum EventParameterListingVisitSource {
    // https://ambatana.atlassian.net/wiki/spaces/MOB/pages/1114200/Parameters
    // (FWI SEO parameters are for web, we don't need to add them here)
    var rawValue: String {
        switch self {
        case .next(let source): return "next-\(source.rawValue)"
        case .previous(let source): return "previous-\(source.rawValue)"

        case .listingList: return "product-list" // from the main feed without filters
        case .collection: return "collection" // from the main feed, touching a collection cell
        case .search: return "search" // from the main feed, with text filter
        case .filter: return "filter" // from the main feed, with top filters
        case .searchAndFilter: return "search-and-filter" // from the main feed, with both
        case .category: return "category" // from the main feed, with bubble filters
        case .profile: return "profile" // from the user profile
        case .relatedChat: return "related-chat" // from the chat, related products
        case .notificationCenter: return "notification-center" // from notification center
        case .external: return "external" // from push notification
        case .relatedListings: return "related-items-list" // related items when you don't find a push listing
        case .chat: return "chat" // from the chat
        case .promoteBump: return "promote-bump-up" // from the promote bump up screen
        case .favourite: return "favourite" // from your private profile favourite's list
        case .map: return "map"
        case .unknown: return "N/A"
        case .section: return "section" // when a user visits an item in the sections
        case .sectionList: return "section-list" // when a user visits an item through the section list
        case .relatedItemList: return "related-item-list"
        }
    }

    private var isNext: Bool {
        guard case .next(_) = self else { return false }
        return true
    }

    private var isPrevious: Bool {
        guard case .previous(_) = self else { return false }
        return true
    }

    var next: EventParameterListingVisitSource {
        guard !isNext else { return self }
        guard case let .previous(source) = self else { return .next(self) }
        return .next(source)
    }

    var previous: EventParameterListingVisitSource {
        guard !isPrevious else { return self }
        guard case let .next(source) = self else { return .previous(self) }
        return .previous(source)
    }

    static func ==(lhs: EventParameterListingVisitSource, rhs: EventParameterListingVisitSource) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    indirect case next(EventParameterListingVisitSource)
    indirect case previous(EventParameterListingVisitSource)

    case listingList
    case collection
    case search
    case filter
    case searchAndFilter
    case category
    case profile
    case relatedChat
    case notificationCenter
    case external
    case relatedListings
    case chat
    case promoteBump
    case favourite
    case map
    case unknown
    case section
    case sectionList
    case relatedItemList
}

enum EventParameterRelatedListingsVisitSource: String {
    case notFound = "product-not-found"
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

enum EventParameterSectionPosition {
    case position(index: UInt)
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
    case section = "section"
}

enum EventParameterAccountNetwork: String {
    case facebook = "facebook"
    case google = "google"
    case email = "email"
    case sms = "sms"
    case id = "id"
    case profilePhoto = "profilePhoto"
    case passwordless = "passwordless"
}

enum EventParameterBlockedAccountReason: String {
    case secondDevice = "second-device"
    case accountUnderReview = "account-under-review"
}

enum EventParameterProfileType: String {
    case publicParameter = "public"
    case privateParameter = "private"
}

enum EventParameterNotificationClickArea {
    case basicImage
    case heroImage
    case text
    case thumbnail1
    case thumbnail2
    case thumbnail3
    case thumbnail4
    case cta1
    case cta2
    case cta3
    case main
    case unknown
    case thumbnail(index: Int)
    
    var name: String {
        switch self {
        case .basicImage:
            return "basic-image"
        case .heroImage:
            return "hero-image"
        case .text:
            return "text"
        case .thumbnail1:
            return "thumbnail-1"
        case .thumbnail2:
            return "thumbnail-2"
        case .thumbnail3:
            return "thumbnail-3"
        case .thumbnail4:
            return "thumbnail-4"
        case .cta1:
            return "cta-1"
        case .cta2:
            return "cta-2"
        case .cta3:
            return "cta-3"
        case .main:
            return "main"
        case .unknown:
            return "N/A"
        case .thumbnail(let index):
            return String(format: "thumbnail-%i", index)
        }
    }
}

enum EventParameterNotificationAction: String {
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

enum EventParameterRelatedShownReason: String {
    case listingSold = "product-sold"
    case listingDeleted = "product-deleted"
    case userDeleted = "user-deleted"
    case unanswered48h = "unanswered-48h"
    case forbidden = "forbidden"

    init(chatInfoStatus: ChatInfoViewStatus) {
        switch chatInfoStatus {
        case .forbidden:
            self = .forbidden
        case .blocked, .blockedBy, .inactiveConversation:
            self = .unanswered48h
        case .listingDeleted:
            self = .listingDeleted
        case .listingSold, .listingGivenAway:
            self = .listingSold
        case .userPendingDelete, .userDeleted:
            self = .userDeleted
        case .available:
            self = .unanswered48h
        }
    }
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

enum EventParameterBumpUpType: String {
    case free = "free"
    case paid = "paid"
    case retry = "retry"
    case loading = "loading"

    init(bumpType: BumpUpType) {
        switch bumpType {
        case .free:
            self = .free
        case .priced, .hidden, .boost, .ongoingBump:
            self = .paid
        case .restore:
            self = .retry
        case .loading:
            self = .loading
        }
    }
}

enum EventParameterPurchaseType: String {
    case bump = "bump"
    case boost = "boost"
    case threeDays = "3x"
    case sevenDays = "7x"

    init(type: FeaturePurchaseType) {
        switch type {
        case .bump:
            self = .bump
        case .boost:
            self = .boost
        case .threeDays:
            self = .threeDays
        case .sevenDays:
            self = .sevenDays
        }
    }
}

enum EventParameterTransactionStatus: String {
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

enum EventParameterBumpUpNotAllowedReason: String {
    case notAllowedInternal = "internal"
}

enum EventParameterEmptyReason: String {
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

enum EventParameterQuickAnswerType: String {
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

enum EventParameterNotAvailableReason: String {
    
    case internalError       = "internal-error"
    case notFound            = "not-found"
    case unauthorized        = "unauthorized"
    case forbidden           = "forbidden"
    case tooManyRequests     = "too-many-requests"
    case userNotVerified     = "user-not-verified"
    case serverError         = "server-error"
    case network             = "network"
    
}

enum EventParameterBlockButtonPosition: String {
    case threeDots          = "three-dots"
    case safetyPopup        = "safety-popup"
    case others             = "N/A"
}

enum EventParamenterLocationTypePage: String {
    case filter     = "filter"
    case profile    = "profile"
    case feedBubble = "feed-bubble"
    case automatic  = "automatic"
}

enum EventParameterAdType {
    case dfp
    case moPub
    case adx
    case interstitial
    case variableSize(size: CGSize)

    var stringValue: String {
        switch self {
        case .variableSize(let size):
            return "\(Int(size.width))x\(Int(size.height))"
        case .dfp:
            return "dfp"
        case .moPub:
            return "moPub"
        case .adx:
            return "adx"
        case .interstitial:
            return "interstitial"
        }
    }
}

enum EventParameterAdQueryType: String {
    case title = "title"
    case cloudsight = "cloudsight"
    case category = "category"
    case hardcoded = "hardcoded"
}

enum EventParameterAdVisibility: String {
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

enum EventParameterAdSenseRequestErrorReason: String {
    case invalidRequest = "invalid-request"
    case noAdsToShow = "no-fill"
    case networkError = "network"
    case internalError = "internal"

    init(errorCode: GADErrorCode) {
        switch errorCode {
        case .invalidRequest:
            self = .invalidRequest
        case .noFill:
            self = .noAdsToShow
        case .networkError:
            self = .networkError
        default:
            self = .internalError
        }
    }
}

enum EventParameterAssistantMeetingType: String {
    case request = "assistant-meeting-complete"
    case accept = "assistant-meeting-accept"
    case decline = "assistant-meeting-decline"

    init(meetingMessageType: MeetingMessageType) {
        switch meetingMessageType {
        case .requested:
            self = .request
        case .accepted:
            self = .accept
        case .rejected:
            self = .decline
        }
    }
}

enum EventParameterOptionSummary: String {
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
    
    init(optionSelected: PostingSummaryOption) {
        switch optionSelected {
        case .price:
            self = .price
        case .propertyType:
            self = .propertyType
        case .offerType:
            self = .offerType
        case .bedrooms:
            self = .bedrooms
        case .rooms:
            self = .rooms
        case .sizeSquareMeters:
            self = .sizeSquareMeters
        case .bathrooms:
            self = .bathrooms
        case .location:
            self = .location
        case .make:
            self = .make
        case .model:
            self = .model
        case .year:
            self = .year
        }
    }
}

enum EventParameterTutorialType: String {
    case realEstate = "real-estate"
}

enum EventParameterUserBadge: String {
    case noBadge = ""
    case gold = "gold"
    case silver = "silver"

    init(userBadge: UserReputationBadge) {
        switch userBadge {
        case .noBadge: self = .noBadge
        case .gold: self = .gold
        case .silver: self = .silver
        }
    }
}

enum EventBannerType: String {
    case joinCommunity = "join-community"
}

enum EventParameterSectionName {
    case identifier(id: String)
    
    var value: String {
        switch self {
        case let .identifier(id): return id
        }
    }

}

struct EventParameters {
    var params: [EventParameterName : Any] = [:]
    var dynamicParams: [String : Any] = [:]
    
    // transforms the params to [String: Any]
    var stringKeyParams: [String: Any] {
        get {
            var res = [String: Any]()
            for (paramName, value) in params {
                res[paramName.rawValue] = value
            }
            for (paramName, value) in dynamicParams {
                res[paramName] = value
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
    
    internal subscript(dynamicParamName: String) -> Any? {
        get {
            return dynamicParams[dynamicParamName]
        }
        set(newValue) {
            dynamicParams[dynamicParamName] = newValue
        }
    }
}
