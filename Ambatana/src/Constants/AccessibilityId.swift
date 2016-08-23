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

    case AlertMainButton
    case AlertSecondaryButton
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


    /** ABIOS-1556 */
    // ...

    /** ABIOS-1557 */
    // ...
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
