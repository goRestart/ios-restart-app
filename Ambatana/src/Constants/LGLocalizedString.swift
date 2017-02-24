//
//  LGLocalized.swift
//  LetGo
//
//  Created by Eli Kohen on 15/10/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

struct LGLocalizedString {
	static var accountDeactivated: String {
		return NSLocalizedString("account_deactivated", comment: "")
	}

	static func accountDeactivatedWName(_ var1: String) -> String {
		return String(format: NSLocalizedString("account_deactivated_w_name", comment: ""), var1)
	}

	static var accountPendingModeration: String {
		return NSLocalizedString("account_pending_moderation", comment: "")
	}

	static func accountPendingModerationWName(_ var1: String) -> String {
		return String(format: NSLocalizedString("account_pending_moderation_w_name", comment: ""), var1)
	}

	static var appShareDownloadText: String {
		return NSLocalizedString("app_share_download_text", comment: "")
	}

	static var appShareEmailButton: String {
		return NSLocalizedString("app_share_email_button", comment: "")
	}

	static var appShareFbmessengerButton: String {
		return NSLocalizedString("app_share_fbmessenger_button", comment: "")
	}

	static var appShareMessageText: String {
		return NSLocalizedString("app_share_message_text", comment: "")
	}

	static var appShareSubjectText: String {
		return NSLocalizedString("app_share_subject_text", comment: "")
	}

	static var appShareSubtitle: String {
		return NSLocalizedString("app_share_subtitle", comment: "")
	}

	static var appShareSubtitleAlternative: String {
		return NSLocalizedString("app_share_subtitle_alternative", comment: "")
	}

	static var appShareTitle: String {
		return NSLocalizedString("app_share_title", comment: "")
	}

	static var appShareTitleAlternative: String {
		return NSLocalizedString("app_share_title_alternative", comment: "")
	}

	static var appShareWhatsappButton: String {
		return NSLocalizedString("app_share_whatsapp_button", comment: "")
	}

	static var appShareInviteText: String {
		return NSLocalizedString("app_share_invite_text", comment: "")
	}

	static var appShareSuccess: String {
		return NSLocalizedString("app_share_success", comment: "")
	}

	static var appShareError: String {
		return NSLocalizedString("app_share_error", comment: "")
	}

	static var appNotificationReply: String {
		return NSLocalizedString("app_notification_reply", comment: "")
	}

	static var blockUserErrorGeneric: String {
		return NSLocalizedString("block_user_error_generic", comment: "")
	}

	static var bumpUpBannerFreeText: String {
		return NSLocalizedString("bump_up_banner_free_text", comment: "")
	}

	static var bumpUpBannerPayText: String {
		return NSLocalizedString("bump_up_banner_pay_text", comment: "")
	}

	static var bumpUpBannerWaitText: String {
		return NSLocalizedString("bump_up_banner_wait_text", comment: "")
	}

	static var bumpUpBannerFreeButtonTitle: String {
		return NSLocalizedString("bump_up_banner_free_button_title", comment: "")
	}

	static var bumpUpFreeSuccess: String {
		return NSLocalizedString("bump_up_free_success", comment: "")
	}

	static var bumpUpPaySuccess: String {
		return NSLocalizedString("bump_up_pay_success", comment: "")
	}

	static var bumpUpErrorBumpGeneric: String {
		return NSLocalizedString("bump_up_error_bump_generic", comment: "")
	}

	static var bumpUpErrorBumpToken: String {
		return NSLocalizedString("bump_up_error_bump_token", comment: "")
	}

	static var bumpUpErrorPaymentFailed: String {
		return NSLocalizedString("bump_up_error_payment_failed", comment: "")
	}

	static var bumpUpProcessingFreeText: String {
		return NSLocalizedString("bump_up_processing_free_text", comment: "")
	}

	static var bumpUpProcessingPricedText: String {
		return NSLocalizedString("bump_up_processing_priced_text", comment: "")
	}

	static var bumpUpProductCellFeaturedStripe: String {
		return NSLocalizedString("bump_up_product_cell_featured_stripe", comment: "")
	}

	static var bumpUpProductDetailFeaturedLabel: String {
		return NSLocalizedString("bump_up_product_detail_featured_label", comment: "")
	}

	static var bumpUpViewFreeTitle: String {
		return NSLocalizedString("bump_up_view_free_title", comment: "")
	}

	static var bumpUpViewFreeSubtitle: String {
		return NSLocalizedString("bump_up_view_free_subtitle", comment: "")
	}

	static var bumpUpViewPayTitle: String {
		return NSLocalizedString("bump_up_view_pay_title", comment: "")
	}

	static var bumpUpViewPaySubtitle: String {
		return NSLocalizedString("bump_up_view_pay_subtitle", comment: "")
	}

	static func bumpUpViewPayButtonTitle(_ var1: String) -> String {
		return String(format: NSLocalizedString("bump_up_view_pay_button_title", comment: ""), var1)
	}

	static var bumpUpViewPayBumpsLeftText: String {
		return NSLocalizedString("bump_up_view_pay_bumps_left_text", comment: "")
	}

	static var categoriesBabyAndChild: String {
		return NSLocalizedString("categories_baby_and_child", comment: "")
	}

	static var categoriesCarsAndMotors: String {
		return NSLocalizedString("categories_cars_and_motors", comment: "")
	}

	static var categoriesElectronics: String {
		return NSLocalizedString("categories_electronics", comment: "")
	}

	static var categoriesFashionAndAccessories: String {
		return NSLocalizedString("categories_fashion_and_accessories", comment: "")
	}

	static var categoriesFree: String {
		return NSLocalizedString("categories_free", comment: "")
	}

	static var categoriesHomeAndGarden: String {
		return NSLocalizedString("categories_home_and_garden", comment: "")
	}

	static var categoriesMoviesBooksAndMusic: String {
		return NSLocalizedString("categories_movies_books_and_music", comment: "")
	}

	static var categoriesOther: String {
		return NSLocalizedString("categories_other", comment: "")
	}

	static var categoriesSportsLeisureAndGames: String {
		return NSLocalizedString("categories_sports_leisure_and_games", comment: "")
	}

	static var categoriesTitle: String {
		return NSLocalizedString("categories_title", comment: "")
	}

	static var categoriesUnassigned: String {
		return NSLocalizedString("categories_unassigned", comment: "")
	}

	static var changeLocationApplyButton: String {
		return NSLocalizedString("change_location_apply_button", comment: "")
	}

	static var changeLocationApproximateLocationLabel: String {
		return NSLocalizedString("change_location_approximate_location_label", comment: "")
	}

	static var changeLocationErrorCountryAlertMessage: String {
		return NSLocalizedString("change_location_error_country_alert_message", comment: "")
	}

	static var changeLocationErrorSearchLocationMessage: String {
		return NSLocalizedString("change_location_error_search_location_message", comment: "")
	}

	static func changeLocationErrorUnknownLocationMessage(_ var1: String) -> String {
		return String(format: NSLocalizedString("change_location_error_unknown_location_message", comment: ""), var1)
	}

	static var changeLocationErrorUpdatingLocationMessage: String {
		return NSLocalizedString("change_location_error_updating_location_message", comment: "")
	}

	static var changeLocationRecommendUpdateLocationMessage: String {
		return NSLocalizedString("change_location_recommend_update_location_message", comment: "")
	}

	static var changeLocationSearchFieldHint: String {
		return NSLocalizedString("change_location_search_field_hint", comment: "")
	}

	static var changeLocationTitle: String {
		return NSLocalizedString("change_location_title", comment: "")
	}

	static var changePasswordConfirmPasswordFieldHint: String {
		return NSLocalizedString("change_password_confirm_password_field_hint", comment: "")
	}

	static var changePasswordNewPasswordFieldHint: String {
		return NSLocalizedString("change_password_new_password_field_hint", comment: "")
	}

	static var changePasswordSendErrorGeneric: String {
		return NSLocalizedString("change_password_send_error_generic", comment: "")
	}

	static func changePasswordSendErrorInvalidPasswordWithMax(_ var1: Int, _ var2: Int) -> String {
		return String(format: NSLocalizedString("change_password_send_error_invalid_password_with_max", comment: ""), var1, var2)
	}

	static var changePasswordSendErrorPasswordsMismatch: String {
		return NSLocalizedString("change_password_send_error_passwords_mismatch", comment: "")
	}

	static var changePasswordSendErrorLinkExpired: String {
		return NSLocalizedString("change_password_send_error_link_expired", comment: "")
	}

	static var changePasswordSendOk: String {
		return NSLocalizedString("change_password_send_ok", comment: "")
	}

	static var changePasswordTitle: String {
		return NSLocalizedString("change_password_title", comment: "")
	}

	static func changeUsernameErrorInvalidUsername(_ var1: Int) -> String {
		return String(format: NSLocalizedString("change_username_error_invalid_username", comment: ""), var1)
	}

	static func changeUsernameErrorInvalidUsernameLetgo(_ var1: String) -> String {
		return String(format: NSLocalizedString("change_username_error_invalid_username_letgo", comment: ""), var1)
	}

	static var changeUsernameFieldHint: String {
		return NSLocalizedString("change_username_field_hint", comment: "")
	}

	static var changeUsernameLoading: String {
		return NSLocalizedString("change_username_loading", comment: "")
	}

	static var changeUsernameSaveButton: String {
		return NSLocalizedString("change_username_save_button", comment: "")
	}

	static var changeUsernameSendOk: String {
		return NSLocalizedString("change_username_send_ok", comment: "")
	}

	static var changeUsernameTitle: String {
		return NSLocalizedString("change_username_title", comment: "")
	}

	static var changeEmailTitle: String {
		return NSLocalizedString("change_email_title", comment: "")
	}

	static var changeEmailCurrentEmailLabel: String {
		return NSLocalizedString("change_email_current_email_label", comment: "")
	}

	static func changeEmailSendOk(_ var1: String) -> String {
		return String(format: NSLocalizedString("change_email_send_ok", comment: ""), var1)
	}

	static var changeEmailSaveButton: String {
		return NSLocalizedString("change_email_save_button", comment: "")
	}

	static var changeEmailLoading: String {
		return NSLocalizedString("change_email_loading", comment: "")
	}

	static var changeEmailFieldHint: String {
		return NSLocalizedString("change_email_field_hint", comment: "")
	}

	static var changeEmailErrorInvalidEmail: String {
		return NSLocalizedString("change_email_error_invalid_email", comment: "")
	}

	static var changeEmailErrorAlreadyRegistered: String {
		return NSLocalizedString("change_email_error_already_registered", comment: "")
	}

	static func chatAccountDeletedWName(_ var1: String) -> String {
		return String(format: NSLocalizedString("chat_account_deleted_w_name", comment: ""), var1)
	}

	static var chatAccountDeletedWoName: String {
		return NSLocalizedString("chat_account_deleted_wo_name", comment: "")
	}

	static var chatBlockUser: String {
		return NSLocalizedString("chat_block_user", comment: "")
	}

	static var chatBlockUserAlertBlockButton: String {
		return NSLocalizedString("chat_block_user_alert_block_button", comment: "")
	}

	static var chatBlockUserAlertText: String {
		return NSLocalizedString("chat_block_user_alert_text", comment: "")
	}

	static var chatBlockUserAlertTitle: String {
		return NSLocalizedString("chat_block_user_alert_title", comment: "")
	}

	static var chatBlockedByMeLabel: String {
		return NSLocalizedString("chat_blocked_by_me_label", comment: "")
	}

	static func chatBlockedByMeLabelWName(_ var1: String) -> String {
		return String(format: NSLocalizedString("chat_blocked_by_me_label_w_name", comment: ""), var1)
	}

	static var chatBlockedByOtherLabel: String {
		return NSLocalizedString("chat_blocked_by_other_label", comment: "")
	}

	static var chatDisclaimerLetgoTeam: String {
		return NSLocalizedString("chat_disclaimer_letgo_team", comment: "")
	}

	static var chatBlockedDisclaimerSafetyTipsButton: String {
		return NSLocalizedString("chat_blocked_disclaimer_safety_tips_button", comment: "")
	}

	static func chatBlockedDisclaimerScammerAppendSafetyTips(_ var1: String) -> String {
		return String(format: NSLocalizedString("chat_blocked_disclaimer_scammer_append_safety_tips", comment: ""), var1)
	}

	static var chatBlockedDisclaimerScammerAppendSafetyTipsKeyword: String {
		return NSLocalizedString("chat_blocked_disclaimer_scammer_append_safety_tips_keyword", comment: "")
	}

	static func chatBlockedDisclaimerScammerWName(_ var1: String) -> String {
		return String(format: NSLocalizedString("chat_blocked_disclaimer_scammer_w_name", comment: ""), var1)
	}

	static var chatBlockedDisclaimerScammerWoName: String {
		return NSLocalizedString("chat_blocked_disclaimer_scammer_wo_name", comment: "")
	}

	static var chatForbiddenDisclaimerSellerWoName: String {
		return NSLocalizedString("chat_forbidden_disclaimer_seller_wo_name", comment: "")
	}

	static func chatForbiddenDisclaimerSellerWName(_ var1: String) -> String {
		return String(format: NSLocalizedString("chat_forbidden_disclaimer_seller_w_name", comment: ""), var1)
	}

