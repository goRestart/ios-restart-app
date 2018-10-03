import LGComponents

/**
 Defines the accessibility identifiers used for automated UI testing. The format is the following:
    case <screen><element-name>
 
 i.e:
    case SignUpLoginEmailButton
 */
enum AccessibilityId: Equatable, Accessible {
    // Tab Bar
    case tabBarFirstTab
    case tabBarSecondTab
    case tabBarThirdTab
    case tabBarFourthTab
    case tabBarFifthTab
    case tabBarFloatingSellButton

    // Main Listings List
    case mainListingsNavBarSearch
    case mainListingsFilterButton
    case mainListingsInviteButton
    case mainListingsListView
    case mainListingsTagsCollection
    case mainListingsInfoBubbleLabel
    case mainListingsSuggestionSearchesTable

    // SectionedFeed
    case feedNavBarSearch
    case feedFilterButton
    case feedInviteButton
    case feedCollectionView
    
    // Passive buyers
    case passiveBuyersTitle
    case passiveBuyersMessage
    case passiveBuyersContactButton
    case passiveBuyersTable
    case passiveBuyerCellName

    // Listing List View
    case listingListViewFirstLoadView
    case listingListViewFirstLoadActivityIndicator
    case listingListViewCollection
    case listingListViewErrorView
    case listingListErrorImageView
    case listingListErrorTitleLabel
    case listingListErrorBodyLabel
    case listingListErrorButton

    // Listing Cell
    case listingCell(listingId: String?)
    case listingCellThumbnailImageView
    case listingCellThumbnailGifImageView
    case listingCellStripeImageView
    case listingCellStripeLabel
    case listingCellStripeIcon
    case listingCellFeaturedPrice
    case listingCellFeaturedTitle
    case listingCellFeaturedChatButton

    // Collection & Banner Cells
    case collectionCell
    case collectionCellImageView
    case collectionCellTitle
    case collectionCellExploreButton

    case bannerCell
    case bannerCellImageView
    case bannerCellTitle

    // Advertisement Cell
    case advertisementCell
    case advertisementCellBanner
    
    // Filter Tags VC
    case filterTagsCollectionView
    case filterTagCell(tag: FilterTag)
    case filterTagCellTagIcon
    case filterTagCellTagLabel
    
    // CategoriesHeader Cells
    case categoriesHeaderCollectionView
    case categoryHeaderCell
    case categoryHeaderCellCategoryIcon
    case categoryHeaderCellCategoryTitle

    // SuggestionSearchCell
    case suggestionSearchCell
    case suggestionSearchCellTitle
    case suggestionSearchCellSubtitle

    // Filters
    case filtersCollectionView
    case filtersSaveFiltersButton
    case filtersCancelButton
    case filtersResetButton

    // Filters Cells
    case filterCategoryCell
    case filterCategoryCellIcon
    case filterCategoryCellTitleLabel

    case filterCarInfoMakeModelCell
    case filterCarInfoMakeModelCellTitleLabel
    case filterCarInfoMakeModelCellInfoLabel
    case filterCarInfoYearCell
    case filterCarInfoYearCellTitleLabel
    case filterCarInfoYearCellInfoLabel

    case filterSingleCheckCell
    case filterSingleCheckCellTickIcon
    case filterSingleCheckCellTitleLabel

    case filterDistanceCell
    case filterDistanceSlider
    case filterDistanceTip
    case filterDistanceLabel

    case filterHeaderCell
    case filterHeaderCellTitleLabel

    case filterDisclosureCell
    case filterDisclosureCellTitleLabel
    case filterDisclosureCellSubtitleLabel

    case filterTextFieldIntCell
    case filterTextFieldIntCellTitleLabel
    case filterTextFieldIntCellTextField

    // Listing Detail
    case listingDetailOnboarding

    // listing Carousel
    case listingCarouselCollectionView
    case listingCarouselButtonBottom
    case listingCarouselButtonTop
    case listingCarouselFavoriteButton
    case listingCarouselMoreInfoView
    case listingCarouselListingStatusLabel
    case listingCarouselDirectChatTable
    case listingCarouselFullScreenAvatarView
    case listingCarouselPageControl
    case listingCarouselUserView
    case listingCarouselChatTextView
    case listingCarouselChatButton
    case listingCarouselChatFooterLabel
    case listingCarouselInterestedButton
    case listingCarouselStatusView
    case listingCarouselPlayButton
    case listingCarouselVideoProgressView

    case listingCarouselNavBarCloseButton
    case listingCarouselNavBarEditButton
    case listingCarouselNavBarShareButton
    case listingCarouselNavBarActionsButton
    case listingCarouselNavBarFavoriteButton

    case listingCarouselMoreInfoScrollView
    case listingCarouselMoreInfoTitleLabel
    case listingCarouselMoreInfoPriceLabel
    case listingCarouselMoreInfoTransTitleLabel
    case listingCarouselMoreInfoStatsView
    case listingCarouselMoreInfoAddressLabel
    case listingCarouselMoreInfoDistanceLabel
    case listingCarouselMoreInfoMapView
    case listingCarouselMoreInfoSocialShareTitleLabel
    case listingCarouselMoreInfoSocialShareView
    case listingCarouselMoreInfoDescriptionLabel

    // listing stats view
    case listingStatsViewFavouriteStatsView
    case listingStatsViewFavouriteStatsLabel
    case listingStatsViewFavouriteViewCountView
    case listingStatsViewFavouriteViewCountLabel
    case listingStatsViewFavouriteTimePostedView
    case listingStatsViewFavouriteTimePostedLabel
    
    // listing Carousel Cell
    case listingCarouselCell
    case listingCarouselCellCollectionView
    case listingCarouselCellPlaceholderImage
    case listingCarouselImageCell
    case listingCarouselImageCellImageView
    case listingCarouselVideoCell
    case listingCarouselVideoCellVideoPreview

    // listing Carousel Post Delete screens
    case postDeleteAlertButton
    case postDeleteFullscreenButton
    case postDeleteFullscreenIncentiveView

    // Chat Text View
    case chatTextViewTextField
    case chatTextViewSendButton

    // User View
    case userViewNameLabel
    case userViewSubtitleLabel
    case userViewTextInfoContainer

    // Notifications
    case notificationsRefresh
    case notificationsTable
    case notificationsLoading
    case notificationsEmptyView
    case notificationsCellSecondaryImage
    case notificationsModularTextTitleLabel
    case notificationsModularTextBodyLabel
    case notificationsModularBasicImageView
    case notificationsModularHeroImageView
    case notificationsModularIconImageView
    case notificationsModularThumbnailCollectionView
    case notificationsModularThumbnailCollectionViewCell
    case notificationsModularThumbnailView
    case notificationsModularCTA1
    case notificationsModularCTA2
    case notificationsModularCTA3

    // Posting
    case postingCameraImagePreview
    case postingCameraSwitchCamButton
    case postingCameraUsePhotoButton
    case postingCameraInfoScreenButton
    case postingCameraFlashButton
    case postingCameraRetryPhotoButton
    case postingCameraFirstTimeAlert
    case postingCameraCloseButton
    case postingGalleryLoading
    case postingGalleryCollection
    case postingGalleryAlbumButton
    case postingGalleryUsePhotoButton
    case postingGalleryInfoScreenButton
    case postingGalleryImageContainer
    case postingGalleryCloseButton
    case postingCloseButton
    case postingGalleryButton
    case postingCameraButton
    case postingPhotoButton
    case postingVideoButton
    case postingInfoButton
    case postingLoading
    case postingRetryButton
    case postingDoneButton
    case postingCurrencyLabel
    case postingTitleField
    case postingPriceField
    case postingDescriptionField
    case postingBackButton
    case postingInfoCloseButton
    case postingInfoCollectionView
    case postingInfoShareButton
    case postingInfoLoading
    case postingInfoEditButton
    case postingInfoMainButton
    case postingInfoIncentiveContainer
    case postingCategorySelectionCarsButton
    case postingCategorySelectionMotorsAndAccessoriesButton
    case postingCategorySelectionOtherButton
    case postingCategorySelectionRealEstateButton
    case postingCategorySelectionServicesButton
    case postingCategoryDeatilNavigationBackButton
    case postingCategoryDeatilNavigationMakeButton
    case postingCategoryDeatilNavigationModelButton
    case postingCategoryDeatilNavigationYearButton
    case postingCategoryDeatilNavigationOkButton
    case postingCategoryDeatilDoneButton
    case postingCategoryDeatilRowButton
    case postingCategoryDeatilTextField
    case postingCategoryDeatilSearchBar
    case postingCategoryDeatilTableView
    case postingAddDetailTableView
    case postingAddDetailSearchBar
    case postingDetailMaxServices
    case postingDetailShareOnFacebookTitleLabel
    case postingDetailShareOnFacebookFooterLabel
    case postingDetailShareOnFacebookCheckbox
    case postingCameraTooltipLabel

    // Editlisting
    case editListingCloseButton
    case editListingScroll
    case editListingTitleField
    case editListingAutoGenTitleButton
    case editListingImageCollection
    case editListingCurrencyLabel
    case editListingPriceField
    case editListingDescriptionField
    case editListingLocationButton
    case editListingCategoryButton
    case editListingCarsMakeButton
    case editListingCarsModelButton
    case editListingCarsYearButton
    case editListingSendButton
    case editListingShareFBSwitch
    case editListingLoadingView
    case editListingPostFreeSwitch
    case editListingOptionSelector
    case editListingOptionSelectorTitleLabel
    case editListingOptionSelectorCurrentValueLabel
    case editListingFeatureIcon
    case editListingFeatureLabel
    case editListingFeatureSwitch
    case editListingServicesTypeButton
    case editListingServicesSubtypeButton
    case editListingServicesListingTypeButton
    case editListingPaymentFrequencyButton
    
    // ReportUser
    case reportUserCollection
    case reportUserCommentField
    case reportUserSendButton

