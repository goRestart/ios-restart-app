// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSImage
  public typealias AssetColorTypeAlias = NSColor
  public typealias Image = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  public typealias AssetColorTypeAlias = UIColor
  public typealias Image = UIImage
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

@available(*, deprecated, renamed: "ImageAsset")
public typealias AssetType = R.ImageAsset

extension R {

  public struct ImageAsset {
    public fileprivate(set) var name: String

    public var image: Image {
      #if os(iOS) || os(tvOS)
      let image = Image(named: name, in: R.bundle, compatibleWith: nil)
      #elseif os(OSX)
      let image = bundle.image(forResource: NSImage.Name(name))
      #elseif os(watchOS)
      let image = Image(named: name)
      #endif
      guard let result = image else { fatalError("Unable to load image named \(name).") }
      return result
    }
  }

  public struct ColorAsset {
    public fileprivate(set) var name: String

    @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
    public var color: AssetColorTypeAlias {
      return AssetColorTypeAlias(asset: self)
    }
  }

  // swiftlint:disable identifier_name line_length nesting type_body_length type_name
  public enum Asset {
    public enum Affiliation {
      public enum Error {
        public static let errorFeatureUnavailable = ImageAsset(name: "error_feature_unavailable")
        public static let errorOops = ImageAsset(name: "error_oops")
      }
      public enum Partners {
        public static let amazon = ImageAsset(name: "amazon")
      }
      public static let affiliationIcon = ImageAsset(name: "affiliationIcon")
      public static let chevronRight24 = ImageAsset(name: "chevronRight24")
      public static let icnCheck = ImageAsset(name: "icnCheck")
      public static let icnClockFill24 = ImageAsset(name: "icnClockFill24")
      public static let icnReward24 = ImageAsset(name: "icnReward24")
      public static let icnAffiliationPoints = ImageAsset(name: "icn_affiliation_points")
      public static let icnModalSuccess = ImageAsset(name: "icn_modal_success")
      public static let icnThreeDots = ImageAsset(name: "icn_three_dots")
      public static let iconCheck = ImageAsset(name: "iconCheck")
      public static let materialBackground = ImageAsset(name: "material_background")
      public static let question24 = ImageAsset(name: "question24")
      public static let wallet24 = ImageAsset(name: "wallet24")

      // swiftlint:disable trailing_comma
      public static let allColors: [ColorAsset] = [
      ]
      public static let allImages: [ImageAsset] = [
        Error.errorFeatureUnavailable,
        Error.errorOops,
        Partners.amazon,
        affiliationIcon,
        chevronRight24,
        icnCheck,
        icnClockFill24,
        icnReward24,
        icnAffiliationPoints,
        icnModalSuccess,
        icnThreeDots,
        iconCheck,
        materialBackground,
        question24,
        wallet24,
      ]
      // swiftlint:enable trailing_comma
      @available(*, deprecated, renamed: "allImages")
      public static let allValues: [AssetType] = allImages
    }
    public enum BackgroundsAndImages {
      public static let affStoreBackground = ImageAsset(name: "aff_store_background")
      public static let bg1New = ImageAsset(name: "bg_1_new")
      public static let bg2New = ImageAsset(name: "bg_2_new")
      public static let bg3New = ImageAsset(name: "bg_3_new")
      public static let bg4New = ImageAsset(name: "bg_4_new")
      public static let emojiCongrats = ImageAsset(name: "emoji_congrats")
      public static let icAlert = ImageAsset(name: "ic_alert")
      public static let icAlertGray = ImageAsset(name: "ic_alert_gray")
      public static let icAlertYellowWhiteInside = ImageAsset(name: "ic_alert_yellow_white_inside")
      public static let icBlocked = ImageAsset(name: "ic_blocked")
      public static let icBlockedWhite = ImageAsset(name: "ic_blocked_white")
      public static let icBlockedWhiteLine = ImageAsset(name: "ic_blocked_white_line")
      public static let icDollarSold = ImageAsset(name: "ic_dollar_sold")
      public static let icSoldWhite = ImageAsset(name: "ic_sold_white")
      public static let inviteLetgo = ImageAsset(name: "invite_letgo")
      public static let itemLocation = ImageAsset(name: "itemLocation")
      public static let logoBig = ImageAsset(name: "logo-big")
      public static let logoOnboarding = ImageAsset(name: "logo_onboarding")
      public static let navbarLogo = ImageAsset(name: "navbar_logo")
      public static let notificationBasicImageRoundPlaceholder = ImageAsset(name: "notificationBasicImageRoundPlaceholder")
      public static let notificationBasicImageSquarePlaceholder = ImageAsset(name: "notificationBasicImageSquarePlaceholder")
      public static let notificationHeroImagePlaceholder = ImageAsset(name: "notificationHeroImagePlaceholder")
      public static let notificationThumbnailCirclePlaceholder = ImageAsset(name: "notificationThumbnailCirclePlaceholder")
      public static let notificationThumbnailSquarePlaceholder = ImageAsset(name: "notificationThumbnailSquarePlaceholder")
      public static let patternRed = ImageAsset(name: "pattern_red")
      public static let patternTransparent = ImageAsset(name: "pattern_transparent")
      public static let patternWhite = ImageAsset(name: "pattern_white")
      public static let settingsNotifications1 = ImageAsset(name: "settings_notifications1")
      public static let settingsNotifications2 = ImageAsset(name: "settings_notifications2")
      public static let stickerError = ImageAsset(name: "sticker_error")
      public static let stripeWhite = ImageAsset(name: "stripe_white")
      public static let tour1 = ImageAsset(name: "tour_1")
      public static let whitePixel = ImageAsset(name: "white_pixel")

      // swiftlint:disable trailing_comma
      public static let allColors: [ColorAsset] = [
      ]
      public static let allImages: [ImageAsset] = [
        affStoreBackground,
        bg1New,
        bg2New,
        bg3New,
        bg4New,
        emojiCongrats,
        icAlert,
        icAlertGray,
        icAlertYellowWhiteInside,
        icBlocked,
        icBlockedWhite,
        icBlockedWhiteLine,
        icDollarSold,
        icSoldWhite,
        inviteLetgo,
        itemLocation,
        logoBig,
        logoOnboarding,
        navbarLogo,
        notificationBasicImageRoundPlaceholder,
        notificationBasicImageSquarePlaceholder,
        notificationHeroImagePlaceholder,
        notificationThumbnailCirclePlaceholder,
        notificationThumbnailSquarePlaceholder,
        patternRed,
        patternTransparent,
        patternWhite,
        settingsNotifications1,
        settingsNotifications2,
        stickerError,
        stripeWhite,
        tour1,
        whitePixel,
      ]
      // swiftlint:enable trailing_comma
      @available(*, deprecated, renamed: "allImages")
      public static let allValues: [AssetType] = allImages
    }
    public enum Chat {
      public static let icCornerBuying = ImageAsset(name: "ic_corner_buying")
      public static let icCornerSelling = ImageAsset(name: "ic_corner_selling")
      public static let icDobleRead = ImageAsset(name: "ic_doble_read")
      public static let icDobleReceived = ImageAsset(name: "ic_doble_received")
      public static let icFilter = ImageAsset(name: "ic_filter")
      public static let icFilterActive = ImageAsset(name: "ic_filter_active")
      public static let icTickSent = ImageAsset(name: "ic_tick_sent")
      public static let icWatch = ImageAsset(name: "ic_watch")

      // swiftlint:disable trailing_comma
      public static let allColors: [ColorAsset] = [
      ]
      public static let allImages: [ImageAsset] = [
        icCornerBuying,
        icCornerSelling,
        icDobleRead,
        icDobleReceived,
        icFilter,
        icFilterActive,
        icTickSent,
        icWatch,
      ]
      // swiftlint:enable trailing_comma
      @available(*, deprecated, renamed: "allImages")
      public static let allValues: [AssetType] = allImages
    }
    public enum ChatNorris {
      public static let icCalendar = ImageAsset(name: "ic_calendar")
      public static let icMeetingTips = ImageAsset(name: "ic_meeting_tips")
      public static let icTime = ImageAsset(name: "ic_time")
      public static let imageMeetingSafetyTips = ImageAsset(name: "image_meeting_safety_tips")
      public static let meetingMapPlaceholder = ImageAsset(name: "meeting_map_placeholder")