	static var chatForbiddenDisclaimerBuyerWoName: String {
		return NSLocalizedString("chat_forbidden_disclaimer_buyer_wo_name", comment: "")
	}

	static func chatForbiddenDisclaimerBuyerWName(_ var1: String) -> String {
		return String(format: NSLocalizedString("chat_forbidden_disclaimer_buyer_w_name", comment: ""), var1)
	}

	static var chatConnectAccountDisclaimer: String {
		return NSLocalizedString("chat_connect_account_disclaimer", comment: "")
	}

	static var chatConnectAccountDisclaimerButton: String {
		return NSLocalizedString("chat_connect_account_disclaimer_button", comment: "")
	}

	static func chatDeletedDisclaimerWName(_ var1: String) -> String {
		return String(format: NSLocalizedString("chat_deleted_disclaimer_w_name", comment: ""), var1)
	}

	static var chatDeletedDisclaimerWoName: String {
		return NSLocalizedString("chat_deleted_disclaimer_wo_name", comment: "")
	}

	static var chatExpressBannerButtonTitle: String {
		return NSLocalizedString("chat_express_banner_button_title", comment: "")
	}

	static var chatExpressBannerTitle: String {
		return NSLocalizedString("chat_express_banner_title", comment: "")
	}

	static var chatExpressDontMissLabel: String {
		return NSLocalizedString("chat_express_dont_miss_label", comment: "")
	}

	static var chatExpressContactSellersLabel: String {
		return NSLocalizedString("chat_express_contact_sellers_label", comment: "")
	}

	static var chatExpressTextFieldText: String {
		return NSLocalizedString("chat_express_text_field_text", comment: "")
	}

	static var chatExpressContactOneButtonText: String {
		return NSLocalizedString("chat_express_contact_one_button_text", comment: "")
	}

	static func chatExpressContactVariousButtonText(_ var1: String) -> String {
		return String(format: NSLocalizedString("chat_express_contact_various_button_text", comment: ""), var1)
	}

	static func chatExpressSendQuestionText(_ var1: String) -> String {
		return String(format: NSLocalizedString("chat_express_send_question_text", comment: ""), var1)
	}

	static var chatExpressDontAskAgainButton: String {
		return NSLocalizedString("chat_express_dont_ask_again_button", comment: "")
	}

	static var chatExpressOneMessageSentSuccessAlert: String {
		return NSLocalizedString("chat_express_one_message_sent_success_alert", comment: "")
	}

	static var chatExpressSeveralMessagesSentSuccessAlert: String {
		return NSLocalizedString("chat_express_several_messages_sent_success_alert", comment: "")
	}

	static var chatListAccountDeleted: String {
		return NSLocalizedString("chat_list_account_deleted", comment: "")
	}

	static var chatListAccountDeletedUsername: String {
		return NSLocalizedString("chat_list_account_deleted_username", comment: "")
	}

	static var chatListAllEmptyTitle: String {
		return NSLocalizedString("chat_list_all_empty_title", comment: "")
	}

	static var chatListAllTitle: String {
		return NSLocalizedString("chat_list_all_title", comment: "")
	}

	static var chatListArchiveErrorMultiple: String {
		return NSLocalizedString("chat_list_archive_error_multiple", comment: "")
	}

	static var chatListBlockedEmptyBody: String {
		return NSLocalizedString("chat_list_blocked_empty_body", comment: "")
	}

	static var chatListBlockedEmptyTitle: String {
		return NSLocalizedString("chat_list_blocked_empty_title", comment: "")
	}

	static var chatListBlockedUserLabel: String {
		return NSLocalizedString("chat_list_blocked_user_label", comment: "")
	}

	static var chatListBlockedUsersTitle: String {
		return NSLocalizedString("chat_list_blocked_users_title", comment: "")
	}

	static var chatListBuyingEmptyButton: String {
		return NSLocalizedString("chat_list_buying_empty_button", comment: "")
	}

	static var chatListBuyingEmptyTitle: String {
		return NSLocalizedString("chat_list_buying_empty_title", comment: "")
	}

	static var chatListBuyingTitle: String {
		return NSLocalizedString("chat_list_buying_title", comment: "")
	}

	static var chatListDelete: String {
		return NSLocalizedString("chat_list_delete", comment: "")
	}

	static var chatListDeleteAlertSend: String {
		return NSLocalizedString("chat_list_delete_alert_send", comment: "")
	}

	static var chatListDeleteAlertTextMultiple: String {
		return NSLocalizedString("chat_list_delete_alert_text_multiple", comment: "")
	}

	static var chatListDeleteAlertTextOne: String {
		return NSLocalizedString("chat_list_delete_alert_text_one", comment: "")
	}

	static var chatListDeleteAlertTitleMultiple: String {
		return NSLocalizedString("chat_list_delete_alert_title_multiple", comment: "")
	}

	static var chatListDeleteAlertTitleOne: String {
		return NSLocalizedString("chat_list_delete_alert_title_one", comment: "")
	}

	static var chatListDeleteErrorOne: String {
		return NSLocalizedString("chat_list_delete_error_one", comment: "")
	}

	static var chatListDeleteOkOne: String {
		return NSLocalizedString("chat_list_delete_ok_one", comment: "")
	}

	static var chatListSellingEmptyButton: String {
		return NSLocalizedString("chat_list_selling_empty_button", comment: "")
	}

	static var chatListSellingEmptyTitle: String {
		return NSLocalizedString("chat_list_selling_empty_title", comment: "")
	}

	static var chatListSellingTitle: String {
		return NSLocalizedString("chat_list_selling_title", comment: "")
	}

	static var chatListTitle: String {
		return NSLocalizedString("chat_list_title", comment: "")
	}

	static var chatListUnarchiveErrorMultiple: String {
		return NSLocalizedString("chat_list_unarchive_error_multiple", comment: "")
	}

	static var chatListUnblock: String {
		return NSLocalizedString("chat_list_unblock", comment: "")
	}

	static var chatLoginPopupText: String {
		return NSLocalizedString("chat_login_popup_text", comment: "")
	}

	static func chatMessageDisclaimerScammer(_ var1: String) -> String {
		return String(format: NSLocalizedString("chat_message_disclaimer_scammer", comment: ""), var1)
	}

	static var chatMessageFieldHint: String {
		return NSLocalizedString("chat_message_field_hint", comment: "")
	}

	static var chatMessageLoadGenericError: String {
		return NSLocalizedString("chat_message_load_generic_error", comment: "")
	}

	static var chatProductSoldLabel: String {
		return NSLocalizedString("chat_product_sold_label", comment: "")
	}

	static var chatRelatedProductsTitle: String {
		return NSLocalizedString("chat_related_products_title", comment: "")
	}

	static var chatSafetyTips: String {
		return NSLocalizedString("chat_safety_tips", comment: "")
	}

	static var chatSafetyTipsMessage: String {
		return NSLocalizedString("chat_safety_tips_message", comment: "")
	}

	static var chatSafetyTipsTitle: String {
		return NSLocalizedString("chat_safety_tips_title", comment: "")
	}

	static var chatSendButton: String {
		return NSLocalizedString("chat_send_button", comment: "")
	}

	static var chatSendErrorGeneric: String {
		return NSLocalizedString("chat_send_error_generic", comment: "")
	}

	static var chatStickersTooltipAddStickers: String {
		return NSLocalizedString("chat_stickers_tooltip_add_stickers", comment: "")
	}

	static var chatStickersTooltipNew: String {
		return NSLocalizedString("chat_stickers_tooltip_new", comment: "")
	}

	static var chatUnblockUser: String {
		return NSLocalizedString("chat_unblock_user", comment: "")
	}

	static func chatUserInfoName(_ var1: String) -> String {
		return String(format: NSLocalizedString("chat_user_info_name", comment: ""), var1)
	}

	static var chatUserInfoVerifiedWith: String {
		return NSLocalizedString("chat_user_info_verified_with", comment: "")
	}

	static var chatUserRatingButtonTitle: String {
		return NSLocalizedString("chat_user_rating_button_title", comment: "")
	}

	static var chatUserRatingButtonTooltip: String {
		return NSLocalizedString("chat_user_rating_button_tooltip", comment: "")
	}

	static func chatVerifyAlertMessage(_ var1: String) -> String {
		return String(format: NSLocalizedString("chat_verify_alert_message", comment: ""), var1)
	}

	static var chatVerifyAlertOkButton: String {
		return NSLocalizedString("chat_verify_alert_ok_button", comment: "")
	}

	static var chatVerifyAlertResendButton: String {
		return NSLocalizedString("chat_verify_alert_resend_button", comment: "")
	}

	static var chatVerifyAlertTitle: String {
		return NSLocalizedString("chat_verify_alert_title", comment: "")
	}

	static var chatConnectAccountsTitle: String {
		return NSLocalizedString("chat_connect_accounts_title", comment: "")
	}

	static var chatConnectAccountsMessage: String {
		return NSLocalizedString("chat_connect_accounts_message", comment: "")
	}

	static var chatNotVerifiedStateTitle: String {
		return NSLocalizedString("chat_not_verified_state_title", comment: "")
	}

	static var chatNotVerifiedStateMessage: String {
		return NSLocalizedString("chat_not_verified_state_message", comment: "")
	}

	static var chatNotVerifiedStateCheckButton: String {
		return NSLocalizedString("chat_not_verified_state_check_button", comment: "")
	}

	static var chatNotVerifiedAlertMessage: String {
		return NSLocalizedString("chat_not_verified_alert_message", comment: "")
	}

	static var chatWithYourselfAlertMsg: String {
		return NSLocalizedString("chat_with_yourself_alert_msg", comment: "")
	}

	static var collectionGamingTitle: String {
		return NSLocalizedString("collection_gaming_title", comment: "")
	}

	static var collectionTransportTitle: String {
		return NSLocalizedString("collection_transport_title", comment: "")
	}

	static var collectionAppleTitle: String {
		return NSLocalizedString("collection_apple_title", comment: "")
	}

	static var collectionFurnitureTitle: String {
		return NSLocalizedString("collection_furniture_title", comment: "")
	}

	static var collectionYouTitle: String {
		return NSLocalizedString("collection_you_title", comment: "")
	}

	static var collectionHalloweenTitle: String {
		return NSLocalizedString("collection_halloween_title", comment: "")
	}

	static var collectionExploreButton: String {
		return NSLocalizedString("collection_explore_button", comment: "")
	}

	static var commercializerCreateFromSettings: String {
		return NSLocalizedString("commercializer_create_from_settings", comment: "")
	}

	static var commercializerDisplayShareAlert: String {
		return NSLocalizedString("commercializer_display_share_alert", comment: "")
	}

	static var commercializerDisplayShareLabel: String {
		return NSLocalizedString("commercializer_display_share_label", comment: "")
	}

	static var commercializerDisplayShareMyVideoButton: String {
		return NSLocalizedString("commercializer_display_share_my_video_button", comment: "")
	}

	static var commercializerDisplayShareOthersVideoButton: String {
		return NSLocalizedString("commercializer_display_share_others_video_button", comment: "")
	}

	static var commercializerDisplayTitleLabel: String {
		return NSLocalizedString("commercializer_display_title_label", comment: "")
	}

	static var commercializerIntroTitleLabel: String {
		return NSLocalizedString("commercializer_intro_title_label", comment: "")
	}

	static var commercializerLoadVideoFailedErrorMessage: String {
		return NSLocalizedString("commercializer_load_video_failed_error_message", comment: "")
	}

	static var commercializerPreviewSubtitle: String {
		return NSLocalizedString("commercializer_preview_subtitle", comment: "")
	}

	static var commercializerPreviewTitle: String {
		return NSLocalizedString("commercializer_preview_title", comment: "")
	}

	static var commercializerProcessVideoFailedErrorMessage: String {
		return NSLocalizedString("commercializer_process_video_failed_error_message", comment: "")
	}

	static var commercializerProcessingTitleLabel: String {
		return NSLocalizedString("commercializer_processing_title_label", comment: "")
	}

	static var commercializerProcessingWillAppearLabel: String {
		return NSLocalizedString("commercializer_processing_will_appear_label", comment: "")
	}

	static var commercializerProductListEmptyBody: String {
		return NSLocalizedString("commercializer_product_list_empty_body", comment: "")
	}

	static var commercializerProductListEmptyButton: String {
		return NSLocalizedString("commercializer_product_list_empty_button", comment: "")
	}

	static var commercializerProductListEmptyTitle: String {
		return NSLocalizedString("commercializer_product_list_empty_title", comment: "")
	}

	static var commercializerPromoteChooseThemeLabel: String {
		return NSLocalizedString("commercializer_promote_choose_theme_label", comment: "")
	}

	static var commercializerPromoteIntroButton: String {
		return NSLocalizedString("commercializer_promote_intro_button", comment: "")
	}

	static var commercializerPromoteIntroLabel: String {
		return NSLocalizedString("commercializer_promote_intro_label", comment: "")
	}

	static var commercializerPromoteNavigationTitle: String {
		return NSLocalizedString("commercializer_promote_navigation_title", comment: "")
	}

