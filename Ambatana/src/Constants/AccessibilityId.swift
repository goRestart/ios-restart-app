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
    case ProductCellPriceLabel
    case ProductCellThumbnailImageView
    case ProductCellLikeButton
    case ProductCellShareButton
    case ProductCellChatButton
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
    case CategoriesActivityIndicator
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