      // swiftlint:disable trailing_comma
      public static let allColors: [ColorAsset] = [
      ]
      public static let allImages: [ImageAsset] = [
        icCalendar,
        icMeetingTips,
        icTime,
        imageMeetingSafetyTips,
        meetingMapPlaceholder,
      ]
      // swiftlint:enable trailing_comma
      @available(*, deprecated, renamed: "allImages")
      public static let allValues: [AssetType] = allImages
    }
    public enum CongratsScreenImages {
      public static let bike = ImageAsset(name: "bike")
      public static let cars = ImageAsset(name: "cars")
      public static let cleaning = ImageAsset(name: "cleaning")
      public static let creative = ImageAsset(name: "creative")
      public static let dresser = ImageAsset(name: "dresser")
      public static let furniture = ImageAsset(name: "furniture")
      public static let icCloseRed = ImageAsset(name: "ic_close_red")
      public static let icMagnifier = ImageAsset(name: "ic_magnifier")
      public static let icShareRed = ImageAsset(name: "ic_share_red")
      public static let kidsClothes = ImageAsset(name: "kids_clothes")
      public static let lessons = ImageAsset(name: "lessons")
      public static let motorcycle = ImageAsset(name: "motorcycle")
      public static let ps4 = ImageAsset(name: "ps4")
      public static let toys = ImageAsset(name: "toys")
      public static let tv = ImageAsset(name: "tv")

      // swiftlint:disable trailing_comma
      public static let allColors: [ColorAsset] = [
      ]
      public static let allImages: [ImageAsset] = [
        bike,
        cars,
        cleaning,
        creative,
        dresser,
        furniture,
        icCloseRed,
        icMagnifier,
        icShareRed,
        kidsClothes,
        lessons,
        motorcycle,
        ps4,
        toys,
        tv,
      ]
      // swiftlint:enable trailing_comma
      @available(*, deprecated, renamed: "allImages")
      public static let allValues: [AssetType] = allImages
    }
    public enum Errors {
      public static let errGeneric = ImageAsset(name: "err_generic")
      public static let errListNoBlockedUsers = ImageAsset(name: "err_list_no_blocked_users")
      public static let errListNoChats = ImageAsset(name: "err_list_no_chats")
      public static let errListNoProducts = ImageAsset(name: "err_list_no_products")
      public static let errNetwork = ImageAsset(name: "err_network")
      public static let errSearchNoProducts = ImageAsset(name: "err_search_no_products")

      // swiftlint:disable trailing_comma
      public static let allColors: [ColorAsset] = [
      ]
      public static let allImages: [ImageAsset] = [
        errGeneric,
        errListNoBlockedUsers,
        errListNoChats,
        errListNoProducts,
        errNetwork,
        errSearchNoProducts,
      ]
      // swiftlint:enable trailing_comma
      @available(*, deprecated, renamed: "allImages")
      public static let allValues: [AssetType] = allImages
    }
    public enum Icons {
      public static let icArrowLeft = ImageAsset(name: "ic_arrow_left")
      public static let icPen = ImageAsset(name: "ic_pen")