	static var commercializerPromotePromoteButton: String {
		return NSLocalizedString("commercializer_promote_promote_button", comment: "")
	}

	static var commercializerPromoteThemeAlreadyUsed: String {
		return NSLocalizedString("commercializer_promote_theme_already_used", comment: "")
	}

	static var commercializerSelectFromSettingsTitle: String {
		return NSLocalizedString("commercializer_select_from_settings_title", comment: "")
	}

	static var commercializerShareMessageText: String {
		return NSLocalizedString("commercializer_share_message_text", comment: "")
	}

	static var commercializerShareSubjectText: String {
		return NSLocalizedString("commercializer_share_subject_text", comment: "")
	}

	static var commonCancel: String {
		return NSLocalizedString("common_cancel", comment: "")
	}

	static var commonChatNotAvailable: String {
		return NSLocalizedString("common_chat_not_available", comment: "")
	}

	static var commonCollapse: String {
		return NSLocalizedString("common_collapse", comment: "")
	}

	static var commonCopy: String {
		return NSLocalizedString("common_copy", comment: "")
	}

	static var commonError: String {
		return NSLocalizedString("common_error", comment: "")
	}

	static var commonErrorConnectionFailed: String {
		return NSLocalizedString("common_error_connection_failed", comment: "")
	}

	static var commonErrorGenericBody: String {
		return NSLocalizedString("common_error_generic_body", comment: "")
	}

	static var commonErrorListRetryButton: String {
		return NSLocalizedString("common_error_list_retry_button", comment: "")
	}

	static var commonErrorNetworkBody: String {
		return NSLocalizedString("common_error_network_body", comment: "")
	}

	static var commonErrorRetryButton: String {
		return NSLocalizedString("common_error_retry_button", comment: "")
	}

	static var commonErrorTitle: String {
		return NSLocalizedString("common_error_title", comment: "")
	}

	static var commonExpand: String {
		return NSLocalizedString("common_expand", comment: "")
	}

	static var commonLoading: String {
		return NSLocalizedString("common_loading", comment: "")
	}

	static var commonMax: String {
		return NSLocalizedString("common_max", comment: "")
	}

	static var commonNo: String {
		return NSLocalizedString("common_no", comment: "")
	}

	static var commonNext: String {
		return NSLocalizedString("common_next", comment: "")
	}

	static var commonNew: String {
		return NSLocalizedString("common_new", comment: "")
	}

	static var commonOk: String {
		return NSLocalizedString("common_ok", comment: "")
	}

	static var commonOr: String {
		return NSLocalizedString("common_or", comment: "")
	}

	static var commonProductNotAvailable: String {
		return NSLocalizedString("common_product_not_available", comment: "")
	}

	static var commonProductSold: String {
		return NSLocalizedString("common_product_sold", comment: "")
	}

	static var commonSettings: String {
		return NSLocalizedString("common_settings", comment: "")
	}

	static func commonShortTimeDayAgoLabel(_ var1: Int) -> String {
		return String(format: NSLocalizedString("common_short_time_day_ago_label", comment: ""), var1)
	}

	static func commonShortTimeDaysAgoLabel(_ var1: Int) -> String {
		return String(format: NSLocalizedString("common_short_time_days_ago_label", comment: ""), var1)
	}

	static func commonShortTimeHoursAgoLabel(_ var1: Int) -> String {
		return String(format: NSLocalizedString("common_short_time_hours_ago_label", comment: ""), var1)
	}

	static func commonShortTimeMinutesAgoLabel(_ var1: Int) -> String {
		return String(format: NSLocalizedString("common_short_time_minutes_ago_label", comment: ""), var1)
	}

	static var commonShortTimeMoreThanOneMonthAgoLabel: String {
		return NSLocalizedString("common_short_time_more_than_one_month_ago_label", comment: "")
	}

	static func commonShortTimeWeekAgoLabel(_ var1: Int) -> String {
		return String(format: NSLocalizedString("common_short_time_week_ago_label", comment: ""), var1)
	}

	static func commonShortTimeWeeksAgoLabel(_ var1: Int) -> String {
		return String(format: NSLocalizedString("common_short_time_weeks_ago_label", comment: ""), var1)
	}

	static var commonTimeAMinuteAgoLabel: String {
		return NSLocalizedString("common_time_a_minute_ago_label", comment: "")
	}

	static var commonTimeDayAgoLabel: String {
		return NSLocalizedString("common_time_day_ago_label", comment: "")
	}

	static func commonTimeDaysAgoLabel(_ var1: Int) -> String {
		return String(format: NSLocalizedString("common_time_days_ago_label", comment: ""), var1)
	}

	static var commonTimeHourAgoLabel: String {
		return NSLocalizedString("common_time_hour_ago_label", comment: "")
	}

	static func commonTimeHoursAgoLabel(_ var1: Int) -> String {
		return String(format: NSLocalizedString("common_time_hours_ago_label", comment: ""), var1)
	}

	static func commonTimeMinutesAgoLabel(_ var1: Int) -> String {
		return String(format: NSLocalizedString("common_time_minutes_ago_label", comment: ""), var1)
	}

	static var commonTimeMoreThanOneMonthAgoLabel: String {
		return NSLocalizedString("common_time_more_than_one_month_ago_label", comment: "")
	}

	static var commonTimeNowLabel: String {
		return NSLocalizedString("common_time_now_label", comment: "")
	}

	static func commonTimeSecondsAgoLabel(_ var1: Int) -> String {
		return String(format: NSLocalizedString("common_time_seconds_ago_label", comment: ""), var1)
	}

	static var commonTimeWeekAgoLabel: String {
		return NSLocalizedString("common_time_week_ago_label", comment: "")
	}

	static func commonTimeWeeksAgoLabel(_ var1: Int) -> String {
		return String(format: NSLocalizedString("common_time_weeks_ago_label", comment: ""), var1)
	}

	static var commonUserNotAvailable: String {
		return NSLocalizedString("common_user_not_available", comment: "")
	}

	static var commonUserReviewNotAvailable: String {
		return NSLocalizedString("common_user_review_not_available", comment: "")
	}

	static var commonYes: String {
		return NSLocalizedString("common_yes", comment: "")
	}

	static var contactSubjectOptionLocation: String {
		return NSLocalizedString("contact_subject_option_location", comment: "")
	}

	static var contactSubjectOptionLogin: String {
		return NSLocalizedString("contact_subject_option_login", comment: "")
	}

	static var contactSubjectOptionOther: String {
		return NSLocalizedString("contact_subject_option_other", comment: "")
	}

	static var contactSubjectOptionProductEdit: String {
		return NSLocalizedString("contact_subject_option_product_edit", comment: "")
	}

	static var contactSubjectOptionProfileEdit: String {
		return NSLocalizedString("contact_subject_option_profile_edit", comment: "")
	}

	static var contactSubjectOptionReport: String {
		return NSLocalizedString("contact_subject_option_report", comment: "")
	}

	static var directAnswerTitle: String {
		return NSLocalizedString("direct_answer_title", comment: "")
	}

	static var directAnswerCondition: String {
		return NSLocalizedString("direct_answer_condition", comment: "")
	}

	static var directAnswerFreeYours: String {
		return NSLocalizedString("direct_answer_free_yours", comment: "")
	}

	static var directAnswerFreeAvailable: String {
		return NSLocalizedString("direct_answer_free_available", comment: "")
	}

	static var directAnswerFreeNoAvailable: String {
		return NSLocalizedString("direct_answer_free_no_available", comment: "")
	}

	static var directAnswerFreeStillHave: String {
		return NSLocalizedString("direct_answer_free_still_have", comment: "")
	}

	static var directAnswerInterested: String {
		return NSLocalizedString("direct_answer_interested", comment: "")
	}

	static var directAnswerIsNegotiable: String {
		return NSLocalizedString("direct_answer_is_negotiable", comment: "")
	}

	static var directAnswerLikeToBuy: String {
		return NSLocalizedString("direct_answer_like_to_buy", comment: "")
	}

	static var directAnswerMeetUp: String {
		return NSLocalizedString("direct_answer_meet_up", comment: "")
	}

	static var directAnswerNegotiableNo: String {
		return NSLocalizedString("direct_answer_negotiable_no", comment: "")
	}

	static var directAnswerNegotiableYes: String {
		return NSLocalizedString("direct_answer_negotiable_yes", comment: "")
	}

	static var directAnswerNotInterested: String {
		return NSLocalizedString("direct_answer_not_interested", comment: "")
	}

	static var directAnswerProductSold: String {
		return NSLocalizedString("direct_answer_product_sold", comment: "")
	}

	static var directAnswerSoldQuestionMessage: String {
		return NSLocalizedString("direct_answer_sold_question_message", comment: "")
	}

	static var directAnswerSoldQuestionOk: String {
		return NSLocalizedString("direct_answer_sold_question_ok", comment: "")
	}

	static var directAnswerStillAvailable: String {
		return NSLocalizedString("direct_answer_still_available", comment: "")
	}

	static var directAnswerSoldQuestionTitle: String {
		return NSLocalizedString("direct_answer_sold_question_title", comment: "")
	}

	static var directAnswerStillForSale: String {
		return NSLocalizedString("direct_answer_still_for_sale", comment: "")
	}

	static var directAnswerWhatsOffer: String {
		return NSLocalizedString("direct_answer_whats_offer", comment: "")
	}

	static var directAnswersHide: String {
		return NSLocalizedString("direct_answers_hide", comment: "")
	}

	static var directAnswersShow: String {
		return NSLocalizedString("direct_answers_show", comment: "")
	}

	static var editProductLocationAlertText: String {
		return NSLocalizedString("edit_product_location_alert_text", comment: "")
	}

	static var editProductLocationAlertTitle: String {
		return NSLocalizedString("edit_product_location_alert_title", comment: "")
	}

	static var editProductSendButton: String {
		return NSLocalizedString("edit_product_send_button", comment: "")
	}

	static var editProductSendErrorUploadingProduct: String {
		return NSLocalizedString("edit_product_send_error_uploading_product", comment: "")
	}

	static var editProductSendOk: String {
		return NSLocalizedString("edit_product_send_ok", comment: "")
	}

	static var editProductSuggestingTitle: String {
		return NSLocalizedString("edit_product_suggesting_title", comment: "")
	}

	static var editProductTitle: String {
		return NSLocalizedString("edit_product_title", comment: "")
	}

	static var editProductUnsavedChangesAlert: String {
		return NSLocalizedString("edit_product_unsaved_changes_alert", comment: "")
	}

	static var editProductUnsavedChangesAlertOk: String {
		return NSLocalizedString("edit_product_unsaved_changes_alert_ok", comment: "")
	}

	static var filtersDistanceNotSet: String {
		return NSLocalizedString("filters_distance_not_set", comment: "")
	}

	static var filtersNavbarReset: String {
		return NSLocalizedString("filters_navbar_reset", comment: "")
	}

	static var filtersSaveButton: String {
		return NSLocalizedString("filters_save_button", comment: "")
	}

	static var filtersSectionCategories: String {
		return NSLocalizedString("filters_section_categories", comment: "")
	}

	static var filtersSectionDistance: String {
		return NSLocalizedString("filters_section_distance", comment: "")
	}

	static var filtersSectionLocation: String {
		return NSLocalizedString("filters_section_location", comment: "")
	}

	static var filtersSectionPrice: String {
		return NSLocalizedString("filters_section_price", comment: "")
	}

	static var filtersSectionSortby: String {
		return NSLocalizedString("filters_section_sortby", comment: "")
	}

	static var filtersSectionWithin: String {
		return NSLocalizedString("filters_section_within", comment: "")
	}

	static var filtersPriceFrom: String {
		return NSLocalizedString("filters_price_from", comment: "")
	}

	static var filtersPriceTo: String {
		return NSLocalizedString("filters_price_to", comment: "")
	}

	static var filtersPriceWrongRangeError: String {
		return NSLocalizedString("filters_price_wrong_range_error", comment: "")
	}

	static var filtersSortClosest: String {
		return NSLocalizedString("filters_sort_closest", comment: "")
	}

	static var filtersSortNewest: String {
		return NSLocalizedString("filters_sort_newest", comment: "")
	}

	static var filtersSortPriceAsc: String {
		return NSLocalizedString("filters_sort_price_asc", comment: "")
	}

	static var filtersSortPriceDesc: String {
		return NSLocalizedString("filters_sort_price_desc", comment: "")
	}

	static var filtersTitle: String {
		return NSLocalizedString("filters_title", comment: "")
	}

	static var filtersWithinAll: String {
		return NSLocalizedString("filters_within_all", comment: "")
	}

	static var filtersWithinDay: String {
		return NSLocalizedString("filters_within_day", comment: "")
	}

	static var filtersWithinMonth: String {
		return NSLocalizedString("filters_within_month", comment: "")
	}

	static var filtersWithinWeek: String {
		return NSLocalizedString("filters_within_week", comment: "")
	}

	static var forcedUpdateMessage: String {
		return NSLocalizedString("forced_update_message", comment: "")
	}

	static var forcedUpdateTitle: String {
		return NSLocalizedString("forced_update_title", comment: "")
	}

