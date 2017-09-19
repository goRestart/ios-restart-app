//
//  AccessibilityId.swift
//  LetGo
//
//  Created by Albert Hernández López on 23/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

/**
 Defines the accessibility identifiers used for automated UI testing. The format is the following:
    case <screen><element-name>
 
 i.e:
    case SignUpLoginEmailButton
 */
enum AccessibilityId: String {
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
    case listingCell
    case listingCellThumbnailImageView
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

    // Filter Tags VC
    case filterTagsCollectionView
    case filterTagCell
    case filterTagCellTagIcon
    case filterTagCellTagLabel
    
    // Taxonomies
    case taxonomiesTableView
    
    // Taxonomies Onboarding
    case tourCategoriesTitleLabel
    case tourCategoriesTitleOkButton
    case tourCategoriesCollectionViewCell
    case tourCategoriesCollectionViewCellTitle
    case tourCategoriesCollectionViewCellImage
    case tourCategoriesCollectionViewCellSelectedIcon
    
    // CategoriesHeader Cells
    case categoriesHeaderCollectionView
    case categoryHeaderCell
    case categoryHeaderCellCategoryIcon
    case categoryHeaderCellCategoryTitle

    // SuggestionSearchCell
    case suggestionSearchCell
    case suggestionSearchCellSuggestionText

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

    case filterPriceCell
    case filterPriceCellTitleLabel
    case filterPriceCellTextField
    case filterPriceCellTitleLabelFrom
    case filterPriceCellTitleLabelTo
    case filterPriceCellTextFieldFrom
    case filterPriceCellTextFieldTo
    
    case filterFreeCell
    case filterFreeCellTitleLabel

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

    case listingCarouselNavBarEditButton
    case listingCarouselNavBarShareButton
    case listingCarouselNavBarActionsButton
    case listingCarouselNavBarFavoriteButton

    case listingCarouselMoreInfoScrollView
    case listingCarouselMoreInfoTitleLabel
    case listingCarouselMoreInfoTransTitleLabel
    case listingCarouselMoreInfoAddressLabel
    case listingCarouselMoreInfoDistanceLabel
    case listingCarouselMoreInfoMapView
    case listingCarouselMoreInfoSocialShareTitleLabel
    case listingCarouselMoreInfoSocialShareView
    case listingCarouselMoreInfoDescriptionLabel


    // listing Carousel Cell
    case listingCarouselCell
    case listingCarouselCellCollectionView
    case listingCarouselCellPlaceholderImage
    case listingCarouselImageCell
    case listingCarouselImageCellImageView

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
    case notificationsModularThumbnailView1
    case notificationsModularThumbnailView2
    case notificationsModularThumbnailView3
    case notificationsModularThumbnailView4
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
    case postingPhotoButton
    case postingLoading
    case postingRetryButton
    case postingDoneButton
    case postingCurrencyLabel
    case postingTitleField
    case postingPriceField
    case postingDescriptionField
    case postingBackButton
    case postingInfoCloseButton
    case postingInfoShareButton
    case postingInfoLoading
    case postingInfoEditButton
    case postingInfoMainButton
    case postingInfoIncentiveContainer
    case postingCategorySelectionCarsButton
    case postingCategorySelectionMotorsAndAccessoriesButton
    case postingCategorySelectionOtherButton
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
    case conversationCellContainer
    case conversationCellUserLabel
    case conversationCellListingLabel
    case conversationCellTimeLabel
    case conversationCellBadgeLabel
    case conversationCellThumbnailImageView
    case conversationCellAvatarImageView
    case conversationCellStatusImageView

    // BlockedUserCell
    case blockedUserCellAvatarImageView
    case blockedUserCellUserNameLabel
    case blockedUserCellBlockedLabel
    case blockedUserCellBlockedIcon

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

    // DirectAnswers
    case directAnswersPresenterCollectionView

    // ChatCell
    case chatCellMessageLabel
    case chatCellDateLabel

    // ChatStickerCell
    case chatStickerCellLeftImage
    case chatStickerCellRightImage

    // ChatDisclaimerCell
    case chatDisclaimerCellMessageLabel
    case chatDisclaimerCellButton

    // ChatOtherInfoCell
    case chatOtherInfoCellNameLabel
    case chatOtherInfoCell

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
    case userHeaderExpandedAvatarButton
    case userHeaderExpandedRatingsButton
    case userHeaderExpandedRelationLabel
    case userHeaderExpandedVerifyFacebookButton
    case userHeaderExpandedVerifyGoogleButton
    case userHeaderExpandedVerifyEmailButton
    case userHeaderExpandedBuildTrustButton
    case userEnableNotificationsButton
    case userSellingTab
    case userSoldTab
    case userFavoritesTab
    case userListingsFirstLoad
    case userListingsList
    case userListingsError
    case userPushPermissionOK
    case userPushPermissionCancel

    // Verify Accounts popup
    case verifyAccountsBackgroundButton
    case verifyAccountsFacebookButton
    case verifyAccountsGoogleButton
    case verifyAccountsEmailButton
    case verifyAccountsEmailTextField
    case verifyAccountsEmailTextFieldButton

    // Settings
    case settingsList
    case settingsLogoutAlertCancel
    case settingsLogoutAlertOK

    // SettingsCell
    case settingsCellIcon
    case settingsCellTitle
    case settingsCellValue
    case settingsCellSwitch

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

    // Help
    case helpWebView

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

    // NPS Survey
    case npsCloseButton
    case npsScore1
    case npsScore2
    case npsScore3
    case npsScore4
    case npsScore5
    case npsScore6
    case npsScore7
    case npsScore8
    case npsScore9
    case npsScore10

    // Express chat
    case expressChatCloseButton
    case expressChatCollection
    case expressChatSendButton
    case expressChatDontAskButton

    // Express chat cell
    case expressChatCell
    case expressChatCellListingTitle
    case expressChatCellListingPrice
    case expressChatCellTickSelected

    // ExpressChatBanner
    case expressChatBanner
    case expressChatBannerActionButton
    case expressChatBannerCloseButton
    
    // Pop-up alert. 
    case acceptPopUpButton
    
    // Bubble notifications
    case bubbleButton

    // Monetization

    // Bubble
    case bumpUpBanner
    case bumpUpBannerButton
    case bumpUpBannerLabel

    // Free bump up screen
    case freeBumpUpCloseButton
    case freeBumpUpImage
    case freeBumpUpTitleLabel
    case freeBumpUpSubtitleLabel
    case freeBumpUpSocialShareView

    // Payment bump up screen
    case paymentBumpUpCloseButton
    case paymentBumpUpImage
    case paymentBumpUpTitleLabel
    case paymentBumpUpSubtitleLabel
    case paymentBumpUpButton

    // Bump Up Hidden Alert
    case bumpUpHiddenListingAlertContactButton
    case bumpUpHiddenListingAlertCancelButton
    
    
    // ExpandableSelectionCategoryView
    case expandableCategorySelectionCloseButton
    case expandableCategorySelectionView
    case expandableCategorySelectionButton
}

extension UIAccessibilityIdentification {
    var accessibilityId: AccessibilityId? {
        get {
            guard let accessibilityIdentifier = accessibilityIdentifier else { return nil }
            return AccessibilityId(rawValue: accessibilityIdentifier)
        }
        set {
            accessibilityIdentifier = newValue?.rawValue
        }
    }
}