      // swiftlint:disable trailing_comma
      public static let allColors: [ColorAsset] = [
      ]
      public static let allImages: [ImageAsset] = [
        icArrowLeft,
        icPen,
      ]
      // swiftlint:enable trailing_comma
      @available(*, deprecated, renamed: "allImages")
      public static let allValues: [AssetType] = allImages
    }
    public enum IconsButtons {
      public enum CategoriesHeaderIcons {
        public static let carsFeed = ImageAsset(name: "cars_feed")
        public static let childFeed = ImageAsset(name: "child_feed")
        public static let entretainmentFeed = ImageAsset(name: "entretainment_feed")
        public static let fashionFeed = ImageAsset(name: "fashion_feed")
        public static let freeFeed = ImageAsset(name: "free_feed")
        public static let homeFeed = ImageAsset(name: "home_feed")
        public static let housingFeed = ImageAsset(name: "housing_feed")
        public static let leisureFeed = ImageAsset(name: "leisure_feed")
        public static let motorsFeed = ImageAsset(name: "motors_feed")
        public static let othersFeed = ImageAsset(name: "others_feed")
        public static let servicesFeed = ImageAsset(name: "services_feed")
        public static let techFeed = ImageAsset(name: "tech_feed")
      }
      public enum Community {
        public static let icCommunityBanner = ImageAsset(name: "ic_community_banner")
        public static let shapeBrightblue = ImageAsset(name: "shapeBrightblue")
        public static let shapeDarkblue = ImageAsset(name: "shapeDarkblue")
        public static let shapeYellow = ImageAsset(name: "shapeYellow")
      }
      public enum IAmInterested {
        public static let icIamiSeeconv = ImageAsset(name: "ic_iami_seeconv")
        public static let icIamiSend = ImageAsset(name: "ic_iami_send")
      }
      public enum NewItemPage {
        public static let nitArrowDown = ImageAsset(name: "nit_arrow_down")
        public static let nitFavourite = ImageAsset(name: "nit_favourite")
        public static let nitFavouriteOn = ImageAsset(name: "nit_favourite_on")
        public static let nitLocation = ImageAsset(name: "nit_location")
        public static let nitMore = ImageAsset(name: "nit_more")
        public static let nitOnboarding = ImageAsset(name: "nit_onboarding")
        public static let nitPhotoChat = ImageAsset(name: "nit_photo_chat")
        public static let nitPreviewCount = ImageAsset(name: "nit_preview_count")
        public static let nitShare = ImageAsset(name: "nit_share")
        public static let nitTapGesture = ImageAsset(name: "nit_tap_gesture")
      }
      public enum SearchAlerts {
        public static let icSearchAlertsEmpty = ImageAsset(name: "ic_search_alerts_empty")
        public static let icSearchAlertsError = ImageAsset(name: "ic_search_alerts_error")
      }
      public enum VideoPosting {
        public static let icVideopostingPlay = ImageAsset(name: "ic_videoposting_play")
      }
      public static let carIcon = ImageAsset(name: "carIcon")
      public static let checkboxSelectedRound = ImageAsset(name: "checkbox_selected_round")
      public static let checkboxSelectedRoundGray = ImageAsset(name: "checkbox_selected_round_gray")
      public static let chevronDownGrey = ImageAsset(name: "chevron_down_grey")
      public static let customPermissionProfile = ImageAsset(name: "custom_permission_profile")
      public static let downChevronRed = ImageAsset(name: "down_chevron_red")
      public enum FiltersCarExtrasIcons {
        public enum Bodytype {
          public static let bodyTypeHybrid = ImageAsset(name: "bodyTypeHybrid")
          public static let convertible = ImageAsset(name: "convertible")
          public static let coupe = ImageAsset(name: "coupe")
          public static let hatchback = ImageAsset(name: "hatchback")
          public static let minivan = ImageAsset(name: "minivan")
          public static let other = ImageAsset(name: "other")
          public static let sedan = ImageAsset(name: "sedan")
          public static let suv = ImageAsset(name: "suv")
          public static let truck = ImageAsset(name: "truck")
          public static let wagon = ImageAsset(name: "wagon")
        }
        public enum Drivetrain {
          public static let _4wd = ImageAsset(name: "4wd")
          public static let awd = ImageAsset(name: "awd")
          public static let fwd = ImageAsset(name: "fwd")
          public static let rwd = ImageAsset(name: "rwd")
        }
        public enum Fueltype {
          public static let diesel = ImageAsset(name: "diesel")
          public static let electric = ImageAsset(name: "electric")
          public static let flex = ImageAsset(name: "flex")
          public static let fuelTypeHybrid = ImageAsset(name: "fuelTypeHybrid")
          public static let gas = ImageAsset(name: "gas")
        }
        public static let mileage = ImageAsset(name: "mileage")
        public static let seats = ImageAsset(name: "seats")
        public enum Transmission {
          public static let automatic = ImageAsset(name: "automatic")
          public static let manual = ImageAsset(name: "manual")
        }
      }
      public enum FiltersCategoriesIcons {
        public static let categoriesBabiesInactive = ImageAsset(name: "categories_babies_inactive")
        public static let categoriesCarsInactive = ImageAsset(name: "categories_cars_inactive")
        public static let categoriesElectronicsInactive = ImageAsset(name: "categories_electronics_inactive")
        public static let categoriesFashionInactive = ImageAsset(name: "categories_fashion_inactive")
        public static let categoriesFreeInactive = ImageAsset(name: "categories_free_inactive")
        public static let categoriesHomesInactive = ImageAsset(name: "categories_homes_inactive")
        public static let categoriesMotorsInactive = ImageAsset(name: "categories_motors_inactive")
        public static let categoriesMusicInactive = ImageAsset(name: "categories_music_inactive")
        public static let categoriesOtherItems = ImageAsset(name: "categories_other_items")
        public static let categoriesOthersInactive = ImageAsset(name: "categories_others_inactive")
        public static let categoriesRealestateInactive = ImageAsset(name: "categories_realestate_inactive")
        public static let categoriesServicesInactive = ImageAsset(name: "categories_services_inactive")
        public static let categoriesSportsInactive = ImageAsset(name: "categories_sports_inactive")
      }
      public static let filtersClearBtn = ImageAsset(name: "filters_clear_btn")
      public enum FiltersTagCategories {
        public static let categoriesBabiesTag = ImageAsset(name: "categories_babies_tag")
        public static let categoriesCarsTag = ImageAsset(name: "categories_cars_tag")
        public static let categoriesElectronicsTag = ImageAsset(name: "categories_electronics_tag")
        public static let categoriesFashionTag = ImageAsset(name: "categories_fashion_tag")
        public static let categoriesFreeTag = ImageAsset(name: "categories_free_tag")
        public static let categoriesHomesTag = ImageAsset(name: "categories_homes_tag")
        public static let categoriesHousingTag = ImageAsset(name: "categories_housing_tag")
        public static let categoriesMotorsTag = ImageAsset(name: "categories_motors_tag")
        public static let categoriesMusicTag = ImageAsset(name: "categories_music_tag")
        public static let categoriesOthersTag = ImageAsset(name: "categories_others_tag")
        public static let categoriesServicesTag = ImageAsset(name: "categories_services_tag")
        public static let categoriesSportsTag = ImageAsset(name: "categories_sports_tag")
      }
      public static let freeSwitchActive = ImageAsset(name: "free_switch_active")
      public static let freeSwitchInactive = ImageAsset(name: "free_switch_inactive")
      public static let housingIcon = ImageAsset(name: "housingIcon")
      public static let icStickersWithBadge = ImageAsset(name: "icStickersWithBadge")
      public static let icAddSummary = ImageAsset(name: "ic_add_summary")
      public static let icAddWhite = ImageAsset(name: "ic_add_white")
      public static let icArrowDown = ImageAsset(name: "ic_arrow_down")
      public static let icArrowRightWhite = ImageAsset(name: "ic_arrow_right_white")
      public static let icAssistantTag = ImageAsset(name: "ic_assistant_tag")
      public static let icBack = ImageAsset(name: "ic_back")
      public static let icBannerCat = ImageAsset(name: "ic_banner_cat")
      public static let icBuildTrust = ImageAsset(name: "ic_build_trust")
      public static let icBuildTrustBig = ImageAsset(name: "ic_build_trust_big")
      public static let icBuildTrustSmall = ImageAsset(name: "ic_build_trust_small")
      public static let icCameraBlockingTour = ImageAsset(name: "ic_camera_blocking_tour")
      public static let icCameraTour = ImageAsset(name: "ic_camera_tour")
      public static let icChatFilter = ImageAsset(name: "ic_chat_filter")
      public static let icChatFilterActive = ImageAsset(name: "ic_chat_filter_active")
      public static let icChatInfoDark = ImageAsset(name: "ic_chat_info_dark")
      public static let icCheckSent = ImageAsset(name: "ic_check_sent")
      public static let icCheckbox = ImageAsset(name: "ic_checkbox")
      public static let icCheckboxSelected = ImageAsset(name: "ic_checkbox_selected")
      public static let icCheckmark = ImageAsset(name: "ic_checkmark")
      public static let icChevronRight = ImageAsset(name: "ic_chevron_right")
      public static let icChevronUp = ImageAsset(name: "ic_chevron_up")
      public static let icCirlePlus = ImageAsset(name: "ic_cirle_plus")
      public static let icClickToTalk = ImageAsset(name: "ic_click_to_talk")
      public static let icClose = ImageAsset(name: "ic_close")
      public static let icCloseCarousel = ImageAsset(name: "ic_close_carousel")
      public static let icCloseDark = ImageAsset(name: "ic_close_dark")
      public static let icCloseGray = ImageAsset(name: "ic_close_gray")
      public static let icCrossTags = ImageAsset(name: "ic_cross_tags")
      public static let icDeviceBlockedAlert = ImageAsset(name: "ic_device_blocked_alert")
      public static let icDisclosure = ImageAsset(name: "ic_disclosure")
      public static let icDisclosureChat = ImageAsset(name: "ic_disclosure_chat")
      public static let icDisclosureTapToAction = ImageAsset(name: "ic_disclosure_tap_to_action")
      public static let icDownTriangle = ImageAsset(name: "ic_down_triangle")
      public static let icEmail = ImageAsset(name: "ic_email")
      public static let icEmailActive = ImageAsset(name: "ic_email_active")
      public static let icEmailActiveDark = ImageAsset(name: "ic_email_active_dark")
      public static let icEmailDark = ImageAsset(name: "ic_email_dark")
      public static let icEmailRounded = ImageAsset(name: "ic_email_rounded")
      public static let icEmojiNo = ImageAsset(name: "ic_emoji_no")
      public static let icEmojiYes = ImageAsset(name: "ic_emoji_yes")
      public static let icFacebookRounded = ImageAsset(name: "ic_facebook_rounded")
      public static let icFavoriteBigOff = ImageAsset(name: "ic_favorite_big_off")
      public static let icFavoriteBigOn = ImageAsset(name: "ic_favorite_big_on")
      public static let icFilterFar = ImageAsset(name: "ic_filter_far")
      public static let icFilterFarActive = ImageAsset(name: "ic_filter_far_active")
      public static let icFilterHome = ImageAsset(name: "ic_filter_home")
      public static let icFilterHomeActive = ImageAsset(name: "ic_filter_home_active")
      public static let icFilters = ImageAsset(name: "ic_filters")
      public static let icFiltersActive = ImageAsset(name: "ic_filters_active")
      public static let icFiltersGray = ImageAsset(name: "ic_filters_gray")
      public static let icGoogleRounded = ImageAsset(name: "ic_google_rounded")
      public static let icHeart = ImageAsset(name: "ic_heart")
      public static let icInfo = ImageAsset(name: "ic_info")
      public static let icInfoDark = ImageAsset(name: "ic_info_dark")
      public static let icKarmaBadgeActive = ImageAsset(name: "ic_karma_badge_active")
      public static let icKarmaBadgeInactive = ImageAsset(name: "ic_karma_badge_inactive")
      public static let icKarmaEye = ImageAsset(name: "ic_karma_eye")
      public static let icKeyboard = ImageAsset(name: "ic_keyboard")
      public static let icLocation = ImageAsset(name: "ic_location")
      public static let icLocationAlert = ImageAsset(name: "ic_location_alert")
      public static let icMagic = ImageAsset(name: "ic_magic")
      public static let icMap = ImageAsset(name: "ic_map")
      public static let icMessages = ImageAsset(name: "ic_messages")
      public static let icModerationAlert = ImageAsset(name: "ic_moderation_alert")
      public static let icMoreOptions = ImageAsset(name: "ic_more_options")
      public static let icName = ImageAsset(name: "ic_name")
      public static let icNameActive = ImageAsset(name: "ic_name_active")
      public static let icNameActiveDark = ImageAsset(name: "ic_name_active_dark")
      public static let icNameDark = ImageAsset(name: "ic_name_dark")
      public static let icNewStripe = ImageAsset(name: "ic_new_stripe")
      public static let icNotificationsEmpty = ImageAsset(name: "ic_notifications_empty")
      public static let icPassword = ImageAsset(name: "ic_password")
      public static let icPasswordActive = ImageAsset(name: "ic_password_active")
      public static let icPasswordActiveDark = ImageAsset(name: "ic_password_active_dark")
      public static let icPasswordDark = ImageAsset(name: "ic_password_dark")
      public static let icPasswordlessEmail = ImageAsset(name: "ic_passwordless_email")
      public static let icPen = ImageAsset(name: "ic_pen")
      public static let icPendingModeration = ImageAsset(name: "ic_pending_moderation")
      public static let icPhone = ImageAsset(name: "ic_phone")
      public static let icPostClose = ImageAsset(name: "ic_post_close")
      public static let icPostCorner = ImageAsset(name: "ic_post_corner")
      public static let icPostDisclousure = ImageAsset(name: "ic_post_disclousure")
      public static let icPostFlash = ImageAsset(name: "ic_post_flash")
      public static let icPostFlashAuto = ImageAsset(name: "ic_post_flash_auto")
      public static let icPostFlashInnactive = ImageAsset(name: "ic_post_flash_innactive")
      public static let icPostGallery = ImageAsset(name: "ic_post_gallery")
      public static let icPostOk = ImageAsset(name: "ic_post_ok")
      public static let icPostRecordVideoIcon = ImageAsset(name: "ic_post_record_video_icon")
      public static let icPostSwitchCam = ImageAsset(name: "ic_post_switch_cam")
      public static let icPostTabCamera = ImageAsset(name: "ic_post_tab_camera")
      public static let icPostTabGallery = ImageAsset(name: "ic_post_tab_gallery")
      public static let icPostTakePhoto = ImageAsset(name: "ic_post_take_photo")
      public static let icPostTakePhotoIcon = ImageAsset(name: "ic_post_take_photo_icon")
      public static let icPostWrong = ImageAsset(name: "ic_post_wrong")
      public static let icProTagWithShadow = ImageAsset(name: "ic_pro_tag_with_shadow")
      public static let icRatingPending = ImageAsset(name: "ic_rating_pending")
      public static let icRefresh = ImageAsset(name: "ic_refresh")
      public static let icReportCounterfeit = ImageAsset(name: "ic_report_counterfeit")
      public static let icReportInactive = ImageAsset(name: "ic_report_inactive")
      public static let icReportMia = ImageAsset(name: "ic_report_mia")
      public static let icReportOffensive = ImageAsset(name: "ic_report_offensive")
      public static let icReportOthers = ImageAsset(name: "ic_report_others")
      public static let icReportProhibited = ImageAsset(name: "ic_report_prohibited")
      public static let icReportScammer = ImageAsset(name: "ic_report_scammer")
      public static let icReportSpammer = ImageAsset(name: "ic_report_spammer")
      public static let icReportSuspicious = ImageAsset(name: "ic_report_suspicious")
      public static let icSafetyTipsBig = ImageAsset(name: "ic_safety_tips_big")
      public static let icSearch = ImageAsset(name: "ic_search")
      public static let icSearchFill = ImageAsset(name: "ic_search_fill")
      public static let icSellWhite = ImageAsset(name: "ic_sell_white")
      public static let icSend = ImageAsset(name: "ic_send")
      public static let icSettingAffiliation = ImageAsset(name: "ic_setting_affiliation")
      public static let icSettingEmail = ImageAsset(name: "ic_setting_email")
      public static let icSettingHelp = ImageAsset(name: "ic_setting_help")
      public static let icSettingLocation = ImageAsset(name: "ic_setting_location")
      public static let icSettingName = ImageAsset(name: "ic_setting_name")
      public static let icSettingNotifications = ImageAsset(name: "ic_setting_notifications")
      public static let icSettingPassword = ImageAsset(name: "ic_setting_password")
      public static let icSettingPrivacyPolicy = ImageAsset(name: "ic_setting_privacy_policy")
      public static let icSettingTermsAndConditions = ImageAsset(name: "ic_setting_terms_and_conditions")
      public static let icSettingsBio = ImageAsset(name: "ic_settings_bio")
      public static let icShare = ImageAsset(name: "ic_share")
      public static let icShareEmail = ImageAsset(name: "ic_share_email")
      public static let icShareFbmessenger = ImageAsset(name: "ic_share_fbmessenger")
      public static let icShareWhatsapp = ImageAsset(name: "ic_share_whatsapp")
      public static let icShowPassword = ImageAsset(name: "ic_show_password")
      public static let icShowPasswordInactive = ImageAsset(name: "ic_show_password_inactive")
      public static let icStar = ImageAsset(name: "ic_star")
      public static let icStarAvgEmpty = ImageAsset(name: "ic_star_avg_empty")
      public static let icStarAvgFull = ImageAsset(name: "ic_star_avg_full")
      public static let icStarAvgHalf = ImageAsset(name: "ic_star_avg_half")
      public static let icStarFilled = ImageAsset(name: "ic_star_filled")
      public static let icStarInnactive = ImageAsset(name: "ic_star_innactive")
      public static let icStatsFavorite = ImageAsset(name: "ic_stats_favorite")
      public static let icStatsTime = ImageAsset(name: "ic_stats_time")
      public static let icStatsViews = ImageAsset(name: "ic_stats_views")
      public static let icStickers = ImageAsset(name: "ic_stickers")
      public static let icTick = ImageAsset(name: "ic_tick")
      public static let icUserProfileStar = ImageAsset(name: "ic_user_profile_star")
      public static let icUserPublicEmail = ImageAsset(name: "ic_user_public_email")
      public static let icUserPublicFb = ImageAsset(name: "ic_user_public_fb")
      public static let icUserPublicGoogle = ImageAsset(name: "ic_user_public_google")
      public static let icVerified = ImageAsset(name: "ic_verified")
      public static let icVerifiedEmail = ImageAsset(name: "ic_verified_email")
      public static let icVerifiedFb = ImageAsset(name: "ic_verified_fb")
      public static let icVerifiedGoogle = ImageAsset(name: "ic_verified_google")
      public static let icVerifiedId = ImageAsset(name: "ic_verified_id")
      public static let icVerifiedPhone = ImageAsset(name: "ic_verified_phone")
      public static let info = ImageAsset(name: "info")
      public static let itemLocationWhite = ImageAsset(name: "item_location_white")
      public static let itemShareEmail = ImageAsset(name: "item_share_email")
      public static let itemShareEmailBig = ImageAsset(name: "item_share_email_big")
      public static let itemShareFb = ImageAsset(name: "item_share_fb")
      public static let itemShareFbBig = ImageAsset(name: "item_share_fb_big")
      public static let itemShareFbMessenger = ImageAsset(name: "item_share_fb_messenger")
      public static let itemShareFbMessengerBig = ImageAsset(name: "item_share_fb_messenger_big")
      public static let itemShareLink = ImageAsset(name: "item_share_link")
      public static let itemShareLinkBig = ImageAsset(name: "item_share_link_big")
      public static let itemShareMore = ImageAsset(name: "item_share_more")
      public static let itemShareMoreBig = ImageAsset(name: "item_share_more_big")
      public static let itemShareSms = ImageAsset(name: "item_share_sms")
      public static let itemShareSmsBig = ImageAsset(name: "item_share_sms_big")
      public static let itemShareTelegram = ImageAsset(name: "item_share_telegram")
      public static let itemShareTelegramBig = ImageAsset(name: "item_share_telegram_big")
      public static let itemShareTwitter = ImageAsset(name: "item_share_twitter")
      public static let itemShareTwitterBig = ImageAsset(name: "item_share_twitter_big")
      public static let itemShareWhatsapp = ImageAsset(name: "item_share_whatsapp")
      public static let itemShareWhatsappBig = ImageAsset(name: "item_share_whatsapp_big")
      public static let items = ImageAsset(name: "items")
      public static let listSearch = ImageAsset(name: "list_search")
      public static let listSearchGrey = ImageAsset(name: "list_search_grey")
      public enum Map {
        public static let icPin = ImageAsset(name: "ic_pin")
        public static let icPinFeatured = ImageAsset(name: "ic_pin_featured")
        public static let icPinFeaturedRealEstate = ImageAsset(name: "ic_pin_featured_real_estate")
        public static let icPinRealEstate = ImageAsset(name: "ic_pin_real_estate")
        public static let mapPin = ImageAsset(name: "map_pin")
        public static let mapUserLocationButton = ImageAsset(name: "map_user_location_button")
      }
      public static let motorsAndAccesories = ImageAsset(name: "motorsAndAccesories")
      public static let navbarBack = ImageAsset(name: "navbar_back")
      public static let navbarBackRed = ImageAsset(name: "navbar_back_red")
      public static let navbarBackWhiteShadow = ImageAsset(name: "navbar_back_white_shadow")
      public static let navbarClose = ImageAsset(name: "navbar_close")
      public static let navbarEdit = ImageAsset(name: "navbar_edit")
      public static let navbarFavOff = ImageAsset(name: "navbar_fav_off")
      public static let navbarFavOn = ImageAsset(name: "navbar_fav_on")
      public static let navbarMore = ImageAsset(name: "navbar_more")
      public static let navbarMoreRed = ImageAsset(name: "navbar_more_red")
      public static let navbarSettings = ImageAsset(name: "navbar_settings")
      public static let navbarSettingsRed = ImageAsset(name: "navbar_settings_red")
      public static let navbarShare = ImageAsset(name: "navbar_share")
      public static let navbarShareRed = ImageAsset(name: "navbar_share_red")
      public static let oval = ImageAsset(name: "oval")
      public static let productPlaceholder = ImageAsset(name: "product_placeholder")
      public static let rightChevron = ImageAsset(name: "right_chevron")
      public static let searchAlertIcon = ImageAsset(name: "search_alert_icon")
      public static let servicesIcon = ImageAsset(name: "servicesIcon")
      public static let tabbarChats = ImageAsset(name: "tabbar_chats")
      public static let tabbarCommunity = ImageAsset(name: "tabbar_community")
      public static let tabbarHome = ImageAsset(name: "tabbar_home")
      public static let tabbarNotifications = ImageAsset(name: "tabbar_notifications")
      public static let tabbarProfile = ImageAsset(name: "tabbar_profile")
      public static let tabbarSell = ImageAsset(name: "tabbar_sell")
      public static let tooltipPeakCenterBlack = ImageAsset(name: "tooltip_peak_center_black")
      public static let tooltipPeakSideBlack = ImageAsset(name: "tooltip_peak_side_black")
      public static let trendingExpandable = ImageAsset(name: "trending_expandable")
      public static let userPlaceholder = ImageAsset(name: "user_placeholder")
      public static let userProfileAddAvatar = ImageAsset(name: "user_profile_add_avatar")
      public static let userProfileEditAvatar = ImageAsset(name: "user_profile_edit_avatar")
      public static let verifyBio = ImageAsset(name: "verify_bio")
      public static let verifyCheck = ImageAsset(name: "verify_check")
      public static let verifyFacebook = ImageAsset(name: "verify_facebook")
      public static let verifyGoogle = ImageAsset(name: "verify_google")
      public static let verifyId = ImageAsset(name: "verify_id")
      public static let verifyMail = ImageAsset(name: "verify_mail")
      public static let verifyPhone = ImageAsset(name: "verify_phone")
      public static let verifyPhoto = ImageAsset(name: "verify_photo")
      public static let verifySold = ImageAsset(name: "verify_sold")