	static var forcedUpdateUpdateButton: String {
		return NSLocalizedString("forced_update_update_button", comment: "")
	}

	static var helpTitle: String {
		return NSLocalizedString("help_title", comment: "")
	}

	static var locationPermissionsBubble: String {
		return NSLocalizedString("location_permissions_bubble", comment: "")
	}

	static var locationPermissionsButton: String {
		return NSLocalizedString("location_permissions_button", comment: "")
	}

	static var locationPermissionsTitle: String {
		return NSLocalizedString("location_permissions_title", comment: "")
	}

	static var locationPermissionsTitleV2: String {
		return NSLocalizedString("location_permissions_title_v2", comment: "")
	}

	static var locationPermissonsSubtitle: String {
		return NSLocalizedString("location_permissons_subtitle", comment: "")
	}

	static var locationPermissionsAllowButton: String {
		return NSLocalizedString("location_permissions_allow_button", comment: "")
	}

	static var logInErrorSendErrorGeneric: String {
		return NSLocalizedString("log_in_error_send_error_generic", comment: "")
	}

	static var logInErrorSendErrorInvalidEmail: String {
		return NSLocalizedString("log_in_error_send_error_invalid_email", comment: "")
	}

	static var logInErrorSendErrorUserNotFoundOrWrongPassword: String {
		return NSLocalizedString("log_in_error_send_error_user_not_found_or_wrong_password", comment: "")
	}

	static var logInResetPasswordButton: String {
		return NSLocalizedString("log_in_reset_password_button", comment: "")
	}

	static var logInSendButton: String {
		return NSLocalizedString("log_in_send_button", comment: "")
	}

	static var logInTitle: String {
		return NSLocalizedString("log_in_title", comment: "")
	}

	static var loginScammerAlertTitle: String {
		return NSLocalizedString("login_scammer_alert_title", comment: "")
	}

	static var loginScammerAlertMessage: String {
		return NSLocalizedString("login_scammer_alert_message", comment: "")
	}

	static var loginScammerAlertContactButton: String {
		return NSLocalizedString("login_scammer_alert_contact_button", comment: "")
	}

	static var loginScammerAlertKeepBrowsingButton: String {
		return NSLocalizedString("login_scammer_alert_keep_browsing_button", comment: "")
	}

	static var logInEmailTitle: String {
		return NSLocalizedString("log_in_email_title", comment: "")
	}

	static var logInEmailHelpButton: String {
		return NSLocalizedString("log_in_email_help_button", comment: "")
	}

	static var logInEmailEmailFieldHint: String {
		return NSLocalizedString("log_in_email_email_field_hint", comment: "")
	}

	static var logInEmailPasswordFieldHint: String {
		return NSLocalizedString("log_in_email_password_field_hint", comment: "")
	}

	static var logInEmailForgotPasswordButton: String {
		return NSLocalizedString("log_in_email_forgot_password_button", comment: "")
	}

	static var logInEmailFooter: String {
		return NSLocalizedString("log_in_email_footer", comment: "")
	}

	static var logInEmailFooterSignUpKw: String {
		return NSLocalizedString("log_in_email_footer_sign_up_kw", comment: "")
	}

	static var logInEmailWrongPasswordAlertTitle: String {
		return NSLocalizedString("log_in_email_wrong_password_alert_title", comment: "")
	}

	static func logInEmailWrongPasswordAlertMessage(_ var1: String) -> String {
		return String(format: NSLocalizedString("log_in_email_wrong_password_alert_message", comment: ""), var1)
	}

	static var logInEmailWrongPasswordAlertCancelAction: String {
		return NSLocalizedString("log_in_email_wrong_password_alert_cancel_action", comment: "")
	}

	static var logInEmailForgotPasswordAlertTitle: String {
		return NSLocalizedString("log_in_email_forgot_password_alert_title", comment: "")
	}

	static func logInEmailForgotPasswordAlertMessage(_ var1: String) -> String {
		return String(format: NSLocalizedString("log_in_email_forgot_password_alert_message", comment: ""), var1)
	}

	static var logInEmailForgotPasswordAlertCancelAction: String {
		return NSLocalizedString("log_in_email_forgot_password_alert_cancel_action", comment: "")
	}

	static var logInEmailForgotPasswordAlertRememberAction: String {
		return NSLocalizedString("log_in_email_forgot_password_alert_remember_action", comment: "")
	}

	static var logInEmailLogInButton: String {
		return NSLocalizedString("log_in_email_log_in_button", comment: "")
	}

	static var signUpEmailStep1Title: String {
		return NSLocalizedString("sign_up_email_step1_title", comment: "")
	}

	static var signUpEmailStep1HelpButton: String {
		return NSLocalizedString("sign_up_email_step1_help_button", comment: "")
	}

	static var signUpEmailStep1EmailFieldHint: String {
		return NSLocalizedString("sign_up_email_step1_email_field_hint", comment: "")
	}

	static var signUpEmailStep1PasswordFieldHint: String {
		return NSLocalizedString("sign_up_email_step1_password_field_hint", comment: "")
	}

	static var signUpEmailStep1ContinueButton: String {
		return NSLocalizedString("sign_up_email_step1_continue_button", comment: "")
	}

	static var signUpEmailStep1Footer: String {
		return NSLocalizedString("sign_up_email_step1_footer", comment: "")
	}

	static var signUpEmailStep1FooterLogInKw: String {
		return NSLocalizedString("sign_up_email_step1_footer_log_in_kw", comment: "")
	}

	static var signUpEmailStep2Title: String {
		return NSLocalizedString("sign_up_email_step2_title", comment: "")
	}

	static var signUpEmailStep2HelpButton: String {
		return NSLocalizedString("sign_up_email_step2_help_button", comment: "")
	}

	static func signUpEmailStep2Header(_ var1: String) -> String {
		return String(format: NSLocalizedString("sign_up_email_step2_header", comment: ""), var1)
	}

	static var signUpEmailStep2NameFieldHint: String {
		return NSLocalizedString("sign_up_email_step2_name_field_hint", comment: "")
	}

	static var signUpEmailStep2TermsConditions: String {
		return NSLocalizedString("sign_up_email_step2_terms_conditions", comment: "")
	}

	static var signUpEmailStep2TermsConditionsPrivacyKw: String {
		return NSLocalizedString("sign_up_email_step2_terms_conditions_privacy_kw", comment: "")
	}

	static var signUpEmailStep2TermsConditionsTermsKw: String {
		return NSLocalizedString("sign_up_email_step2_terms_conditions_terms_kw", comment: "")
	}

	static var signUpEmailStep2Newsletter: String {
		return NSLocalizedString("sign_up_email_step2_newsletter", comment: "")
	}

	static var signUpEmailStep2SignUpButton: String {
		return NSLocalizedString("sign_up_email_step2_sign_up_button", comment: "")
	}

	static var mainSignUpClaimLabel: String {
		return NSLocalizedString("main_sign_up_claim_label", comment: "")
	}

	static var mainSignUpFacebookConnectButton: String {
		return NSLocalizedString("main_sign_up_facebook_connect_button", comment: "")
	}

	static func mainSignUpFacebookConnectButtonWName(_ var1: String) -> String {
		return String(format: NSLocalizedString("main_sign_up_facebook_connect_button_w_name", comment: ""), var1)
	}

	static var mainSignUpFbConnectErrorEmailTaken: String {
		return NSLocalizedString("main_sign_up_fb_connect_error_email_taken", comment: "")
	}

	static var mainSignUpFbConnectErrorGeneric: String {
		return NSLocalizedString("main_sign_up_fb_connect_error_generic", comment: "")
	}

	static var mainSignUpErrorUserRejected: String {
		return NSLocalizedString("main_sign_up_error_user_rejected", comment: "")
	}

	static var mainSignUpErrorRequestAlreadySent: String {
		return NSLocalizedString("main_sign_up_error_request_already_sent", comment: "")
	}

	static var mainSignUpGoogleConnectButton: String {
		return NSLocalizedString("main_sign_up_google_connect_button", comment: "")
	}

	static func mainSignUpGoogleConnectButtonWName(_ var1: String) -> String {
		return String(format: NSLocalizedString("main_sign_up_google_connect_button_w_name", comment: ""), var1)
	}

	static var mainSignUpHelpButton: String {
		return NSLocalizedString("main_sign_up_help_button", comment: "")
	}

	static var mainSignUpLogInLabel: String {
		return NSLocalizedString("main_sign_up_log_in_label", comment: "")
	}

	static var mainSignUpOrLabel: String {
		return NSLocalizedString("main_sign_up_or_label", comment: "")
	}

	static var mainSignUpQuicklyLabel: String {
		return NSLocalizedString("main_sign_up_quickly_label", comment: "")
	}

	static var mainSignUpSignUpButton: String {
		return NSLocalizedString("main_sign_up_sign_up_button", comment: "")
	}

	static var mainSignUpTermsConditions: String {
		return NSLocalizedString("main_sign_up_terms_conditions", comment: "")
	}

	static var mainSignUpTermsConditionsPrivacyPart: String {
		return NSLocalizedString("main_sign_up_terms_conditions_privacy_part", comment: "")
	}

	static var mainSignUpTermsConditionsTermsPart: String {
		return NSLocalizedString("main_sign_up_terms_conditions_terms_part", comment: "")
	}

	static var mainProductsInviteNavigationBarButton: String {
		return NSLocalizedString("main_products_invite_navigation_bar_button", comment: "")
	}

	static var mainProductsFilterNavigationBarButton: String {
		return NSLocalizedString("main_products_filter_navigation_bar_button", comment: "")
	}

	static var notificationsEmptySubtitle: String {
		return NSLocalizedString("notifications_empty_subtitle", comment: "")
	}

	static var notificationsEmptyTitle: String {
		return NSLocalizedString("notifications_empty_title", comment: "")
	}

	static var notificationsPermissions1Push: String {
		return NSLocalizedString("notifications_permissions_1_push", comment: "")
	}

	static var notificationsPermissions1Subtitle: String {
		return NSLocalizedString("notifications_permissions_1_subtitle", comment: "")
	}

	static var notificationsPermissions1Title: String {
		return NSLocalizedString("notifications_permissions_1_title", comment: "")
	}

	static var notificationsPermissions1TitleV2: String {
		return NSLocalizedString("notifications_permissions_1_title_v2", comment: "")
	}

	static var notificationsPermissions2Title: String {
		return NSLocalizedString("notifications_permissions_2_title", comment: "")
	}

	static var notificationsPermissions3Push: String {
		return NSLocalizedString("notifications_permissions_3_push", comment: "")
	}

	static var notificationsPermissions3Subtitle: String {
		return NSLocalizedString("notifications_permissions_3_subtitle", comment: "")
	}

	static var notificationsPermissions3Title: String {
		return NSLocalizedString("notifications_permissions_3_title", comment: "")
	}

	static var notificationsPermissions4Push: String {
		return NSLocalizedString("notifications_permissions_4_push", comment: "")
	}

	static var notificationsPermissions4Subtitle: String {
		return NSLocalizedString("notifications_permissions_4_subtitle", comment: "")
	}

	static var notificationsPermissions4Title: String {
		return NSLocalizedString("notifications_permissions_4_title", comment: "")
	}

	static var notificationsPermissionsSettingsCell1: String {
		return NSLocalizedString("notifications_permissions_settings_cell1", comment: "")
	}

	static var notificationsPermissionsSettingsCell2: String {
		return NSLocalizedString("notifications_permissions_settings_cell2", comment: "")
	}

	static var notificationsPermissionsSettingsSection1: String {
		return NSLocalizedString("notifications_permissions_settings_section1", comment: "")
	}

	static var notificationsPermissionsSettingsSection2: String {
		return NSLocalizedString("notifications_permissions_settings_section2", comment: "")
	}

	static var notificationsPermissionsSettingsSubtitle: String {
		return NSLocalizedString("notifications_permissions_settings_subtitle", comment: "")
	}

	static var notificationsPermissionsSettingsTitle: String {
		return NSLocalizedString("notifications_permissions_settings_title", comment: "")
	}

	static var notificationsPermissionsSettingsTitleChat: String {
		return NSLocalizedString("notifications_permissions_settings_title_chat", comment: "")
	}

	static var notificationsPermissionsSettingsYesButton: String {
		return NSLocalizedString("notifications_permissions_settings_yes_button", comment: "")
	}

	static var notificationsPermissionsYesButton: String {
		return NSLocalizedString("notifications_permissions_yes_button", comment: "")
	}

	static var notificationsTitle: String {
		return NSLocalizedString("notifications_title", comment: "")
	}

	static func notificationsTypeLikeWName(_ var1: String) -> String {
		return String(format: NSLocalizedString("notifications_type_like_w_name", comment: ""), var1)
	}

	static func notificationsTypeLikeWNameWTitle(_ var1: String, _ var2: String) -> String {
		return String(format: NSLocalizedString("notifications_type_like_w_name_w_title", comment: ""), var1, var2)
	}

	static var notificationsTypeLikeButton: String {
		return NSLocalizedString("notifications_type_like_button", comment: "")
	}

	static var notificationsTypeSold: String {
		return NSLocalizedString("notifications_type_sold", comment: "")
	}

