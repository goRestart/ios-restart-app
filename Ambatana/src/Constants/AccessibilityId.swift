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
    case TabBarFirstTab
    case TabBarSecondTab
    case TabBarThirdTab
    case TabBarFourthTab
    case TabBarFifthTab
    case TabBarFloatingSellButton

    // Main Products List
    case MainProductsNavBarSearch
    case MainProductsFilterButton
    case MainProductsInviteButton
    case MainProductsListView
    case MainProductsTagsCollection
    case MainProductsInfoBubbleLabel
    case MainProductsTrendingSearchesTable

    // Product List View
    case ProductListViewFirstLoadView
    case ProductListViewFirstLoadActivityIndicator
    case ProductListViewCollection
    case ProductListViewErrorView
    case ProductListErrorImageView
    case ProductListErrorTitleLabel
    case ProductListErrorBodyLabel
    case ProductListErrorButton

    // Product Cell
    case ProductCell
    case ProductCellThumbnailImageView
    case ProductCellStripeImageView
    case ProductCellStripeLabel
    case ProductCellStripeIcon

    // Collection & Banner Cells
    case CollectionCell
    case CollectionCellImageView
    case CollectionCellTitle
    case CollectionCellExploreButton

    case BannerCell
    case BannerCellImageView
    case BannerCellTitle

    // Filter Tags VC
    case FilterTagsCollectionView
    case FilterTagCell
    case FilterTagCellTagIcon
    case FilterTagCellTagLabel

    // TrendingSearchCell
    case TrendingSearchCell
    case TrendingSearchCellTrendingText

    // Categories
    case CategoriesCollectionView
    case CategoryCell
    case CategoryCellTitleLabel
    case CategoryCellImageView

    // Filters
    case FiltersCollectionView
    case FiltersSaveFiltersButton
    case FiltersCancelButton
    case FiltersResetButton

    // Filters Cells
    case FilterCategoryCell
    case FilterCategoryCellIcon
    case FilterCategoryCellTitleLabel

    case FilterSingleCheckCell
    case FilterSingleCheckCellTickIcon
    case FilterSingleCheckCellTitleLabel

    case FilterDistanceCell
    case FilterDistanceSlider
    case FilterDistanceTip
    case FilterDistanceLabel

    case FilterHeaderCell
    case FilterHeaderCellTitleLabel

    case FilterLocationCell
    case FilterLocationCellTitleLabel
    case FilterLocationCellLocationLabel

    case FilterPriceCell
    case FilterPriceCellTitleLabel
    case FilterPriceCellTextField

    // Product Detail
    case ProductDetailOnboarding

    // Product Carousel
    case ProductCarouselCollectionView
    case ProductCarouselButtonBottom
    case ProductCarouselButtonTop
    case ProductCarouselFavoriteButton
    case ProductCarouselMoreInfoView
    case ProductCarouselProductStatusLabel
    case ProductCarouselDirectChatTable
    case ProductCarouselStickersButton
    case ProductCarouselFullScreenAvatarView
    case ProductCarouselPageControl

    case ProductCarouselNavBarEditButton
    case ProductCarouselNavBarShareButton
    case ProductCarouselNavBarActionsButton
    case ProductCarouselNavBarFavoriteButton

    case ProductCarouselMoreInfoScrollView
    case ProductCarouselMoreInfoTitleLabel
    case ProductCarouselMoreInfoTransTitleLabel
    case ProductCarouselMoreInfoAddressLabel
    case ProductCarouselMoreInfoDistanceLabel
    case ProductCarouselMoreInfoMapView
    case ProductCarouselMoreInfoSocialShareTitleLabel
    case ProductCarouselMoreInfoSocialShareView
    case ProductCarouselMoreInfoDescriptionLabel

    // Product Carousel Cell
    case ProductCarouselCell
    case ProductCarouselCellCollectionView
    case ProductCarouselCellPlaceholderImage
    case ProductCarouselImageCell
    case ProductCarouselImageCellImageView

    // Notifications
    case NotificationsRefresh
    case NotificationsTable
    case NotificationsLoading
    case NotificationsEmptyView
    case NotificationsCellPrimaryImage
    case NotificationsCellSecondaryImage

    // Posting
    case PostingCameraImagePreview
    case PostingCameraSwitchCamButton
    case PostingCameraUsePhotoButton
    case PostingCameraInfoScreenButton
    case PostingCameraFlashButton
    case PostingCameraRetryPhotoButton
    case PostingCameraFirstTimeAlert
    case PostingCameraCloseButton
    case PostingGalleryLoading
    case PostingGalleryCollection
    case PostingGalleryAlbumButton
    case PostingGalleryUsePhotoButton
    case PostingGalleryInfoScreenButton
    case PostingGalleryImageContainer
    case PostingGalleryCloseButton
    case PostingCloseButton
    case PostingGalleryButton
    case PostingPhotoButton
    case PostingLoading
    case PostingRetryButton
    case PostingDoneButton
    case PostingCurrencyButton
    case PostingTitleField
    case PostingPriceField
    case PostingDescriptionField
    case PostingBackButton
    case PostingInfoCloseButton
    case PostingInfoShareButton
    case PostingInfoLoading
    case PostingInfoEditButton
    case PostingInfoMainButton
    case PostingInfoIncentiveContainer

    // EditProduct
    case EditProductCloseButton
    case EditProductScroll
    case EditProductTitleField
    case EditProductAutoGenTitleButton
    case EditProductImageCollection
    case EditProductCurrencyButton
    case EditProductPriceField
    case EditProductDescriptionField
    case EditProductLocationButton
    case EditProductCategoryButton
    case EditProductSendButton
    case EditProductShareFBSwitch
    case EditProductLoadingView

    // ReportUser
    case ReportUserCollection
    case ReportUserCommentField
    case ReportUserSendButton

    // RateUser
    case RateUserUserNameLabel
    case RateUserStarButton1
    case RateUserStarButton2
    case RateUserStarButton3
    case RateUserStarButton4
    case RateUserStarButton5
    case RateUserDescriptionField
    case RateUserLoading
    case RateUserPublishButton

    // RatingList
    case RatingListTable
    case RatingListLoading
    case RatingListCellUserName
    case RatingListCellReport
    case RatingListCellReview

    // AppRating
    case AppRatingStarButton1
    case AppRatingStarButton2
    case AppRatingStarButton3
    case AppRatingStarButton4
    case AppRatingStarButton5
    case AppRatingBgButton
    case AppRatingDismissButton
    case AppRatingBannerCloseButton
    case AppRatingBannerRateButton

    // SafetyTips
    case SafetyTipsOkButton

    // EmptyView
    case EmptyViewPrimaryButton
    case EmptyViewSecondaryButton

    // SocialShare
    case SocialShareFacebook
    case SocialShareFBMessenger
    case SocialShareEmail
    case SocialShareWhatsapp
    case SocialShareTwitter
    case SocialShareTelegram
    case SocialShareCopyLink
    case SocialShareSMS

    // MainSignUp
    case MainSignUpFacebookButton
    case MainSignUpGoogleButton
    case MainSignUpSignupButton
    case MainSignupLogInButton
    case MainSignupCloseButton
    case MainSignupHelpButton

    // SignUpLogin
    case SignUpLoginFacebookButton
    case SignUpLoginGoogleButton
    case SignUpLoginEmailButton
    case SignUpLoginEmailTextField
    case SignUpLoginPasswordButton
    case SignUpLoginPasswordTextField
    case SignUpLoginUserNameButton
    case SignUpLoginUserNameTextField
    case SignUpLoginShowPasswordButton
    case SignUpLoginForgotPasswordButton
    case SignUpLoginSegmentedControl
    case SignUpLoginHelpButton
    case SignUpLoginCloseButton
    case SignUpLoginSendButton

    // ChatGrouped
    case ChatGroupedViewRightNavBarButton

    // ChatList
    case ChatListViewTabAll
    case ChatListViewTabSelling
    case ChatListViewTabBuying
    case ChatListViewTabBlockedUsers

    case ChatListViewFooterButton
    case ChatListViewTabAllTableView
    case ChatListViewTabSellingTableView
    case ChatListViewTabBuyingTableView
    case ChatListViewTabBlockedUsersTableView

    // ConversationCell
    case ConversationCellUserLabel
    case ConversationCellProductLabel
    case ConversationCellTimeLabel
    case ConversationCellBadgeLabel
    case ConversationCellThumbnailImageView
    case ConversationCellAvatarImageView
    case ConversationCellStatusImageView

    // BlockedUserCell
    case BlockedUserCellAvatarImageView
    case BlockedUserCellUserNameLabel
    case BlockedUserCellBlockedLabel
    case BlockedUserCellBlockedIcon

    // ChatProductView
    case ChatProductViewUserAvatar
    case ChatProductViewUserNameLabel
    case ChatProductViewProductNameLabel
    case ChatProductViewProductPriceLabel
    case ChatProductViewProductButton
    case ChatProductViewUserButton
    case ChatProductViewReviewButton

    // Chat
    case ChatViewTableView
    case ChatViewMoreOptionsButton
    case ChatViewBackButton
    case ChatViewStickersButton
    case ChatViewSendButton
    case ChatViewCloseStickersButton
    case ChatViewTextInputBar

    // DirectAnswers
    case DirectAnswersPresenterCollectionView

    // ChatCell
    case ChatCellMessageLabel
    case ChatCellDateLabel

    // ChatStickerCell
    case ChatStickerCellLeftImage
    case ChatStickerCellRightImage

    // ChatDisclaimerCell
    case ChatDisclaimerCellMessageLabel
    case ChatDisclaimerCellButton

    // ChatOtherInfoCell
    case ChatOtherInfoCellNameLabel
    case ChatOtherInfoCell

    // TourLogin
    case TourLoginCloseButton
    case TourLoginSignUpButton
    case TourLoginLogInButton
    case TourLoginSkipButton

    // TourNotifications
    case TourNotificationsCloseButton
    case TourNotificationsOKButton
    case TourNotificationsCancelButton
    case TourNotificationsAlert

    // TourLocation
    case TourLocationCloseButton
    case TourLocationOKButton
    case TourLocationCancelButton
    case TourLocationAlert

    // User
    case UserNavBarShareButton
    case UserNavBarSettingsButton
    case UserNavBarMoreButton
    case UserHeaderCollapsedNameLabel
    case UserHeaderCollapsedLocationLabel
    case UserHeaderExpandedNameLabel
    case UserHeaderExpandedLocationLabel
    case UserHeaderExpandedAvatarButton
    case UserHeaderExpandedRatingsButton
    case UserHeaderExpandedRelationLabel
    case UserHeaderExpandedVerifyFacebookButton
    case UserHeaderExpandedVerifyGoogleButton
    case UserHeaderExpandedVerifyEmailButton
    case UserHeaderExpandedBuildTrustButton
    case UserEnableNotificationsButton
    case UserSellingTab
    case UserSoldTab
    case UserFavoritesTab
    case UserProductsFirstLoad
    case UserProductsList
    case UserProductsError
    case UserPushPermissionOK
    case UserPushPermissionCancel

    // Verify Accounts popup
    case VerifyAccountsBackgroundButton
    case VerifyAccountsFacebookButton
    case VerifyAccountsGoogleButton
    case VerifyAccountsEmailButton
    case VerifyAccountsEmailTextField
    case VerifyAccountsEmailTextFieldButton

    // Settings
    case SettingsList

    // SettingsCell
    case SettingsCellIcon
    case SettingsCellTitle
    case SettingsCellValue

    // ChangeUsername
    case ChangeUsernameNameField
    case ChangeUsernameSendButton

    // ChangePassword
    case ChangePasswordPwdTextfield
    case ChangePasswordPwdConfirmTextfield
    case ChangePasswordSendButton

    // Help
    case HelpWebView

    // EditLocation
    case EditLocationMap
    case EditLocationSearchButton
    case EditLocationSearchTextField
    case EditLocationSearchSuggestionsTable
    case EditLocationSensorLocationButton
    case EditLocationApproxLocationCircleView
    case EditLocationPOIImageView
    case EditLocationSetLocationButton
    case EditLocationApproxLocationSwitch
    
    // NPS Survey
    case NPSCloseButton
    case NPSScore1
    case NPSScore2
    case NPSScore3
    case NPSScore4
    case NPSScore5
    case NPSScore6
    case NPSScore7
    case NPSScore8
    case NPSScore9
    case NPSScore10
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