      // swiftlint:disable trailing_comma
      public static let allColors: [ColorAsset] = [
      ]
      public static let allImages: [ImageAsset] = [
        CategoriesHeaderIcons.carsFeed,
        CategoriesHeaderIcons.childFeed,
        CategoriesHeaderIcons.entretainmentFeed,
        CategoriesHeaderIcons.fashionFeed,
        CategoriesHeaderIcons.freeFeed,
        CategoriesHeaderIcons.homeFeed,
        CategoriesHeaderIcons.housingFeed,
        CategoriesHeaderIcons.leisureFeed,
        CategoriesHeaderIcons.motorsFeed,
        CategoriesHeaderIcons.othersFeed,
        CategoriesHeaderIcons.servicesFeed,
        CategoriesHeaderIcons.techFeed,
        Community.icCommunityBanner,
        Community.shapeBrightblue,
        Community.shapeDarkblue,
        Community.shapeYellow,
        IAmInterested.icIamiSeeconv,
        IAmInterested.icIamiSend,
        NewItemPage.nitArrowDown,
        NewItemPage.nitFavourite,
        NewItemPage.nitFavouriteOn,
        NewItemPage.nitLocation,
        NewItemPage.nitMore,
        NewItemPage.nitOnboarding,
        NewItemPage.nitPhotoChat,
        NewItemPage.nitPreviewCount,
        NewItemPage.nitShare,
        NewItemPage.nitTapGesture,
        SearchAlerts.icSearchAlertsEmpty,
        SearchAlerts.icSearchAlertsError,
        VideoPosting.icVideopostingPlay,
        carIcon,
        checkboxSelectedRound,
        checkboxSelectedRoundGray,
        chevronDownGrey,
        customPermissionProfile,
        downChevronRed,
        FiltersCarExtrasIcons.Bodytype.bodyTypeHybrid,
        FiltersCarExtrasIcons.Bodytype.convertible,
        FiltersCarExtrasIcons.Bodytype.coupe,
        FiltersCarExtrasIcons.Bodytype.hatchback,
        FiltersCarExtrasIcons.Bodytype.minivan,
        FiltersCarExtrasIcons.Bodytype.other,
        FiltersCarExtrasIcons.Bodytype.sedan,
        FiltersCarExtrasIcons.Bodytype.suv,
        FiltersCarExtrasIcons.Bodytype.truck,
        FiltersCarExtrasIcons.Bodytype.wagon,
        FiltersCarExtrasIcons.Drivetrain._4wd,
        FiltersCarExtrasIcons.Drivetrain.awd,
        FiltersCarExtrasIcons.Drivetrain.fwd,
        FiltersCarExtrasIcons.Drivetrain.rwd,
        FiltersCarExtrasIcons.Fueltype.diesel,
        FiltersCarExtrasIcons.Fueltype.electric,
        FiltersCarExtrasIcons.Fueltype.flex,
        FiltersCarExtrasIcons.Fueltype.fuelTypeHybrid,
        FiltersCarExtrasIcons.Fueltype.gas,
        FiltersCarExtrasIcons.mileage,
        FiltersCarExtrasIcons.seats,
        FiltersCarExtrasIcons.Transmission.automatic,
        FiltersCarExtrasIcons.Transmission.manual,
        FiltersCategoriesIcons.categoriesBabiesInactive,
        FiltersCategoriesIcons.categoriesCarsInactive,
        FiltersCategoriesIcons.categoriesElectronicsInactive,
        FiltersCategoriesIcons.categoriesFashionInactive,
        FiltersCategoriesIcons.categoriesFreeInactive,
        FiltersCategoriesIcons.categoriesHomesInactive,
        FiltersCategoriesIcons.categoriesMotorsInactive,
        FiltersCategoriesIcons.categoriesMusicInactive,
        FiltersCategoriesIcons.categoriesOtherItems,
        FiltersCategoriesIcons.categoriesOthersInactive,
        FiltersCategoriesIcons.categoriesRealestateInactive,
        FiltersCategoriesIcons.categoriesServicesInactive,
        FiltersCategoriesIcons.categoriesSportsInactive,
        filtersClearBtn,
        FiltersTagCategories.categoriesBabiesTag,
        FiltersTagCategories.categoriesCarsTag,
        FiltersTagCategories.categoriesElectronicsTag,
        FiltersTagCategories.categoriesFashionTag,
        FiltersTagCategories.categoriesFreeTag,
        FiltersTagCategories.categoriesHomesTag,
        FiltersTagCategories.categoriesHousingTag,
        FiltersTagCategories.categoriesMotorsTag,
        FiltersTagCategories.categoriesMusicTag,
        FiltersTagCategories.categoriesOthersTag,
        FiltersTagCategories.categoriesServicesTag,
        FiltersTagCategories.categoriesSportsTag,
        freeSwitchActive,
        freeSwitchInactive,
        housingIcon,
        icStickersWithBadge,
        icAddSummary,
        icAddWhite,
        icArrowDown,
        icArrowRightWhite,
        icAssistantTag,
        icBack,
        icBannerCat,
        icBuildTrust,
        icBuildTrustBig,
        icBuildTrustSmall,
        icCameraBlockingTour,
        icCameraTour,
        icChatFilter,
        icChatFilterActive,
        icChatInfoDark,
        icCheckSent,
        icCheckbox,
        icCheckboxSelected,
        icCheckmark,
        icChevronRight,
        icChevronUp,
        icCirlePlus,
        icClickToTalk,
        icClose,
        icCloseCarousel,
        icCloseDark,
        icCloseGray,
        icCrossTags,
        icDeviceBlockedAlert,
        icDisclosure,
        icDisclosureChat,
        icDisclosureTapToAction,
        icDownTriangle,
        icEmail,
        icEmailActive,
        icEmailActiveDark,
        icEmailDark,
        icEmailRounded,
        icEmojiNo,
        icEmojiYes,
        icFacebookRounded,
        icFavoriteBigOff,
        icFavoriteBigOn,
        icFilterFar,
        icFilterFarActive,
        icFilterHome,
        icFilterHomeActive,
        icFilters,
        icFiltersActive,
        icFiltersGray,
        icGoogleRounded,
        icHeart,
        icInfo,
        icInfoDark,
        icKarmaBadgeActive,
        icKarmaBadgeInactive,
        icKarmaEye,
        icKeyboard,
        icLocation,
        icLocationAlert,
        icMagic,
        icMap,
        icMessages,
        icModerationAlert,
        icMoreOptions,
        icName,
        icNameActive,
        icNameActiveDark,
        icNameDark,
        icNewStripe,
        icNotificationsEmpty,
        icPassword,
        icPasswordActive,
        icPasswordActiveDark,
        icPasswordDark,
        icPasswordlessEmail,
        icPen,
        icPendingModeration,
        icPhone,
        icPostClose,
        icPostCorner,
        icPostDisclousure,
        icPostFlash,
        icPostFlashAuto,
        icPostFlashInnactive,
        icPostGallery,
        icPostOk,
        icPostRecordVideoIcon,
        icPostSwitchCam,
        icPostTabCamera,
        icPostTabGallery,
        icPostTakePhoto,
        icPostTakePhotoIcon,
        icPostWrong,
        icProTagWithShadow,
        icRatingPending,
        icRefresh,
        icReportCounterfeit,
        icReportInactive,
        icReportMia,
        icReportOffensive,
        icReportOthers,
        icReportProhibited,
        icReportScammer,
        icReportSpammer,
        icReportSuspicious,
        icSafetyTipsBig,
        icSearch,
        icSearchFill,
        icSellWhite,
        icSend,
        icSettingAffiliation,
        icSettingEmail,
        icSettingHelp,
        icSettingLocation,
        icSettingName,
        icSettingNotifications,
        icSettingPassword,
        icSettingPrivacyPolicy,
        icSettingTermsAndConditions,
        icSettingsBio,
        icShare,
        icShareEmail,
        icShareFbmessenger,
        icShareWhatsapp,
        icShowPassword,
        icShowPasswordInactive,
        icStar,
        icStarAvgEmpty,
        icStarAvgFull,
        icStarAvgHalf,
        icStarFilled,
        icStarInnactive,
        icStatsFavorite,
        icStatsTime,
        icStatsViews,
        icStickers,
        icTick,
        icUserProfileStar,
        icUserPublicEmail,
        icUserPublicFb,
        icUserPublicGoogle,
        icVerified,
        icVerifiedEmail,
        icVerifiedFb,
        icVerifiedGoogle,
        icVerifiedId,
        icVerifiedPhone,
        info,
        itemLocationWhite,
        itemShareEmail,
        itemShareEmailBig,
        itemShareFb,
        itemShareFbBig,
        itemShareFbMessenger,
        itemShareFbMessengerBig,
        itemShareLink,
        itemShareLinkBig,
        itemShareMore,
        itemShareMoreBig,
        itemShareSms,
        itemShareSmsBig,
        itemShareTelegram,
        itemShareTelegramBig,
        itemShareTwitter,
        itemShareTwitterBig,
        itemShareWhatsapp,
        itemShareWhatsappBig,
        items,
        listSearch,
        listSearchGrey,
        Map.icPin,
        Map.icPinFeatured,
        Map.icPinFeaturedRealEstate,
        Map.icPinRealEstate,
        Map.mapPin,
        Map.mapUserLocationButton,
        motorsAndAccesories,
        navbarBack,
        navbarBackRed,
        navbarBackWhiteShadow,
        navbarClose,
        navbarEdit,
        navbarFavOff,
        navbarFavOn,
        navbarMore,
        navbarMoreRed,
        navbarSettings,
        navbarSettingsRed,
        navbarShare,
        navbarShareRed,
        oval,
        productPlaceholder,
        rightChevron,
        searchAlertIcon,
        servicesIcon,
        tabbarChats,
        tabbarCommunity,
        tabbarHome,
        tabbarNotifications,
        tabbarProfile,
        tabbarSell,
        tooltipPeakCenterBlack,
        tooltipPeakSideBlack,
        trendingExpandable,
        userPlaceholder,
        userProfileAddAvatar,
        userProfileEditAvatar,
        verifyBio,
        verifyCheck,
        verifyFacebook,
        verifyGoogle,
        verifyId,
        verifyMail,
        verifyPhone,
        verifyPhoto,
        verifySold,
      ]
      // swiftlint:enable trailing_comma
      @available(*, deprecated, renamed: "allImages")
      public static let allValues: [AssetType] = allImages
    }
    public enum Monetization {
      public static let boostBgBottomCell = ImageAsset(name: "boost_bg_bottom_cell")
      public static let boostBgLeftColumn = ImageAsset(name: "boost_bg_left_column")
      public static let boostBgRedArrow = ImageAsset(name: "boost_bg_red_arrow")
      public static let boostBgRightColumn = ImageAsset(name: "boost_bg_right_column")
      public static let boostBgYellowArrow = ImageAsset(name: "boost_bg_yellow_arrow")
      public static let bumpup2X = ImageAsset(name: "bumpup2X")
      public static let clock = ImageAsset(name: "clock")
      public static let cloud = ImageAsset(name: "cloud")
      public static let fakeCellBottom = ImageAsset(name: "fake_cell_bottom")
      public static let featured3DaysBackground = ImageAsset(name: "featured_3_days_background")
      public static let featured7DaysBackground = ImageAsset(name: "featured_7_days_background")
      public static let featuredBackground = ImageAsset(name: "featured_background")
      public static let grayChevronDown = ImageAsset(name: "gray_chevron_down")
      public static let grayChevronUp = ImageAsset(name: "gray_chevron_up")
      public static let icExtraBoost = ImageAsset(name: "ic_extra_boost")
      public static let icInterestedBuyers = ImageAsset(name: "ic_interested_buyers")
      public static let icLightning = ImageAsset(name: "ic_lightning")
      public static let icLightningRound = ImageAsset(name: "ic_lightning_round")
      public static let icPhoneCall = ImageAsset(name: "ic_phone_call")
      public static let icSellFaster = ImageAsset(name: "ic_sell_faster")
      public static let icVisibility = ImageAsset(name: "ic_visibility")
      public static let proTag = ImageAsset(name: "pro_tag")
      public static let redChevronDown = ImageAsset(name: "red_chevron_down")
      public static let redChevronUp = ImageAsset(name: "red_chevron_up")
      public static let redRibbon = ImageAsset(name: "red_ribbon")