	static var notificationsTypeSoldButton: String {
		return NSLocalizedString("notifications_type_sold_button", comment: "")
	}

	static func notificationsTypeRating(_ var1: String) -> String {
		return String(format: NSLocalizedString("notifications_type_rating", comment: ""), var1)
	}

	static var notificationsTypeRatingButton: String {
		return NSLocalizedString("notifications_type_rating_button", comment: "")
	}

	static func notificationsTypeRatingUpdated(_ var1: String) -> String {
		return String(format: NSLocalizedString("notifications_type_rating_updated", comment: ""), var1)
	}

	static func notificationsTypeProductSuggested(_ var1: String) -> String {
		return String(format: NSLocalizedString("notifications_type_product_suggested", comment: ""), var1)
	}

	static func notificationsTypeProductSuggestedWTitle(_ var1: String, _ var2: String) -> String {
		return String(format: NSLocalizedString("notifications_type_product_suggested_w_title", comment: ""), var1, var2)
	}

	static var notificationsTypeProductSuggestedButton: String {
		return NSLocalizedString("notifications_type_product_suggested_button", comment: "")
	}

	static func notificationsTypeBuyersInterested(_ var1: Int) -> String {
		return String(format: NSLocalizedString("notifications_type_buyers_interested", comment: ""), var1)
	}

	static func notificationsTypeBuyersInterestedWTitle(_ var1: Int, _ var2: String) -> String {
		return String(format: NSLocalizedString("notifications_type_buyers_interested_w_title", comment: ""), var1, var2)
	}

	static var notificationsTypeBuyersInterestedButton: String {
		return NSLocalizedString("notifications_type_buyers_interested_button", comment: "")
	}

	static var notificationsTypeBuyersInterestedButtonDone: String {
		return NSLocalizedString("notifications_type_buyers_interested_button_done", comment: "")
	}

	static func notificationsTypeFacebookFriend(_ var1: String, _ var2: String) -> String {
		return String(format: NSLocalizedString("notifications_type_facebook_friend", comment: ""), var1, var2)
	}

	static var notificationsTypeFacebookFriendButton: String {
		return NSLocalizedString("notifications_type_facebook_friend_button", comment: "")
	}

	static var notificationsTypeWelcomeSubtitle: String {
		return NSLocalizedString("notifications_type_welcome_subtitle", comment: "")
	}

	static func notificationsTypeWelcomeSubtitleWCity(_ var1: String) -> String {
		return String(format: NSLocalizedString("notifications_type_welcome_subtitle_w_city", comment: ""), var1)
	}

	static var notificationsTypeWelcomeTitle: String {
		return NSLocalizedString("notifications_type_welcome_title", comment: "")
	}

	static var notificationsTypeWelcomeButton: String {
		return NSLocalizedString("notifications_type_welcome_button", comment: "")
	}

	static var notificationsUserWoName: String {
		return NSLocalizedString("notifications_user_wo_name", comment: "")
	}

	static var npsSurveyTitle: String {
		return NSLocalizedString("nps_survey_title", comment: "")
	}

	static var npsSurveySubtitle: String {
		return NSLocalizedString("nps_survey_subtitle", comment: "")
	}

	static var npsSurveyVeryBad: String {
		return NSLocalizedString("nps_survey_very_bad", comment: "")
	}

	static var npsSurveyVeryGood: String {
		return NSLocalizedString("nps_survey_very_good", comment: "")
	}

	static var onboardingDirectCameraAlertTitle: String {
		return NSLocalizedString("onboarding_direct_camera_alert_title", comment: "")
	}

	static var onboardingDirectCameraAlertSubtitle: String {
		return NSLocalizedString("onboarding_direct_camera_alert_subtitle", comment: "")
	}

	static var onboardingLoginSkip: String {
		return NSLocalizedString("onboarding_login_skip", comment: "")
	}

	static var onboardingPostingTitleA: String {
		return NSLocalizedString("onboarding_posting_title_a", comment: "")
	}

	static var onboardingPostingTitleB: String {
		return NSLocalizedString("onboarding_posting_title_b", comment: "")
	}

	static var onboardingPostingTitleC: String {
		return NSLocalizedString("onboarding_posting_title_c", comment: "")
	}

	static var onboardingPostingSubtitleA: String {
		return NSLocalizedString("onboarding_posting_subtitle_a", comment: "")
	}

	static var onboardingPostingSubtitleB: String {
		return NSLocalizedString("onboarding_posting_subtitle_b", comment: "")
	}

	static var onboardingPostingSubtitleC: String {
		return NSLocalizedString("onboarding_posting_subtitle_c", comment: "")
	}

	static var onboardingPostingButtonA: String {
		return NSLocalizedString("onboarding_posting_button_a", comment: "")
	}

	static var onboardingPostingButtonB: String {
		return NSLocalizedString("onboarding_posting_button_b", comment: "")
	}

	static var onboardingPostingButtonC: String {
		return NSLocalizedString("onboarding_posting_button_c", comment: "")
	}

	static var passiveBuyersTitle: String {
		return NSLocalizedString("passive_buyers_title", comment: "")
	}

	static var passiveBuyersMessage: String {
		return NSLocalizedString("passive_buyers_message", comment: "")
	}

	static func passiveBuyersButton(_ var1: Int) -> String {
		return String(format: NSLocalizedString("passive_buyers_button", comment: ""), var1)
	}

	static var passiveBuyersNotAvailable: String {
		return NSLocalizedString("passive_buyers_not_available", comment: "")
	}

	static var passiveBuyersContactError: String {
		return NSLocalizedString("passive_buyers_contact_error", comment: "")
	}

	static var passiveBuyersContactSuccess: String {
		return NSLocalizedString("passive_buyers_contact_success", comment: "")
	}

	static var productAskAQuestionButton: String {
		return NSLocalizedString("product_ask_a_question_button", comment: "")
	}

	static var productAutoGeneratedTitleLabel: String {
		return NSLocalizedString("product_auto_generated_title_label", comment: "")
	}

	static var productAutoGeneratedTranslatedTitleLabel: String {
		return NSLocalizedString("product_auto_generated_translated_title_label", comment: "")
	}

	static var productBubbleOneUserInterested: String {
		return NSLocalizedString("product_bubble_one_user_interested", comment: "")
	}

	static var productBubbleSeveralUsersInterested: String {
		return NSLocalizedString("product_bubble_several_users_interested", comment: "")
	}

	static var productBubbleFavoriteText: String {
		return NSLocalizedString("product_bubble_favorite_text", comment: "")
	}

	static var productBubbleFavoriteButton: String {
		return NSLocalizedString("product_bubble_favorite_button", comment: "")
	}

	static var productChatDirectErrorBlockedUserMessage: String {
		return NSLocalizedString("product_chat_direct_error_blocked_user_message", comment: "")
	}

	static func productChatDirectMessage(_ var1: String) -> String {
		return String(format: NSLocalizedString("product_chat_direct_message", comment: ""), var1)
	}

	static var productChatDirectMessageSending: String {
		return NSLocalizedString("product_chat_direct_message_sending", comment: "")
	}

	static var productChatWithSellerButton: String {
		return NSLocalizedString("product_chat_with_seller_button", comment: "")
	}

	static func productChatWithSellerNameButton(_ var1: String) -> String {
		return String(format: NSLocalizedString("product_chat_with_seller_name_button", comment: ""), var1)
	}

	static var productChatWithSellerSendOk: String {
		return NSLocalizedString("product_chat_with_seller_send_ok", comment: "")
	}

	static var productContinueChattingButton: String {
		return NSLocalizedString("product_continue_chatting_button", comment: "")
	}

	static var productCreateCommercialButton: String {
		return NSLocalizedString("product_create_commercial_button", comment: "")
	}

	static var productDateMoreThanXMonthsAgo: String {
		return NSLocalizedString("product_date_more_than_X_months_ago", comment: "")
	}

	static var productDateOneDayAgo: String {
		return NSLocalizedString("product_date_one_day_ago", comment: "")
	}

	static var productDateOneHourAgo: String {
		return NSLocalizedString("product_date_one_hour_ago", comment: "")
	}

	static var productDateOneMinuteAgo: String {
		return NSLocalizedString("product_date_one_minute_ago", comment: "")
	}

	static var productDateOneMonthAgo: String {
		return NSLocalizedString("product_date_one_month_ago", comment: "")
	}

	static var productDateXDaysAgo: String {
		return NSLocalizedString("product_date_X_days_ago", comment: "")
	}

	static var productDateXHoursAgo: String {
		return NSLocalizedString("product_date_X_hours_ago", comment: "")
	}

	static var productDateXMinutesAgo: String {
		return NSLocalizedString("product_date_X_minutes_ago", comment: "")
	}

	static var productDateXMonthsAgo: String {
		return NSLocalizedString("product_date_X_months_ago", comment: "")
	}

	static var productDeleteConfirmCancelButton: String {
		return NSLocalizedString("product_delete_confirm_cancel_button", comment: "")
	}

	static var productDeleteConfirmMessage: String {
		return NSLocalizedString("product_delete_confirm_message", comment: "")
	}

	static var productDeleteConfirmOkButton: String {
		return NSLocalizedString("product_delete_confirm_ok_button", comment: "")
	}

	static var productDeleteConfirmSoldButton: String {
		return NSLocalizedString("product_delete_confirm_sold_button", comment: "")
	}

	static var productDeleteConfirmTitle: String {
		return NSLocalizedString("product_delete_confirm_title", comment: "")
	}

	static var productDeleteSendErrorGeneric: String {
		return NSLocalizedString("product_delete_send_error_generic", comment: "")
	}

	static var productDeleteSoldConfirmMessage: String {
		return NSLocalizedString("product_delete_sold_confirm_message", comment: "")
	}

	static var productDeleteSuccessMessage: String {
		return NSLocalizedString("product_delete_success_message", comment: "")
	}

	static var productDeletePostButtonTitle: String {
		return NSLocalizedString("product_delete_post_button_title", comment: "")
	}

	static var productDeletePostTitle: String {
		return NSLocalizedString("product_delete_post_title", comment: "")
	}

	static var productDeletePostSubtitle: String {
		return NSLocalizedString("product_delete_post_subtitle", comment: "")
	}

	static func productDistanceMoreThanFromYou(_ var1: String) -> String {
		return String(format: NSLocalizedString("product_distance_more_than_from_you", comment: ""), var1)
	}

	static func productDistanceXFromYou(_ var1: String) -> String {
		return String(format: NSLocalizedString("product_distance_X_from_you", comment: ""), var1)
	}

	static var productFavoriteDirectMessage: String {
		return NSLocalizedString("product_favorite_direct_message", comment: "")
	}

	static var productFreePrice: String {
		return NSLocalizedString("product_free_price", comment: "")
	}

	static var productSellAgainFreeButton: String {
		return NSLocalizedString("product_sell_again_free_button", comment: "")
	}

	static var productSellAgainFreeConfirmCancelButton: String {
		return NSLocalizedString("product_sell_again_free_confirm_cancel_button", comment: "")
	}

	static var productSellAgainFreeConfirmMessage: String {
		return NSLocalizedString("product_sell_again_free_confirm_message", comment: "")
	}

	static var productSellAgainFreeConfirmOkButton: String {
		return NSLocalizedString("product_sell_again_free_confirm_ok_button", comment: "")
	}

	static var productSellAgainFreeSuccessMessage: String {
		return NSLocalizedString("product_sell_again_free_success_message", comment: "")
	}

	static var productSellAgainFreeConfirmTitle: String {
		return NSLocalizedString("product_sell_again_free_confirm_title", comment: "")
	}

	static var productListBannerCellTitle: String {
		return NSLocalizedString("product_list_banner_cell_title", comment: "")
	}

	static var productListItemGivenAwayStatusLabel: String {
		return NSLocalizedString("product_list_item_given_away_status_label", comment: "")
	}

	static var productListItemSoldStatusLabel: String {
		return NSLocalizedString("product_list_item_sold_status_label", comment: "")
	}

	static var productListItemTimeHourLabel: String {
		return NSLocalizedString("product_list_item_time_hour_label", comment: "")
	}

	static var productListItemTimeMinuteLabel: String {
		return NSLocalizedString("product_list_item_time_minute_label", comment: "")
	}

	static var productListNoProductsBody: String {
		return NSLocalizedString("product_list_no_products_body", comment: "")
	}

	static var productListNoProductsTitle: String {
		return NSLocalizedString("product_list_no_products_title", comment: "")
	}

	static var productMarkAsSoldFreeConfirmCancelButton: String {
		return NSLocalizedString("product_mark_as_sold_free_confirm_cancel_button", comment: "")
	}

	static var productMarkAsSoldFreeButton: String {
		return NSLocalizedString("product_mark_as_sold_free_button", comment: "")
	}

	static var productMarkAsSoldFreeConfirmMessage: String {
		return NSLocalizedString("product_mark_as_sold_free_confirm_message", comment: "")
	}

	static var productMarkAsSoldFreeConfirmOkButton: String {
		return NSLocalizedString("product_mark_as_sold_free_confirm_ok_button", comment: "")
	}

	static var productMarkAsSoldFreeConfirmTitle: String {
		return NSLocalizedString("product_mark_as_sold_free_confirm_title", comment: "")
	}