    // RateUser
    case rateUserUserNameLabel
    case rateUserStarButton1
    case rateUserStarButton2
    case rateUserStarButton3
    case rateUserStarButton4
    case rateUserStarButton5
    case rateUserDescriptionField
    case rateUserLoading
    case rateUserSendButton

    // RatingList
    case ratingListTable
    case ratingListLoading
    case ratingListCellUserName
    case ratingListCellReport
    case ratingListCellReview

    // AppRating
    case appRatingStarButton1
    case appRatingStarButton2
    case appRatingStarButton3
    case appRatingStarButton4
    case appRatingStarButton5
    case appRatingBgButton
    case appRatingDismissButton

    // SafetyTips
    case safetyTipsOkButton

    // EmptyView
    case emptyViewPrimaryButton
    case emptyViewSecondaryButton

    // SocialShare
    case socialShareFacebook
    case socialShareFBMessenger
    case socialShareEmail
    case socialShareWhatsapp
    case socialShareTwitter
    case socialShareTelegram
    case socialShareCopyLink
    case socialShareSMS
    case socialShareMore

    // MainSignUp
    case mainSignUpFacebookButton
    case mainSignUpGoogleButton
    case mainSignUpSignupButton
    case mainSignupLogInButton
    case mainSignupCloseButton
    case mainSignupHelpButton
    case mainSignupContinueWithEmailButton

    // SignUpLogin
    case signUpLoginFacebookButton
    case signUpLoginGoogleButton
    case signUpLoginEmailButton
    case signUpLoginEmailTextField
    case signUpLoginPasswordButton
    case signUpLoginPasswordTextField
    case signUpLoginUserNameButton
    case signUpLoginUserNameTextField
    case signUpLoginShowPasswordButton
    case signUpLoginForgotPasswordButton
    case signUpLoginSegmentedControl
    case signUpLoginHelpButton
    case signUpLoginCloseButton
    case signUpLoginSendButton

    // Recaptcha
    case recaptchaCloseButton
    case recaptchaLoading
    case recaptchaWebView

    // Passwordless
    case passwordlessEmailTitleLabel
    case passwordlessEmailDescriptionLabel
    case passwordlessEmailTextField
    case passwordlessEmailContinueButton
    case passwordlessUsernameTitleLabel
    case passwordlessUsernameUsernameTextField
    case passwordlessDoneButton
    case passwordlessEmailSentTitleLabel
    case passwordlessEmailSentSubtitleLabel
    case passwordlessEmailSentImageView

    // ChatConversationsList
    case chatConversationsListOptionsNavBarButton
    case chatConversationsListFiltersNavBarButton
    
    // ChatGrouped
    case chatGroupedViewRightNavBarButton

    // ChatList
    case chatListViewTabAll
    case chatListViewTabSelling
    case chatListViewTabBuying
    case chatListViewTabBlockedUsers

    case chatListViewFooterButton
    case chatListViewTabAllTableView
    case chatListViewTabSellingTableView
    case chatListViewTabBuyingTableView
    case chatListViewTabBlockedUsersTableView

    // ConversationCell
    case conversationCellContainer(conversationId: String?)
    case conversationCellUserLabel(interlocutorId: String?)
    case conversationCellListingLabel(listingId: String?)
    case conversationCellTimeLabel
    case conversationCellBadgeLabel
    case conversationCellThumbnailImageView
    case conversationCellAvatarImageView
    case conversationCellStatusImageView
    case conversationCellStatusLabel
    case conversationCellAssistantInfoLabel
    case conversationCellProfessionalTag

    // Chat Assistant Conversation Cell
    case assistantConversationCellContainer(conversationId: String?)
    case assistantConversationCellNameLabel
    case assistantConversationCellAvatarImageView
    case assistantConversationCellInfoLabel
    case assistantConversationCellTimeLabel
    case assistantConversationCellBadgeLabel

    // ChatBlockedUserVC
    case chatBlockedUsersTableView
    case chatBlockedUsersEmptyView

    // BlockedUserCell
    case blockedUserCellAvatarImageView
    case blockedUserCellUserNameLabel

    // ChatListingView
    case chatListingViewUserAvatar
    case chatListingViewUserNameLabel
    case chatListingViewListingNameLabel
    case chatListingViewListingPriceLabel
    case chatListingViewListingButton
    case chatListingViewUserButton

    // Chat
    case chatViewTableView
    case chatViewMoreOptionsButton
    case chatViewBackButton
    case chatViewStickersButton
    case chatViewQuickAnswersButton
    case chatViewSendButton
    case chatViewTextInputBar
    
    // Inactive Chat
    case inactiveChatViewTableView
    case inactiveChatViewMoreOptionsButton
    case inactiveChatViewBackButton

    // DirectAnswers
    case directAnswersPresenterCollectionView

    // ChatCell
    case chatCellContainer(type: ChatBubbleCellType)
    case chatCellMessageLabel
    case chatCellDateLabel
    case chatCellAvatar
    case chatCellSystemLabel

    // ChatStickerCell
    case chatStickerCellContainer
    case chatStickerCellLeftImage
    case chatStickerCellRightImage

    // ChatDisclaimerCell
    case chatDisclaimerCellContainer
    case chatDisclaimerCellMessageLabel

    // ChatOtherInfoCell
    case chatOtherInfoCellContainer
    case chatOtherInfoCellNameLabel

    // ChatInterlocutorTypingCell
    case chatInterlocutorTypingCell

    // TourLogin
    case tourLoginCloseButton
    case tourFacebookButton
    case tourGoogleButton
    case tourEmailButton

    // TourNotifications
    case tourNotificationsCloseButton
    case tourNotificationsOKButton
    case tourNotificationsAlert

    // TourLocation
    case tourLocationCloseButton
    case tourLocationOKButton
    case tourLocationAlert

    // TourPosting
    case tourPostingCloseButton
    case tourPostingOkButton

    // User
    case userNavBarShareButton
    case userNavBarSettingsButton
    case userNavBarMoreButton
    case userHeaderCollapsedNameLabel
    case userHeaderCollapsedLocationLabel
    case userHeaderExpandedNameLabel
    case userHeaderExpandedLocationLabel
    case userHeaderExpandedAvatar
    case userHeaderExpandedAvatarButton
    case userHeaderExpandedRatingsButton
    case userHeaderExpandedRelationLabel
    case userHeaderExpandedVerifyFacebookButton
    case userHeaderExpandedVerifyGoogleButton
    case userHeaderExpandedVerifyEmailButton
    case userHeaderExpandedBuildTrustButton
    case userHeaderExpandedMemberSinceLabel
    case userEnableNotificationsButton
    case userSellingTab
    case userSoldTab
    case userFavoritesTab
    case userReviewsTab
    case userListingsFirstLoad
    case userListingsList
    case userListingsError
    case userPushPermissionOK
    case userPushPermissionCancel
    case userProfileAddBioButton
    case userProfileBuildTrustButton
    case userProfileVerifiedTitle
    case userProfileMoreBioTitle
    case userProfileBioLabel
    case userProfileVerifiedWithFacebook
    case userProfileVerifiedWithGoogle
    case userProfileVerifiedWithEmail
    
    // Verify Accounts popup
    case verifyAccountsBackgroundButton
    case verifyAccountsFacebookButton
    case verifyAccountsGoogleButton
    case verifyAccountsEmailButton
    case verifyAccountsEmailTextField
    case verifyAccountsEmailTextFieldButton

    // Verifications view
    case verificationsOptionsTitle
    case verificationsFacebookOption
    case verificationsGoogleOption
    case verificationsEmailOption
    case verificationsPhoneNumberOption
    case verificationsPhotoIDOption
    case verificationsAvatarOption
    case verificationsBioOption
    case verificationsMarkAsSoldOption

    // Phone Verification
    case phoneVerificationNumberInputCountryButton
    case phoneVerificationNumberInputCountryCodeLabel
    case phoneVerificationNumberInputTextField
    case phoneVerificationNumberInputContinueButton
    case phoneVerificationCodeInputTitle
    case phoneVerificationCodeInputSubtitle
    case phoneVerificationCodeInputTextfield
    case phoneVerificationCodeInputInfoLabel
    case phoneVerificationCodeInputInfoButton
    case phoneVerificationCountryPickerTable
    case phoneVerificationCountryPickerSearchBar

    // Verification awareness
    case verificationAwarenessAvatar
    case verificationAwarenessLabel
    case verificationAwarenessButton
    case verificationAwarenessLaterButton

    // Settings
    case settingsList
    case settingsLogoutAlertCancel
    case settingsLogoutAlertOK

    // SettingsCell
    case settingsCellIcon
    case settingsCellTitle
    case settingsCellValue
    case settingsCellSwitch
    
    // NotificationSettings
    case notificationSettingsTableView
    
    // NotificationSettingsCell
    case notificationSettingsCellTitle
    case notificationSettingsCellSwitch

    // ChangeUsername
    case changeUsernameNameField
    case changeUsernameSendButton
    
    // ChangeEmail
    case changeEmailCurrentEmailLabel
    case changeEmailTextField
    case changeEmailSendButton

    // ChangePassword
    case changePasswordPwdTextfield
    case changePasswordPwdConfirmTextfield
    case changePasswordSendButton

    // EditLocation
    case editLocationMap
    case editLocationSearchButton
    case editLocationSearchTextField
    case editLocationSearchSuggestionsTable
    case editLocationSensorLocationButton
    case editLocationApproxLocationCircleView
    case editLocationPOIImageView
    case editLocationSetLocationButton
    case editLocationApproxLocationSwitch

    // Express chat
    case expressChatCloseButton
    case expressChatCollection
    case expressChatSendButton
    case expressChatDontAskButton
    case expressChatMoreOptionsButton

    // Express chat cell
    case expressChatCell
    case expressChatCellListingTitle
    case expressChatCellListingPrice
    case expressChatCellTickSelected

    // Chat Banner
    case chatBannerActionButton
    case chatBannerCloseButton
    // ExpressChatBanner
    case expressChatBanner
    // ProfessionalSellerChatBanner
    case professionalSellerChatBanner
    