      // swiftlint:disable trailing_comma
      public static let allColors: [ColorAsset] = [
      ]
      public static let allImages: [ImageAsset] = [
        boostBgBottomCell,
        boostBgLeftColumn,
        boostBgRedArrow,
        boostBgRightColumn,
        boostBgYellowArrow,
        bumpup2X,
        clock,
        cloud,
        fakeCellBottom,
        featured3DaysBackground,
        featured7DaysBackground,
        featuredBackground,
        grayChevronDown,
        grayChevronUp,
        icExtraBoost,
        icInterestedBuyers,
        icLightning,
        icLightningRound,
        icPhoneCall,
        icSellFaster,
        icVisibility,
        proTag,
        redChevronDown,
        redChevronUp,
        redRibbon,
      ]
      // swiftlint:enable trailing_comma
      @available(*, deprecated, renamed: "allImages")
      public static let allValues: [AssetType] = allImages
    }
    public enum P2PPayments {
      public static let close = ImageAsset(name: "close")
      public static let icError = ImageAsset(name: "ic_Error")
      public static let icCheck = ImageAsset(name: "ic_check")
      public static let icOptions = ImageAsset(name: "ic_options")
      public static let icTrust = ImageAsset(name: "ic_trust")
      public static let onboardingStep1 = ImageAsset(name: "onboardingStep1")
      public static let onboardingStep2 = ImageAsset(name: "onboardingStep2")
      public static let onboardingStep3 = ImageAsset(name: "onboardingStep3")