	static var productMarkAsSoldFreeSuccessMessage: String {
		return NSLocalizedString("product_mark_as_sold_free_success_message", comment: "")
	}

	static var productMarkAsSoldButton: String {
		return NSLocalizedString("product_mark_as_sold_button", comment: "")
	}

	static var productMarkAsSoldConfirmCancelButton: String {
		return NSLocalizedString("product_mark_as_sold_confirm_cancel_button", comment: "")
	}

	static var productMarkAsSoldConfirmMessage: String {
		return NSLocalizedString("product_mark_as_sold_confirm_message", comment: "")
	}

	static var productMarkAsSoldConfirmOkButton: String {
		return NSLocalizedString("product_mark_as_sold_confirm_ok_button", comment: "")
	}

	static var productMarkAsSoldConfirmTitle: String {
		return NSLocalizedString("product_mark_as_sold_confirm_title", comment: "")
	}

	static var productMarkAsSoldErrorGeneric: String {
		return NSLocalizedString("product_mark_as_sold_error_generic", comment: "")
	}

	static var productMarkAsSoldSuccessMessage: String {
		return NSLocalizedString("product_mark_as_sold_success_message", comment: "")
	}

	static var productMoreInfoTooltipPart1: String {
		return NSLocalizedString("product_more_info_tooltip_part_1", comment: "")
	}

	static func productMoreInfoTooltipPart2(_ var1: String) -> String {
		return String(format: NSLocalizedString("product_more_info_tooltip_part_2", comment: ""), var1)
	}

	static var productMoreInfoOpenButton: String {
		return NSLocalizedString("product_more_info_open_button", comment: "")
	}

	static var productMoreInfoRelatedTitle: String {
		return NSLocalizedString("product_more_info_related_title", comment: "")
	}

	static var productMoreInfoRelatedViewMore: String {
		return NSLocalizedString("product_more_info_related_view_more", comment: "")
	}

	static var productNegotiablePrice: String {
		return NSLocalizedString("product_negotiable_price", comment: "")
	}

	static var productOnboardingFingerScrollLabel: String {
		return NSLocalizedString("product_onboarding_finger_scroll_label", comment: "")
	}

	static var productOnboardingFingerSwipeLabel: String {
		return NSLocalizedString("product_onboarding_finger_swipe_label", comment: "")
	}

	static var productOnboardingFingerTapLabel: String {
		return NSLocalizedString("product_onboarding_finger_tap_label", comment: "")
	}

	static var productOnboardingShowAgainButtonTitle: String {
		return NSLocalizedString("product_onboarding_show_again_button_title", comment: "")
	}

	static var productOpenCommercialButton: String {
		return NSLocalizedString("product_open_commercial_button", comment: "")
	}

	static var productOptionEdit: String {
		return NSLocalizedString("product_option_edit", comment: "")
	}

	static var productOptionShare: String {
		return NSLocalizedString("product_option_share", comment: "")
	}

	static var productOptionShowCommercial: String {
		return NSLocalizedString("product_option_show_commercial", comment: "")
	}

	static var productPopularNearYou: String {
		return NSLocalizedString("product_popular_near_you", comment: "")
	}

	static var productPostCameraFirstTimeAlertSubtitle: String {
		return NSLocalizedString("product_post_camera_first_time_alert_subtitle", comment: "")
	}

	static var productPostCameraFirstTimeAlertTitle: String {
		return NSLocalizedString("product_post_camera_first_time_alert_title", comment: "")
	}

	static var productPostCameraPermissionsButton: String {
		return NSLocalizedString("product_post_camera_permissions_button", comment: "")
	}

	static var productPostCameraPermissionsSubtitle: String {
		return NSLocalizedString("product_post_camera_permissions_subtitle", comment: "")
	}

	static var productPostCameraPermissionsTitle: String {
		return NSLocalizedString("product_post_camera_permissions_title", comment: "")
	}

	static var productPostCameraTab: String {
		return NSLocalizedString("product_post_camera_tab", comment: "")
	}

	static var productPostCloseAlertCloseButton: String {
		return NSLocalizedString("product_post_close_alert_close_button", comment: "")
	}

	static var productPostCloseAlertDescription: String {
		return NSLocalizedString("product_post_close_alert_description", comment: "")
	}

	static var productPostCloseAlertOkButton: String {
		return NSLocalizedString("product_post_close_alert_ok_button", comment: "")
	}

	static var productPostCloseAlertTitle: String {
		return NSLocalizedString("product_post_close_alert_title", comment: "")
	}

	static var productPostConfirmationAnother: String {
		return NSLocalizedString("product_post_confirmation_another", comment: "")
	}

	static var productPostConfirmationAnotherButton: String {
		return NSLocalizedString("product_post_confirmation_another_button", comment: "")
	}

	static var productPostConfirmationEdit: String {
		return NSLocalizedString("product_post_confirmation_edit", comment: "")
	}

	static var productPostDone: String {
		return NSLocalizedString("product_post_done", comment: "")
	}

	static var productPostEmptyGalleryButton: String {
		return NSLocalizedString("product_post_empty_gallery_button", comment: "")
	}

	static var productPostEmptyGallerySubtitle: String {
		return NSLocalizedString("product_post_empty_gallery_subtitle", comment: "")
	}

	static var productPostEmptyGalleryTitle: String {
		return NSLocalizedString("product_post_empty_gallery_title", comment: "")
	}

	static var productPostFreeCameraFirstTimeAlertTitle: String {
		return NSLocalizedString("product_post_free_camera_first_time_alert_title", comment: "")
	}

	static var productPostFreeCameraFirstTimeAlertSubtitle: String {
		return NSLocalizedString("product_post_free_camera_first_time_alert_subtitle", comment: "")
	}

	static var productPostFreeConfirmationAnotherButton: String {
		return NSLocalizedString("product_post_free_confirmation_another_button", comment: "")
	}

	static var productPostGalleryLoadImageErrorSubtitle: String {
		return NSLocalizedString("product_post_gallery_load_image_error_subtitle", comment: "")
	}

	static var productPostGalleryLoadImageErrorTitle: String {
		return NSLocalizedString("product_post_gallery_load_image_error_title", comment: "")
	}

	static var productPostGalleryMultiplePicsSelected: String {
		return NSLocalizedString("product_post_gallery_multiple_pics_selected", comment: "")
	}

	static var productPostGalleryPermissionsButton: String {
		return NSLocalizedString("product_post_gallery_permissions_button", comment: "")
	}

	static var productPostGalleryPermissionsSubtitle: String {
		return NSLocalizedString("product_post_gallery_permissions_subtitle", comment: "")
	}

	static var productPostGalleryPermissionsTitle: String {
		return NSLocalizedString("product_post_gallery_permissions_title", comment: "")
	}

	static var productPostGallerySelectPicturesTitle: String {
		return NSLocalizedString("product_post_gallery_select_pictures_title", comment: "")
	}

	static var productPostGallerySelectPicturesSubtitle: String {
		return NSLocalizedString("product_post_gallery_select_pictures_subtitle", comment: "")
	}

	static var productPostGalleryTab: String {
		return NSLocalizedString("product_post_gallery_tab", comment: "")
	}

	static var productPostGenericError: String {
		return NSLocalizedString("product_post_generic_error", comment: "")
	}

	static var productPostIncentiveBike: String {
		return NSLocalizedString("product_post_incentive_bike", comment: "")
	}

	static var productPostIncentiveCar: String {
		return NSLocalizedString("product_post_incentive_car", comment: "")
	}

	static var productPostIncentiveDresser: String {
		return NSLocalizedString("product_post_incentive_dresser", comment: "")
	}

	static var productPostIncentiveFurniture: String {
		return NSLocalizedString("product_post_incentive_furniture", comment: "")
	}

	static var productPostIncentiveGotAny: String {
		return NSLocalizedString("product_post_incentive_got_any", comment: "")
	}

	static var productPostIncentiveGotAnyFree: String {
		return NSLocalizedString("product_post_incentive_got_any_free", comment: "")
	}

	static var productPostIncentiveKidsClothes: String {
		return NSLocalizedString("product_post_incentive_kids_clothes", comment: "")
	}

	static func productPostIncentiveLookingFor(_ var1: String) -> String {
		return String(format: NSLocalizedString("product_post_incentive_looking_for", comment: ""), var1)
	}

	static var productPostIncentiveMotorcycle: String {
		return NSLocalizedString("product_post_incentive_motorcycle", comment: "")
	}

	static var productPostIncentivePs4: String {
		return NSLocalizedString("product_post_incentive_ps4", comment: "")
	}

	static var productPostIncentiveSubtitle: String {
		return NSLocalizedString("product_post_incentive_subtitle", comment: "")
	}

	static var productPostIncentiveSubtitleFree: String {
		return NSLocalizedString("product_post_incentive_subtitle_free", comment: "")
	}

	static var productPostIncentiveTitle: String {
		return NSLocalizedString("product_post_incentive_title", comment: "")
	}

	static var productPostIncentiveToys: String {
		return NSLocalizedString("product_post_incentive_toys", comment: "")
	}

	static var productPostIncentiveTv: String {
		return NSLocalizedString("product_post_incentive_tv", comment: "")
	}

	static var productPostLoginMessage: String {
		return NSLocalizedString("product_post_login_message", comment: "")
	}

	static var productPostNetworkError: String {
		return NSLocalizedString("product_post_network_error", comment: "")
	}

	static var productPostPriceLabel: String {
		return NSLocalizedString("product_post_price_label", comment: "")
	}

	static var productPostProductPosted: String {
		return NSLocalizedString("product_post_product_posted", comment: "")
	}

	static var productPostProductPostedNotLogged: String {
		return NSLocalizedString("product_post_product_posted_not_logged", comment: "")
	}

	static var productPostRetake: String {
		return NSLocalizedString("product_post_retake", comment: "")
	}

	static var productPostRetryButton: String {
		return NSLocalizedString("product_post_retry_button", comment: "")
	}

	static var productPostUsePhoto: String {
		return NSLocalizedString("product_post_use_photo", comment: "")
	}

	static var productPostUsePhotoNotLogged: String {
		return NSLocalizedString("product_post_use_photo_not_logged", comment: "")
	}

	static var productPriceLabel: String {
		return NSLocalizedString("product_price_label", comment: "")
	}

	static var productReportConfirmMessage: String {
		return NSLocalizedString("product_report_confirm_message", comment: "")
	}

	static var productReportConfirmTitle: String {
		return NSLocalizedString("product_report_confirm_title", comment: "")
	}

	static var productReportProductButton: String {
		return NSLocalizedString("product_report_product_button", comment: "")
	}

	static var productReportedErrorGeneric: String {
		return NSLocalizedString("product_reported_error_generic", comment: "")
	}

	static var productReportedSuccessMessage: String {
		return NSLocalizedString("product_reported_success_message", comment: "")
	}

	static var productReportingLoadingMessage: String {
		return NSLocalizedString("product_reporting_loading_message", comment: "")
	}

	static var productSearchNoProductsBody: String {
		return NSLocalizedString("product_search_no_products_body", comment: "")
	}

	static var productSearchNoProductsTitle: String {
		return NSLocalizedString("product_search_no_products_title", comment: "")
	}

	static var productSellAgainButton: String {
		return NSLocalizedString("product_sell_again_button", comment: "")
	}

	static var productSellAgainConfirmCancelButton: String {
		return NSLocalizedString("product_sell_again_confirm_cancel_button", comment: "")
	}

	static var productSellAgainConfirmMessage: String {
		return NSLocalizedString("product_sell_again_confirm_message", comment: "")
	}

	static var productSellAgainConfirmOkButton: String {
		return NSLocalizedString("product_sell_again_confirm_ok_button", comment: "")
	}

	static var productSellAgainConfirmTitle: String {
		return NSLocalizedString("product_sell_again_confirm_title", comment: "")
	}

	static var productSellAgainErrorGeneric: String {
		return NSLocalizedString("product_sell_again_error_generic", comment: "")
	}

	static var productSellAgainSuccessMessage: String {
		return NSLocalizedString("product_sell_again_success_message", comment: "")
	}

	static var productSellCameraPermissionsError: String {
		return NSLocalizedString("product_sell_camera_permissions_error", comment: "")
	}

	static var productSellCameraRestrictedError: String {
		return NSLocalizedString("product_sell_camera_restricted_error", comment: "")
	}

	static var productSellPhotolibraryPermissionsError: String {
		return NSLocalizedString("product_sell_photolibrary_permissions_error", comment: "")
	}

	static var productSellPhotolibraryRestrictedError: String {
		return NSLocalizedString("product_sell_photolibrary_restricted_error", comment: "")
	}

	static var productShareFullscreenTitle: String {
		return NSLocalizedString("product_share_fullscreen_title", comment: "")
	}

	static var productShareFullscreenSubtitle: String {
		return NSLocalizedString("product_share_fullscreen_subtitle", comment: "")
	}

	static var productShareNavbarButton: String {
		return NSLocalizedString("product_share_navbar_button", comment: "")
	}

	static var productShareBody: String {
		return NSLocalizedString("product_share_body", comment: "")
	}