    // Pop-up alert. 
    case acceptPopUpButton
    
    // Bubble notifications
    case bubbleButton

    // Meeting Creation
    case meetingCreationView
    case meetingCreationPlaceHeaderLabel
    case meetingCreationdateTimeHeaderLabel
    case meetingCreationLocationLabel
    case meetingCreationSuggestedLocationsCollection
    case meetingCreationSelectDayLabel
    case meetingCreationSendMeetingButton

    // Meeting creation tips
    case meetingCreationTipsView
    case meetingCreationTipsCloseButton
    case meetingCreationTipsImageView
    case meetingCreationTipsTitleLabel
    case meetingCreationTipsSubtitleLabel
    case meetingCreationTipsSendMeetingButton
    case meetingCreationTipsSecondaryCloseButton


    // Monetization

    // Bump Up Banner
    case bumpUpBanner
    case bumpUpBannerButton
    case bumpUpBannerLabel

    // Boost Timer View
    case boostTitleLabel
    case boostTimeLabel
    case boostProgressBar

    // Payment bump up screen
    case paymentBumpUpCloseButton
    case paymentBumpUpImage
    case paymentBumpUpTitleLabel
    case paymentBumpUpSubtitleLabel
    case paymentBumpUpButton

    // Multi day bump up screen
    case multiDayBumpCloseButton
    case multiDayBumpTitleLabel
    case multiDayBump1DayItem
    case multiDayBump3DaysItem
    case multiDayBump7DaysItem

    case multiDayBumpItemTitleLabel
    case multiDayBumpItemDaysTag
    case multiDayBumpItemSubtitleLabel
    case multiDayBumpItemListingImage
    case multiDayBumpItemButton

    // Multi day info bump up screen
    case multiDayBumpInfoCloseButton
    case multiDayBumpInfoTimerBar
    case multiDayBumpInfo1DayItem
    case multiDayBumpInfo3DaysItem
    case multiDayBumpInfo7DaysItem

    // Bump up boost screen
    case boostViewTimer
    case boostViewCloseButton
    case boostViewImage
    case boostViewTitleLabel
    case boostViewSubtitleLabel
    case boostViewButton

    case boostSucceededAlert
    case boostSuccededAlertLabel
    case boostSuccededAlertAnimationView

    // Bump Up Hidden Alert
    case bumpUpHiddenListingAlertContactButton
    case bumpUpHiddenListingAlertCancelButton

    // Offensive Report Alert
    case offensiveReportAlertOpenGuidelineButton
    case offensiveReportAlertSkipButton

    // ExpandableSelectionCategoryView
    case expandableCategorySelectionCloseButton
    case expandableCategorySelectionView
    case expandableCategorySelectionButton

    // Featured Info View
    case featuredInfoCloseButton

    // Promote Bump Up view
    case promoteBumpUpView
    case promoteBumpUpTitle
    case promoteBumpUpSellFasterButton
    case promoteBumpUpLaterButton

    // Professional Dealers Ask for phone number
    case askPhoneNumberView
    case askPhoneNumberCloseButton
    case askPhoneNumberNotNowButton
    case askPhoneNumberIntroText
    case askPhoneNumberLetstalkText
    case askPhoneNumberTextfield
    case askPhoneNumberSendPhoneButton

    //  MARK - Verticals
    case promoCell
    case promoCellTitle
    case promoCellIcon
    case promoCellPostNowButton

    // Search Alerts Placeholder
    case searchAlertsPlaceholderIcon
    case searchAlertsPlaceholderText
    case searchAlertsPlaceholderButton

    // Letgo Tooltip
    case letgoTooltipButton
    case letgoTooltipText
    
    
    // DropdownTableView
    
    case dropdownViewControllerTableView
    case dropdownViewControllerSearchBar
    case dropdownViewControllerApplyButton
    case dropdownViewControllerResetButton

    // Post Another Listing
    case postAnotherListingCloseButton
    case postAnotherListingTitleLabel
    case postAnotherListingDescriptionLabel
    case postAnotherListingPostButton
    