      // swiftlint:disable trailing_comma
      public static let allColors: [ColorAsset] = [
      ]
      public static let allImages: [ImageAsset] = [
        close,
        icError,
        icCheck,
        icOptions,
        icTrust,
        onboardingStep1,
        onboardingStep2,
        onboardingStep3,
      ]
      // swiftlint:enable trailing_comma
      @available(*, deprecated, renamed: "allImages")
      public static let allValues: [AssetType] = allImages
    }
    public enum ProductCellBanners {
      public static let collectionYou = ImageAsset(name: "collection_you")

      // swiftlint:disable trailing_comma
      public static let allColors: [ColorAsset] = [
      ]
      public static let allImages: [ImageAsset] = [
        collectionYou,
      ]
      // swiftlint:enable trailing_comma
      @available(*, deprecated, renamed: "allImages")
      public static let allValues: [AssetType] = allImages
    }
    public enum ProductOnboardingImages {
      public static let fingerScroll = ImageAsset(name: "finger_scroll")
      public static let fingerSwipe = ImageAsset(name: "finger_swipe")
      public static let fingerTap = ImageAsset(name: "finger_tap")

      // swiftlint:disable trailing_comma
      public static let allColors: [ColorAsset] = [
      ]
      public static let allImages: [ImageAsset] = [
        fingerScroll,
        fingerSwipe,
        fingerTap,
      ]
      // swiftlint:enable trailing_comma
      @available(*, deprecated, renamed: "allImages")
      public static let allValues: [AssetType] = allImages
    }
    public enum Verticals {
      public enum CarPromos {
        public enum Backgrounds {
          public static let background1 = ImageAsset(name: "background-1")
          public static let background2 = ImageAsset(name: "background-2")
          public static let background3 = ImageAsset(name: "background-3")
          public static let background4 = ImageAsset(name: "background-4")
          public static let background5 = ImageAsset(name: "background-5")
        }
        public enum Icons {
          public static let promo1 = ImageAsset(name: "promo-1")
          public static let promo2 = ImageAsset(name: "promo-2")
          public static let promo3 = ImageAsset(name: "promo-3")
          public static let promo4 = ImageAsset(name: "promo-4")
          public static let promo5 = ImageAsset(name: "promo-5")
        }
      }
      public enum RealEstatePromos {
        public enum Backgrounds {
          public static let realEstateBackground1 = ImageAsset(name: "real-estate-background-1")
          public static let realEstateBackground2 = ImageAsset(name: "real-estate-background-2")
          public static let realEstateBackground3 = ImageAsset(name: "real-estate-background-3")
          public static let realEstateBackground4 = ImageAsset(name: "real-estate-background-4")
          public static let realEstateBackground5 = ImageAsset(name: "real-estate-background-5")
          public static let realEstateBackground6 = ImageAsset(name: "real-estate-background-6")
        }
        public enum Icons {
          public static let realEstatePromo1 = ImageAsset(name: "real-estate-promo-1")
          public static let realEstatePromo2 = ImageAsset(name: "real-estate-promo-2")
          public static let realEstatePromo3 = ImageAsset(name: "real-estate-promo-3")
          public static let realEstatePromo4 = ImageAsset(name: "real-estate-promo-4")
          public static let realEstatePromo5 = ImageAsset(name: "real-estate-promo-5")
          public static let realEstatePromo6 = ImageAsset(name: "real-estate-promo-6")
          public static let realEstatePromo7 = ImageAsset(name: "real-estate-promo-7")
          public static let realEstatePromoCell1 = ImageAsset(name: "real-estate-promo-cell-1")
          public static let realEstatePromoCell2 = ImageAsset(name: "real-estate-promo-cell-2")
          public static let realEstatePromoCell3 = ImageAsset(name: "real-estate-promo-cell-3")
          public static let realEstatePromoCell4 = ImageAsset(name: "real-estate-promo-cell-4")
          public static let realEstatePromoCell5 = ImageAsset(name: "real-estate-promo-cell-5")
          public static let realEstatePromoCell6 = ImageAsset(name: "real-estate-promo-cell-6")
        }
      }
      public enum ServicesPromos {
        public enum Backgrounds {
          public static let servicesBackground1 = ImageAsset(name: "services-background-1")
          public static let servicesBackground2 = ImageAsset(name: "services-background-2")
          public static let servicesBackground3 = ImageAsset(name: "services-background-3")
          public static let servicesBackground4 = ImageAsset(name: "services-background-4")
          public static let servicesBackground5 = ImageAsset(name: "services-background-5")
        }
        public enum Icons {
          public static let servicesPromo1 = ImageAsset(name: "services-promo-1")
          public static let servicesPromo2 = ImageAsset(name: "services-promo-2")
          public static let servicesPromo3 = ImageAsset(name: "services-promo-3")
          public static let servicesPromo4 = ImageAsset(name: "services-promo-4")
          public static let servicesPromo5 = ImageAsset(name: "services-promo-5")
        }
      }
      public enum SmokeTests {
        public enum ClickToTalk {
          public static let smokeTestClickToTalkImage = ImageAsset(name: "SmokeTestClickToTalkImage")
          public static let bannerClickToTalk = ImageAsset(name: "banner-click-to-talk")
        }
      }