	static var productIsMineShareBody: String {
		return NSLocalizedString("product_is_mine_share_body", comment: "")
	}

	static var productIsMineShareBodyFree: String {
		return NSLocalizedString("product_is_mine_share_body_free", comment: "")
	}

	static var productShareCopylinkOk: String {
		return NSLocalizedString("product_share_copylink_ok", comment: "")
	}

	static var productShareEmailError: String {
		return NSLocalizedString("product_share_email_error", comment: "")
	}

	static var productShareGenericError: String {
		return NSLocalizedString("product_share_generic_error", comment: "")
	}

	static var productShareGenericOk: String {
		return NSLocalizedString("product_share_generic_ok", comment: "")
	}

	static var productShareSmsError: String {
		return NSLocalizedString("product_share_sms_error", comment: "")
	}

	static var productShareSmsOk: String {
		return NSLocalizedString("product_share_sms_ok", comment: "")
	}

	static var productShareTelegramError: String {
		return NSLocalizedString("product_share_telegram_error", comment: "")
	}

	static var productShareTitleLabel: String {
		return NSLocalizedString("product_share_title_label", comment: "")
	}

	static var productShareWhatsappError: String {
		return NSLocalizedString("product_share_whatsapp_error", comment: "")
	}

	static func productSharePostedBy(_ var1: String) -> String {
		return String(format: NSLocalizedString("product_share_posted_by", comment: ""), var1)
	}

	static func productShareTitleOnLetgo(_ var1: String) -> String {
		return String(format: NSLocalizedString("product_share_title_on_letgo", comment: ""), var1)
	}

	static func productStickersSelectionWName(_ var1: String) -> String {
		return String(format: NSLocalizedString("product_stickers_selection_w_name", comment: ""), var1)
	}

	static var productStickersSelectionWoName: String {
		return NSLocalizedString("product_stickers_selection_wo_name", comment: "")
	}

	static var profileBlockedByMeLabel: String {
		return NSLocalizedString("profile_blocked_by_me_label", comment: "")
	}

	static func profileBlockedByMeLabelWName(_ var1: String) -> String {
		return String(format: NSLocalizedString("profile_blocked_by_me_label_w_name", comment: ""), var1)
	}

	static var profileBlockedByOtherLabel: String {
		return NSLocalizedString("profile_blocked_by_other_label", comment: "")
	}

	static var profileFavouritesMyUserNoProductsButton: String {
		return NSLocalizedString("profile_favourites_my_user_no_products_button", comment: "")
	}

	static var profileFavouritesMyUserNoProductsLabel: String {
		return NSLocalizedString("profile_favourites_my_user_no_products_label", comment: "")
	}

	static var profileFavouritesProductsTab: String {
		return NSLocalizedString("profile_favourites_products_tab", comment: "")
	}

	static var profilePermissionsAlertCancel: String {
		return NSLocalizedString("profile_permissions_alert_cancel", comment: "")
	}

	static var profilePermissionsAlertMessage: String {
		return NSLocalizedString("profile_permissions_alert_message", comment: "")
	}

	static var profilePermissionsAlertOk: String {
		return NSLocalizedString("profile_permissions_alert_ok", comment: "")
	}

	static var profilePermissionsAlertTitle: String {
		return NSLocalizedString("profile_permissions_alert_title", comment: "")
	}

	static var profilePermissionsHeaderMessage: String {
		return NSLocalizedString("profile_permissions_header_message", comment: "")
	}

	static var profileReviewsCount: String {
		return NSLocalizedString("profile_reviews_count", comment: "")
	}

	static var profileSellingNoProductsLabel: String {
		return NSLocalizedString("profile_selling_no_products_label", comment: "")
	}

	static var profileSellingOtherUserNoProductsButton: String {
		return NSLocalizedString("profile_selling_other_user_no_products_button", comment: "")
	}

	static var profileSellingProductsTab: String {
		return NSLocalizedString("profile_selling_products_tab", comment: "")
	}

	static var profileSoldNoProductsLabel: String {
		return NSLocalizedString("profile_sold_no_products_label", comment: "")
	}

	static var profileSoldOtherNoProductsButton: String {
		return NSLocalizedString("profile_sold_other_no_products_button", comment: "")
	}

	static var profileSoldProductsTab: String {
		return NSLocalizedString("profile_sold_products_tab", comment: "")
	}

	static var profileVerifiedAccountsMyUser: String {
		return NSLocalizedString("profile_verified_accounts_my_user", comment: "")
	}

	static var profileVerifiedAccountsOtherUser: String {
		return NSLocalizedString("profile_verified_accounts_other_user", comment: "")
	}

	static var profileVerifyEmailButton: String {
		return NSLocalizedString("profile_verify_email_button", comment: "")
	}

	static var profileVerifyEmailMessageNotPresent: String {
		return NSLocalizedString("profile_verify_email_message_not_present", comment: "")
	}

	static func profileVerifyEmailMessagePresent(_ var1: String) -> String {
		return String(format: NSLocalizedString("profile_verify_email_message_present", comment: ""), var1)
	}

	static var profileVerifyEmailPlaceholder: String {
		return NSLocalizedString("profile_verify_email_placeholder", comment: "")
	}

	static var profileVerifyEmailSuccess: String {
		return NSLocalizedString("profile_verify_email_success", comment: "")
	}

	static var profileVerifyEmailTitle: String {
		return NSLocalizedString("profile_verify_email_title", comment: "")
	}

	static var profileVerifyEmailTooManyRequests: String {
		return NSLocalizedString("profile_verify_email_too_many_requests", comment: "")
	}

	static var profileVerifyFacebookButton: String {
		return NSLocalizedString("profile_verify_facebook_button", comment: "")
	}

	static var profileVerifyFacebookMessage: String {
		return NSLocalizedString("profile_verify_facebook_message", comment: "")
	}

	static var profileVerifyFacebookTitle: String {
		return NSLocalizedString("profile_verify_facebook_title", comment: "")
	}

	static var profileVerifyGoogleButton: String {
		return NSLocalizedString("profile_verify_google_button", comment: "")
	}

	static var profileVerifyGoogleMessage: String {
		return NSLocalizedString("profile_verify_google_message", comment: "")
	}

	static var profileVerifyGoogleTitle: String {
		return NSLocalizedString("profile_verify_google_title", comment: "")
	}

	static var profileBuildTrustButton: String {
		return NSLocalizedString("profile_build_trust_button", comment: "")
	}

	static var profileConnectAccountsMessage: String {
		return NSLocalizedString("profile_connect_accounts_message", comment: "")
	}

	static var rateBuyersTitle: String {
		return NSLocalizedString("rate_buyers_title", comment: "")
	}

	static var rateBuyersMessage: String {
		return NSLocalizedString("rate_buyers_message", comment: "")
	}

	static var rateBuyersSubMessage: String {
		return NSLocalizedString("rate_buyers_sub_message", comment: "")
	}

	static var rateBuyersNotOnLetgoButton: String {
		return NSLocalizedString("rate_buyers_not_on_letgo_button", comment: "")
	}

	static var ratingListActionReportReview: String {
		return NSLocalizedString("rating_list_action_report_review", comment: "")
	}

	static var ratingListActionReportReviewErrorMessage: String {
		return NSLocalizedString("rating_list_action_report_review_error_message", comment: "")
	}

	static var ratingListActionReportReviewSuccessMessage: String {
		return NSLocalizedString("rating_list_action_report_review_success_message", comment: "")
	}

	static var ratingListActionReviewUser: String {
		return NSLocalizedString("rating_list_action_review_user", comment: "")
	}

	static var ratingListLoadingErrorMessage: String {
		return NSLocalizedString("rating_list_loading_error_message", comment: "")
	}

	static func ratingListRatingTypeBuyerTextLabel(_ var1: String) -> String {
		return String(format: NSLocalizedString("rating_list_rating_type_buyer_text_label", comment: ""), var1)
	}

	static func ratingListRatingTypeConversationTextLabel(_ var1: String) -> String {
		return String(format: NSLocalizedString("rating_list_rating_type_conversation_text_label", comment: ""), var1)
	}

	static func ratingListRatingTypeSellerTextLabel(_ var1: String) -> String {
		return String(format: NSLocalizedString("rating_list_rating_type_seller_text_label", comment: ""), var1)
	}

	static var ratingListRatingStatusPending: String {
		return NSLocalizedString("rating_list_rating_status_pending", comment: "")
	}

	static var ratingListTitle: String {
		return NSLocalizedString("rating_list_title", comment: "")
	}

	static var ratingViewDontAskAgainButton: String {
		return NSLocalizedString("rating_view_dont_ask_again_button", comment: "")
	}

	static var ratingViewRateUsLabel: String {
		return NSLocalizedString("rating_view_rate_us_label", comment: "")
	}

	static var ratingViewRemindLaterButton: String {
		return NSLocalizedString("rating_view_remind_later_button", comment: "")
	}

	static var ratingViewTitleLabel: String {
		return NSLocalizedString("rating_view_title_label", comment: "")
	}

	static var ratingViewTitleLabelUppercase: String {
		return NSLocalizedString("rating_view_title_label_uppercase", comment: "")
	}

	static var relatedItemsTitle: String {
		return NSLocalizedString("related_items_title", comment: "")
	}

	static var reportUserCounterfeit: String {
		return NSLocalizedString("report_user_counterfeit", comment: "")
	}

	static var reportUserErrorAlreadyReported: String {
		return NSLocalizedString("report_user_error_already_reported", comment: "")
	}

	static var reportUserInactive: String {
		return NSLocalizedString("report_user_inactive", comment: "")
	}

	static var reportUserMia: String {
		return NSLocalizedString("report_user_mia", comment: "")
	}

	static var reportUserOffensive: String {
		return NSLocalizedString("report_user_offensive", comment: "")
	}

	static var reportUserOthers: String {
		return NSLocalizedString("report_user_others", comment: "")
	}

	static var reportUserProhibitedItems: String {
		return NSLocalizedString("report_user_prohibited_items", comment: "")
	}

	static var reportUserScammer: String {
		return NSLocalizedString("report_user_scammer", comment: "")
	}

	static var reportUserSendButton: String {
		return NSLocalizedString("report_user_send_button", comment: "")
	}

	static var reportUserSendFailure: String {
		return NSLocalizedString("report_user_send_failure", comment: "")
	}

	static var reportUserSendOk: String {
		return NSLocalizedString("report_user_send_ok", comment: "")
	}

	static var reportUserSpammer: String {
		return NSLocalizedString("report_user_spammer", comment: "")
	}

	static var reportUserSuspcious: String {
		return NSLocalizedString("report_user_suspcious", comment: "")
	}

	static var reportUserTextPlaceholder: String {
		return NSLocalizedString("report_user_text_placeholder", comment: "")
	}

	static var reportUserTitle: String {
		return NSLocalizedString("report_user_title", comment: "")
	}

	static var resetPasswordEmailFieldHint: String {
		return NSLocalizedString("reset_password_email_field_hint", comment: "")
	}

	static var resetPasswordInstructions: String {
		return NSLocalizedString("reset_password_instructions", comment: "")
	}

	static var resetPasswordSendButton: String {
		return NSLocalizedString("reset_password_send_button", comment: "")
	}

	static var resetPasswordSendErrorGeneric: String {
		return NSLocalizedString("reset_password_send_error_generic", comment: "")
	}

	static var resetPasswordSendErrorInvalidEmail: String {
		return NSLocalizedString("reset_password_send_error_invalid_email", comment: "")
	}

	static func resetPasswordSendErrorUserNotFoundOrWrongPassword(_ var1: String) -> String {
		return String(format: NSLocalizedString("reset_password_send_error_user_not_found_or_wrong_password", comment: ""), var1)
	}

	static func resetPasswordSendOk(_ var1: String) -> String {
		return String(format: NSLocalizedString("reset_password_send_ok", comment: ""), var1)
	}

	static var resetPasswordSendTooManyRequests: String {
		return NSLocalizedString("reset_password_send_too_many_requests", comment: "")
	}

	static var resetPasswordTitle: String {
		return NSLocalizedString("reset_password_title", comment: "")
	}

	static var sellBackButton: String {
		return NSLocalizedString("sell_back_button", comment: "")
	}

	static var sellCategorySelectionLabel: String {
		return NSLocalizedString("sell_category_selection_label", comment: "")
	}

	static var sellChooseCategoryDialogCancelButton: String {
		return NSLocalizedString("sell_choose_category_dialog_cancel_button", comment: "")
	}

	static var sellChooseCategoryDialogTitle: String {
		return NSLocalizedString("sell_choose_category_dialog_title", comment: "")
	}

	static var sellDescriptionFieldHint: String {
		return NSLocalizedString("sell_description_field_hint", comment: "")
	}

	static var sellDescriptionInformation: String {
		return NSLocalizedString("sell_description_information", comment: "")
	}

	static var sellPictureImageSourceCameraButton: String {
		return NSLocalizedString("sell_picture_image_source_camera_button", comment: "")
	}

	static var sellPictureImageSourceCameraRollButton: String {
		return NSLocalizedString("sell_picture_image_source_camera_roll_button", comment: "")
	}

	static var sellPictureImageSourceCancelButton: String {
		return NSLocalizedString("sell_picture_image_source_cancel_button", comment: "")
	}