    static func ==(lhs: AccessibilityId, rhs: AccessibilityId) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    var identifier: String {
        switch self {
        // Tab Bar
        case .tabBarFirstTab:
            return "tabBarFirstTab"
        case .tabBarSecondTab:
            return "tabBarSecondTab"
        case .tabBarThirdTab:
            return "tabBarThirdTab"
        case .tabBarFourthTab:
            return "tabBarFourthTab"
        case .tabBarFifthTab:
            return "tabBarFifthTab"
        case .tabBarFloatingSellButton:
            return "tabBarFloatingSellButton"
            
        // Main Listings List
        case .mainListingsNavBarSearch:
            return "mainListingsNavBarSearch"
        case .mainListingsFilterButton:
            return "mainListingsFilterButton"
        case .mainListingsInviteButton:
            return "mainListingsInviteButton"
        case .mainListingsListView:
            return "mainListingsListView"
        case .mainListingsTagsCollection:
            return "mainListingsTagsCollection"
        case .mainListingsInfoBubbleLabel:
            return "mainListingsInfoBubbleLabel"
        case .mainListingsSuggestionSearchesTable:
            return "mainListingsSuggestionSearchesTable"
           
        // Sectioned Feed
        case .feedFilterButton:
            return "feedFilterButton"
        case .feedInviteButton:
            return "feedInviteButton"
        case .feedNavBarSearch:
            return "feedNavBarSearch"
        case .feedCollectionView:
            return "feedCollectionView"
            
        // Passive buyers
        case .passiveBuyersTitle:
            return "passiveBuyersTitle"
        case .passiveBuyersMessage:
            return "passiveBuyersMessage"
        case .passiveBuyersContactButton:
            return "passiveBuyersContactButton"
        case .passiveBuyersTable:
            return "passiveBuyersTable"
        case .passiveBuyerCellName:
            return "passiveBuyerCellName"
            
        // Listing List View
        case .listingListViewFirstLoadView:
            return "listingListViewFirstLoadView"
        case .listingListViewFirstLoadActivityIndicator:
            return "listingListViewFirstLoadActivityIndicator"
        case .listingListViewCollection:
            return "listingListViewCollection"
        case .listingListViewErrorView:
            return "listingListViewErrorView"
        case .listingListErrorImageView:
            return "listingListErrorImageView"
        case .listingListErrorTitleLabel:
            return "listingListErrorTitleLabel"
        case .listingListErrorBodyLabel:
            return "listingListErrorBodyLabel"
        case .listingListErrorButton:
            return "listingListErrorButton"
            
        // Listing Cell
        case let .listingCell(listingId):
            return "listingCell-\(listingId ?? "")"
        case .listingCellThumbnailImageView:
            return "listingCellThumbnailImageView"
        case .listingCellThumbnailGifImageView:
            return "listingCellThumbnailGifImageView"
        case .listingCellStripeImageView:
            return "listingCellStripeImageView"
        case .listingCellStripeLabel:
            return "listingCellStripeLabel"
        case .listingCellStripeIcon:
            return "listingCellStripeIcon"
        case .listingCellFeaturedPrice:
            return "listingCellFeaturedPrice"
        case .listingCellFeaturedTitle:
            return "listingCellFeaturedTitle"
        case .listingCellFeaturedChatButton:
            return "listingCellFeaturedChatButton"
            
        // Collection & Banner Cells
        case .collectionCell:
            return "collectionCell"
        case .collectionCellImageView:
            return "collectionCellImageView"
        case .collectionCellTitle:
            return "collectionCellTitle"
        case .collectionCellExploreButton:
            return "collectionCellExploreButton"
            
        case .bannerCell:
            return "bannerCell"
        case .bannerCellImageView:
            return "bannerCellImageView"
        case .bannerCellTitle:
            return "bannerCellTitle"
            
        // Advertisement Cell
        case .advertisementCell:
            return "advertisementCell"
        case .advertisementCellBanner:
            return "advertisementCellBanner"
            
        // Filter Tags VC
        case .filterTagsCollectionView:
            return "filterTagsCollectionView"
        case .filterTagCell(let tag):
            let idPrefix = "filterTagCell"
            let idSuffix: String
            switch tag {
            case .location:
                idSuffix = "Location"
            case let .within(timeCriteria):
                idSuffix = "WithinTime-\(timeCriteria.accessibilityId)"
            case let .orderBy(sortCriteria):
                idSuffix = "OrderBy-\(sortCriteria.rawValue)"
            case let .category(category):
                idSuffix = "Category-\(category.rawValue)"
            case let .priceRange(from, to, currency):
                var params = [String]()
                if let from = from {
                    params.append(String(from))
                }
                if let to = to {
                    params.append(String(to))
                }
                if let currency = currency {
                    params.append(currency.code)
                }
                idSuffix = "PriceRange-\(params.joined(separator: "_"))"
            case .freeStuff:
                idSuffix = "Free"
            case let .distance(distance):
                idSuffix = "Distance-\(String(distance))"
            case .carSellerType(_, let name):
                idSuffix = "CarSeller-\(name)"
            case let .make(carId, carName):
                idSuffix = "CarMake-\(carId)_\(carName)"
            case let .model(carId, carName):
                idSuffix = "CarModel-\(carId)_\(carName)"
            case let .carDriveTrainType(driveTrainType):
                idSuffix = "CarDriveTrain-\(driveTrainType.value)"
            case let .carBodyType(bodyType):
                idSuffix = "CarBodyType-\(bodyType.value)"
            case let .carFuelType(fuelType):
                idSuffix = "CarFuelType-\(fuelType.value)"
            case let .carTransmissionType(transmissionType):
                idSuffix = "CarTransmissionType-\(transmissionType.value)"
            case let .mileageRange(from, to):
                idSuffix = AccessibilityId.rangeIdentifier(forRange: AccessibilityRange(withLowerBound: from,
                                                                                        upperBound: to),
                                                           identifierPrefix: "CarMileage")
            case let .numberOfSeats(from, to):
                idSuffix = AccessibilityId.rangeIdentifier(forRange: AccessibilityRange(withLowerBound: from,
                                                                                        upperBound: to),
                                                           identifierPrefix: "CarNumberOfSeats")
            case let .yearsRange(from, to):
                idSuffix = AccessibilityId.rangeIdentifier(forRange: AccessibilityRange(withLowerBound: from,
                                                                                        upperBound: to),
                                                           identifierPrefix: "CarYears")
            case let .realEstateNumberOfBedrooms(number):
                idSuffix = "RealEstateNumBedRooms-\(number)"
            case let .realEstateNumberOfBathrooms(number):
                idSuffix = "RealEstateNumBathRooms-\(String(number.rawValue))"
            case let .realEstatePropertyType(type):
                idSuffix = "RealEstatePropertyType-\(type.rawValue)"
            case let .realEstateOfferType(type):
                idSuffix = "RealEstateOfferType-\(type.rawValue)"
            case let .realEstateNumberOfRooms(number):
                idSuffix = "RealEstateNumRooms-\(number)"
            case let .serviceType(serviceType):
                idSuffix = "ServicesServiceType-\(serviceType.name)"
            case let .serviceSubtype(serviceSubtype):
                idSuffix = "ServicesServiceSubtype-\(serviceSubtype.name)"
            case let .unifiedServiceType(serviceType, subtypes):
                idSuffix = "ServicesServiceType-\(serviceType.name)+\(subtypes.count)"
            case let .sizeSquareMetersRange(from, to):
                idSuffix = AccessibilityId.rangeIdentifier(forRange: AccessibilityRange(withLowerBound: from,
                                                                                        upperBound: to),
                                                           identifierPrefix: "RealEstateSizeSquareMetersRange")
            case let .serviceListingType(listingType):
                idSuffix = "ServicesListingType-\(listingType.rawValue)"
            }
            return idPrefix + idSuffix
        case .filterTagCellTagIcon:
            return "filterTagCellTagIcon"
        case .filterTagCellTagLabel:
            return "filterTagCellTagLabel"
            
        // CategoriesHeader Cells
        case .categoriesHeaderCollectionView:
            return "categoriesHeaderCollectionView"
        case .categoryHeaderCell:
            return "categoryHeaderCell"
        case .categoryHeaderCellCategoryIcon:
            return "categoryHeaderCellCategoryIcon"
        case .categoryHeaderCellCategoryTitle:
            return "categoryHeaderCellCategoryTitle"
            
        // SuggestionSearchCell
        case .suggestionSearchCell:
            return "suggestionSearchCell"
        case .suggestionSearchCellTitle:
            return "suggestionSearchCellTitle"
        case .suggestionSearchCellSubtitle:
            return "suggestionSearchCellSubtitle"
            
        // Filters
        case .filtersCollectionView:
            return "filtersCollectionView"
        case .filtersSaveFiltersButton:
            return "filtersSaveFiltersButton"
        case .filtersCancelButton:
            return "filtersCancelButton"
        case .filtersResetButton:
            return "filtersResetButton"
            
        // Filters Cells
        case .filterCategoryCell:
            return "filterCategoryCell"
        case .filterCategoryCellIcon:
            return "filterCategoryCellIcon"
        case .filterCategoryCellTitleLabel:
            return "filterCategoryCellTitleLabel"
            
        case .filterCarInfoMakeModelCell:
            return "filterCarInfoMakeModelCell"
        case .filterCarInfoMakeModelCellTitleLabel:
            return "filterCarInfoMakeModelCellTitleLabel"
        case .filterCarInfoMakeModelCellInfoLabel:
            return "filterCarInfoMakeModelCellInfoLabel"
        case .filterCarInfoYearCell:
            return "filterCarInfoYearCell"
        case .filterCarInfoYearCellTitleLabel:
            return "filterCarInfoYearCellTitleLabel"
        case .filterCarInfoYearCellInfoLabel:
            return "filterCarInfoYearCellInfoLabel"
            
        case .filterSingleCheckCell:
            return "filterSingleCheckCell"
        case .filterSingleCheckCellTickIcon:
            return "filterSingleCheckCellTickIcon"
        case .filterSingleCheckCellTitleLabel:
            return "filterSingleCheckCellTitleLabel"
            
        case .filterDistanceCell:
            return "filterDistanceCell"
        case .filterDistanceSlider:
            return "filterDistanceSlider"
        case .filterDistanceTip:
            return "filterDistanceTip"
        case .filterDistanceLabel:
            return "filterDistanceLabel"
            
        case .filterHeaderCell:
            return "filterHeaderCell"
        case .filterHeaderCellTitleLabel:
            return "filterHeaderCellTitleLabel"
            
        case .filterDisclosureCell:
            return "filterDisclosureCell"
        case .filterDisclosureCellTitleLabel:
            return "filterDisclosureCellTitleLabel"
        case .filterDisclosureCellSubtitleLabel:
            return "filterDisclosureCellSubtitleLabel"
            
        case .filterTextFieldIntCell:
            return "filterTextFieldIntCell"
        case .filterTextFieldIntCellTitleLabel:
            return "filterTextFieldIntCellTitleLabel"
        case .filterTextFieldIntCellTextField:
            return "filterTextFieldIntCellTextField"
            
        // Listing Detail
        case .listingDetailOnboarding:
            return "listingDetailOnboarding"
            
        // listing Carousel
        case .listingCarouselCollectionView:
            return "listingCarouselCollectionView"
        case .listingCarouselButtonBottom:
            return "listingCarouselButtonBottom"
        case .listingCarouselButtonTop:
            return "listingCarouselButtonTop"
        case .listingCarouselFavoriteButton:
            return "listingCarouselFavoriteButton"
        case .listingCarouselMoreInfoView:
            return "listingCarouselMoreInfoView"
        case .listingCarouselListingStatusLabel:
            return "listingCarouselListingStatusLabel"
        case .listingCarouselDirectChatTable:
            return "listingCarouselDirectChatTable"
        case .listingCarouselFullScreenAvatarView:
            return "listingCarouselFullScreenAvatarView"
        case .listingCarouselPageControl:
            return "listingCarouselPageControl"
        case .listingCarouselUserView:
            return "listingCarouselUserView"
        case .listingCarouselChatTextView:
            return "listingCarouselChatTextView"
        case .listingCarouselChatButton:
            return "listingCarouselChatButton"
        case .listingCarouselChatFooterLabel:
            return "listingCarouselChatFooterLabel"
        case .listingCarouselInterestedButton:
            return "listingCarouselInterestedButton"
        case .listingCarouselStatusView:
            return "listingCarouselStatusView"
        case .listingCarouselPlayButton:
            return "listingCarouselPlayButton"
        case .listingCarouselVideoProgressView:
            return "listingCarouselVideoProgressView"
            
        case .listingCarouselNavBarCloseButton:
            return "listingCarouselNavBarCloseButton"
        case .listingCarouselNavBarEditButton:
            return "listingCarouselNavBarEditButton"
        case .listingCarouselNavBarShareButton:
            return "listingCarouselNavBarShareButton"
        case .listingCarouselNavBarActionsButton:
            return "listingCarouselNavBarActionsButton"
        case .listingCarouselNavBarFavoriteButton:
            return "listingCarouselNavBarFavoriteButton"
            
        case .listingCarouselMoreInfoScrollView:
            return "listingCarouselMoreInfoScrollView"
        case .listingCarouselMoreInfoTitleLabel:
            return "listingCarouselMoreInfoTitleLabel"
        case .listingCarouselMoreInfoPriceLabel:
            return "listingCarouselMoreInfoPriceLabel"
        case .listingCarouselMoreInfoTransTitleLabel:
            return "listingCarouselMoreInfoTransTitleLabel"
        case .listingCarouselMoreInfoStatsView:
            return "listingCarouselMoreInfoStatsView"
        case .listingCarouselMoreInfoAddressLabel:
            return "listingCarouselMoreInfoAddressLabel"
        case .listingCarouselMoreInfoDistanceLabel:
            return "listingCarouselMoreInfoDistanceLabel"
        case .listingCarouselMoreInfoMapView:
            return "listingCarouselMoreInfoMapView"
        case .listingCarouselMoreInfoSocialShareTitleLabel:
            return "listingCarouselMoreInfoSocialShareTitleLabel"
        case .listingCarouselMoreInfoSocialShareView:
            return "listingCarouselMoreInfoSocialShareView"
        case .listingCarouselMoreInfoDescriptionLabel:
            return "listingCarouselMoreInfoDescriptionLabel"
        
        // listing Stats View
        case .listingStatsViewFavouriteStatsView:
            return "listingStatsViewFavouriteStatsView"
        case .listingStatsViewFavouriteStatsLabel:
            return "listingStatsViewFavouriteStatsLabel"
        case .listingStatsViewFavouriteViewCountView:
            return "listingStatsViewFavouriteViewCountView"
        case .listingStatsViewFavouriteViewCountLabel:
            return "listingStatsViewFavouriteViewCountLabel"
        case .listingStatsViewFavouriteTimePostedView:
            return "listingStatsViewFavouriteTimePostedView"
        case .listingStatsViewFavouriteTimePostedLabel:
            return "listingStatsViewFavouriteTimePostedLabel"
            
        // listing Carousel Cell
        case .listingCarouselCell:
            return "listingCarouselCell"
        case .listingCarouselCellCollectionView:
            return "listingCarouselCellCollectionView"
        case .listingCarouselCellPlaceholderImage:
            return "listingCarouselCellPlaceholderImage"
        case .listingCarouselImageCell:
            return "listingCarouselImageCell"
        case .listingCarouselImageCellImageView:
            return "listingCarouselImageCellImageView"
        case .listingCarouselVideoCell:
            return "listingCarouselVideoCell"
        case .listingCarouselVideoCellVideoPreview:
            return "listingCarouselVideoCellVideoPreview"
            
        // listing Carousel Post Delete screens
        case .postDeleteAlertButton:
            return "postDeleteAlertButton"
        case .postDeleteFullscreenButton:
            return "postDeleteFullscreenButton"
        case .postDeleteFullscreenIncentiveView:
            return "postDeleteFullscreenIncentiveView"
            
        // Chat Text View
        case .chatTextViewTextField:
            return "chatTextViewTextField"
        case .chatTextViewSendButton:
            return "chatTextViewSendButton"
            
        // User View
        case .userViewNameLabel:
            return "userViewNameLabel"
        case .userViewSubtitleLabel:
            return "userViewSubtitleLabel"
        case .userViewTextInfoContainer:
            return "userViewTextInfoContainer"
            
        // Notifications
        case .notificationsRefresh:
            return "notificationsRefresh"
        case .notificationsTable:
            return "notificationsTable"
        case .notificationsLoading:
            return "notificationsLoading"
        case .notificationsEmptyView:
            return "notificationsEmptyView"
        case .notificationsCellSecondaryImage:
            return "notificationsCellSecondaryImage"
        case .notificationsModularTextTitleLabel:
            return "notificationsModularTextTitleLabel"
        case .notificationsModularTextBodyLabel:
            return "notificationsModularTextBodyLabel"
        case .notificationsModularBasicImageView:
            return "notificationsModularBasicImageView"
        case .notificationsModularIconImageView:
            return "notificationsModularIconImageView"
        case .notificationsModularThumbnailCollectionView:
            return "notificationsModularThumbnailCollectionView"
        case .notificationsModularThumbnailCollectionViewCell:
            return "notificationsModularThumbnailCollectionViewCell"
        case .notificationsModularThumbnailView:
            return "notificationsModularThumbnailView"
        case .notificationsModularHeroImageView:
            return "notificationsModularHeroImageView"
        case .notificationsModularCTA1:
            return "notificationsModularCTA1"
        case .notificationsModularCTA2:
            return "notificationsModularCTA2"
        case .notificationsModularCTA3:
            return "notificationsModularCTA3"
            
            
        // Posting
        case .postingCameraImagePreview:
            return "postingCameraImagePreview"
        case .postingCameraSwitchCamButton:
            return "postingCameraSwitchCamButton"
        case .postingCameraUsePhotoButton:
            return "postingCameraUsePhotoButton"
        case .postingCameraInfoScreenButton:
            return "postingCameraInfoScreenButton"
        case .postingCameraFlashButton:
            return "postingCameraFlashButton"
        case .postingCameraRetryPhotoButton:
            return "postingCameraRetryPhotoButton"
        case .postingCameraFirstTimeAlert:
            return "postingCameraFirstTimeAlert"
        case .postingCameraCloseButton:
            return "postingCameraCloseButton"
        case .postingGalleryLoading:
            return "postingGalleryLoading"
        case .postingGalleryCollection:
            return "postingGalleryCollection"
        case .postingGalleryAlbumButton:
            return "postingGalleryAlbumButton"
        case .postingGalleryUsePhotoButton:
            return "postingGalleryUsePhotoButton"
        case .postingGalleryInfoScreenButton:
            return "postingGalleryInfoScreenButton"
        case .postingGalleryImageContainer:
            return "postingGalleryImageContainer"
        case .postingGalleryCloseButton:
            return "postingGalleryCloseButton"
        case .postingCloseButton:
            return "postingCloseButton"
        case .postingGalleryButton:
            return "postingGalleryButton"
        case .postingInfoButton:
            return "postingInfoButton"
        case .postingCameraButton:
            return "postingCameraButton"
        case .postingPhotoButton:
            return "postingPhotoButton"
        case .postingVideoButton:
            return "postingVideoButton"
        case .postingLoading:
            return "postingLoading"
        case .postingRetryButton:
            return "postingRetryButton"
        case .postingDoneButton:
            return "postingDoneButton"
        case .postingCurrencyLabel:
            return "postingCurrencyLabel"
        case .postingTitleField:
            return "postingTitleField"
        case .postingPriceField:
            return "postingPriceField"
        case .postingDescriptionField:
            return "postingDescriptionField"
        case .postingBackButton:
            return "postingBackButton"
        case .postingInfoCloseButton:
            return "postingInfoCloseButton"
        case .postingInfoCollectionView:
            return "postingInfoCollectionView"
        case .postingInfoShareButton:
            return "postingInfoShareButton"
        case .postingInfoLoading:
            return "postingInfoLoading"
        case .postingInfoEditButton:
            return "postingInfoEditButton"
        case .postingInfoMainButton:
            return "postingInfoMainButton"
        case .postingInfoIncentiveContainer:
            return "postingInfoIncentiveContainer"
        case .postingCategorySelectionCarsButton:
            return "postingCategorySelectionCarsButton"
        case .postingCategorySelectionMotorsAndAccessoriesButton:
            return "postingCategorySelectionMotorsAndAccessoriesButton"
        case .postingCategorySelectionOtherButton:
            return "postingCategorySelectionOtherButton"
        case .postingCategorySelectionRealEstateButton:
            return "postingCategorySelectionRealEstateButton"
        case .postingCategorySelectionServicesButton:
            return "postingCategorySelectionServicesButton"
        case .postingCategoryDeatilNavigationBackButton:
            return "postingCategoryDeatilNavigationBackButton"
        case .postingCategoryDeatilNavigationMakeButton:
            return "postingCategoryDeatilNavigationMakeButton"
        case .postingCategoryDeatilNavigationModelButton:
            return "postingCategoryDeatilNavigationModelButton"
        case .postingCategoryDeatilNavigationYearButton:
            return "postingCategoryDeatilNavigationYearButton"
        case .postingCategoryDeatilNavigationOkButton:
            return "postingCategoryDeatilNavigationOkButton"
        case .postingCategoryDeatilDoneButton:
            return "postingCategoryDeatilDoneButton"
        case .postingCategoryDeatilRowButton:
            return "postingCategoryDeatilRowButton"
        case .postingCategoryDeatilTextField:
            return "postingCategoryDeatilTextField"
        case .postingCategoryDeatilSearchBar:
            return "postingCategoryDeatilSearchBar"
        case .postingCategoryDeatilTableView:
            return "postingCategoryDeatilTableView"
        case .postingAddDetailTableView:
            return "postingAddDetailTableView"
        case .postingAddDetailSearchBar:
            return "postingAddDetailSearchBar"
        case .postingDetailMaxServices:
            return "postingDetailMaxServices"
        case .postingDetailShareOnFacebookTitleLabel:
            return "postingDetailShareOnFacebookTitleLabel"
        case .postingDetailShareOnFacebookFooterLabel:
            return "postingDetailShareOnFacebookFooterLabel"
        case .postingDetailShareOnFacebookCheckbox:
            return "postingDetailShareOnFacebookCheckbox"
        case .postingCameraTooltipLabel:
            return "postingCameraTooltipLabel"
            
        // Editlisting
        case .editListingCloseButton:
            return "editListingCloseButton"
        case .editListingScroll:
            return "editListingScroll"
        case .editListingTitleField:
            return "editListingTitleField"
        case .editListingAutoGenTitleButton:
            return "editListingAutoGenTitleButton"
        case .editListingImageCollection:
            return "editListingImageCollection"
        case .editListingCurrencyLabel:
            return "editListingCurrencyLabel"
        case .editListingPriceField:
            return "editListingPriceField"
        case .editListingDescriptionField:
            return "editListingDescriptionField"
        case .editListingLocationButton:
            return "editListingLocationButton"
        case .editListingCategoryButton:
            return "editListingCategoryButton"
        case .editListingCarsMakeButton:
            return "editListingCarsMakeButton"
        case .editListingCarsModelButton:
            return "editListingCarsModelButton"
        case .editListingCarsYearButton:
            return "editListingCarsYearButton"
        case .editListingSendButton:
            return "editListingSendButton"
        case .editListingShareFBSwitch:
            return "editListingShareFBSwitch"
        case .editListingLoadingView:
            return "editListingLoadingView"
        case .editListingPostFreeSwitch:
            return "editListingPostFreeSwitch"
        case .editListingOptionSelector:
            return "editListingOptionSelector"
        case .editListingOptionSelectorTitleLabel:
            return "editListingOptionSelectorTitleLabel"
        case .editListingOptionSelectorCurrentValueLabel:
            return "editListingOptionSelectorCurrentValueLabel"
        case .editListingFeatureIcon:
            return "editListingFeatureIcon"
        case .editListingFeatureLabel:
            return "editListingFeatureLabel"
        case .editListingFeatureSwitch:
            return "editListingFeatureSwitch"
        case .editListingServicesTypeButton:
            return "editListingServicesTypeButton"
        case .editListingServicesSubtypeButton:
            return "editListingServicesSubtypeButton"
        case .editListingServicesListingTypeButton:
            return "editListingServicesListingTypeButton"
        case .editListingPaymentFrequencyButton:
            return "editListingPaymentFrequencyButton"

            
        // ReportUser
        case .reportUserCollection:
            return "reportUserCollection"
        case .reportUserCommentField:
            return "reportUserCommentField"
        case .reportUserSendButton:
            return "reportUserSendButton"
            
        // RateUser
        case .rateUserUserNameLabel:
            return "rateUserUserNameLabel"
        case .rateUserStarButton1:
            return "rateUserStarButton1"
        case .rateUserStarButton2:
            return "rateUserStarButton2"
        case .rateUserStarButton3:
            return "rateUserStarButton3"
        case .rateUserStarButton4:
            return "rateUserStarButton4"
        case .rateUserStarButton5:
            return "rateUserStarButton5"
        case .rateUserDescriptionField:
            return "rateUserDescriptionField"
        case .rateUserLoading:
            return "rateUserLoading"
        case .rateUserSendButton:
            return "rateUserSendButton"
            
        // RatingList
        case .ratingListTable:
            return "ratingListTable"
        case .ratingListLoading:
            return "ratingListLoading"
        case .ratingListCellUserName:
            return "ratingListCellUserName"
        case .ratingListCellReport:
            return "ratingListCellReport"
        case .ratingListCellReview:
            return "ratingListCellReview"
            
        // AppRating
        case .appRatingStarButton1:
            return "appRatingStarButton1"
        case .appRatingStarButton2:
            return "appRatingStarButton2"
        case .appRatingStarButton3:
            return "appRatingStarButton3"
        case .appRatingStarButton4:
            return "appRatingStarButton4"
        case .appRatingStarButton5:
            return "appRatingStarButton5"
        case .appRatingBgButton:
            return "appRatingBgButton"
        case .appRatingDismissButton:
            return "appRatingDismissButton"
            
        // SafetyTips
        case .safetyTipsOkButton:
            return "safetyTipsOkButton"
            
        // EmptyView
        case .emptyViewPrimaryButton:
            return "emptyViewPrimaryButton"
        case .emptyViewSecondaryButton:
            return "emptyViewSecondaryButton"
            
        // SocialShare
        case .socialShareFacebook:
            return "socialShareFacebook"
        case .socialShareFBMessenger:
            return "socialShareFBMessenger"
        case .socialShareEmail:
            return "socialShareEmail"
        case .socialShareWhatsapp:
            return "socialShareWhatsapp"
        case .socialShareTwitter:
            return "socialShareTwitter"
        case .socialShareTelegram:
            return "socialShareTelegram"
        case .socialShareCopyLink:
            return "socialShareCopyLink"
        case .socialShareSMS:
            return "socialShareSMS"
        case .socialShareMore:
            return "socialShareMore"
            
        // MainSignUp
        case .mainSignUpFacebookButton:
            return "mainSignUpFacebookButton"
        case .mainSignUpGoogleButton:
            return "mainSignUpGoogleButton"
        case .mainSignUpSignupButton:
            return "mainSignUpSignupButton"
        case .mainSignupLogInButton:
            return "mainSignupLogInButton"
        case .mainSignupCloseButton:
            return "mainSignupCloseButton"
        case .mainSignupHelpButton:
            return "mainSignupHelpButton"
        case .mainSignupContinueWithEmailButton:
            return "mainSignupContinueWithEmailButton"
            
            
        // SignUpLogin
        case .signUpLoginFacebookButton:
            return "signUpLoginFacebookButton"
        case .signUpLoginGoogleButton:
            return "signUpLoginGoogleButton"
        case .signUpLoginEmailButton:
            return "signUpLoginEmailButton"
        case .signUpLoginEmailTextField:
            return "signUpLoginEmailTextField"
        case .signUpLoginPasswordButton:
            return "signUpLoginPasswordButton"
        case .signUpLoginPasswordTextField:
            return "signUpLoginPasswordTextField"
        case .signUpLoginUserNameButton:
            return "signUpLoginUserNameButton"
        case .signUpLoginUserNameTextField:
            return "signUpLoginUserNameTextField"
        case .signUpLoginShowPasswordButton:
            return "signUpLoginShowPasswordButton"
        case .signUpLoginForgotPasswordButton:
            return "signUpLoginForgotPasswordButton"
        case .signUpLoginSegmentedControl:
            return "signUpLoginSegmentedControl"
        case .signUpLoginHelpButton:
            return "signUpLoginHelpButton"
        case .signUpLoginCloseButton:
            return "signUpLoginCloseButton"
        case .signUpLoginSendButton:
            return "signUpLoginSendButton"
            
        // Recaptcha
        case .recaptchaCloseButton:
            return "recaptchaCloseButton"
        case .recaptchaLoading:
            return "recaptchaLoading"
        case .recaptchaWebView:
            return "recaptchaWebView"

        // Passowrdless
        case .passwordlessEmailTitleLabel:
            return "passwordlessEmailTitleLabel"
        case .passwordlessEmailDescriptionLabel:
            return "passwordlessEmailDescriptionLabel"
        case .passwordlessEmailTextField:
            return "passwordlessEmailTextField"
        case .passwordlessEmailContinueButton:
            return "passwordlessEmailContinueButton"
        case .passwordlessUsernameTitleLabel:
            return "passwordlessUsernameTitleLabel"
        case .passwordlessUsernameUsernameTextField:
            return "passwordlessUsernameUsernameTextField"
        case .passwordlessDoneButton:
            return "passwordlessDoneButton"
        case .passwordlessEmailSentTitleLabel:
            return "passwordlessEmailSentTitleLabel"
        case .passwordlessEmailSentSubtitleLabel:
            return "passwordlessEmailSentSubtitleLabel"
        case .passwordlessEmailSentImageView:
            return "passwordlessEmailSentImageView"

            
        // ChatConversationsList
        case .chatConversationsListOptionsNavBarButton:
            return "chatConversationsListOptionsNavBarButton"
        case .chatConversationsListFiltersNavBarButton:
            return "chatConversationsListFiltersNavBarButton"
            
        // ChatGrouped
        case .chatGroupedViewRightNavBarButton:
            return "chatGroupedViewRightNavBarButton"
            
        // ChatList
        case .chatListViewTabAll:
            return "chatListViewTabAll"
        case .chatListViewTabSelling:
            return "chatListViewTabSelling"
        case .chatListViewTabBuying:
            return "chatListViewTabBuying"
        case .chatListViewTabBlockedUsers:
            return "chatListViewTabBlockedUsers"
            
        case .chatListViewFooterButton:
            return "chatListViewFooterButton"
        case .chatListViewTabAllTableView:
            return "chatListViewTabAllTableView"
        case .chatListViewTabSellingTableView:
            return "chatListViewTabSellingTableView"
        case .chatListViewTabBuyingTableView:
            return "chatListViewTabBuyingTableView"
        case .chatListViewTabBlockedUsersTableView:
            return "chatListViewTabBlockedUsersTableView"
            
        // ConversationCell
        case let .conversationCellContainer(conversationId):
            return "conversationCellContainer-\(conversationId ?? "")"
        case let .conversationCellUserLabel(interlocutorId):
            return "conversationCellUserLabel-\(interlocutorId ?? "")"
        case let .conversationCellListingLabel(listingId):
            return "conversationCellListingLabel-\(listingId ?? "")"
        case .conversationCellTimeLabel:
            return "conversationCellTimeLabel"
        case .conversationCellBadgeLabel:
            return "conversationCellBadgeLabel"
        case .conversationCellThumbnailImageView:
            return "conversationCellThumbnailImageView"
        case .conversationCellAvatarImageView:
            return "conversationCellAvatarImageView"
        case .conversationCellStatusImageView:
            return "conversationCellStatusImageView"
        case .conversationCellStatusLabel:
            return "conversationCellStatusLabel"
        case .conversationCellAssistantInfoLabel:
            return "conversationCellAssistantInfoLabel"
        case .conversationCellProfessionalTag:
            return "conversationCellProfessionalTag"

        // Chat Assistant Conversation Cell
        case let .assistantConversationCellContainer(conversationId):
            return "assistantConversationCellContainer-\(conversationId ?? "")"
        case .assistantConversationCellNameLabel:
            return "assistantConversationCellNameLabel"
        case .assistantConversationCellAvatarImageView:
            return "assistantConversationCellAvatarImageView"
        case .assistantConversationCellInfoLabel:
            return "assistantConversationCellInfoLabel"
        case .assistantConversationCellTimeLabel:
            return "assistantConversationCellTimeLabel"
        case .assistantConversationCellBadgeLabel:
            return "assistantConversationCellBadgeLabel"

        // ChatBlockedUserVC
        case .chatBlockedUsersTableView:
            return "chatBlockedUsersTableView"
        case .chatBlockedUsersEmptyView:
            return "chatBlockedUsersEmptyView"
            
        // BlockedUserCell
        case .blockedUserCellAvatarImageView:
            return "blockedUserCellAvatarImageView"
        case .blockedUserCellUserNameLabel:
            return "blockedUserCellUserNameLabel"
            
        // ChatListingView
        case .chatListingViewUserAvatar:
            return "chatListingViewUserAvatar"
        case .chatListingViewUserNameLabel:
            return "chatListingViewUserNameLabel"
        case .chatListingViewListingNameLabel:
            return "chatListingViewListingNameLabel"
        case .chatListingViewListingPriceLabel:
            return "chatListingViewListingPriceLabel"
        case .chatListingViewListingButton:
            return "chatListingViewListingButton"
        case .chatListingViewUserButton:
            return "chatListingViewUserButton"
            
        // Chat
        case .chatViewTableView:
            return "chatViewTableView"
        case .chatViewMoreOptionsButton:
            return "chatViewMoreOptionsButton"
        case .chatViewBackButton:
            return "chatViewBackButton"
        case .chatViewStickersButton:
            return "chatViewStickersButton"
        case .chatViewQuickAnswersButton:
            return "chatViewQuickAnswersButton"
        case .chatViewSendButton:
            return "chatViewSendButton"
        case .chatViewTextInputBar:
            return "chatViewTextInputBar"
            
        // Inactive Chat
        case .inactiveChatViewTableView:
            return "inactiveChatViewTableView"
        case .inactiveChatViewMoreOptionsButton:
            return "inactiveChatViewMoreOptionsButton"
        case .inactiveChatViewBackButton:
            return "inactiveChatViewBackButton"
            
        // DirectAnswers
        case .directAnswersPresenterCollectionView:
            return "directAnswersPresenterCollectionView"
            
        // ChatCell
        case let .chatCellContainer(type):
            let suffix: String
            switch type {
            case .myMessage:
                suffix = "MyMessage"
            case .othersMessage:
                suffix = "OthersMessage"
            case .askPhoneNumber:
                suffix = "AskPhoneNumber"
            case .callToAction:
                suffix = "CallToAction"
            case .carousel:
                suffix = "Carousel"
            case .system:
                suffix = "System"
            }
            return "chatCellContainer\(suffix)"
        case .chatCellMessageLabel:
            return "chatCellMessageLabel"
        case .chatCellDateLabel:
            return "chatCellDateLabel"
        case .chatCellAvatar:
            return "chatCellAvatar"
        case .chatCellSystemLabel:
            return "chatCellSystemLabel"
            
        // ChatStickerCell
        case .chatStickerCellContainer:
            return "chatStickerCellContainer"
        case .chatStickerCellLeftImage:
            return "chatStickerCellLeftImage"
        case .chatStickerCellRightImage:
            return "chatStickerCellRightImage"
            
        // ChatDisclaimerCell
        case .chatDisclaimerCellContainer:
            return "chatDisclaimerCellContainer"
        case .chatDisclaimerCellMessageLabel:
            return "chatDisclaimerCellMessageLabel"

        // ChatOtherInfoCell
        case .chatOtherInfoCellContainer:
            return "chatOtherInfoCellContainer"
        case .chatOtherInfoCellNameLabel:
            return "chatOtherInfoCellNameLabel"

        // ChatInterlocutorTypingCell
        case .chatInterlocutorTypingCell:
            return "chatInterlocutorTypingCell"

        // TourLogin
        case .tourLoginCloseButton:
            return "tourLoginCloseButton"
        case .tourFacebookButton:
            return "tourFacebookButton"
        case .tourGoogleButton:
            return "tourGoogleButton"
        case .tourEmailButton:
            return "tourEmailButton"
            
        // TourNotifications
        case .tourNotificationsCloseButton:
            return "tourNotificationsCloseButton"
        case .tourNotificationsOKButton:
            return "tourNotificationsOKButton"
        case .tourNotificationsAlert:
            return "tourNotificationsAlert"
            
        // TourLocation
        case .tourLocationCloseButton:
            return "tourLocationCloseButton"
        case .tourLocationOKButton:
            return "tourLocationOKButton"
        case .tourLocationAlert:
            return "tourLocationAlert"
            
        // TourPosting
        case .tourPostingCloseButton:
            return "tourPostingCloseButton"
        case .tourPostingOkButton:
            return "tourPostingOkButton"
            
        // User
        case .userNavBarShareButton:
            return "userNavBarShareButton"
        case .userNavBarSettingsButton:
            return "userNavBarSettingsButton"
        case .userNavBarMoreButton:
            return "userNavBarMoreButton"
        case .userHeaderCollapsedNameLabel:
            return "userHeaderCollapsedNameLabel"
        case .userHeaderCollapsedLocationLabel:
            return "userHeaderCollapsedLocationLabel"
        case .userHeaderExpandedNameLabel:
            return "userHeaderExpandedNameLabel"
        case .userHeaderExpandedLocationLabel:
            return "userHeaderExpandedLocationLabel"
        case .userHeaderExpandedAvatar:
            return "userHeaderExpandedAvatar"
        case .userHeaderExpandedAvatarButton:
            return "userHeaderExpandedAvatarButton"
        case .userHeaderExpandedRatingsButton:
            return "userHeaderExpandedRatingsButton"
        case .userHeaderExpandedRelationLabel:
            return "userHeaderExpandedRelationLabel"
        case .userHeaderExpandedVerifyFacebookButton:
            return "userHeaderExpandedVerifyFacebookButton"
        case .userHeaderExpandedVerifyGoogleButton:
            return "userHeaderExpandedVerifyGoogleButton"
        case .userHeaderExpandedVerifyEmailButton:
            return "userHeaderExpandedVerifyEmailButton"
        case .userHeaderExpandedBuildTrustButton:
            return "userHeaderExpandedBuildTrustButton"
        case .userHeaderExpandedMemberSinceLabel:
            return "userHeaderExpandedMemberSinceLabel"
        case .userEnableNotificationsButton:
            return "userEnableNotificationsButton"
        case .userSellingTab:
            return "userSellingTab"
        case .userSoldTab:
            return "userSoldTab"
        case .userFavoritesTab:
            return "userFavoritesTab"
        case .userReviewsTab:
            return "userReviewsTab"
        case .userListingsFirstLoad:
            return "userListingsFirstLoad"
        case .userListingsList:
            return "userListingsList"
        case .userListingsError:
            return "userListingsError"
        case .userPushPermissionOK:
            return "userPushPermissionOK"
        case .userPushPermissionCancel:
            return "userPushPermissionCancel"
        case .userProfileAddBioButton:
            return "userProfileAddBioButton"
        case .userProfileBuildTrustButton:
            return "userProfileBuildTrustButton"
        case .userProfileVerifiedTitle:
            return "userProfileVerifiedTitle"
        case .userProfileMoreBioTitle:
            return "userProfileMoreBioTitle"
        case .userProfileBioLabel:
            return "userProfileBioLabel"
        case .userProfileVerifiedWithFacebook:
            return "userProfileVerifiedWithFacebook"
        case .userProfileVerifiedWithGoogle:
            return "userProfileVerifiedWithGoogle"
        case .userProfileVerifiedWithEmail:
            return "userProfileVerifiedWithEmail"

        // Verify Accounts popup
        case .verifyAccountsBackgroundButton:
            return "verifyAccountsBackgroundButton"
        case .verifyAccountsFacebookButton:
            return "verifyAccountsFacebookButton"
        case .verifyAccountsGoogleButton:
            return "verifyAccountsGoogleButton"
        case .verifyAccountsEmailButton:
            return "verifyAccountsEmailButton"
        case .verifyAccountsEmailTextField:
            return "verifyAccountsEmailTextField"
        case .verifyAccountsEmailTextFieldButton:
            return "verifyAccountsEmailTextFieldButton"
            
        // Verifications view
        case .verificationsOptionsTitle:
            return "verificationsOptionsTitle"
        case .verificationsFacebookOption:
            return "verificationsFacebookOption"
        case .verificationsGoogleOption:
            return "verificationsGoogleOption"
        case .verificationsEmailOption:
            return "verificationsEmailOption"
        case .verificationsPhoneNumberOption:
            return "verificationsPhoneNumberOption"
        case .verificationsPhotoIDOption:
            return "verificationsPhotoIDOption"
        case .verificationsAvatarOption:
            return "verificationsAvatarOption"
        case .verificationsBioOption:
            return "verificationsBioOption"
        case .verificationsMarkAsSoldOption:
            return "verificationsMarkAsSoldOption"

        // Phone Verification
        case .phoneVerificationNumberInputCountryButton:
            return "phoneVerificationNumberInputCountryButton"
        case .phoneVerificationNumberInputCountryCodeLabel:
            return "phoneVerificationNumberInputCountryCodeLabel"
        case .phoneVerificationNumberInputTextField:
            return "phoneVerificationNumberInputTextField"
        case .phoneVerificationNumberInputContinueButton:
            return "phoneVerificationNumberInputContinueButton"
        case .phoneVerificationCodeInputTitle:
            return "phoneVerificationCodeInputTitle"
        case .phoneVerificationCodeInputSubtitle:
            return "phoneVerificationCodeInputSubtitle"
        case .phoneVerificationCodeInputTextfield:
            return "phoneVerificationCodeInputTextfield"
        case .phoneVerificationCodeInputInfoLabel:
            return "phoneVerificationCodeInputInfoLabel"
        case .phoneVerificationCodeInputInfoButton:
            return "phoneVerificationCodeInputInfoButton"
        case .phoneVerificationCountryPickerTable:
            return "phoneVerificationCountryPickerTable"
        case .phoneVerificationCountryPickerSearchBar:
            return "phoneVerificationCountryPickerSearchBar"

        // Verification awareness
        case .verificationAwarenessLabel:
            return "verificationAwarenessLabel"
        case .verificationAwarenessAvatar:
            return "verificationAwarenessAvatar"
        case .verificationAwarenessButton:
            return "verificationAwarenessButton"
        case .verificationAwarenessLaterButton:
            return "verificationAwarenessLaterButton"

        // Settings
        case .settingsList:
            return "settingsList"
        case .settingsLogoutAlertCancel:
            return "settingsLogoutAlertCancel"
        case .settingsLogoutAlertOK:
            return "settingsLogoutAlertOK"
            
        // SettingsCell
        case .settingsCellIcon:
            return "settingsCellIcon"
        case .settingsCellTitle:
            return "settingsCellTitle"
        case .settingsCellValue:
            return "settingsCellValue"
        case .settingsCellSwitch:
            return "settingsCellSwitch"
            
        // NotificationSettings
        case .notificationSettingsTableView:
            return "notificationSettingsTableView"
        
        // NotificationSettingsCell
        case .notificationSettingsCellTitle:
            return "notificationSettingsCellTitle"
        case .notificationSettingsCellSwitch:
            return "notificationSettingsCellSwitch"
            
        // ChangeUsername
        case .changeUsernameNameField:
            return "changeUsernameNameField"
        case .changeUsernameSendButton:
            return "changeUsernameSendButton"
            
        // ChangeEmail
        case .changeEmailCurrentEmailLabel:
            return "changeEmailCurrentEmailLabel"
        case .changeEmailTextField:
            return "changeEmailTextField"
        case .changeEmailSendButton:
            return "changeEmailSendButton"
            
        // ChangePassword
        case .changePasswordPwdTextfield:
            return "changePasswordPwdTextfield"
        case .changePasswordPwdConfirmTextfield:
            return "changePasswordPwdConfirmTextfield"
        case .changePasswordSendButton:
            return "changePasswordSendButton"
            
        // EditLocation
        case .editLocationMap:
            return "editLocationMap"
        case .editLocationSearchButton:
            return "editLocationSearchButton"
        case .editLocationSearchTextField:
            return "editLocationSearchTextField"
        case .editLocationSearchSuggestionsTable:
            return "editLocationSearchSuggestionsTable"
        case .editLocationSensorLocationButton:
            return "editLocationSensorLocationButton"
        case .editLocationApproxLocationCircleView:
            return "editLocationApproxLocationCircleView"
        case .editLocationPOIImageView:
            return "editLocationPOIImageView"
        case .editLocationSetLocationButton:
            return "editLocationSetLocationButton"
        case .editLocationApproxLocationSwitch:
            return "editLocationApproxLocationSwitch"
            
        // Express chat
        case .expressChatCloseButton:
            return "expressChatCloseButton"
        case .expressChatCollection:
            return "expressChatCollection"
        case .expressChatSendButton:
            return "expressChatSendButton"
        case .expressChatDontAskButton:
            return "expressChatDontAskButton"
        case .expressChatMoreOptionsButton:
            return "expressChatMoreOptionsButton"
            
        // Express chat cell
        case .expressChatCell:
            return "expressChatCell"
        case .expressChatCellListingTitle:
            return "expressChatCellListingTitle"
        case .expressChatCellListingPrice:
            return "expressChatCellListingPrice"
        case .expressChatCellTickSelected:
            return "expressChatCellTickSelected"
            
        // Chat Banner
        case .chatBannerActionButton:
            return "chatBannerActionButton"
        case .chatBannerCloseButton:
            return "chatBannerCloseButton"
        // ExpressChatBanner
        case .expressChatBanner:
            return "expressChatBanner"
        // ProfessionalSellerChatBanner
        case .professionalSellerChatBanner:
            return "professionalSellerChatBanner"
            
        // Pop-up alert.
        case .acceptPopUpButton:
            return "acceptPopUpButton"
            
        // Bubble notifications
        case .bubbleButton:
            return "bubbleButton"

        // Meeting creation
        case .meetingCreationView:
            return "meetingCreationView"
        case .meetingCreationPlaceHeaderLabel:
            return "meetingCreationPlaceHeaderLabel"
        case .meetingCreationdateTimeHeaderLabel:
            return "meetingCreationdateTimeHeaderLabel"
        case .meetingCreationLocationLabel:
            return "meetingCreationLocationLabel"
        case .meetingCreationSuggestedLocationsCollection:
            return "meetingCreationSuggestedLocationsCollection"
        case .meetingCreationSelectDayLabel:
            return "meetingCreationSelectDayLabel"
        case .meetingCreationSendMeetingButton:
            return "meetingCreationSendMeetingButton"

        // Meeting creation tips
        case .meetingCreationTipsView:
            return "meetingCreationTipsView"
        case .meetingCreationTipsCloseButton:
            return "meetingCreationTipsCloseButton"
        case .meetingCreationTipsImageView:
            return "meetingCreationTipsImageView"
        case .meetingCreationTipsTitleLabel:
            return "meetingCreationTipsTitleLabel"
        case .meetingCreationTipsSubtitleLabel:
            return "meetingCreationTipsSubtitleLabel"
        case .meetingCreationTipsSendMeetingButton:
            return "meetingCreationTipsSendMeetingButton"
        case .meetingCreationTipsSecondaryCloseButton:
            return "meetingCreationTipsSecondaryCloseButton"


        // Monetization
            
        // Bump Up Banner
        case .bumpUpBanner:
            return "bumpUpBanner"
        case .bumpUpBannerButton:
            return "bumpUpBannerButton"
        case .bumpUpBannerLabel:
            return "bumpUpBannerLabel"

        // Boost Timer View
        case .boostTitleLabel:
            return "boostTitleLabel"
        case .boostTimeLabel:
            return "boostTimeLabel"
        case .boostProgressBar:
            return "boostProgressBar"

        // Payment bump up screen
        case .paymentBumpUpCloseButton:
            return "paymentBumpUpCloseButton"
        case .paymentBumpUpImage:
            return "paymentBumpUpImage"
        case .paymentBumpUpTitleLabel:
            return "paymentBumpUpTitleLabel"
        case .paymentBumpUpSubtitleLabel:
            return "paymentBumpUpSubtitleLabel"
        case .paymentBumpUpButton:
            return "paymentBumpUpButton"

        // Multi day bump up screen
        case .multiDayBumpCloseButton:
            return "multiDayBumpCloseButton"
        case .multiDayBumpTitleLabel:
            return "multiDayBumpTitleLabel"
        case .multiDayBump1DayItem:
            return "multiDayBump1DayItem"
        case .multiDayBump3DaysItem:
            return "multiDayBump3DaysItem"
        case .multiDayBump7DaysItem:
            return "multiDayBump7DaysItem"

        case .multiDayBumpItemTitleLabel:
            return "multiDayBumpItemTitleLabel"
        case .multiDayBumpItemDaysTag:
            return "multiDayBumpItemDaysTag"
        case .multiDayBumpItemSubtitleLabel:
            return "multiDayBumpItemSubtitleLabel"
        case .multiDayBumpItemListingImage:
            return "multiDayBumpItemListingImage"
        case .multiDayBumpItemButton:
            return "multiDayBumpItemButton"

        // Multi day info bump up screen
        case .multiDayBumpInfoCloseButton:
            return "multiDayBumpInfoCloseButton"
        case .multiDayBumpInfoTimerBar:
            return "multiDayBumpInfoTimerBar"
        case .multiDayBumpInfo1DayItem:
            return "multiDayBumpInfo1DayItem"
        case .multiDayBumpInfo3DaysItem:
            return "multiDayBumpInfo3DaysItem"
        case .multiDayBumpInfo7DaysItem:
            return "multiDayBumpInfo7DaysItem"

        // Bump up boost screen

        case .boostViewTimer:
            return "boostViewTimer"
        case .boostViewCloseButton:
            return "boostViewCloseButton"
        case .boostViewImage:
            return "boostViewImage"
        case .boostViewTitleLabel:
            return "boostViewTitleLabel"
        case .boostViewSubtitleLabel:
            return "boostViewSubtitleLabel"
        case .boostViewButton:
            return "boostViewButton"
        case .boostSucceededAlert:
            return "boostSucceededAlert"
        case .boostSuccededAlertLabel:
            return "boostSuccededAlertLabel"
        case .boostSuccededAlertAnimationView:
            return "boostSuccededAlertAnimationView"

        // Bump Up Hidden Alert
        case .bumpUpHiddenListingAlertContactButton:
            return "bumpUpHiddenListingAlertContactButton"
        case .bumpUpHiddenListingAlertCancelButton:
            return "bumpUpHiddenListingAlertCancelButton"

        // Offensive Report Alert
        case .offensiveReportAlertOpenGuidelineButton:
            return "offensiveReportAlertOpenGuidelineButton"
        case .offensiveReportAlertSkipButton:
            return "offensiveReportAlertSkipButton"

        // ExpandableSelectionCategoryView
        case .expandableCategorySelectionCloseButton:
            return "expandableCategorySelectionCloseButton"
        case .expandableCategorySelectionView:
            return "expandableCategorySelectionView"
        case .expandableCategorySelectionButton:
            return "expandableCategorySelectionButton"
            
        // Featured Info View
        case .featuredInfoCloseButton:
            return "featuredInfoCloseButton"
            
        // Promote Bump Up view
        case .promoteBumpUpView:
            return "promoteBumpUpView"
        case .promoteBumpUpTitle:
            return "promoteBumpUpTitle"
        case .promoteBumpUpSellFasterButton:
            return "promoteBumpUpSellFasterButton"
        case .promoteBumpUpLaterButton:
            return "promoteBumpUpLaterButton"
            
        // Professional Dealers Ask for phone number
        case .askPhoneNumberView:
            return "askPhoneNumberView"
        case .askPhoneNumberCloseButton:
            return "askPhoneNumberCloseButton"
        case .askPhoneNumberNotNowButton:
            return "askPhoneNumberNotNowButton"
        case .askPhoneNumberIntroText:
            return "askPhoneNumberIntroText"
        case .askPhoneNumberLetstalkText:
            return "askPhoneNumberLetstalkText"
        case .askPhoneNumberTextfield:
            return "askPhoneNumberTextfield"
        case .askPhoneNumberSendPhoneButton:
            return "askPhoneNumberSendPhoneButton"
            
            //  MARK: Verticals
        case .promoCell:
            return "promoCell"
        case .promoCellTitle:
            return "promoCellTitle"
        case .promoCellIcon:
            return "promoCellIcon"
        case .promoCellPostNowButton:
            return "promoCellPostNowButton"
        // Search Alerts Placeholder
        case .searchAlertsPlaceholderIcon:
            return "searchAlertsPlaceholderIcon"
        case .searchAlertsPlaceholderText:
            return "searchAlertsPlaceholderText"
        case .searchAlertsPlaceholderButton:
            return "searchAlertsPlaceholderButton"
        // Letgo Tooltip
        case .letgoTooltipButton:
            return "letgoTooltipButton"
        case .letgoTooltipText:
            return "letgoTooltipText"
            
            
        // DropdownTableView
        case .dropdownViewControllerTableView:
            return "dropdownViewControllerTableView"
        case .dropdownViewControllerSearchBar:
            return "dropdownViewControllerSearchBar"
        case .dropdownViewControllerApplyButton:
            return "dropdownViewControllerApplyButton"
        case .dropdownViewControllerResetButton:
            return "dropdownViewControllerResetButton"

        // Post Another Listing
        case .postAnotherListingCloseButton:
            return "postAnotherListingCloseButton"
        case .postAnotherListingTitleLabel:
            return "postAnotherListingTitleLabel"
        case .postAnotherListingDescriptionLabel:
            return "postAnotherListingDescriptionLabel"
        case .postAnotherListingPostButton:
            return "postAnotherListingPostButton"
        }
    }
    
    static func rangeIdentifier(forRange range: AccessibilityRange,
                                identifierPrefix: String) -> String {
        return "\(identifierPrefix)-\(range.lowerBound)_\(range.upperBound)"
    }
}

struct AccessibilityRange {
    
    let lowerBound: String
    let upperBound: String
    
    init(withLowerBound lowerBound: CustomStringConvertible?,
         upperBound: CustomStringConvertible?) {
        self.lowerBound = lowerBound?.description ?? ""
        self.upperBound = upperBound?.description ?? ""
    }
}

extension UIAccessibilityIdentification {
    func set(accessibilityId: AccessibilityId?) {
        accessibilityIdentifier = accessibilityId?.identifier
    }
}

extension NSObject {
    var accessibilityInspectionEnabled: Bool {
        get { return !accessibilityElementsHidden }
        set { accessibilityElementsHidden = !accessibilityInspectionEnabled }
    }
}