      // swiftlint:disable trailing_comma
      public static let allColors: [ColorAsset] = [
      ]
      public static let allImages: [ImageAsset] = [
        CarPromos.Backgrounds.background1,
        CarPromos.Backgrounds.background2,
        CarPromos.Backgrounds.background3,
        CarPromos.Backgrounds.background4,
        CarPromos.Backgrounds.background5,
        CarPromos.Icons.promo1,
        CarPromos.Icons.promo2,
        CarPromos.Icons.promo3,
        CarPromos.Icons.promo4,
        CarPromos.Icons.promo5,
        RealEstatePromos.Backgrounds.realEstateBackground1,
        RealEstatePromos.Backgrounds.realEstateBackground2,
        RealEstatePromos.Backgrounds.realEstateBackground3,
        RealEstatePromos.Backgrounds.realEstateBackground4,
        RealEstatePromos.Backgrounds.realEstateBackground5,
        RealEstatePromos.Backgrounds.realEstateBackground6,
        RealEstatePromos.Icons.realEstatePromo1,
        RealEstatePromos.Icons.realEstatePromo2,
        RealEstatePromos.Icons.realEstatePromo3,
        RealEstatePromos.Icons.realEstatePromo4,
        RealEstatePromos.Icons.realEstatePromo5,
        RealEstatePromos.Icons.realEstatePromo6,
        RealEstatePromos.Icons.realEstatePromo7,
        RealEstatePromos.Icons.realEstatePromoCell1,
        RealEstatePromos.Icons.realEstatePromoCell2,
        RealEstatePromos.Icons.realEstatePromoCell3,
        RealEstatePromos.Icons.realEstatePromoCell4,
        RealEstatePromos.Icons.realEstatePromoCell5,
        RealEstatePromos.Icons.realEstatePromoCell6,
        ServicesPromos.Backgrounds.servicesBackground1,
        ServicesPromos.Backgrounds.servicesBackground2,
        ServicesPromos.Backgrounds.servicesBackground3,
        ServicesPromos.Backgrounds.servicesBackground4,
        ServicesPromos.Backgrounds.servicesBackground5,
        ServicesPromos.Icons.servicesPromo1,
        ServicesPromos.Icons.servicesPromo2,
        ServicesPromos.Icons.servicesPromo3,
        ServicesPromos.Icons.servicesPromo4,
        ServicesPromos.Icons.servicesPromo5,
        SmokeTests.ClickToTalk.smokeTestClickToTalkImage,
        SmokeTests.ClickToTalk.bannerClickToTalk,
      ]
      // swiftlint:enable trailing_comma
      @available(*, deprecated, renamed: "allImages")
      public static let allValues: [AssetType] = allImages
    }
    public enum Reporting {
      public static let communityBadge = ImageAsset(name: "CommunityBadge")
      public static let counterfeitMoney = ImageAsset(name: "CounterfeitMoney")
      public static let drugs = ImageAsset(name: "Drugs")
      public static let duplicate = ImageAsset(name: "Duplicate")
      public static let forbidden = ImageAsset(name: "Forbidden")
      public static let inappropriateBio = ImageAsset(name: "InappropriateBio")
      public static let inappropriateChat = ImageAsset(name: "InappropriateChat")
      public static let inappropriateItem = ImageAsset(name: "InappropriateItem")
      public static let inappropriatePhoto = ImageAsset(name: "InappropriatePhoto")
      public static let inappropriateProfile = ImageAsset(name: "InappropriateProfile")
      public static let itemDefective = ImageAsset(name: "ItemDefective")
      public static let meetupProblem = ImageAsset(name: "MeetupProblem")
      public static let noAnswerChat = ImageAsset(name: "NoAnswerChat")
      public static let noShow = ImageAsset(name: "NoShow")
      public static let obsceneLanguage = ImageAsset(name: "ObsceneLanguage")
      public static let offensiveChat = ImageAsset(name: "OffensiveChat")
      public static let onlinePayment = ImageAsset(name: "OnlinePayment")
      public static let other = ImageAsset(name: "Other")
      public static let robbery = ImageAsset(name: "Robbery")
      public static let rocket = ImageAsset(name: "Rocket")
      public static let scam = ImageAsset(name: "Scam")
      public static let sexualContent = ImageAsset(name: "SexualContent")
      public static let spam = ImageAsset(name: "Spam")
      public static let suspicious = ImageAsset(name: "Suspicious")
      public static let trade = ImageAsset(name: "Trade")
      public static let unrealisticPrice = ImageAsset(name: "UnrealisticPrice")
      public static let violence = ImageAsset(name: "Violence")
      public static let weapons = ImageAsset(name: "Weapons")
      public static let wrongCategory = ImageAsset(name: "WrongCategory")
      public static let feedbackHappy = ImageAsset(name: "feedback_happy")
      public static let feedbackHappyDisabled = ImageAsset(name: "feedback_happyDisabled")
      public static let feedbackNeutral = ImageAsset(name: "feedback_neutral")
      public static let feedbackNeutralDisabled = ImageAsset(name: "feedback_neutralDisabled")
      public static let feedbackSad = ImageAsset(name: "feedback_sad")
      public static let feedbackSadDisabled = ImageAsset(name: "feedback_sadDisabled")
      public static let feedbackVeryHappy = ImageAsset(name: "feedback_veryHappy")
      public static let feedbackVeryHappyDisabled = ImageAsset(name: "feedback_veryHappyDisabled")
      public static let feedbackVerySad = ImageAsset(name: "feedback_verySad")
      public static let feedbackVerySadDisabled = ImageAsset(name: "feedback_verySadDisabled")
      public static let icCheck = ImageAsset(name: "ic_check")