	static var sellPictureImageSourceTitle: String {
		return NSLocalizedString("sell_picture_image_source_title", comment: "")
	}

	static var sellPictureLabel: String {
		return NSLocalizedString("sell_picture_label", comment: "")
	}

	static var sellPictureSaveIntoCameraRollErrorGeneric: String {
		return NSLocalizedString("sell_picture_save_into_camera_roll_error_generic", comment: "")
	}

	static var sellPictureSaveIntoCameraRollLoading: String {
		return NSLocalizedString("sell_picture_save_into_camera_roll_loading", comment: "")
	}

	static var sellPictureSaveIntoCameraRollOk: String {
		return NSLocalizedString("sell_picture_save_into_camera_roll_ok", comment: "")
	}

	static var sellPictureSelectedCancelButton: String {
		return NSLocalizedString("sell_picture_selected_cancel_button", comment: "")
	}

	static var sellPictureSelectedDeleteButton: String {
		return NSLocalizedString("sell_picture_selected_delete_button", comment: "")
	}

	static var sellPictureSelectedSaveIntoCameraRollButton: String {
		return NSLocalizedString("sell_picture_selected_save_into_camera_roll_button", comment: "")
	}

	static var sellPictureSelectedTitle: String {
		return NSLocalizedString("sell_picture_selected_title", comment: "")
	}

	static var sellPriceField: String {
		return NSLocalizedString("sell_price_field", comment: "")
	}

	static var sellPostFreeLabel: String {
		return NSLocalizedString("sell_post_free_label", comment: "")
	}

	static var sellSendErrorInvalidCategory: String {
		return NSLocalizedString("sell_send_error_invalid_category", comment: "")
	}

	static var sellSendErrorInvalidDescription: String {
		return NSLocalizedString("sell_send_error_invalid_description", comment: "")
	}

	static func sellSendErrorInvalidDescriptionTooLong(_ var1: Int) -> String {
		return String(format: NSLocalizedString("sell_send_error_invalid_description_too_long", comment: ""), var1)
	}

	static var sellSendErrorInvalidImageCount: String {
		return NSLocalizedString("sell_send_error_invalid_image_count", comment: "")
	}

	static var sellSendErrorInvalidPrice: String {
		return NSLocalizedString("sell_send_error_invalid_price", comment: "")
	}

	static var sellSendErrorInvalidTitle: String {
		return NSLocalizedString("sell_send_error_invalid_title", comment: "")
	}

	static var sellSendErrorSharingFacebook: String {
		return NSLocalizedString("sell_send_error_sharing_facebook", comment: "")
	}

	static var sellShareFbContent: String {
		return NSLocalizedString("sell_share_fb_content", comment: "")
	}

	static var sellShareOnFacebookLabel: String {
		return NSLocalizedString("sell_share_on_facebook_label", comment: "")
	}

	static var sellTitleAutogenAutotransLabel: String {
		return NSLocalizedString("sell_title_autogen_autotrans_label", comment: "")
	}

	static var sellTitleAutogenLabel: String {
		return NSLocalizedString("sell_title_autogen_label", comment: "")
	}

	static var sellTitleFieldHint: String {
		return NSLocalizedString("sell_title_field_hint", comment: "")
	}

	static var sellTitleInformation: String {
		return NSLocalizedString("sell_title_information", comment: "")
	}

	static var sellUploadingLabel: String {
		return NSLocalizedString("sell_uploading_label", comment: "")
	}

	static var settingsChangeLocationButton: String {
		return NSLocalizedString("settings_change_location_button", comment: "")
	}

	static var settingsChangePasswordButton: String {
		return NSLocalizedString("settings_change_password_button", comment: "")
	}

	static var settingsChangeProfilePictureButton: String {
		return NSLocalizedString("settings_change_profile_picture_button", comment: "")
	}

	static var settingsChangeProfilePictureErrorGeneric: String {
		return NSLocalizedString("settings_change_profile_picture_error_generic", comment: "")
	}

	static var settingsChangeProfilePictureLoading: String {
		return NSLocalizedString("settings_change_profile_picture_loading", comment: "")
	}

	static var settingsChangeUsernameButton: String {
		return NSLocalizedString("settings_change_username_button", comment: "")
	}

	static var settingsChangeEmailButton: String {
		return NSLocalizedString("settings_change_email_button", comment: "")
	}

	static var settingsHelpButton: String {
		return NSLocalizedString("settings_help_button", comment: "")
	}

	static var settingsInviteFacebookFriendsButton: String {
		return NSLocalizedString("settings_invite_facebook_friends_button", comment: "")
	}

	static var settingsInviteFacebookFriendsError: String {
		return NSLocalizedString("settings_invite_facebook_friends_error", comment: "")
	}

	static var settingsInviteFacebookFriendsOk: String {
		return NSLocalizedString("settings_invite_facebook_friends_ok", comment: "")
	}

	static var settingsLogoutButton: String {
		return NSLocalizedString("settings_logout_button", comment: "")
	}

	static var settingsLogoutAlertMessage: String {
		return NSLocalizedString("settings_logout_alert_message", comment: "")
	}

	static var settingsLogoutAlertOk: String {
		return NSLocalizedString("settings_logout_alert_ok", comment: "")
	}

	static var settingsTitle: String {
		return NSLocalizedString("settings_title", comment: "")
	}

	static var settingsSectionProfile: String {
		return NSLocalizedString("settings_section_profile", comment: "")
	}

	static var settingsSectionPromote: String {
		return NSLocalizedString("settings_section_promote", comment: "")
	}

	static var settingsSectionSupport: String {
		return NSLocalizedString("settings_section_support", comment: "")
	}

	static var settingsMarketingNotificationsSwitch: String {
		return NSLocalizedString("settings_marketing_notifications_switch", comment: "")
	}

	static var settingsMarketingNotificationsAlertMessage: String {
		return NSLocalizedString("settings_marketing_notifications_alert_message", comment: "")
	}

	static var settingsGeneralNotificationsAlertMessage: String {
		return NSLocalizedString("settings_general_notifications_alert_message", comment: "")
	}

	static var settingsMarketingNotificationsAlertActivate: String {
		return NSLocalizedString("settings_marketing_notifications_alert_activate", comment: "")
	}

	static var settingsMarketingNotificationsAlertDeactivate: String {
		return NSLocalizedString("settings_marketing_notifications_alert_deactivate", comment: "")
	}

	static var settingsMarketingNotificationsAlertCancel: String {
		return NSLocalizedString("settings_marketing_notifications_alert_cancel", comment: "")
	}

	static var signUpAcceptanceError: String {
		return NSLocalizedString("sign_up_acceptance_error", comment: "")
	}

	static var signUpEmailFieldHint: String {
		return NSLocalizedString("sign_up_email_field_hint", comment: "")
	}

	static var signUpNewsleter: String {
		return NSLocalizedString("sign_up_newsleter", comment: "")
	}

	static var signUpPasswordFieldHint: String {
		return NSLocalizedString("sign_up_password_field_hint", comment: "")
	}

	static var signUpSendButton: String {
		return NSLocalizedString("sign_up_send_button", comment: "")
	}

	static func signUpSendErrorEmailTaken(_ var1: String) -> String {
		return String(format: NSLocalizedString("sign_up_send_error_email_taken", comment: ""), var1)
	}

	static var signUpSendErrorGeneric: String {
		return NSLocalizedString("sign_up_send_error_generic", comment: "")
	}

	static var signUpSendErrorInvalidDomain: String {
		return NSLocalizedString("sign_up_send_error_invalid_domain", comment: "")
	}

	static var signUpSendErrorInvalidEmail: String {
		return NSLocalizedString("sign_up_send_error_invalid_email", comment: "")
	}

	static func signUpSendErrorInvalidPasswordWithMax(_ var1: Int, _ var2: Int) -> String {
		return String(format: NSLocalizedString("sign_up_send_error_invalid_password_with_max", comment: ""), var1, var2)
	}

	static func signUpSendErrorInvalidUsername(_ var1: Int) -> String {
		return String(format: NSLocalizedString("sign_up_send_error_invalid_username", comment: ""), var1)
	}

	static var signUpTermsConditions: String {
		return NSLocalizedString("sign_up_terms_conditions", comment: "")
	}

	static var signUpTermsConditionsPrivacyPart: String {
		return NSLocalizedString("sign_up_terms_conditions_privacy_part", comment: "")
	}

	static var signUpTermsConditionsTermsPart: String {
		return NSLocalizedString("sign_up_terms_conditions_terms_part", comment: "")
	}

	static var signUpTitle: String {
		return NSLocalizedString("sign_up_title", comment: "")
	}

	static var signUpUsernameFieldHint: String {
		return NSLocalizedString("sign_up_username_field_hint", comment: "")
	}

	static var suggestionsLastSearchesTitle: String {
		return NSLocalizedString("suggestions_last_searches_title", comment: "")
	}

	static var suggestionsLastSearchesClearButton: String {
		return NSLocalizedString("suggestions_last_searches_clear_button", comment: "")
	}

	static var tabBarToolTip: String {
		return NSLocalizedString("tab_bar_tool_tip", comment: "")
	}

	static var tabBarSellStuffButton: String {
		return NSLocalizedString("tab_bar_sell_stuff_button", comment: "")
	}

	static var tabBarGiveAwayButton: String {
		return NSLocalizedString("tab_bar_give_away_button", comment: "")
	}

	static var tabBarGiveAwayTooltip: String {
		return NSLocalizedString("tab_bar_give_away_tooltip", comment: "")
	}

	static var toastErrorInternal: String {
		return NSLocalizedString("toast_error_internal", comment: "")
	}

	static var toastNoNetwork: String {
		return NSLocalizedString("toast_no_network", comment: "")
	}

	static var tourClaimLabel: String {
		return NSLocalizedString("tour_claim_label", comment: "")
	}

	static var tourEmailButton: String {
		return NSLocalizedString("tour_email_button", comment: "")
	}

	static var tourContinueWEmail: String {
		return NSLocalizedString("tour_continue_w_email", comment: "")
	}

	static var tourFacebookButton: String {
		return NSLocalizedString("tour_facebook_button", comment: "")
	}

	static var tourGoogleButton: String {
		return NSLocalizedString("tour_google_button", comment: "")
	}

	static var tourHelpButton: String {
		return NSLocalizedString("tour_help_button", comment: "")
	}

	static var tourOrLabel: String {
		return NSLocalizedString("tour_or_label", comment: "")
	}

	static var tourPage1Body: String {
		return NSLocalizedString("tour_page_1_body", comment: "")
	}

	static var trendingSearchesTitle: String {
		return NSLocalizedString("trending_searches_Title", comment: "")
	}

	static var unblockUserErrorGeneric: String {
		return NSLocalizedString("unblock_user_error_generic", comment: "")
	}

	static var userShareNavbarButton: String {
		return NSLocalizedString("user_share_navbar_button", comment: "")
	}

	static var userShareTitleTextMine: String {
		return NSLocalizedString("user_share_title_text_mine", comment: "")
	}

	static var userShareTitleTextOther: String {
		return NSLocalizedString("user_share_title_text_other", comment: "")
	}

	static func userShareTitleTextOtherWName(_ var1: String) -> String {
		return String(format: NSLocalizedString("user_share_title_text_other_w_name", comment: ""), var1)
	}

	static var userShareMessageMine: String {
		return NSLocalizedString("user_share_message_mine", comment: "")
	}

	static var userShareMessageOther: String {
		return NSLocalizedString("user_share_message_other", comment: "")
	}

	static func userShareMessageOtherWName(_ var1: String) -> String {
		return String(format: NSLocalizedString("user_share_message_other_w_name", comment: ""), var1)
	}

	static var userShareSuccess: String {
		return NSLocalizedString("user_share_success", comment: "")
	}

	static var userShareError: String {
		return NSLocalizedString("user_share_error", comment: "")
	}

	static func userRatingMessageWName(_ var1: String) -> String {
		return String(format: NSLocalizedString("user_rating_message_w_name", comment: ""), var1)
	}

	static var userRatingMessageWoName: String {
		return NSLocalizedString("user_rating_message_wo_name", comment: "")
	}

	static var userRatingReviewButton: String {
		return NSLocalizedString("user_rating_review_button", comment: "")
	}

	static var userRatingSkipButton: String {
		return NSLocalizedString("user_rating_skip_button", comment: "")
	}

	static var userRatingReviewInfo: String {
		return NSLocalizedString("user_rating_review_info", comment: "")
	}

	static var userRatingReviewPlaceholder: String {
		return NSLocalizedString("user_rating_review_placeholder", comment: "")
	}

	static var userRatingReviewPlaceholderMandatory: String {
		return NSLocalizedString("user_rating_review_placeholder_mandatory", comment: "")
	}

	static var userRatingReviewPlaceholderOptional: String {
		return NSLocalizedString("user_rating_review_placeholder_optional", comment: "")
	}

	static var userRatingReviewSendSuccess: String {
		return NSLocalizedString("user_rating_review_send_success", comment: "")
	}

	static var userRatingTitle: String {
		return NSLocalizedString("user_rating_title", comment: "")
	}
}
