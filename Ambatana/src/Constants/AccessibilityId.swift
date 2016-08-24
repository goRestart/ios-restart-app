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
    case EraseMe

    /** ABIOS-1554 */
    // ...

    /** ABIOS-1555 */
    // ...
    case NotificationsRefresh
    case NotificationsTable
    case NotificationsLoading
    case NotificationsEmptyView
    case NotificationsCellPrimaryImage
    case NotificationsCellSecondaryImage

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

    case ReportUserCollection
    case ReportUserCommentField
    case ReportUserSendButton

    case RateUserUserNameLabel
    case RateUserStarButton1
    case RateUserStarButton2
    case RateUserStarButton3
    case RateUserStarButton4
    case RateUserStarButton5
    case RateUserDescriptionField
    case RateUserLoading
    case RateUserPublishButton
    case RatingListTable
    case RatingListLoading
    case RatingListCellUserName
    case RatingListCellReport
    case RatingListCellReview

    case AppRatingStarButton1
    case AppRatingStarButton2
    case AppRatingStarButton3
    case AppRatingStarButton4
    case AppRatingStarButton5
    case AppRatingBgButton
    case AppRatingDismissButton
    case AppRatingBannerCloseButton
    case AppRatingBannerRateButton
    case SafetyTipsOkButton
    case EmptyViewPrimaryButton
    case EmptyViewSecondaryButton
    case SocialShareFacebook
    case SocialShareFBMessenger
    case SocialShareEmail
    case SocialShareWhatsapp
    case SocialShareTwitter
    case SocialShareTelegram
    case SocialShareCopyLink
    case SocialShareSMS


    /** ABIOS-1556 */
    // ...

    /** ABIOS-1557 */
    // TourLogin
    case TourLoginCloseButton
    case TourLoginSignUpButton
    case TourLoginLogInButton
    case TourLoginSkipButton

    // TourNotifications
    case TourNotificationsCloseButton
    case TourNotificationsOKButton
    case TourNotificationsCancelButton

    // TourLocation
    case TourLocationCloseButton
    case TourLocationOKButton
    case TourLocationCancelButton

    // User
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
    case UserEnableNotificationsButton
    case UserSellingTab
    case UserSoldTab
    case UserFavoritesTab
    case UserProductsFirstLoad
    case UserProductsList
    case UserProductsError
    case UserPushPermissionOK
    case UserPushPermissionCancel

    // Settings
    case SettingsList

    // SettingsCell
    case SettingsCellIcon
    case SettingsCellTitle
    case SettingsCellValue

    // ChangeUsername
    case ChangeUsernameNameTextfield
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