      // swiftlint:disable trailing_comma
      public static let allColors: [ColorAsset] = [
      ]
      public static let allImages: [ImageAsset] = [
        communityBadge,
        counterfeitMoney,
        drugs,
        duplicate,
        forbidden,
        inappropriateBio,
        inappropriateChat,
        inappropriateItem,
        inappropriatePhoto,
        inappropriateProfile,
        itemDefective,
        meetupProblem,
        noAnswerChat,
        noShow,
        obsceneLanguage,
        offensiveChat,
        onlinePayment,
        other,
        robbery,
        rocket,
        scam,
        sexualContent,
        spam,
        suspicious,
        trade,
        unrealisticPrice,
        violence,
        weapons,
        wrongCategory,
        feedbackHappy,
        feedbackHappyDisabled,
        feedbackNeutral,
        feedbackNeutralDisabled,
        feedbackSad,
        feedbackSadDisabled,
        feedbackVeryHappy,
        feedbackVeryHappyDisabled,
        feedbackVerySad,
        feedbackVerySadDisabled,
        icCheck,
      ]
      // swiftlint:enable trailing_comma
      @available(*, deprecated, renamed: "allImages")
      public static let allValues: [AssetType] = allImages
    }
    public enum IPhoneParts {
      public static let imgNotifications = ImageAsset(name: "img_notifications")
      public static let imgPermissionsAlert = ImageAsset(name: "img_permissions_alert")
      public static let imgPermissionsBackground = ImageAsset(name: "img_permissions_background")
      public static let imgPush = ImageAsset(name: "img_push")
      public static let iphoneBottom = ImageAsset(name: "iphone_bottom")
      public static let iphoneLeft = ImageAsset(name: "iphone_left")
      public static let iphoneRight = ImageAsset(name: "iphone_right")
      public static let iphoneTop = ImageAsset(name: "iphone_top")

      // swiftlint:disable trailing_comma
      public static let allColors: [ColorAsset] = [
      ]
      public static let allImages: [ImageAsset] = [
        imgNotifications,
        imgPermissionsAlert,
        imgPermissionsBackground,
        imgPush,
        iphoneBottom,
        iphoneLeft,
        iphoneRight,
        iphoneTop,
      ]
      // swiftlint:enable trailing_comma
      @available(*, deprecated, renamed: "allImages")
      public static let allValues: [AssetType] = allImages
    }
    public enum Machinelearning {
      public static let mlIconChevron = ImageAsset(name: "ml_icon_chevron")
      public static let mlIconOff = ImageAsset(name: "ml_icon_off")
      public static let mlIconOn = ImageAsset(name: "ml_icon_on")
      public static let mlIconRedBig = ImageAsset(name: "ml_icon_red_big")

      // swiftlint:disable trailing_comma
      public static let allColors: [ColorAsset] = [
      ]
      public static let allImages: [ImageAsset] = [
        mlIconChevron,
        mlIconOff,
        mlIconOn,
        mlIconRedBig,
      ]
      // swiftlint:enable trailing_comma
      @available(*, deprecated, renamed: "allImages")
      public static let allValues: [AssetType] = allImages
    }
  }
}

// swiftlint:enable identifier_name line_length nesting type_body_length type_name

public extension Image {
  @available(iOS 1.0, tvOS 1.0, watchOS 1.0, *)
  @available(OSX, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: R.ImageAsset) {
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: R.bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

public extension AssetColorTypeAlias {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  convenience init!(asset: R.ColorAsset) {
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: R.bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSColor.Name(asset.name), bundle: R.bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

