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

    // Main Products List
    case mainProductsNavBarSearch
    case mainProductsFilterButton
    case mainProductsInviteButton
    case mainProductsListView
    case mainProductsTagsCollection
    case mainProductsInfoBubbleLabel
    case mainProductsSuggestionSearchesTable

    // Passive buyers
    case passiveBuyersTitle
    case passiveBuyersMessage
    case passiveBuyersContactButton
    case passiveBuyersTable
    case passiveBuyerCellName

    // Product List View
    case productListViewFirstLoadView
    case productListViewFirstLoadActivityIndicator
    case productListViewCollection
    case productListViewErrorView
    case productListErrorImageView
    case productListErrorTitleLabel
    case productListErrorBodyLabel
    case productListErrorButton

    // Product Cell
    case productCell
    case productCellThumbnailImageView
    case productCellStripeImageView
    case productCellStripeLabel
    case productCellStripeIcon

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

    case filterLocationCell
    case filterLocationCellTitleLabel
    case filterLocationCellLocationLabel

    case filterPriceCell
    case filterPriceCellTitleLabel
    case filterPriceCellTextField

    // Product Detail
    case productDetailOnboarding

    // Product Carousel
    case productCarouselCollectionView
    case productCarouselButtonBottom
    case productCarouselButtonTop
    case productCarouselFavoriteButton
    case productCarouselMoreInfoView
    case productCarouselProductStatusLabel
    case productCarouselDirectChatTable
    case productCarouselFullScreenAvatarView
    case productCarouselPageControl
    case productCarouselUserView
    case productCarouselChatTextView

    case productCarouselNavBarEditButton
    case productCarouselNavBarShareButton
    case productCarouselNavBarActionsButton
    case productCarouselNavBarFavoriteButton

    case productCarouselMoreInfoScrollView
    case productCarouselMoreInfoTitleLabel
    case productCarouselMoreInfoTransTitleLabel
    case productCarouselMoreInfoAddressLabel
    case productCarouselMoreInfoDistanceLabel
    case productCarouselMoreInfoMapView
    case productCarouselMoreInfoSocialShareTitleLabel
    case productCarouselMoreInfoSocialShareView
    case productCarouselMoreInfoDescriptionLabel


    // Product Carousel Cell
    case productCarouselCell
    case productCarouselCellCollectionView
    case productCarouselCellPlaceholderImage
    case productCarouselImageCell
    case productCarouselImageCellImageView

    // Product Carousel Post Delete screens
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
    case notificationsCellPrimaryImage
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
    case postingFooterPostButton
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

    // EditProduct
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
    case rateUserPublishButton

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
    case conversationCellProductLabel
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

    // ChatProductView
    case chatProductViewUserAvatar
    case chatProductViewUserNameLabel
    case chatProductViewProductNameLabel
    case chatProductViewProductPriceLabel
    case chatProductViewProductButton
    case chatProductViewUserButton
    case chatProductViewReviewButton

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
    case userProductsFirstLoad
    case userProductsList
    case userProductsError
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
    case expressChatCellProductTitle
    case expressChatCellProductPrice
    case expressChatCellTickSelected

    // ExpressChatBanner
    case expressChatBanner
    case expressChatBannerActionButton
    case expressChatBannerCloseButton
    
    // Pop-up alert. 
    case acceptPopUpButton
    
    // Bubble notifications
    case bubbleButton

    // LogInEmail
    case logInEmailScrollView
    case logInEmailEmailButton
    case logInEmailEmailImageView
    case logInEmailEmailTextField
    case logInEmailPasswordButton
    case logInEmailPasswordImageView
    case logInEmailPasswordTextField
    case logInEmailShowPasswordButton
    case logInEmailRememberPasswordButton
    case logInEmailLoginButton
    case logInEmailFooterButton

    // SignUpEmailStep1
    case signUpEmailStep1ScrollView
    case signUpEmailStep1EmailButton
    case signUpEmailStep1EmailImageView
    case signUpEmailStep1EmailTextField
    case signUpEmailStep1PasswordButton
    case signUpEmailStep1PasswordImageView
    case signUpEmailStep1PasswordTextField
    case signUpEmailStep1ShowPasswordButton
    case signUpEmailStep1NextStepButton
    case signUpEmailStep1FooterButton

    // SignUpEmailStep2
    case signUpEmailStep2ScrollView
    case signUpEmailStep2HeaderLabel
    case signUpEmailStep2FullNameButton
    case signUpEmailStep2FullNameImageView
    case signUpEmailStep2FullNameTextField
    case signUpEmailStep2TermsTextView
    case signUpEmailStep2TermsSwitch
    case signUpEmailStep2NewsletterLabel
    case signUpEmailStep2NewsletterSwitch
    case signUpEmailStep2SignUpButton

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
