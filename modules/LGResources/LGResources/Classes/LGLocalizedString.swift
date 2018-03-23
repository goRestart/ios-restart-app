import Foundation

/// This class only exists to be able to determine the bundle where it belongs to.
fileprivate class Helper { }

fileprivate let bundle: Bundle = {
    let path = Bundle(for: Helper.self).path(forResource: "LGResourcesBundle", ofType: "bundle")!
    return Bundle(path: path)!
}()

public struct LGLocalizedString {
	public static func accountDeactivatedWName(_ var1: String) -> String {
		return String(format: NSLocalizedString("account_deactivated_w_name", bundle: bundle, comment: ""), var1)
	}

	public static var accountPendingModeration: String {
		return NSLocalizedString("account_pending_moderation", bundle: bundle, comment: "")
	}

	public static func accountPendingModerationWName(_ var1: String) -> String {
		return String(format: NSLocalizedString("account_pending_moderation_w_name", bundle: bundle, comment: ""), var1)
	}

	public static var appShareDownloadText: String {
		return NSLocalizedString("app_share_download_text", bundle: bundle, comment: "")
	}

	public static var appShareEmailButton: String {
		return NSLocalizedString("app_share_email_button", bundle: bundle, comment: "")
	}

	public static var appShareFbmessengerButton: String {
		return NSLocalizedString("app_share_fbmessenger_button", bundle: bundle, comment: "")
	}

	public static var appShareMessageText: String {
		return NSLocalizedString("app_share_message_text", bundle: bundle, comment: "")
	}

	public static var appShareSubjectText: String {
		return NSLocalizedString("app_share_subject_text", bundle: bundle, comment: "")
	}

	public static var appShareSubtitle: String {
		return NSLocalizedString("app_share_subtitle", bundle: bundle, comment: "")
	}

	public static var appShareTitle: String {
		return NSLocalizedString("app_share_title", bundle: bundle, comment: "")
	}

	public static var appShareWhatsappButton: String {
		return NSLocalizedString("app_share_whatsapp_button", bundle: bundle, comment: "")
	}

	public static var appShareSuccess: String {
		return NSLocalizedString("app_share_success", bundle: bundle, comment: "")
	}

	public static var appNotificationReply: String {
		return NSLocalizedString("app_notification_reply", bundle: bundle, comment: "")
	}

	public static var blockUserErrorGeneric: String {
		return NSLocalizedString("block_user_error_generic", bundle: bundle, comment: "")
	}

	public static var bumpUpBannerFreeText: String {
		return NSLocalizedString("bump_up_banner_free_text", bundle: bundle, comment: "")
	}

	public static var bumpUpBannerPayText: String {
		return NSLocalizedString("bump_up_banner_pay_text", bundle: bundle, comment: "")
	}

	public static var bumpUpBannerPayTextImprovement: String {
		return NSLocalizedString("bump_up_banner_pay_text_improvement", bundle: bundle, comment: "")
	}

	public static var bumpUpBannerWaitText: String {
		return NSLocalizedString("bump_up_banner_wait_text", bundle: bundle, comment: "")
	}

	public static var bumpUpBannerFreeButtonTitle: String {
		return NSLocalizedString("bump_up_banner_free_button_title", bundle: bundle, comment: "")
	}

	public static var bumpUpFreeSuccess: String {
		return NSLocalizedString("bump_up_free_success", bundle: bundle, comment: "")
	}

	public static var bumpUpPaySuccess: String {
		return NSLocalizedString("bump_up_pay_success", bundle: bundle, comment: "")
	}

	public static var bumpUpErrorBumpGeneric: String {
		return NSLocalizedString("bump_up_error_bump_generic", bundle: bundle, comment: "")
	}

	public static var bumpUpErrorBumpToken: String {
		return NSLocalizedString("bump_up_error_bump_token", bundle: bundle, comment: "")
	}

	public static var bumpUpErrorPaymentFailed: String {
		return NSLocalizedString("bump_up_error_payment_failed", bundle: bundle, comment: "")
	}

	public static var bumpUpProcessingFreeText: String {
		return NSLocalizedString("bump_up_processing_free_text", bundle: bundle, comment: "")
	}

	public static var bumpUpProcessingPricedText: String {
		return NSLocalizedString("bump_up_processing_priced_text", bundle: bundle, comment: "")
	}

	public static var bumpUpProductCellFeaturedStripe: String {
		return NSLocalizedString("bump_up_product_cell_featured_stripe", bundle: bundle, comment: "")
	}

	public static var bumpUpProductCellChatNowButton: String {
		return NSLocalizedString("bump_up_product_cell_chat_now_button", bundle: bundle, comment: "")
	}

	public static var bumpUpProductCellChatNowButtonA: String {
		return NSLocalizedString("bump_up_product_cell_chat_now_button_a", bundle: bundle, comment: "")
	}

	public static var bumpUpProductCellChatNowButtonB: String {
		return NSLocalizedString("bump_up_product_cell_chat_now_button_b", bundle: bundle, comment: "")
	}

	public static var bumpUpProductCellChatNowButtonC: String {
		return NSLocalizedString("bump_up_product_cell_chat_now_button_c", bundle: bundle, comment: "")
	}

	public static var bumpUpProductCellChatNowButtonD: String {
		return NSLocalizedString("bump_up_product_cell_chat_now_button_d", bundle: bundle, comment: "")
	}

	public static var bumpUpProductDetailFeaturedLabel: String {
		return NSLocalizedString("bump_up_product_detail_featured_label", bundle: bundle, comment: "")
	}

	public static var bumpUpViewFreeTitle: String {
		return NSLocalizedString("bump_up_view_free_title", bundle: bundle, comment: "")
	}

	public static var bumpUpViewFreeSubtitle: String {
		return NSLocalizedString("bump_up_view_free_subtitle", bundle: bundle, comment: "")
	}

	public static var bumpUpViewPayTitle: String {
		return NSLocalizedString("bump_up_view_pay_title", bundle: bundle, comment: "")
	}

	public static var bumpUpViewPaySubtitle: String {
		return NSLocalizedString("bump_up_view_pay_subtitle", bundle: bundle, comment: "")
	}

	public static func bumpUpViewPayButtonTitle(_ var1: String) -> String {
		return String(format: NSLocalizedString("bump_up_view_pay_button_title", bundle: bundle, comment: ""), var1)
	}

	public static var bumpUpOldViewPayTitle: String {
		return NSLocalizedString("bump_up_old_view_pay_title", bundle: bundle, comment: "")
	}

	public static var bumpUpOldViewPaySubtitle: String {
		return NSLocalizedString("bump_up_old_view_pay_subtitle", bundle: bundle, comment: "")
	}

	public static func bumpUpOldViewPayButtonTitle(_ var1: String) -> String {
		return String(format: NSLocalizedString("bump_up_old_view_pay_button_title", bundle: bundle, comment: ""), var1)
	}

	public static var bumpUpNotAllowedAlertText: String {
		return NSLocalizedString("bump_up_not_allowed_alert_text", bundle: bundle, comment: "")
	}

	public static var bumpUpNotAllowedAlertContactButton: String {
		return NSLocalizedString("bump_up_not_allowed_alert_contact_button", bundle: bundle, comment: "")
	}

	public static var categoriesBabyAndChild: String {
		return NSLocalizedString("categories_baby_and_child", bundle: bundle, comment: "")
	}

	public static var categoriesCarsAndMotors: String {
		return NSLocalizedString("categories_cars_and_motors", bundle: bundle, comment: "")
	}

	public static var categoriesElectronics: String {
		return NSLocalizedString("categories_electronics", bundle: bundle, comment: "")
	}

	public static var categoriesFashionAndAccessories: String {
		return NSLocalizedString("categories_fashion_and_accessories", bundle: bundle, comment: "")
	}

	public static var categoriesFree: String {
		return NSLocalizedString("categories_free", bundle: bundle, comment: "")
	}

	public static var categoriesHomeAndGarden: String {
		return NSLocalizedString("categories_home_and_garden", bundle: bundle, comment: "")
	}

	public static var categoriesMoviesBooksAndMusic: String {
		return NSLocalizedString("categories_movies_books_and_music", bundle: bundle, comment: "")
	}

	public static var categoriesOther: String {
		return NSLocalizedString("categories_other", bundle: bundle, comment: "")
	}

	public static var categoriesRealEstate: String {
		return NSLocalizedString("categories_real_estate", bundle: bundle, comment: "")
	}

	public static var categoriesRealEstateTitle: String {
		return NSLocalizedString("categories_real_estate_title", bundle: bundle, comment: "")
	}

	public static var categoriesServices: String {
		return NSLocalizedString("categories_services", bundle: bundle, comment: "")
	}

	public static var categoriesSportsLeisureAndGames: String {
		return NSLocalizedString("categories_sports_leisure_and_games", bundle: bundle, comment: "")
	}

	public static var categoriesTitle: String {
		return NSLocalizedString("categories_title", bundle: bundle, comment: "")
	}

	public static var categoriesUnassigned: String {
		return NSLocalizedString("categories_unassigned", bundle: bundle, comment: "")
	}

	public static var categoriesUnassignedItems: String {
		return NSLocalizedString("categories_unassigned_items", bundle: bundle, comment: "")
	}

	public static var categoriesCar: String {
		return NSLocalizedString("categories_car", bundle: bundle, comment: "")
	}

	public static var categoriesInfeedElectronics: String {
		return NSLocalizedString("categories_inFeed_electronics", bundle: bundle, comment: "")
	}

	public static var categoriesInfeedMotors: String {
		return NSLocalizedString("categories_inFeed_motors", bundle: bundle, comment: "")
	}

	public static var categoriesInfeedSportsLeisureGames: String {
		return NSLocalizedString("categories_inFeed_sports_leisure_games", bundle: bundle, comment: "")
	}

	public static var categoriesInfeedServices: String {
		return NSLocalizedString("categories_inFeed_services", bundle: bundle, comment: "")
	}

	public static var categoriesInfeedHome: String {
		return NSLocalizedString("categories_inFeed_home", bundle: bundle, comment: "")
	}

	public static var categoriesInfeedBooksMovies: String {
		return NSLocalizedString("categories_inFeed_books_movies", bundle: bundle, comment: "")
	}

	public static var categoriesInfeedFashion: String {
		return NSLocalizedString("categories_inFeed_fashion", bundle: bundle, comment: "")
	}

	public static var categoriesInfeedBabyChild: String {
		return NSLocalizedString("categories_inFeed_baby_child", bundle: bundle, comment: "")
	}

	public static var categoriesInfeedOthers: String {
		return NSLocalizedString("categories_inFeed_others", bundle: bundle, comment: "")
	}

	public static var categoriesInfeedCars: String {
		return NSLocalizedString("categories_inFeed_cars", bundle: bundle, comment: "")
	}

	public static var categoriesInfeedRealEstate: String {
		return NSLocalizedString("categories_inFeed_real_estate", bundle: bundle, comment: "")
	}

	public static var categoriesInfeedRealEstateTitle: String {
		return NSLocalizedString("categories_inFeed_real_estate_title", bundle: bundle, comment: "")
	}

	public static var categoriesSuperKeywordsInfeedShowMore: String {
		return NSLocalizedString("categories_super_keywords_inFeed_show_more", bundle: bundle, comment: "")
	}

	public static var changeBioPlaceholder: String {
		return NSLocalizedString("change_bio_placeholder", bundle: bundle, comment: "")
	}

	public static var changeBioTitle: String {
		return NSLocalizedString("change_bio_title", bundle: bundle, comment: "")
	}

	public static var changeBioSaveButton: String {
		return NSLocalizedString("change_bio_save_button", bundle: bundle, comment: "")
	}

	public static var changeBioErrorMessage: String {
		return NSLocalizedString("change_bio_error_message", bundle: bundle, comment: "")
	}

	public static var changeLocationApplyButton: String {
		return NSLocalizedString("change_location_apply_button", bundle: bundle, comment: "")
	}

	public static var changeLocationApproximateLocationLabel: String {
		return NSLocalizedString("change_location_approximate_location_label", bundle: bundle, comment: "")
	}

	public static var changeLocationErrorCountryAlertMessage: String {
		return NSLocalizedString("change_location_error_country_alert_message", bundle: bundle, comment: "")
	}

	public static var changeLocationErrorSearchLocationMessage: String {
		return NSLocalizedString("change_location_error_search_location_message", bundle: bundle, comment: "")
	}

	public static func changeLocationErrorUnknownLocationMessage(_ var1: String) -> String {
		return String(format: NSLocalizedString("change_location_error_unknown_location_message", bundle: bundle, comment: ""), var1)
	}

	public static var changeLocationErrorUpdatingLocationMessage: String {
		return NSLocalizedString("change_location_error_updating_location_message", bundle: bundle, comment: "")
	}

	public static var changeLocationRecommendUpdateLocationMessage: String {
		return NSLocalizedString("change_location_recommend_update_location_message", bundle: bundle, comment: "")
	}

	public static var changeLocationSearchFieldHint: String {
		return NSLocalizedString("change_location_search_field_hint", bundle: bundle, comment: "")
	}

	public static var changeLocationTitle: String {
		return NSLocalizedString("change_location_title", bundle: bundle, comment: "")
	}

	public static var changeLocationZipPlaceholder: String {
		return NSLocalizedString("change_location_zip_placeholder", bundle: bundle, comment: "")
	}

	public static var changeLocationZipNotFoundErrorMessage: String {
		return NSLocalizedString("change_location_zip_not_found_error_message", bundle: bundle, comment: "")
	}

	public static var changePasswordConfirmPasswordFieldHint: String {
		return NSLocalizedString("change_password_confirm_password_field_hint", bundle: bundle, comment: "")
	}

	public static var changePasswordNewPasswordFieldHint: String {
		return NSLocalizedString("change_password_new_password_field_hint", bundle: bundle, comment: "")
	}

	public static var changePasswordSendErrorGeneric: String {
		return NSLocalizedString("change_password_send_error_generic", bundle: bundle, comment: "")
	}

	public static func changePasswordSendErrorInvalidPasswordWithMax(_ var1: Int, _ var2: Int) -> String {
		return String(format: NSLocalizedString("change_password_send_error_invalid_password_with_max", bundle: bundle, comment: ""), var1, var2)
	}

	public static var changePasswordSendErrorPasswordsMismatch: String {
		return NSLocalizedString("change_password_send_error_passwords_mismatch", bundle: bundle, comment: "")
	}

	public static var changePasswordSendErrorLinkExpired: String {
		return NSLocalizedString("change_password_send_error_link_expired", bundle: bundle, comment: "")
	}

	public static var changePasswordSendOk: String {
		return NSLocalizedString("change_password_send_ok", bundle: bundle, comment: "")
	}

	public static var changePasswordTitle: String {
		return NSLocalizedString("change_password_title", bundle: bundle, comment: "")
	}

	public static func changeUsernameErrorInvalidUsername(_ var1: Int) -> String {
		return String(format: NSLocalizedString("change_username_error_invalid_username", bundle: bundle, comment: ""), var1)
	}

	public static func changeUsernameErrorInvalidUsernameLetgo(_ var1: String) -> String {
		return String(format: NSLocalizedString("change_username_error_invalid_username_letgo", bundle: bundle, comment: ""), var1)
	}

	public static var changeUsernameFieldHint: String {
		return NSLocalizedString("change_username_field_hint", bundle: bundle, comment: "")
	}

	public static var changeUsernameLoading: String {
		return NSLocalizedString("change_username_loading", bundle: bundle, comment: "")
	}

	public static var changeUsernameSaveButton: String {
		return NSLocalizedString("change_username_save_button", bundle: bundle, comment: "")
	}

	public static var changeUsernameSendOk: String {
		return NSLocalizedString("change_username_send_ok", bundle: bundle, comment: "")
	}

	public static var changeUsernameTitle: String {
		return NSLocalizedString("change_username_title", bundle: bundle, comment: "")
	}

	public static var changeEmailTitle: String {
		return NSLocalizedString("change_email_title", bundle: bundle, comment: "")
	}

	public static var changeEmailCurrentEmailLabel: String {
		return NSLocalizedString("change_email_current_email_label", bundle: bundle, comment: "")
	}

	public static func changeEmailSendOk(_ var1: String) -> String {
		return String(format: NSLocalizedString("change_email_send_ok", bundle: bundle, comment: ""), var1)
	}

	public static var changeEmailLoading: String {
		return NSLocalizedString("change_email_loading", bundle: bundle, comment: "")
	}

	public static var changeEmailFieldHint: String {
		return NSLocalizedString("change_email_field_hint", bundle: bundle, comment: "")
	}

	public static var changeEmailErrorInvalidEmail: String {
		return NSLocalizedString("change_email_error_invalid_email", bundle: bundle, comment: "")
	}

	public static var changeEmailErrorAlreadyRegistered: String {
		return NSLocalizedString("change_email_error_already_registered", bundle: bundle, comment: "")
	}

	public static var chatInactiveConversationsExplanationLabel: String {
		return NSLocalizedString("chat_inactive_conversations_explanation_label", bundle: bundle, comment: "")
	}

	public static var chatInactiveConversationsButton: String {
		return NSLocalizedString("chat_inactive_conversations_button", bundle: bundle, comment: "")
	}

	public static var chatInactiveConversationRelationExplanation: String {
		return NSLocalizedString("chat_inactive_conversation_relation_explanation", bundle: bundle, comment: "")
	}

	public static func chatAccountDeletedWName(_ var1: String) -> String {
		return String(format: NSLocalizedString("chat_account_deleted_w_name", bundle: bundle, comment: ""), var1)
	}

	public static var chatAccountDeletedWoName: String {
		return NSLocalizedString("chat_account_deleted_wo_name", bundle: bundle, comment: "")
	}

	public static var chatBlockUser: String {
		return NSLocalizedString("chat_block_user", bundle: bundle, comment: "")
	}

	public static var chatBlockUserAlertBlockButton: String {
		return NSLocalizedString("chat_block_user_alert_block_button", bundle: bundle, comment: "")
	}

	public static var chatBlockUserAlertText: String {
		return NSLocalizedString("chat_block_user_alert_text", bundle: bundle, comment: "")
	}

	public static var chatBlockUserAlertTitle: String {
		return NSLocalizedString("chat_block_user_alert_title", bundle: bundle, comment: "")
	}

	public static var chatBlockedByMeLabel: String {
		return NSLocalizedString("chat_blocked_by_me_label", bundle: bundle, comment: "")
	}

	public static func chatBlockedByMeLabelWName(_ var1: String) -> String {
		return String(format: NSLocalizedString("chat_blocked_by_me_label_w_name", bundle: bundle, comment: ""), var1)
	}

	public static var chatBlockedByOtherLabel: String {
		return NSLocalizedString("chat_blocked_by_other_label", bundle: bundle, comment: "")
	}

	public static var chatDisclaimerLetgoTeam: String {
		return NSLocalizedString("chat_disclaimer_letgo_team", bundle: bundle, comment: "")
	}

	public static func chatBlockedDisclaimerScammerAppendSafetyTips(_ var1: String) -> String {
		return String(format: NSLocalizedString("chat_blocked_disclaimer_scammer_append_safety_tips", bundle: bundle, comment: ""), var1)
	}

	public static var chatBlockedDisclaimerScammerAppendSafetyTipsKeyword: String {
		return NSLocalizedString("chat_blocked_disclaimer_scammer_append_safety_tips_keyword", bundle: bundle, comment: "")
	}

	public static var chatBlockedDisclaimerScammerWoName: String {
		return NSLocalizedString("chat_blocked_disclaimer_scammer_wo_name", bundle: bundle, comment: "")
	}

	public static var chatForbiddenDisclaimerSellerWoName: String {
		return NSLocalizedString("chat_forbidden_disclaimer_seller_wo_name", bundle: bundle, comment: "")
	}

	public static func chatForbiddenDisclaimerSellerWName(_ var1: String) -> String {
		return String(format: NSLocalizedString("chat_forbidden_disclaimer_seller_w_name", bundle: bundle, comment: ""), var1)
	}

	public static var chatForbiddenDisclaimerBuyerWoName: String {
		return NSLocalizedString("chat_forbidden_disclaimer_buyer_wo_name", bundle: bundle, comment: "")
	}

	public static func chatForbiddenDisclaimerBuyerWName(_ var1: String) -> String {
		return String(format: NSLocalizedString("chat_forbidden_disclaimer_buyer_w_name", bundle: bundle, comment: ""), var1)
	}

	public static var chatConnectAccountDisclaimerButton: String {
		return NSLocalizedString("chat_connect_account_disclaimer_button", bundle: bundle, comment: "")
	}

	public static func chatDeletedDisclaimerWName(_ var1: String) -> String {
		return String(format: NSLocalizedString("chat_deleted_disclaimer_w_name", bundle: bundle, comment: ""), var1)
	}

	public static var chatDeletedDisclaimerWoName: String {
		return NSLocalizedString("chat_deleted_disclaimer_wo_name", bundle: bundle, comment: "")
	}

	public static var chatExpressBannerButtonTitle: String {
		return NSLocalizedString("chat_express_banner_button_title", bundle: bundle, comment: "")
	}

	public static var chatExpressBannerTitle: String {
		return NSLocalizedString("chat_express_banner_title", bundle: bundle, comment: "")
	}

	public static var chatExpressDontMissLabel: String {
		return NSLocalizedString("chat_express_dont_miss_label", bundle: bundle, comment: "")
	}

	public static var chatExpressContactSellersLabel: String {
		return NSLocalizedString("chat_express_contact_sellers_label", bundle: bundle, comment: "")
	}

	public static var chatExpressTextFieldText: String {
		return NSLocalizedString("chat_express_text_field_text", bundle: bundle, comment: "")
	}

	public static var chatExpressContactOneButtonText: String {
		return NSLocalizedString("chat_express_contact_one_button_text", bundle: bundle, comment: "")
	}

	public static func chatExpressContactVariousButtonText(_ var1: String) -> String {
		return String(format: NSLocalizedString("chat_express_contact_various_button_text", bundle: bundle, comment: ""), var1)
	}

	public static var chatExpressDontAskAgainButton: String {
		return NSLocalizedString("chat_express_dont_ask_again_button", bundle: bundle, comment: "")
	}

	public static var chatExpressOneMessageSentSuccessAlert: String {
		return NSLocalizedString("chat_express_one_message_sent_success_alert", bundle: bundle, comment: "")
	}

	public static var chatExpressSeveralMessagesSentSuccessAlert: String {
		return NSLocalizedString("chat_express_several_messages_sent_success_alert", bundle: bundle, comment: "")
	}

	public static var chatProfessionalBannerButtonTitle: String {
		return NSLocalizedString("chat_professional_banner_button_title", bundle: bundle, comment: "")
	}

	public static var chatProfessionalBannerTitle: String {
		return NSLocalizedString("chat_professional_banner_title", bundle: bundle, comment: "")
	}

	public static var chatListAccountDeleted: String {
		return NSLocalizedString("chat_list_account_deleted", bundle: bundle, comment: "")
	}

	public static var chatListAccountDeletedUsername: String {
		return NSLocalizedString("chat_list_account_deleted_username", bundle: bundle, comment: "")
	}

	public static var chatListAllEmptyTitle: String {
		return NSLocalizedString("chat_list_all_empty_title", bundle: bundle, comment: "")
	}

	public static var chatListAllTitle: String {
		return NSLocalizedString("chat_list_all_title", bundle: bundle, comment: "")
	}

	public static var chatListArchiveErrorMultiple: String {
		return NSLocalizedString("chat_list_archive_error_multiple", bundle: bundle, comment: "")
	}

	public static var chatListBlockedEmptyBody: String {
		return NSLocalizedString("chat_list_blocked_empty_body", bundle: bundle, comment: "")
	}

	public static var chatListBlockedEmptyTitle: String {
		return NSLocalizedString("chat_list_blocked_empty_title", bundle: bundle, comment: "")
	}

	public static var chatListBlockedUserLabel: String {
		return NSLocalizedString("chat_list_blocked_user_label", bundle: bundle, comment: "")
	}

	public static var chatListBlockedUsersTitle: String {
		return NSLocalizedString("chat_list_blocked_users_title", bundle: bundle, comment: "")
	}

	public static var chatListBuyingEmptyButton: String {
		return NSLocalizedString("chat_list_buying_empty_button", bundle: bundle, comment: "")
	}

	public static var chatListBuyingEmptyTitle: String {
		return NSLocalizedString("chat_list_buying_empty_title", bundle: bundle, comment: "")
	}

	public static var chatListBuyingTitle: String {
		return NSLocalizedString("chat_list_buying_title", bundle: bundle, comment: "")
	}

	public static var chatListDelete: String {
		return NSLocalizedString("chat_list_delete", bundle: bundle, comment: "")
	}

	public static var chatListDeleteAlertSend: String {
		return NSLocalizedString("chat_list_delete_alert_send", bundle: bundle, comment: "")
	}

	public static var chatListDeleteAlertTextMultiple: String {
		return NSLocalizedString("chat_list_delete_alert_text_multiple", bundle: bundle, comment: "")
	}

	public static var chatListDeleteAlertTextOne: String {
		return NSLocalizedString("chat_list_delete_alert_text_one", bundle: bundle, comment: "")
	}

	public static var chatListDeleteAlertTitleMultiple: String {
		return NSLocalizedString("chat_list_delete_alert_title_multiple", bundle: bundle, comment: "")
	}

	public static var chatListDeleteAlertTitleOne: String {
		return NSLocalizedString("chat_list_delete_alert_title_one", bundle: bundle, comment: "")
	}

	public static var chatListDeleteErrorOne: String {
		return NSLocalizedString("chat_list_delete_error_one", bundle: bundle, comment: "")
	}

	public static var chatListDeleteOkOne: String {
		return NSLocalizedString("chat_list_delete_ok_one", bundle: bundle, comment: "")
	}

	public static var chatListSellingEmptyButton: String {
		return NSLocalizedString("chat_list_selling_empty_button", bundle: bundle, comment: "")
	}

	public static var chatListSellingEmptyTitle: String {
		return NSLocalizedString("chat_list_selling_empty_title", bundle: bundle, comment: "")
	}

	public static var chatListSellingTitle: String {
		return NSLocalizedString("chat_list_selling_title", bundle: bundle, comment: "")
	}

	public static var chatListTitle: String {
		return NSLocalizedString("chat_list_title", bundle: bundle, comment: "")
	}

	public static var chatListUnarchiveErrorMultiple: String {
		return NSLocalizedString("chat_list_unarchive_error_multiple", bundle: bundle, comment: "")
	}

	public static var chatListUnblock: String {
		return NSLocalizedString("chat_list_unblock", bundle: bundle, comment: "")
	}

	public static var chatInactiveListTitle: String {
		return NSLocalizedString("chat_inactive_list_title", bundle: bundle, comment: "")
	}

	public static var chatLoginPopupText: String {
		return NSLocalizedString("chat_login_popup_text", bundle: bundle, comment: "")
	}

	public static var chatMessageDisclaimerMeetingSecurity: String {
		return NSLocalizedString("chat_message_disclaimer_meeting_security", bundle: bundle, comment: "")
	}

	public static func chatMessageDisclaimerScammerBaseBlocked(_ var1: String) -> String {
		return String(format: NSLocalizedString("chat_message_disclaimer_scammer_base_blocked", bundle: bundle, comment: ""), var1)
	}

	public static var chatMessageDisclaimerScammerAppendBlocked: String {
		return NSLocalizedString("chat_message_disclaimer_scammer_append_blocked", bundle: bundle, comment: "")
	}

	public static var chatMessageFieldHint: String {
		return NSLocalizedString("chat_message_field_hint", bundle: bundle, comment: "")
	}

	public static var chatProductGivenAwayLabel: String {
		return NSLocalizedString("chat_product_given_away_label", bundle: bundle, comment: "")
	}

	public static var chatMessageLoadGenericError: String {
		return NSLocalizedString("chat_message_load_generic_error", bundle: bundle, comment: "")
	}

	public static var chatProductSoldLabel: String {
		return NSLocalizedString("chat_product_sold_label", bundle: bundle, comment: "")
	}

	public static var chatRelatedProductsTitle: String {
		return NSLocalizedString("chat_related_products_title", bundle: bundle, comment: "")
	}

	public static var chatSafetyTips: String {
		return NSLocalizedString("chat_safety_tips", bundle: bundle, comment: "")
	}

	public static var chatSafetyTipsMessage: String {
		return NSLocalizedString("chat_safety_tips_message", bundle: bundle, comment: "")
	}

	public static var chatSafetyTipsTitle: String {
		return NSLocalizedString("chat_safety_tips_title", bundle: bundle, comment: "")
	}

	public static var chatSendButton: String {
		return NSLocalizedString("chat_send_button", bundle: bundle, comment: "")
	}

	public static var chatSendErrorGeneric: String {
		return NSLocalizedString("chat_send_error_generic", bundle: bundle, comment: "")
	}

	public static var chatSendErrorDifferentCountry: String {
		return NSLocalizedString("chat_send_error_different_country", bundle: bundle, comment: "")
	}

	public static var chatStickersTooltipNew: String {
		return NSLocalizedString("chat_stickers_tooltip_new", bundle: bundle, comment: "")
	}

	public static var chatUnblockUser: String {
		return NSLocalizedString("chat_unblock_user", bundle: bundle, comment: "")
	}

	public static func chatUserInfoName(_ var1: String) -> String {
		return String(format: NSLocalizedString("chat_user_info_name", bundle: bundle, comment: ""), var1)
	}

	public static var chatUserInfoVerifiedWith: String {
		return NSLocalizedString("chat_user_info_verified_with", bundle: bundle, comment: "")
	}

	public static var chatUserRatingButtonTooltip: String {
		return NSLocalizedString("chat_user_rating_button_tooltip", bundle: bundle, comment: "")
	}

	public static var chatVerifyAlertOkButton: String {
		return NSLocalizedString("chat_verify_alert_ok_button", bundle: bundle, comment: "")
	}

	public static var chatVerifyAlertTitle: String {
		return NSLocalizedString("chat_verify_alert_title", bundle: bundle, comment: "")
	}

	public static var chatConnectAccountsTitle: String {
		return NSLocalizedString("chat_connect_accounts_title", bundle: bundle, comment: "")
	}

	public static var chatNotVerifiedStateTitle: String {
		return NSLocalizedString("chat_not_verified_state_title", bundle: bundle, comment: "")
	}

	public static var chatNotVerifiedStateMessage: String {
		return NSLocalizedString("chat_not_verified_state_message", bundle: bundle, comment: "")
	}

	public static var chatNotVerifiedStateCheckButton: String {
		return NSLocalizedString("chat_not_verified_state_check_button", bundle: bundle, comment: "")
	}

	public static var chatNotVerifiedAlertMessage: String {
		return NSLocalizedString("chat_not_verified_alert_message", bundle: bundle, comment: "")
	}

	public static var chatWithYourselfAlertMsg: String {
		return NSLocalizedString("chat_with_yourself_alert_msg", bundle: bundle, comment: "")
	}

	public static var collectionTransportTitle: String {
		return NSLocalizedString("collection_transport_title", bundle: bundle, comment: "")
	}

	public static var collectionFurnitureTitle: String {
		return NSLocalizedString("collection_furniture_title", bundle: bundle, comment: "")
	}

	public static var collectionYouTitle: String {
		return NSLocalizedString("collection_you_title", bundle: bundle, comment: "")
	}

	public static var collectionExploreButton: String {
		return NSLocalizedString("collection_explore_button", bundle: bundle, comment: "")
	}

	public static var commercializerDisplayShareAlert: String {
		return NSLocalizedString("commercializer_display_share_alert", bundle: bundle, comment: "")
	}

	public static var commercializerDisplayShareMyVideoButton: String {
		return NSLocalizedString("commercializer_display_share_my_video_button", bundle: bundle, comment: "")
	}

	public static var commercializerDisplayTitleLabel: String {
		return NSLocalizedString("commercializer_display_title_label", bundle: bundle, comment: "")
	}

	public static var commercializerLoadVideoFailedErrorMessage: String {
		return NSLocalizedString("commercializer_load_video_failed_error_message", bundle: bundle, comment: "")
	}

	public static var commercializerPreviewTitle: String {
		return NSLocalizedString("commercializer_preview_title", bundle: bundle, comment: "")
	}

	public static var commercializerProcessingTitleLabel: String {
		return NSLocalizedString("commercializer_processing_title_label", bundle: bundle, comment: "")
	}

	public static var commercializerProductListEmptyBody: String {
		return NSLocalizedString("commercializer_product_list_empty_body", bundle: bundle, comment: "")
	}

	public static var commercializerProductListEmptyTitle: String {
		return NSLocalizedString("commercializer_product_list_empty_title", bundle: bundle, comment: "")
	}

	public static var commercializerPromoteIntroButton: String {
		return NSLocalizedString("commercializer_promote_intro_button", bundle: bundle, comment: "")
	}

	public static var commercializerPromoteNavigationTitle: String {
		return NSLocalizedString("commercializer_promote_navigation_title", bundle: bundle, comment: "")
	}

	public static var commercializerPromoteThemeAlreadyUsed: String {
		return NSLocalizedString("commercializer_promote_theme_already_used", bundle: bundle, comment: "")
	}

	public static var commercializerShareMessageText: String {
		return NSLocalizedString("commercializer_share_message_text", bundle: bundle, comment: "")
	}

	public static var commonCancel: String {
		return NSLocalizedString("common_cancel", bundle: bundle, comment: "")
	}

	public static var commonChatNotAvailable: String {
		return NSLocalizedString("common_chat_not_available", bundle: bundle, comment: "")
	}

	public static var commonCollapse: String {
		return NSLocalizedString("common_collapse", bundle: bundle, comment: "")
	}

	public static var commonConfirm: String {
		return NSLocalizedString("common_confirm", bundle: bundle, comment: "")
	}

	public static var commonError: String {
		return NSLocalizedString("common_error", bundle: bundle, comment: "")
	}

	public static var commonErrorConnectionFailed: String {
		return NSLocalizedString("common_error_connection_failed", bundle: bundle, comment: "")
	}

	public static var commonErrorGenericBody: String {
		return NSLocalizedString("common_error_generic_body", bundle: bundle, comment: "")
	}

	public static var commonErrorListRetryButton: String {
		return NSLocalizedString("common_error_list_retry_button", bundle: bundle, comment: "")
	}

	public static var commonErrorNetworkBody: String {
		return NSLocalizedString("common_error_network_body", bundle: bundle, comment: "")
	}

	public static var commonErrorRetryButton: String {
		return NSLocalizedString("common_error_retry_button", bundle: bundle, comment: "")
	}

	public static var commonErrorTitle: String {
		return NSLocalizedString("common_error_title", bundle: bundle, comment: "")
	}

	public static var commonErrorPostingLoadedImage: String {
		return NSLocalizedString("common_error_posting_loaded_image", bundle: bundle, comment: "")
	}

	public static var commonExpand: String {
		return NSLocalizedString("common_expand", bundle: bundle, comment: "")
	}

	public static var commonLoading: String {
		return NSLocalizedString("common_loading", bundle: bundle, comment: "")
	}

	public static var commonMax: String {
		return NSLocalizedString("common_max", bundle: bundle, comment: "")
	}

	public static var commonNo: String {
		return NSLocalizedString("common_no", bundle: bundle, comment: "")
	}

	public static var commonNew: String {
		return NSLocalizedString("common_new", bundle: bundle, comment: "")
	}

	public static var commonOk: String {
		return NSLocalizedString("common_ok", bundle: bundle, comment: "")
	}

	public static var commonProductGivenAway: String {
		return NSLocalizedString("common_product_given_away", bundle: bundle, comment: "")
	}

	public static var commonProductNotAvailable: String {
		return NSLocalizedString("common_product_not_available", bundle: bundle, comment: "")
	}

	public static var commonProductSold: String {
		return NSLocalizedString("common_product_sold", bundle: bundle, comment: "")
	}

	public static var commonSettings: String {
		return NSLocalizedString("common_settings", bundle: bundle, comment: "")
	}

	public static func commonShortTimeDayAgoLabel(_ var1: Int) -> String {
		return String(format: NSLocalizedString("common_short_time_day_ago_label", bundle: bundle, comment: ""), var1)
	}

	public static func commonShortTimeDaysAgoLabel(_ var1: Int) -> String {
		return String(format: NSLocalizedString("common_short_time_days_ago_label", bundle: bundle, comment: ""), var1)
	}

	public static func commonShortTimeHoursAgoLabel(_ var1: Int) -> String {
		return String(format: NSLocalizedString("common_short_time_hours_ago_label", bundle: bundle, comment: ""), var1)
	}

	public static func commonShortTimeMinutesAgoLabel(_ var1: Int) -> String {
		return String(format: NSLocalizedString("common_short_time_minutes_ago_label", bundle: bundle, comment: ""), var1)
	}

	public static var commonShortTimeMoreThanOneMonthAgoLabel: String {
		return NSLocalizedString("common_short_time_more_than_one_month_ago_label", bundle: bundle, comment: "")
	}

	public static func commonShortTimeWeekAgoLabel(_ var1: Int) -> String {
		return String(format: NSLocalizedString("common_short_time_week_ago_label", bundle: bundle, comment: ""), var1)
	}

	public static func commonShortTimeWeeksAgoLabel(_ var1: Int) -> String {
		return String(format: NSLocalizedString("common_short_time_weeks_ago_label", bundle: bundle, comment: ""), var1)
	}

	public static var commonTimeAMinuteAgoLabel: String {
		return NSLocalizedString("common_time_a_minute_ago_label", bundle: bundle, comment: "")
	}

	public static var commonTimeDayAgoLabel: String {
		return NSLocalizedString("common_time_day_ago_label", bundle: bundle, comment: "")
	}

	public static func commonTimeDaysAgoLabel(_ var1: Int) -> String {
		return String(format: NSLocalizedString("common_time_days_ago_label", bundle: bundle, comment: ""), var1)
	}

	public static var commonTimeHourAgoLabel: String {
		return NSLocalizedString("common_time_hour_ago_label", bundle: bundle, comment: "")
	}

	public static func commonTimeHoursAgoLabel(_ var1: Int) -> String {
		return String(format: NSLocalizedString("common_time_hours_ago_label", bundle: bundle, comment: ""), var1)
	}

	public static func commonTimeMinutesAgoLabel(_ var1: Int) -> String {
		return String(format: NSLocalizedString("common_time_minutes_ago_label", bundle: bundle, comment: ""), var1)
	}

	public static var commonTimeMoreThanOneMonthAgoLabel: String {
		return NSLocalizedString("common_time_more_than_one_month_ago_label", bundle: bundle, comment: "")
	}

	public static var commonTimeNowLabel: String {
		return NSLocalizedString("common_time_now_label", bundle: bundle, comment: "")
	}

	public static func commonTimeSecondsAgoLabel(_ var1: Int) -> String {
		return String(format: NSLocalizedString("common_time_seconds_ago_label", bundle: bundle, comment: ""), var1)
	}

	public static var commonTimeWeekAgoLabel: String {
		return NSLocalizedString("common_time_week_ago_label", bundle: bundle, comment: "")
	}

	public static func commonTimeWeeksAgoLabel(_ var1: Int) -> String {
		return String(format: NSLocalizedString("common_time_weeks_ago_label", bundle: bundle, comment: ""), var1)
	}

	public static var commonUserNotAvailable: String {
		return NSLocalizedString("common_user_not_available", bundle: bundle, comment: "")
	}

	public static var commonUserReviewNotAvailable: String {
		return NSLocalizedString("common_user_review_not_available", bundle: bundle, comment: "")
	}

	public static var commonYes: String {
		return NSLocalizedString("common_yes", bundle: bundle, comment: "")
	}

	public static var contactSubjectOptionLocation: String {
		return NSLocalizedString("contact_subject_option_location", bundle: bundle, comment: "")
	}

	public static var contactSubjectOptionLogin: String {
		return NSLocalizedString("contact_subject_option_login", bundle: bundle, comment: "")
	}

	public static var contactSubjectOptionOther: String {
		return NSLocalizedString("contact_subject_option_other", bundle: bundle, comment: "")
	}

	public static var contactSubjectOptionProductEdit: String {
		return NSLocalizedString("contact_subject_option_product_edit", bundle: bundle, comment: "")
	}

	public static var contactSubjectOptionProfileEdit: String {
		return NSLocalizedString("contact_subject_option_profile_edit", bundle: bundle, comment: "")
	}

	public static var contactSubjectOptionReport: String {
		return NSLocalizedString("contact_subject_option_report", bundle: bundle, comment: "")
	}

	public static var directAnswerCondition: String {
		return NSLocalizedString("direct_answer_condition", bundle: bundle, comment: "")
	}

	public static var directAnswerFreeYours: String {
		return NSLocalizedString("direct_answer_free_yours", bundle: bundle, comment: "")
	}

	public static var directAnswerFreeAvailable: String {
		return NSLocalizedString("direct_answer_free_available", bundle: bundle, comment: "")
	}

	public static var directAnswerFreeNoAvailable: String {
		return NSLocalizedString("direct_answer_free_no_available", bundle: bundle, comment: "")
	}

	public static var directAnswerFreeStillHave: String {
		return NSLocalizedString("direct_answer_free_still_have", bundle: bundle, comment: "")
	}

	public static var directAnswerInterested: String {
		return NSLocalizedString("direct_answer_interested", bundle: bundle, comment: "")
	}

	public static var directAnswerIsNegotiable: String {
		return NSLocalizedString("direct_answer_is_negotiable", bundle: bundle, comment: "")
	}

	public static var directAnswerLikeToBuy: String {
		return NSLocalizedString("direct_answer_like_to_buy", bundle: bundle, comment: "")
	}

	public static var directAnswerMeetUp: String {
		return NSLocalizedString("direct_answer_meet_up", bundle: bundle, comment: "")
	}

	public static var directAnswerNegotiableNo: String {
		return NSLocalizedString("direct_answer_negotiable_no", bundle: bundle, comment: "")
	}

	public static var directAnswerNegotiableYes: String {
		return NSLocalizedString("direct_answer_negotiable_yes", bundle: bundle, comment: "")
	}

	public static var directAnswerNotInterested: String {
		return NSLocalizedString("direct_answer_not_interested", bundle: bundle, comment: "")
	}

	public static var directAnswerProductSold: String {
		return NSLocalizedString("direct_answer_product_sold", bundle: bundle, comment: "")
	}

	public static var directAnswerSoldQuestionMessage: String {
		return NSLocalizedString("direct_answer_sold_question_message", bundle: bundle, comment: "")
	}

	public static var directAnswerGivenAwayQuestionMessage: String {
		return NSLocalizedString("direct_answer_given_away_question_message", bundle: bundle, comment: "")
	}

	public static var directAnswerSoldQuestionOk: String {
		return NSLocalizedString("direct_answer_sold_question_ok", bundle: bundle, comment: "")
	}

	public static var directAnswerGivenAwayQuestionOk: String {
		return NSLocalizedString("direct_answer_given_away_question_ok", bundle: bundle, comment: "")
	}

	public static var directAnswerStillAvailable: String {
		return NSLocalizedString("direct_answer_still_available", bundle: bundle, comment: "")
	}

	public static var directAnswerSoldQuestionTitle: String {
		return NSLocalizedString("direct_answer_sold_question_title", bundle: bundle, comment: "")
	}

	public static var directAnswerStillForSale: String {
		return NSLocalizedString("direct_answer_still_for_sale", bundle: bundle, comment: "")
	}

	public static var directAnswerWhatsOffer: String {
		return NSLocalizedString("direct_answer_whats_offer", bundle: bundle, comment: "")
	}

	public static var directAnswersHide: String {
		return NSLocalizedString("direct_answers_hide", bundle: bundle, comment: "")
	}

	public static var directAnswersShow: String {
		return NSLocalizedString("direct_answers_show", bundle: bundle, comment: "")
	}

	public static var directAnswerGivenAwayQuestionTitle: String {
		return NSLocalizedString("direct_answer_given_away_question_title", bundle: bundle, comment: "")
	}

	public static var directAnswerStillForSaleBuyer: String {
		return NSLocalizedString("direct_answer_still_for_sale_buyer", bundle: bundle, comment: "")
	}

	public static var directAnswerPriceFirm: String {
		return NSLocalizedString("direct_answer_price_firm", bundle: bundle, comment: "")
	}

	public static var directAnswerWillingToNegotiate: String {
		return NSLocalizedString("direct_answer_willing_to_negotiate", bundle: bundle, comment: "")
	}

	public static var directAnswerHowMuchAsking: String {
		return NSLocalizedString("direct_answer_how_much_asking", bundle: bundle, comment: "")
	}

	public static var directAnswerGoodCondition: String {
		return NSLocalizedString("direct_answer_good_condition", bundle: bundle, comment: "")
	}

	public static var directAnswerDescribeCondition: String {
		return NSLocalizedString("direct_answer_describe_condition", bundle: bundle, comment: "")
	}

	public static var directAnswerWhereMeetUp: String {
		return NSLocalizedString("direct_answer_where_meet_up", bundle: bundle, comment: "")
	}

	public static var directAnswerWhereLocated: String {
		return NSLocalizedString("direct_answer_where_located", bundle: bundle, comment: "")
	}

	public static var directAnswerAvailabilityTitle: String {
		return NSLocalizedString("direct_answer_availability_title", bundle: bundle, comment: "")
	}

	public static var directAnswerPriceTitle: String {
		return NSLocalizedString("direct_answer_price_title", bundle: bundle, comment: "")
	}

	public static var directAnswerConditionTitle: String {
		return NSLocalizedString("direct_answer_condition_title", bundle: bundle, comment: "")
	}

	public static var directAnswerMeetUpTitle: String {
		return NSLocalizedString("direct_answer_meet_up_title", bundle: bundle, comment: "")
	}

	public static var directAnswerInterestedTitle: String {
		return NSLocalizedString("direct_answer_interested_title", bundle: bundle, comment: "")
	}

	public static var directAnswerNotInterestedTitle: String {
		return NSLocalizedString("direct_answer_not_interested_title", bundle: bundle, comment: "")
	}

	public static var directAnswerSoldTitle: String {
		return NSLocalizedString("direct_answer_sold_title", bundle: bundle, comment: "")
	}

	public static var directAnswerGivenAwayTitle: String {
		return NSLocalizedString("direct_answer_given_away_title", bundle: bundle, comment: "")
	}

	public static var directAnswerNegotiableTitle: String {
		return NSLocalizedString("direct_answer_negotiable_title", bundle: bundle, comment: "")
	}

	public static var directAnswerNotNegotiableTitle: String {
		return NSLocalizedString("direct_answer_not_negotiable_title", bundle: bundle, comment: "")
	}

	public static var discarded: String {
		return NSLocalizedString("discarded", bundle: bundle, comment: "")
	}

	public static var discardedProductsReasonGoodManners: String {
		return NSLocalizedString("discarded_products_reason_good_manners", bundle: bundle, comment: "")
	}

	public static var discardedProductsReasonDuplicated: String {
		return NSLocalizedString("discarded_products_reason_duplicated", bundle: bundle, comment: "")
	}

	public static var discardedProductsReasonNonRealisticPrice: String {
		return NSLocalizedString("discarded_products_reason_non_realistic_price", bundle: bundle, comment: "")
	}

	public static var discardedProductsReasonPoorAdQuality: String {
		return NSLocalizedString("discarded_products_reason_poor_ad_quality", bundle: bundle, comment: "")
	}

	public static var discardedProductsReasonPhotoNotClear: String {
		return NSLocalizedString("discarded_products_reason_photo_not_clear", bundle: bundle, comment: "")
	}

	public static var discardedProductsReasonReferenceToCompetitors: String {
		return NSLocalizedString("discarded_products_reason_reference_to_competitors", bundle: bundle, comment: "")
	}

	public static var discardedProductsReasonStockPhotoOnly: String {
		return NSLocalizedString("discarded_products_reason_stock_photo_only", bundle: bundle, comment: "")
	}

	public static var discardedProductsEdit: String {
		return NSLocalizedString("discarded_products_edit", bundle: bundle, comment: "")
	}

	public static var discardedProductsDelete: String {
		return NSLocalizedString("discarded_products_delete", bundle: bundle, comment: "")
	}

	public static var discardedProductsDeleteConfirmation: String {
		return NSLocalizedString("discarded_products_delete_confirmation", bundle: bundle, comment: "")
	}

	public static var editProductLocationAlertText: String {
		return NSLocalizedString("edit_product_location_alert_text", bundle: bundle, comment: "")
	}

	public static var editProductLocationAlertTitle: String {
		return NSLocalizedString("edit_product_location_alert_title", bundle: bundle, comment: "")
	}

	public static var editProductSendButton: String {
		return NSLocalizedString("edit_product_send_button", bundle: bundle, comment: "")
	}

	public static var editProductSendErrorUploadingProduct: String {
		return NSLocalizedString("edit_product_send_error_uploading_product", bundle: bundle, comment: "")
	}

	public static var editProductSendOk: String {
		return NSLocalizedString("edit_product_send_ok", bundle: bundle, comment: "")
	}

	public static var editProductSuggestingTitle: String {
		return NSLocalizedString("edit_product_suggesting_title", bundle: bundle, comment: "")
	}

	public static var editProductTitle: String {
		return NSLocalizedString("edit_product_title", bundle: bundle, comment: "")
	}

	public static var editProductUnsavedChangesAlert: String {
		return NSLocalizedString("edit_product_unsaved_changes_alert", bundle: bundle, comment: "")
	}

	public static var editProductUnsavedChangesAlertOk: String {
		return NSLocalizedString("edit_product_unsaved_changes_alert_ok", bundle: bundle, comment: "")
	}

	public static var editProductFeatureLabelShortText: String {
		return NSLocalizedString("edit_product_feature_label_short_text", bundle: bundle, comment: "")
	}

	public static var editProductFeatureLabelLongText: String {
		return NSLocalizedString("edit_product_feature_label_long_text", bundle: bundle, comment: "")
	}

	public static var featuredInfoViewTitle: String {
		return NSLocalizedString("featured_info_view_title", bundle: bundle, comment: "")
	}

	public static var featuredInfoViewSellFaster: String {
		return NSLocalizedString("featured_info_view_sell_faster", bundle: bundle, comment: "")
	}

	public static var featuredInfoViewIncreaseVisibility: String {
		return NSLocalizedString("featured_info_view_increase_visibility", bundle: bundle, comment: "")
	}

	public static var featuredInfoViewMoreBuyers: String {
		return NSLocalizedString("featured_info_view_more_buyers", bundle: bundle, comment: "")
	}

	public static var filtersDistanceNotSet: String {
		return NSLocalizedString("filters_distance_not_set", bundle: bundle, comment: "")
	}

	public static var filtersNavbarReset: String {
		return NSLocalizedString("filters_navbar_reset", bundle: bundle, comment: "")
	}

	public static var filtersSaveButton: String {
		return NSLocalizedString("filters_save_button", bundle: bundle, comment: "")
	}

	public static var filtersSectionCarInfo: String {
		return NSLocalizedString("filters_section_car_info", bundle: bundle, comment: "")
	}

	public static var filtersSectionCategories: String {
		return NSLocalizedString("filters_section_categories", bundle: bundle, comment: "")
	}

	public static var filtersSectionDistance: String {
		return NSLocalizedString("filters_section_distance", bundle: bundle, comment: "")
	}

	public static var filtersSectionLocation: String {
		return NSLocalizedString("filters_section_location", bundle: bundle, comment: "")
	}

	public static var filtersSectionPrice: String {
		return NSLocalizedString("filters_section_price", bundle: bundle, comment: "")
	}

	public static var filtersSectionSortby: String {
		return NSLocalizedString("filters_section_sortby", bundle: bundle, comment: "")
	}

	public static var filtersSectionWithin: String {
		return NSLocalizedString("filters_section_within", bundle: bundle, comment: "")
	}

	public static var filtersSectionPriceFreeTitle: String {
		return NSLocalizedString("filters_section_price_free_title", bundle: bundle, comment: "")
	}

	public static var filtersPriceFrom: String {
		return NSLocalizedString("filters_price_from", bundle: bundle, comment: "")
	}

	public static var filtersPriceTo: String {
		return NSLocalizedString("filters_price_to", bundle: bundle, comment: "")
	}

	public static var filtersPriceFromFeedFilterCell: String {
		return NSLocalizedString("filters_price_from_feed_filter_cell", bundle: bundle, comment: "")
	}

	public static var filtersPriceToFeedFilterCell: String {
		return NSLocalizedString("filters_price_to_feed_filter_cell", bundle: bundle, comment: "")
	}

	public static var filtersPriceWrongRangeError: String {
		return NSLocalizedString("filters_price_wrong_range_error", bundle: bundle, comment: "")
	}

	public static var filtersSizeWrongRangeError: String {
		return NSLocalizedString("filters_size_wrong_range_error", bundle: bundle, comment: "")
	}

	public static var filtersSortClosest: String {
		return NSLocalizedString("filters_sort_closest", bundle: bundle, comment: "")
	}

	public static var filtersSortNewest: String {
		return NSLocalizedString("filters_sort_newest", bundle: bundle, comment: "")
	}

	public static var filtersSortPriceAsc: String {
		return NSLocalizedString("filters_sort_price_asc", bundle: bundle, comment: "")
	}

	public static var filtersSortPriceDesc: String {
		return NSLocalizedString("filters_sort_price_desc", bundle: bundle, comment: "")
	}

	public static var filtersTitle: String {
		return NSLocalizedString("filters_title", bundle: bundle, comment: "")
	}

	public static var filtersWithinAll: String {
		return NSLocalizedString("filters_within_all", bundle: bundle, comment: "")
	}

	public static var filtersWithinDay: String {
		return NSLocalizedString("filters_within_day", bundle: bundle, comment: "")
	}

	public static var filtersWithinMonth: String {
		return NSLocalizedString("filters_within_month", bundle: bundle, comment: "")
	}

	public static var filtersWithinWeek: String {
		return NSLocalizedString("filters_within_week", bundle: bundle, comment: "")
	}

	public static var filtersCarMakeNotSet: String {
		return NSLocalizedString("filters_car_make_not_set", bundle: bundle, comment: "")
	}

	public static var filtersCarModelNotSet: String {
		return NSLocalizedString("filters_car_model_not_set", bundle: bundle, comment: "")
	}

	public static var filtersCarYearAnyYear: String {
		return NSLocalizedString("filters_car_year_any_year", bundle: bundle, comment: "")
	}

	public static var filtersCarYearBeforeYear: String {
		return NSLocalizedString("filters_car_year_before_year", bundle: bundle, comment: "")
	}

	public static var filtersSectionRealEstateInfo: String {
		return NSLocalizedString("filters_section_real_estate_info", bundle: bundle, comment: "")
	}

	public static var filtersRealEstatePropertyTypeNotSet: String {
		return NSLocalizedString("filters_real_estate_property_type_not_set", bundle: bundle, comment: "")
	}

	public static var filtersRealEstateOfferTypeNotSet: String {
		return NSLocalizedString("filters_real_estate_offer_type_not_set", bundle: bundle, comment: "")
	}

	public static var filtersRealEstateBedroomsNotSet: String {
		return NSLocalizedString("filters_real_estate_bedrooms_not_set", bundle: bundle, comment: "")
	}

	public static var filtersRealEstateBathroomsNotSet: String {
		return NSLocalizedString("filters_real_estate_bathrooms_not_set", bundle: bundle, comment: "")
	}

	public static var filtersTagLocationSelected: String {
		return NSLocalizedString("filters_tag_location_selected", bundle: bundle, comment: "")
	}

	public static var filterResultsCarsNoMatches: String {
		return NSLocalizedString("filter_results_cars_no_matches", bundle: bundle, comment: "")
	}

	public static var filterResultsCarsOtherResults: String {
		return NSLocalizedString("filter_results_cars_other_results", bundle: bundle, comment: "")
	}

	public static var forcedUpdateMessage: String {
		return NSLocalizedString("forced_update_message", bundle: bundle, comment: "")
	}

	public static var forcedUpdateTitle: String {
		return NSLocalizedString("forced_update_title", bundle: bundle, comment: "")
	}

	public static var forcedUpdateUpdateButton: String {
		return NSLocalizedString("forced_update_update_button", bundle: bundle, comment: "")
	}

	public static var helpTermsConditionsPrivacyPart: String {
		return NSLocalizedString("help_terms_conditions_privacy_part", bundle: bundle, comment: "")
	}

	public static var helpTitle: String {
		return NSLocalizedString("help_title", bundle: bundle, comment: "")
	}

	public static var hiddenEmailTag: String {
		return NSLocalizedString("hidden_email_tag", bundle: bundle, comment: "")
	}

	public static var hiddenPhoneTag: String {
		return NSLocalizedString("hidden_phone_tag", bundle: bundle, comment: "")
	}

	public static var hiddenTextAlertTitle: String {
		return NSLocalizedString("hidden_text_alert_title", bundle: bundle, comment: "")
	}

	public static var hiddenTextAlertDescription: String {
		return NSLocalizedString("hidden_text_alert_description", bundle: bundle, comment: "")
	}

	public static var locationPermissionsBubble: String {
		return NSLocalizedString("location_permissions_bubble", bundle: bundle, comment: "")
	}

	public static var locationPermissionsButton: String {
		return NSLocalizedString("location_permissions_button", bundle: bundle, comment: "")
	}

	public static var locationPermissionsTitleV2: String {
		return NSLocalizedString("location_permissions_title_v2", bundle: bundle, comment: "")
	}

	public static var locationPermissonsSubtitle: String {
		return NSLocalizedString("location_permissons_subtitle", bundle: bundle, comment: "")
	}

	public static var locationPermissionsAllowButton: String {
		return NSLocalizedString("location_permissions_allow_button", bundle: bundle, comment: "")
	}

	public static var logInErrorSendErrorGeneric: String {
		return NSLocalizedString("log_in_error_send_error_generic", bundle: bundle, comment: "")
	}

	public static var logInErrorSendErrorInvalidEmail: String {
		return NSLocalizedString("log_in_error_send_error_invalid_email", bundle: bundle, comment: "")
	}

	public static var logInErrorSendErrorUserNotFoundOrWrongPassword: String {
		return NSLocalizedString("log_in_error_send_error_user_not_found_or_wrong_password", bundle: bundle, comment: "")
	}

	public static var logInResetPasswordButton: String {
		return NSLocalizedString("log_in_reset_password_button", bundle: bundle, comment: "")
	}

	public static var logInSendButton: String {
		return NSLocalizedString("log_in_send_button", bundle: bundle, comment: "")
	}

	public static var logInTitle: String {
		return NSLocalizedString("log_in_title", bundle: bundle, comment: "")
	}

	public static var loginScammerAlertTitle: String {
		return NSLocalizedString("login_scammer_alert_title", bundle: bundle, comment: "")
	}

	public static var loginScammerAlertMessage: String {
		return NSLocalizedString("login_scammer_alert_message", bundle: bundle, comment: "")
	}

	public static var loginScammerAlertContactButton: String {
		return NSLocalizedString("login_scammer_alert_contact_button", bundle: bundle, comment: "")
	}

	public static var loginScammerAlertKeepBrowsingButton: String {
		return NSLocalizedString("login_scammer_alert_keep_browsing_button", bundle: bundle, comment: "")
	}

	public static var loginDeviceNotAllowedAlertTitle: String {
		return NSLocalizedString("login_device_not_allowed_alert_title", bundle: bundle, comment: "")
	}

	public static var loginDeviceNotAllowedAlertMessage: String {
		return NSLocalizedString("login_device_not_allowed_alert_message", bundle: bundle, comment: "")
	}

	public static var loginDeviceNotAllowedAlertContactButton: String {
		return NSLocalizedString("login_device_not_allowed_alert_contact_button", bundle: bundle, comment: "")
	}

	public static var loginDeviceNotAllowedAlertOkButton: String {
		return NSLocalizedString("login_device_not_allowed_alert_ok_button", bundle: bundle, comment: "")
	}

	public static var logInEmailHelpButton: String {
		return NSLocalizedString("log_in_email_help_button", bundle: bundle, comment: "")
	}

	public static var logInEmailPasswordFieldHint: String {
		return NSLocalizedString("log_in_email_password_field_hint", bundle: bundle, comment: "")
	}

	public static var logInEmailFooter: String {
		return NSLocalizedString("log_in_email_footer", bundle: bundle, comment: "")
	}

	public static var logInEmailWrongPasswordAlertTitle: String {
		return NSLocalizedString("log_in_email_wrong_password_alert_title", bundle: bundle, comment: "")
	}

	public static var logInEmailWrongPasswordAlertCancelAction: String {
		return NSLocalizedString("log_in_email_wrong_password_alert_cancel_action", bundle: bundle, comment: "")
	}

	public static var logInEmailForgotPasswordAlertTitle: String {
		return NSLocalizedString("log_in_email_forgot_password_alert_title", bundle: bundle, comment: "")
	}

	public static func logInEmailForgotPasswordAlertMessage(_ var1: String) -> String {
		return String(format: NSLocalizedString("log_in_email_forgot_password_alert_message", bundle: bundle, comment: ""), var1)
	}

	public static var logInEmailForgotPasswordAlertCancelAction: String {
		return NSLocalizedString("log_in_email_forgot_password_alert_cancel_action", bundle: bundle, comment: "")
	}

	public static var logInEmailForgotPasswordAlertRememberAction: String {
		return NSLocalizedString("log_in_email_forgot_password_alert_remember_action", bundle: bundle, comment: "")
	}

	public static var mlOnboardingNewText: String {
		return NSLocalizedString("ml_onboarding_new_text", bundle: bundle, comment: "")
	}

	public static var mlOnboardingDescriptionText: String {
		return NSLocalizedString("ml_onboarding_description_text", bundle: bundle, comment: "")
	}

	public static var mlOnboardingOkText: String {
		return NSLocalizedString("ml_onboarding_ok_text", bundle: bundle, comment: "")
	}

	public static func mlCameraSellsForText(_ var1: Int) -> String {
		return String(format: NSLocalizedString("ml_camera_sells_for_text", bundle: bundle, comment: ""), var1)
	}

	public static var mlCameraInAboutDaysText: String {
		return NSLocalizedString("ml_camera_in_about_days_text", bundle: bundle, comment: "")
	}

	public static var mlCameraInMoreThanDaysText: String {
		return NSLocalizedString("ml_camera_in_more_than_days_text", bundle: bundle, comment: "")
	}

	public static var mlDetailsSuggestedDetailsText: String {
		return NSLocalizedString("ml_details_suggested_details_text", bundle: bundle, comment: "")
	}

	public static var mlDetailsTitleText: String {
		return NSLocalizedString("ml_details_title_text", bundle: bundle, comment: "")
	}

	public static var mlDetailsPriceText: String {
		return NSLocalizedString("ml_details_price_text", bundle: bundle, comment: "")
	}

	public static var mlCategoryText: String {
		return NSLocalizedString("ml_category_text", bundle: bundle, comment: "")
	}

	public static var signUpEmailStep1Title: String {
		return NSLocalizedString("sign_up_email_step1_title", bundle: bundle, comment: "")
	}

	public static var signUpEmailStep1EmailFieldHint: String {
		return NSLocalizedString("sign_up_email_step1_email_field_hint", bundle: bundle, comment: "")
	}

	public static var signUpEmailStep1ContinueButton: String {
		return NSLocalizedString("sign_up_email_step1_continue_button", bundle: bundle, comment: "")
	}

	public static var signUpEmailStep1FooterLogInKw: String {
		return NSLocalizedString("sign_up_email_step1_footer_log_in_kw", bundle: bundle, comment: "")
	}

	public static var signUpEmailStep2HelpButton: String {
		return NSLocalizedString("sign_up_email_step2_help_button", bundle: bundle, comment: "")
	}

	public static var signUpEmailStep2NameFieldHint: String {
		return NSLocalizedString("sign_up_email_step2_name_field_hint", bundle: bundle, comment: "")
	}

	public static var signUpEmailStep2TermsConditionsPrivacyKw: String {
		return NSLocalizedString("sign_up_email_step2_terms_conditions_privacy_kw", bundle: bundle, comment: "")
	}

	public static var signUpEmailStep2Newsletter: String {
		return NSLocalizedString("sign_up_email_step2_newsletter", bundle: bundle, comment: "")
	}

	public static var mainSignUpClaimLabel: String {
		return NSLocalizedString("main_sign_up_claim_label", bundle: bundle, comment: "")
	}

	public static var mainSignUpFacebookConnectButton: String {
		return NSLocalizedString("main_sign_up_facebook_connect_button", bundle: bundle, comment: "")
	}

	public static func mainSignUpFacebookConnectButtonWName(_ var1: String) -> String {
		return String(format: NSLocalizedString("main_sign_up_facebook_connect_button_w_name", bundle: bundle, comment: ""), var1)
	}

	public static var mainSignUpFbConnectErrorEmailTaken: String {
		return NSLocalizedString("main_sign_up_fb_connect_error_email_taken", bundle: bundle, comment: "")
	}

	public static var mainSignUpFbConnectErrorGeneric: String {
		return NSLocalizedString("main_sign_up_fb_connect_error_generic", bundle: bundle, comment: "")
	}

	public static var mainSignUpErrorUserRejected: String {
		return NSLocalizedString("main_sign_up_error_user_rejected", bundle: bundle, comment: "")
	}

	public static var mainSignUpErrorRequestAlreadySent: String {
		return NSLocalizedString("main_sign_up_error_request_already_sent", bundle: bundle, comment: "")
	}

	public static var mainSignUpGoogleConnectButton: String {
		return NSLocalizedString("main_sign_up_google_connect_button", bundle: bundle, comment: "")
	}

	public static func mainSignUpGoogleConnectButtonWName(_ var1: String) -> String {
		return String(format: NSLocalizedString("main_sign_up_google_connect_button_w_name", bundle: bundle, comment: ""), var1)
	}

	public static var mainSignUpHelpButton: String {
		return NSLocalizedString("main_sign_up_help_button", bundle: bundle, comment: "")
	}

	public static var mainSignUpLogInLabel: String {
		return NSLocalizedString("main_sign_up_log_in_label", bundle: bundle, comment: "")
	}

	public static var mainSignUpOrLabel: String {
		return NSLocalizedString("main_sign_up_or_label", bundle: bundle, comment: "")
	}

	public static var mainSignUpQuicklyLabel: String {
		return NSLocalizedString("main_sign_up_quickly_label", bundle: bundle, comment: "")
	}

	public static var mainSignUpSignUpButton: String {
		return NSLocalizedString("main_sign_up_sign_up_button", bundle: bundle, comment: "")
	}

	public static var mainSignUpTermsConditions: String {
		return NSLocalizedString("main_sign_up_terms_conditions", bundle: bundle, comment: "")
	}

	public static var mainSignUpTermsConditionsPrivacyPart: String {
		return NSLocalizedString("main_sign_up_terms_conditions_privacy_part", bundle: bundle, comment: "")
	}

	public static var mainSignUpTermsConditionsTermsPart: String {
		return NSLocalizedString("main_sign_up_terms_conditions_terms_part", bundle: bundle, comment: "")
	}

	public static var mainProductsInviteNavigationBarButton: String {
		return NSLocalizedString("main_products_invite_navigation_bar_button", bundle: bundle, comment: "")
	}

	public static var mopubAdvertisingText: String {
		return NSLocalizedString("mopub_advertising_text", bundle: bundle, comment: "")
	}

	public static var notificationsEmptySubtitle: String {
		return NSLocalizedString("notifications_empty_subtitle", bundle: bundle, comment: "")
	}

	public static var notificationsEmptyTitle: String {
		return NSLocalizedString("notifications_empty_title", bundle: bundle, comment: "")
	}

	public static var notificationsPermissions1Push: String {
		return NSLocalizedString("notifications_permissions_1_push", bundle: bundle, comment: "")
	}

	public static var notificationsPermissions1Subtitle: String {
		return NSLocalizedString("notifications_permissions_1_subtitle", bundle: bundle, comment: "")
	}

	public static var notificationsPermissions1TitleV2: String {
		return NSLocalizedString("notifications_permissions_1_title_v2", bundle: bundle, comment: "")
	}

	public static var notificationsPermissions3Push: String {
		return NSLocalizedString("notifications_permissions_3_push", bundle: bundle, comment: "")
	}

	public static var notificationsPermissions3Subtitle: String {
		return NSLocalizedString("notifications_permissions_3_subtitle", bundle: bundle, comment: "")
	}

	public static var notificationsPermissions3Title: String {
		return NSLocalizedString("notifications_permissions_3_title", bundle: bundle, comment: "")
	}

	public static var notificationsPermissions4Push: String {
		return NSLocalizedString("notifications_permissions_4_push", bundle: bundle, comment: "")
	}

	public static var notificationsPermissions4Subtitle: String {
		return NSLocalizedString("notifications_permissions_4_subtitle", bundle: bundle, comment: "")
	}

	public static var notificationsPermissions4Title: String {
		return NSLocalizedString("notifications_permissions_4_title", bundle: bundle, comment: "")
	}

	public static var notificationsPermissionsSettingsCell1: String {
		return NSLocalizedString("notifications_permissions_settings_cell1", bundle: bundle, comment: "")
	}

	public static var notificationsPermissionsSettingsCell2: String {
		return NSLocalizedString("notifications_permissions_settings_cell2", bundle: bundle, comment: "")
	}

	public static var notificationsPermissionsSettingsSection1: String {
		return NSLocalizedString("notifications_permissions_settings_section1", bundle: bundle, comment: "")
	}

	public static var notificationsPermissionsSettingsSection2: String {
		return NSLocalizedString("notifications_permissions_settings_section2", bundle: bundle, comment: "")
	}

	public static var notificationsPermissionsSettingsSubtitle: String {
		return NSLocalizedString("notifications_permissions_settings_subtitle", bundle: bundle, comment: "")
	}

	public static var notificationsPermissionsSettingsTitle: String {
		return NSLocalizedString("notifications_permissions_settings_title", bundle: bundle, comment: "")
	}

	public static var notificationsPermissionsSettingsTitleChat: String {
		return NSLocalizedString("notifications_permissions_settings_title_chat", bundle: bundle, comment: "")
	}

	public static var notificationsPermissionsSettingsYesButton: String {
		return NSLocalizedString("notifications_permissions_settings_yes_button", bundle: bundle, comment: "")
	}

	public static var notificationsPermissionsYesButton: String {
		return NSLocalizedString("notifications_permissions_yes_button", bundle: bundle, comment: "")
	}

	public static var notificationsTitle: String {
		return NSLocalizedString("notifications_title", bundle: bundle, comment: "")
	}

	public static func notificationsTypeLikeWName(_ var1: String) -> String {
		return String(format: NSLocalizedString("notifications_type_like_w_name", bundle: bundle, comment: ""), var1)
	}

	public static func notificationsTypeLikeWNameWTitle(_ var1: String, _ var2: String) -> String {
		return String(format: NSLocalizedString("notifications_type_like_w_name_w_title", bundle: bundle, comment: ""), var1, var2)
	}

	public static var notificationsTypeLikeButton: String {
		return NSLocalizedString("notifications_type_like_button", bundle: bundle, comment: "")
	}

	public static var notificationsTypeSold: String {
		return NSLocalizedString("notifications_type_sold", bundle: bundle, comment: "")
	}

	public static var notificationsTypeSoldButton: String {
		return NSLocalizedString("notifications_type_sold_button", bundle: bundle, comment: "")
	}

	public static func notificationsTypeRating(_ var1: String) -> String {
		return String(format: NSLocalizedString("notifications_type_rating", bundle: bundle, comment: ""), var1)
	}

	public static var notificationsTypeRatingButton: String {
		return NSLocalizedString("notifications_type_rating_button", bundle: bundle, comment: "")
	}

	public static func notificationsTypeRatingUpdated(_ var1: String) -> String {
		return String(format: NSLocalizedString("notifications_type_rating_updated", bundle: bundle, comment: ""), var1)
	}

	public static func notificationsTypeProductSuggested(_ var1: String) -> String {
		return String(format: NSLocalizedString("notifications_type_product_suggested", bundle: bundle, comment: ""), var1)
	}

	public static func notificationsTypeProductSuggestedWTitle(_ var1: String, _ var2: String) -> String {
		return String(format: NSLocalizedString("notifications_type_product_suggested_w_title", bundle: bundle, comment: ""), var1, var2)
	}

	public static var notificationsTypeProductSuggestedButton: String {
		return NSLocalizedString("notifications_type_product_suggested_button", bundle: bundle, comment: "")
	}

	public static func notificationsTypeBuyersInterested(_ var1: Int) -> String {
		return String(format: NSLocalizedString("notifications_type_buyers_interested", bundle: bundle, comment: ""), var1)
	}

	public static func notificationsTypeBuyersInterestedWTitle(_ var1: Int, _ var2: String) -> String {
		return String(format: NSLocalizedString("notifications_type_buyers_interested_w_title", bundle: bundle, comment: ""), var1, var2)
	}

	public static var notificationsTypeBuyersInterestedButton: String {
		return NSLocalizedString("notifications_type_buyers_interested_button", bundle: bundle, comment: "")
	}

	public static var notificationsTypeBuyersInterestedButtonDone: String {
		return NSLocalizedString("notifications_type_buyers_interested_button_done", bundle: bundle, comment: "")
	}

	public static func notificationsTypeFacebookFriend(_ var1: String, _ var2: String) -> String {
		return String(format: NSLocalizedString("notifications_type_facebook_friend", bundle: bundle, comment: ""), var1, var2)
	}

	public static var notificationsTypeFacebookFriendButton: String {
		return NSLocalizedString("notifications_type_facebook_friend_button", bundle: bundle, comment: "")
	}

	public static func notificationsTypeWelcomeSubtitleWCity(_ var1: String) -> String {
		return String(format: NSLocalizedString("notifications_type_welcome_subtitle_w_city", bundle: bundle, comment: ""), var1)
	}

	public static var notificationsTypeWelcomeButton: String {
		return NSLocalizedString("notifications_type_welcome_button", bundle: bundle, comment: "")
	}

	public static var npsSurveyTitle: String {
		return NSLocalizedString("nps_survey_title", bundle: bundle, comment: "")
	}

	public static var npsSurveySubtitle: String {
		return NSLocalizedString("nps_survey_subtitle", bundle: bundle, comment: "")
	}

	public static var npsSurveyVeryBad: String {
		return NSLocalizedString("nps_survey_very_bad", bundle: bundle, comment: "")
	}

	public static var npsSurveyVeryGood: String {
		return NSLocalizedString("nps_survey_very_good", bundle: bundle, comment: "")
	}

	public static var surveyConfirmation: String {
		return NSLocalizedString("survey_confirmation", bundle: bundle, comment: "")
	}

	public static var onboardingCategoriesTitle: String {
		return NSLocalizedString("onboarding_categories_title", bundle: bundle, comment: "")
	}

	public static var onboardingCategoriesButtonTitleInitial: String {
		return NSLocalizedString("onboarding_categories_button_title_initial", bundle: bundle, comment: "")
	}

	public static var onboardingCategoriesButtonCountdown: String {
		return NSLocalizedString("onboarding_categories_button_countdown", bundle: bundle, comment: "")
	}

	public static var onboardingCategoriesButtonTitleFinish: String {
		return NSLocalizedString("onboarding_categories_button_title_finish", bundle: bundle, comment: "")
	}

	public static var onboardingDirectCameraAlertSubtitle: String {
		return NSLocalizedString("onboarding_direct_camera_alert_subtitle", bundle: bundle, comment: "")
	}

	public static var onboardingPostingTitleA: String {
		return NSLocalizedString("onboarding_posting_title_a", bundle: bundle, comment: "")
	}

	public static var onboardingPostingTitleB: String {
		return NSLocalizedString("onboarding_posting_title_b", bundle: bundle, comment: "")
	}

	public static var onboardingPostingSubtitleA: String {
		return NSLocalizedString("onboarding_posting_subtitle_a", bundle: bundle, comment: "")
	}

	public static var onboardingPostingSubtitleB: String {
		return NSLocalizedString("onboarding_posting_subtitle_b", bundle: bundle, comment: "")
	}

	public static var onboardingPostingButtonA: String {
		return NSLocalizedString("onboarding_posting_button_a", bundle: bundle, comment: "")
	}

	public static var onboardingPostingButtonB: String {
		return NSLocalizedString("onboarding_posting_button_b", bundle: bundle, comment: "")
	}

	public static var onboardingPostingImprovementBTitle: String {
		return NSLocalizedString("onboarding_posting_improvement_b_title", bundle: bundle, comment: "")
	}

	public static var onboardingPostingImprovementCTitle: String {
		return NSLocalizedString("onboarding_posting_improvement_c_title", bundle: bundle, comment: "")
	}

	public static var onboardingPostingImprovementDTitle: String {
		return NSLocalizedString("onboarding_posting_improvement_d_title", bundle: bundle, comment: "")
	}

	public static var onboardingPostingImprovementETitle: String {
		return NSLocalizedString("onboarding_posting_improvement_e_title", bundle: bundle, comment: "")
	}

	public static var onboardingPostingImprovementFTitle: String {
		return NSLocalizedString("onboarding_posting_improvement_f_title", bundle: bundle, comment: "")
	}

	public static var onboardingPostingImprovementCButton: String {
		return NSLocalizedString("onboarding_posting_improvement_c_button", bundle: bundle, comment: "")
	}

	public static var onboardingLocationPermissionsAlertTitle: String {
		return NSLocalizedString("onboarding_location_permissions_alert_title", bundle: bundle, comment: "")
	}

	public static var onboardingLocationPermissionsAlertSubtitle: String {
		return NSLocalizedString("onboarding_location_permissions_alert_subtitle", bundle: bundle, comment: "")
	}

	public static var onboardingNotificationsPermissionsAlertTitle: String {
		return NSLocalizedString("onboarding_notifications_permissions_alert_title", bundle: bundle, comment: "")
	}

	public static var onboardingNotificationsPermissionsAlertSubtitle: String {
		return NSLocalizedString("onboarding_notifications_permissions_alert_subtitle", bundle: bundle, comment: "")
	}

	public static var onboardingPostingAlertTitle: String {
		return NSLocalizedString("onboarding_posting_alert_title", bundle: bundle, comment: "")
	}

	public static var onboardingPostingAlertSubtitle: String {
		return NSLocalizedString("onboarding_posting_alert_subtitle", bundle: bundle, comment: "")
	}

	public static var onboardingAlertYes: String {
		return NSLocalizedString("onboarding_alert_yes", bundle: bundle, comment: "")
	}

	public static var onboardingAlertNo: String {
		return NSLocalizedString("onboarding_alert_no", bundle: bundle, comment: "")
	}

	public static var passiveBuyersTitle: String {
		return NSLocalizedString("passive_buyers_title", bundle: bundle, comment: "")
	}

	public static var passiveBuyersMessage: String {
		return NSLocalizedString("passive_buyers_message", bundle: bundle, comment: "")
	}

	public static func passiveBuyersButton(_ var1: Int) -> String {
		return String(format: NSLocalizedString("passive_buyers_button", bundle: bundle, comment: ""), var1)
	}

	public static var passiveBuyersNotAvailable: String {
		return NSLocalizedString("passive_buyers_not_available", bundle: bundle, comment: "")
	}

	public static var passiveBuyersContactError: String {
		return NSLocalizedString("passive_buyers_contact_error", bundle: bundle, comment: "")
	}

	public static var passiveBuyersContactSuccess: String {
		return NSLocalizedString("passive_buyers_contact_success", bundle: bundle, comment: "")
	}

	public static var photoViewerChatButton: String {
		return NSLocalizedString("photo_viewer_chat_button", bundle: bundle, comment: "")
	}

	public static var postCategoryDetailsNavigationTitle: String {
		return NSLocalizedString("post_category_details_navigation_title", bundle: bundle, comment: "")
	}

	public static var postCategoryDetailsDescription: String {
		return NSLocalizedString("post_category_details_description", bundle: bundle, comment: "")
	}

	public static var postCategoryDetailCarMake: String {
		return NSLocalizedString("post_category_detail_car_make", bundle: bundle, comment: "")
	}

	public static var postCategoryDetailCarModel: String {
		return NSLocalizedString("post_category_detail_car_model", bundle: bundle, comment: "")
	}

	public static var postCategoryDetailCarYear: String {
		return NSLocalizedString("post_category_detail_car_year", bundle: bundle, comment: "")
	}

	public static var postCategoryDetailOkButton: String {
		return NSLocalizedString("post_category_detail_ok_button", bundle: bundle, comment: "")
	}

	public static func postCategoryDetailsProgress(_ var1: String) -> String {
		return String(format: NSLocalizedString("post_category_details_progress", bundle: bundle, comment: ""), var1)
	}

	public static var postCategoryDetailsProgress100: String {
		return NSLocalizedString("post_category_details_progress_100", bundle: bundle, comment: "")
	}

	public static var postCategoryDetailSearchPlaceholder: String {
		return NSLocalizedString("post_category_detail_search_placeholder", bundle: bundle, comment: "")
	}

	public static var postCategoryDetailAddMake: String {
		return NSLocalizedString("post_category_detail_add_make", bundle: bundle, comment: "")
	}

	public static var postCategoryDetailAddModel: String {
		return NSLocalizedString("post_category_detail_add_model", bundle: bundle, comment: "")
	}

	public static var postHeaderStepTakePicture: String {
		return NSLocalizedString("post_header_step_take_picture", bundle: bundle, comment: "")
	}

	public static var postHeaderStepConfirmPicture: String {
		return NSLocalizedString("post_header_step_confirm_picture", bundle: bundle, comment: "")
	}

	public static var postHeaderStepAddPrice: String {
		return NSLocalizedString("post_header_step_add_price", bundle: bundle, comment: "")
	}

	public static var postQueuedRequestsStateGeneratingTitle: String {
		return NSLocalizedString("post_queued_requests_state_generating_title", bundle: bundle, comment: "")
	}

	public static var postQueuedRequestsStateCategorizingListing: String {
		return NSLocalizedString("post_queued_requests_state_categorizing_listing", bundle: bundle, comment: "")
	}

	public static var postQueuedRequestsStatePostingListing: String {
		return NSLocalizedString("post_queued_requests_state_posting_listing", bundle: bundle, comment: "")
	}

	public static var postQueuedRequestsStateListingPosted: String {
		return NSLocalizedString("post_queued_requests_state_listing_posted", bundle: bundle, comment: "")
	}

	public static func postGetStartedWelcomeUserText(_ var1: String) -> String {
		return String(format: NSLocalizedString("post_get_started_welcome_user_text", bundle: bundle, comment: ""), var1)
	}

	public static var postGetStartedWelcomeLetgoText: String {
		return NSLocalizedString("post_get_started_welcome_letgo_text", bundle: bundle, comment: "")
	}

	public static var postGetStartedIntroText: String {
		return NSLocalizedString("post_get_started_intro_text", bundle: bundle, comment: "")
	}

	public static var postGetStartedButtonText: String {
		return NSLocalizedString("post_get_started_button_text", bundle: bundle, comment: "")
	}

	public static var postGetStartedDiscardText: String {
		return NSLocalizedString("post_get_started_discard_text", bundle: bundle, comment: "")
	}

	public static var postDescriptionDoneText: String {
		return NSLocalizedString("post_description_done_text", bundle: bundle, comment: "")
	}

	public static var postDescriptionSaveButtonText: String {
		return NSLocalizedString("post_description_save_button_text", bundle: bundle, comment: "")
	}

	public static var postDescriptionDiscardButtonText: String {
		return NSLocalizedString("post_description_discard_button_text", bundle: bundle, comment: "")
	}

	public static var postDescriptionInfoTitle: String {
		return NSLocalizedString("post_description_info_title", bundle: bundle, comment: "")
	}

	public static var postDescriptionNamePlaceholder: String {
		return NSLocalizedString("post_description_name_placeholder", bundle: bundle, comment: "")
	}

	public static var postDescriptionCategoryTitle: String {
		return NSLocalizedString("post_description_category_title", bundle: bundle, comment: "")
	}

	public static var postDescriptionDescriptionPlaceholder: String {
		return NSLocalizedString("post_description_description_placeholder", bundle: bundle, comment: "")
	}

	public static var productAutoGeneratedTitleLabel: String {
		return NSLocalizedString("product_auto_generated_title_label", bundle: bundle, comment: "")
	}

	public static var productAutoGeneratedTranslatedTitleLabel: String {
		return NSLocalizedString("product_auto_generated_translated_title_label", bundle: bundle, comment: "")
	}

	public static var productBubbleSeveralUsersInterested: String {
		return NSLocalizedString("product_bubble_several_users_interested", bundle: bundle, comment: "")
	}

	public static var productBubbleFavoriteText: String {
		return NSLocalizedString("product_bubble_favorite_text", bundle: bundle, comment: "")
	}

	public static var productBubbleFavoriteButton: String {
		return NSLocalizedString("product_bubble_favorite_button", bundle: bundle, comment: "")
	}

	public static var productChatDirectErrorBlockedUserMessage: String {
		return NSLocalizedString("product_chat_direct_error_blocked_user_message", bundle: bundle, comment: "")
	}

	public static var productChatDirectMessageSending: String {
		return NSLocalizedString("product_chat_direct_message_sending", bundle: bundle, comment: "")
	}

	public static func productChatWithSellerNameButton(_ var1: String) -> String {
		return String(format: NSLocalizedString("product_chat_with_seller_name_button", bundle: bundle, comment: ""), var1)
	}

	public static var productContinueChattingButton: String {
		return NSLocalizedString("product_continue_chatting_button", bundle: bundle, comment: "")
	}

	public static var productDateMoreThanXMonthsAgo: String {
		return NSLocalizedString("product_date_more_than_X_months_ago", bundle: bundle, comment: "")
	}

	public static var productDateOneDayAgo: String {
		return NSLocalizedString("product_date_one_day_ago", bundle: bundle, comment: "")
	}

	public static var productDateOneHourAgo: String {
		return NSLocalizedString("product_date_one_hour_ago", bundle: bundle, comment: "")
	}

	public static var productDateOneMinuteAgo: String {
		return NSLocalizedString("product_date_one_minute_ago", bundle: bundle, comment: "")
	}

	public static var productDateOneMonthAgo: String {
		return NSLocalizedString("product_date_one_month_ago", bundle: bundle, comment: "")
	}

	public static var productDateXDaysAgo: String {
		return NSLocalizedString("product_date_X_days_ago", bundle: bundle, comment: "")
	}

	public static var productDateXHoursAgo: String {
		return NSLocalizedString("product_date_X_hours_ago", bundle: bundle, comment: "")
	}

	public static var productDateXMinutesAgo: String {
		return NSLocalizedString("product_date_X_minutes_ago", bundle: bundle, comment: "")
	}

	public static var productDateXMonthsAgo: String {
		return NSLocalizedString("product_date_X_months_ago", bundle: bundle, comment: "")
	}

	public static var productDeleteConfirmCancelButton: String {
		return NSLocalizedString("product_delete_confirm_cancel_button", bundle: bundle, comment: "")
	}

	public static var productDeleteConfirmMessage: String {
		return NSLocalizedString("product_delete_confirm_message", bundle: bundle, comment: "")
	}

	public static var productDeleteConfirmOkButton: String {
		return NSLocalizedString("product_delete_confirm_ok_button", bundle: bundle, comment: "")
	}

	public static var productDeleteConfirmSoldButton: String {
		return NSLocalizedString("product_delete_confirm_sold_button", bundle: bundle, comment: "")
	}

	public static var productDeleteConfirmTitle: String {
		return NSLocalizedString("product_delete_confirm_title", bundle: bundle, comment: "")
	}

	public static var productDeleteSendErrorGeneric: String {
		return NSLocalizedString("product_delete_send_error_generic", bundle: bundle, comment: "")
	}

	public static var productDeleteSoldConfirmMessage: String {
		return NSLocalizedString("product_delete_sold_confirm_message", bundle: bundle, comment: "")
	}

	public static var productDeletePostButtonTitle: String {
		return NSLocalizedString("product_delete_post_button_title", bundle: bundle, comment: "")
	}

	public static var productDeletePostTitle: String {
		return NSLocalizedString("product_delete_post_title", bundle: bundle, comment: "")
	}

	public static var productDeletePostSubtitle: String {
		return NSLocalizedString("product_delete_post_subtitle", bundle: bundle, comment: "")
	}

	public static var productDetailSwipeToSeeRelated: String {
		return NSLocalizedString("product_detail_swipe_to_see_related", bundle: bundle, comment: "")
	}

	public static func productDistanceXFromYou(_ var1: String) -> String {
		return String(format: NSLocalizedString("product_distance_X_from_you", bundle: bundle, comment: ""), var1)
	}

	public static func productDistanceMoreThan(_ var1: String) -> String {
		return String(format: NSLocalizedString("product_distance_more_than", bundle: bundle, comment: ""), var1)
	}

	public static var productDistanceNearYou: String {
		return NSLocalizedString("product_distance_near_you", bundle: bundle, comment: "")
	}

	public static var productDistanceCustomLocation: String {
		return NSLocalizedString("product_distance_custom_location", bundle: bundle, comment: "")
	}

	public static var productFavoriteDirectMessage: String {
		return NSLocalizedString("product_favorite_direct_message", bundle: bundle, comment: "")
	}

	public static var productFreePrice: String {
		return NSLocalizedString("product_free_price", bundle: bundle, comment: "")
	}

	public static var productProfessionalChatButton: String {
		return NSLocalizedString("product_professional_chat_button", bundle: bundle, comment: "")
	}

	public static var productProfessionalCallButton: String {
		return NSLocalizedString("product_professional_call_button", bundle: bundle, comment: "")
	}

	public static var productSellAgainFreeButton: String {
		return NSLocalizedString("product_sell_again_free_button", bundle: bundle, comment: "")
	}

	public static var productSellAgainFreeConfirmCancelButton: String {
		return NSLocalizedString("product_sell_again_free_confirm_cancel_button", bundle: bundle, comment: "")
	}

	public static var productSellAgainFreeConfirmMessage: String {
		return NSLocalizedString("product_sell_again_free_confirm_message", bundle: bundle, comment: "")
	}

	public static var productSellAgainFreeConfirmOkButton: String {
		return NSLocalizedString("product_sell_again_free_confirm_ok_button", bundle: bundle, comment: "")
	}

	public static var productSellAgainFreeSuccessMessage: String {
		return NSLocalizedString("product_sell_again_free_success_message", bundle: bundle, comment: "")
	}

	public static var productSellAgainFreeConfirmTitle: String {
		return NSLocalizedString("product_sell_again_free_confirm_title", bundle: bundle, comment: "")
	}

	public static var productListItemGivenAwayStatusLabel: String {
		return NSLocalizedString("product_list_item_given_away_status_label", bundle: bundle, comment: "")
	}

	public static var productListItemSoldStatusLabel: String {
		return NSLocalizedString("product_list_item_sold_status_label", bundle: bundle, comment: "")
	}

	public static var productListItemTimeHourLabel: String {
		return NSLocalizedString("product_list_item_time_hour_label", bundle: bundle, comment: "")
	}

	public static var productListItemTimeMinuteLabel: String {
		return NSLocalizedString("product_list_item_time_minute_label", bundle: bundle, comment: "")
	}

	public static var productListNoProductsBody: String {
		return NSLocalizedString("product_list_no_products_body", bundle: bundle, comment: "")
	}

	public static var productListNoProductsTitle: String {
		return NSLocalizedString("product_list_no_products_title", bundle: bundle, comment: "")
	}

	public static var productMarkAsSoldFreeConfirmCancelButton: String {
		return NSLocalizedString("product_mark_as_sold_free_confirm_cancel_button", bundle: bundle, comment: "")
	}

	public static var productMarkAsSoldFreeButton: String {
		return NSLocalizedString("product_mark_as_sold_free_button", bundle: bundle, comment: "")
	}

	public static var productMarkAsSoldAlertTitle: String {
		return NSLocalizedString("product_mark_as_sold_alert_title", bundle: bundle, comment: "")
	}

	public static var productMarkAsSoldAlertMessage: String {
		return NSLocalizedString("product_mark_as_sold_alert_message", bundle: bundle, comment: "")
	}

	public static var productMarkAsSoldAlertCancel: String {
		return NSLocalizedString("product_mark_as_sold_alert_cancel", bundle: bundle, comment: "")
	}

	public static var productMarkAsSoldAlertConfirm: String {
		return NSLocalizedString("product_mark_as_sold_alert_confirm", bundle: bundle, comment: "")
	}

	public static var productMarkAsGivenAwayAlertTitle: String {
		return NSLocalizedString("product_mark_as_given_away_alert_title", bundle: bundle, comment: "")
	}

	public static var productMarkAsGivenAwayAlertMessage: String {
		return NSLocalizedString("product_mark_as_given_away_alert_message", bundle: bundle, comment: "")
	}

	public static var productMarkAsSoldFreeConfirmMessage: String {
		return NSLocalizedString("product_mark_as_sold_free_confirm_message", bundle: bundle, comment: "")
	}

	public static var productMarkAsSoldFreeConfirmOkButton: String {
		return NSLocalizedString("product_mark_as_sold_free_confirm_ok_button", bundle: bundle, comment: "")
	}

	public static var productMarkAsSoldFreeConfirmTitle: String {
		return NSLocalizedString("product_mark_as_sold_free_confirm_title", bundle: bundle, comment: "")
	}

	public static var productMarkAsSoldFreeSuccessMessage: String {
		return NSLocalizedString("product_mark_as_sold_free_success_message", bundle: bundle, comment: "")
	}

	public static var productMarkAsSoldButton: String {
		return NSLocalizedString("product_mark_as_sold_button", bundle: bundle, comment: "")
	}

	public static var productMarkAsSoldConfirmCancelButton: String {
		return NSLocalizedString("product_mark_as_sold_confirm_cancel_button", bundle: bundle, comment: "")
	}

	public static var productMarkAsSoldConfirmMessage: String {
		return NSLocalizedString("product_mark_as_sold_confirm_message", bundle: bundle, comment: "")
	}

	public static var productMarkAsSoldConfirmOkButton: String {
		return NSLocalizedString("product_mark_as_sold_confirm_ok_button", bundle: bundle, comment: "")
	}

	public static var productMarkAsSoldConfirmTitle: String {
		return NSLocalizedString("product_mark_as_sold_confirm_title", bundle: bundle, comment: "")
	}

	public static var productMarkAsSoldErrorGeneric: String {
		return NSLocalizedString("product_mark_as_sold_error_generic", bundle: bundle, comment: "")
	}

	public static var productMarkAsSoldSuccessMessage: String {
		return NSLocalizedString("product_mark_as_sold_success_message", bundle: bundle, comment: "")
	}

	public static var productMenuRateBuyer: String {
		return NSLocalizedString("product_menu_rate_buyer", bundle: bundle, comment: "")
	}

	public static var productMoreInfoTooltipPart1: String {
		return NSLocalizedString("product_more_info_tooltip_part_1", bundle: bundle, comment: "")
	}

	public static func productMoreInfoTooltipPart2(_ var1: String) -> String {
		return String(format: NSLocalizedString("product_more_info_tooltip_part_2", bundle: bundle, comment: ""), var1)
	}

	public static var productMoreInfoOpenButton: String {
		return NSLocalizedString("product_more_info_open_button", bundle: bundle, comment: "")
	}

	public static var productMoreInfoRelatedViewMore: String {
		return NSLocalizedString("product_more_info_related_view_more", bundle: bundle, comment: "")
	}

	public static var productNegotiablePrice: String {
		return NSLocalizedString("product_negotiable_price", bundle: bundle, comment: "")
	}

	public static var productOnboardingFingerScrollLabel: String {
		return NSLocalizedString("product_onboarding_finger_scroll_label", bundle: bundle, comment: "")
	}

	public static var productOnboardingFingerSwipeLabel: String {
		return NSLocalizedString("product_onboarding_finger_swipe_label", bundle: bundle, comment: "")
	}

	public static var productOnboardingFingerTapLabel: String {
		return NSLocalizedString("product_onboarding_finger_tap_label", bundle: bundle, comment: "")
	}

	public static var productOnboardingShowAgainButtonTitle: String {
		return NSLocalizedString("product_onboarding_show_again_button_title", bundle: bundle, comment: "")
	}

	public static func productNewOnboardingFingerKeepSwipeLabel(_ var1: String) -> String {
		return String(format: NSLocalizedString("product_new_onboarding_finger_keep_swipe_label", bundle: bundle, comment: ""), var1)
	}

	public static func productNewOnboardingFingerSwipeLabel(_ var1: String) -> String {
		return String(format: NSLocalizedString("product_new_onboarding_finger_swipe_label", bundle: bundle, comment: ""), var1)
	}

	public static func productNewOnboardingFingerTapLabel(_ var1: String) -> String {
		return String(format: NSLocalizedString("product_new_onboarding_finger_tap_label", bundle: bundle, comment: ""), var1)
	}

	public static func productNewOnboardingTapRightLabel(_ var1: String, _ var2: String) -> String {
		return String(format: NSLocalizedString("product_new_onboarding_tap_right_label", bundle: bundle, comment: ""), var1, var2)
	}

	public static var productNewOnboardingTapRightHighlightedLabel: String {
		return NSLocalizedString("product_new_onboarding_tap_right_highlighted_label", bundle: bundle, comment: "")
	}

	public static var productNewOnboardingTapRightHighlightedLabel2: String {
		return NSLocalizedString("product_new_onboarding_tap_right_highlighted_label_2", bundle: bundle, comment: "")
	}

	public static func productNewOnboardingTapLeftLabel(_ var1: String) -> String {
		return String(format: NSLocalizedString("product_new_onboarding_tap_left_label", bundle: bundle, comment: ""), var1)
	}

	public static var productNewOnboardingTapLeftLabelHighlighted: String {
		return NSLocalizedString("product_new_onboarding_tap_left_label_highlighted", bundle: bundle, comment: "")
	}

	public static func productNewOnboardingFingerSwipeNextProductLabel(_ var1: String) -> String {
		return String(format: NSLocalizedString("product_new_onboarding_finger_swipe_next_product_label", bundle: bundle, comment: ""), var1)
	}

	public static var productNewOnboardingFingerSwipeNextProductHighlightedLabel: String {
		return NSLocalizedString("product_new_onboarding_finger_swipe_next_product_highlighted_label", bundle: bundle, comment: "")
	}

	public static var productOptionEdit: String {
		return NSLocalizedString("product_option_edit", bundle: bundle, comment: "")
	}

	public static var productOptionShare: String {
		return NSLocalizedString("product_option_share", bundle: bundle, comment: "")
	}

	public static var productPopularNearYou: String {
		return NSLocalizedString("product_popular_near_you", bundle: bundle, comment: "")
	}

	public static var productPostCameraFirstTimeAlertSubtitle: String {
		return NSLocalizedString("product_post_camera_first_time_alert_subtitle", bundle: bundle, comment: "")
	}

	public static var productPostCameraFirstTimeAlertTitle: String {
		return NSLocalizedString("product_post_camera_first_time_alert_title", bundle: bundle, comment: "")
	}

	public static var productPostCameraPermissionsButton: String {
		return NSLocalizedString("product_post_camera_permissions_button", bundle: bundle, comment: "")
	}

	public static var productPostCameraPermissionsSubtitle: String {
		return NSLocalizedString("product_post_camera_permissions_subtitle", bundle: bundle, comment: "")
	}

	public static var productPostCameraPermissionsTitle: String {
		return NSLocalizedString("product_post_camera_permissions_title", bundle: bundle, comment: "")
	}

	public static var productPostCameraTabV2: String {
		return NSLocalizedString("product_post_camera_tab_v2", bundle: bundle, comment: "")
	}

	public static var productPostCloseAlertCloseButton: String {
		return NSLocalizedString("product_post_close_alert_close_button", bundle: bundle, comment: "")
	}

	public static var productPostCloseAlertDescription: String {
		return NSLocalizedString("product_post_close_alert_description", bundle: bundle, comment: "")
	}

	public static var productPostCloseAlertOkButton: String {
		return NSLocalizedString("product_post_close_alert_ok_button", bundle: bundle, comment: "")
	}

	public static var productPostCloseAlertTitle: String {
		return NSLocalizedString("product_post_close_alert_title", bundle: bundle, comment: "")
	}

	public static var productPostConfirmationAnother: String {
		return NSLocalizedString("product_post_confirmation_another", bundle: bundle, comment: "")
	}

	public static var productPostConfirmationAnotherButton: String {
		return NSLocalizedString("product_post_confirmation_another_button", bundle: bundle, comment: "")
	}

	public static var productPostConfirmationAnotherListingButton: String {
		return NSLocalizedString("product_post_confirmation_another_listing_button", bundle: bundle, comment: "")
	}

	public static var productPostConfirmationEdit: String {
		return NSLocalizedString("product_post_confirmation_edit", bundle: bundle, comment: "")
	}

	public static var productPostDone: String {
		return NSLocalizedString("product_post_done", bundle: bundle, comment: "")
	}

	public static var productPostEmptyGalleryButton: String {
		return NSLocalizedString("product_post_empty_gallery_button", bundle: bundle, comment: "")
	}

	public static var productPostEmptyGallerySubtitle: String {
		return NSLocalizedString("product_post_empty_gallery_subtitle", bundle: bundle, comment: "")
	}

	public static var productPostEmptyGalleryTitle: String {
		return NSLocalizedString("product_post_empty_gallery_title", bundle: bundle, comment: "")
	}

	public static var productPostFreeCameraFirstTimeAlertSubtitle: String {
		return NSLocalizedString("product_post_free_camera_first_time_alert_subtitle", bundle: bundle, comment: "")
	}

	public static var productPostFreeConfirmationAnotherButton: String {
		return NSLocalizedString("product_post_free_confirmation_another_button", bundle: bundle, comment: "")
	}

	public static var productPostGalleryLoadImageErrorSubtitle: String {
		return NSLocalizedString("product_post_gallery_load_image_error_subtitle", bundle: bundle, comment: "")
	}

	public static var productPostGalleryLoadImageErrorTitle: String {
		return NSLocalizedString("product_post_gallery_load_image_error_title", bundle: bundle, comment: "")
	}

	public static var productPostGalleryMultiplePicsSelected: String {
		return NSLocalizedString("product_post_gallery_multiple_pics_selected", bundle: bundle, comment: "")
	}

	public static var productPostGalleryPermissionsButton: String {
		return NSLocalizedString("product_post_gallery_permissions_button", bundle: bundle, comment: "")
	}

	public static var productPostGalleryPermissionsSubtitle: String {
		return NSLocalizedString("product_post_gallery_permissions_subtitle", bundle: bundle, comment: "")
	}

	public static var productPostGalleryPermissionsTitle: String {
		return NSLocalizedString("product_post_gallery_permissions_title", bundle: bundle, comment: "")
	}

	public static var productPostGallerySelectPicturesTitle: String {
		return NSLocalizedString("product_post_gallery_select_pictures_title", bundle: bundle, comment: "")
	}

	public static var productPostGallerySelectPicturesSubtitle: String {
		return NSLocalizedString("product_post_gallery_select_pictures_subtitle", bundle: bundle, comment: "")
	}

	public static func productPostGallerySelectPicturesSubtitleParams(_ var1: Int) -> String {
		return String(format: NSLocalizedString("product_post_gallery_select_pictures_subtitle_params", bundle: bundle, comment: ""), var1)
	}

	public static var productPostGalleryTab: String {
		return NSLocalizedString("product_post_gallery_tab", bundle: bundle, comment: "")
	}

	public static var productPostGenericError: String {
		return NSLocalizedString("product_post_generic_error", bundle: bundle, comment: "")
	}

	public static var productPostIncentiveBike: String {
		return NSLocalizedString("product_post_incentive_bike", bundle: bundle, comment: "")
	}

	public static var productPostIncentiveCar: String {
		return NSLocalizedString("product_post_incentive_car", bundle: bundle, comment: "")
	}

	public static var productPostIncentiveDresser: String {
		return NSLocalizedString("product_post_incentive_dresser", bundle: bundle, comment: "")
	}

	public static var productPostIncentiveFurniture: String {
		return NSLocalizedString("product_post_incentive_furniture", bundle: bundle, comment: "")
	}

	public static var productPostIncentiveGotAny: String {
		return NSLocalizedString("product_post_incentive_got_any", bundle: bundle, comment: "")
	}

	public static var productPostIncentiveGotAnyFree: String {
		return NSLocalizedString("product_post_incentive_got_any_free", bundle: bundle, comment: "")
	}

	public static var productPostIncentiveKidsClothes: String {
		return NSLocalizedString("product_post_incentive_kids_clothes", bundle: bundle, comment: "")
	}

	public static func productPostIncentiveLookingFor(_ var1: String) -> String {
		return String(format: NSLocalizedString("product_post_incentive_looking_for", bundle: bundle, comment: ""), var1)
	}

	public static var productPostIncentiveMotorcycle: String {
		return NSLocalizedString("product_post_incentive_motorcycle", bundle: bundle, comment: "")
	}

	public static var productPostIncentivePs4: String {
		return NSLocalizedString("product_post_incentive_ps4", bundle: bundle, comment: "")
	}

	public static var productPostIncentiveSubtitle: String {
		return NSLocalizedString("product_post_incentive_subtitle", bundle: bundle, comment: "")
	}

	public static var productPostIncentiveSubtitleFree: String {
		return NSLocalizedString("product_post_incentive_subtitle_free", bundle: bundle, comment: "")
	}

	public static var productPostIncentiveTitle: String {
		return NSLocalizedString("product_post_incentive_title", bundle: bundle, comment: "")
	}

	public static var productPostIncentiveToys: String {
		return NSLocalizedString("product_post_incentive_toys", bundle: bundle, comment: "")
	}

	public static var productPostIncentiveTv: String {
		return NSLocalizedString("product_post_incentive_tv", bundle: bundle, comment: "")
	}

	public static var productPostLoginMessage: String {
		return NSLocalizedString("product_post_login_message", bundle: bundle, comment: "")
	}

	public static var productPostDifferentCountryError: String {
		return NSLocalizedString("product_post_different_country_error", bundle: bundle, comment: "")
	}

	public static var productPostNetworkError: String {
		return NSLocalizedString("product_post_network_error", bundle: bundle, comment: "")
	}

	public static var productPostPriceLabel: String {
		return NSLocalizedString("product_post_price_label", bundle: bundle, comment: "")
	}

	public static var productPostProductPosted: String {
		return NSLocalizedString("product_post_product_posted", bundle: bundle, comment: "")
	}

	public static var productPostProductPostedNotLogged: String {
		return NSLocalizedString("product_post_product_posted_not_logged", bundle: bundle, comment: "")
	}

	public static var productPostRetake: String {
		return NSLocalizedString("product_post_retake", bundle: bundle, comment: "")
	}

	public static var productPostRetryButton: String {
		return NSLocalizedString("product_post_retry_button", bundle: bundle, comment: "")
	}

	public static var productPostUsePhoto: String {
		return NSLocalizedString("product_post_use_photo", bundle: bundle, comment: "")
	}

	public static var productPostUsePhotoNotLogged: String {
		return NSLocalizedString("product_post_use_photo_not_logged", bundle: bundle, comment: "")
	}

	public static var productPostSelectCategoryTitle: String {
		return NSLocalizedString("product_post_select_category_title", bundle: bundle, comment: "")
	}

	public static var productPostSelectCategoryCars: String {
		return NSLocalizedString("product_post_select_category_cars", bundle: bundle, comment: "")
	}

	public static var productPostSelectCategoryMotorsAndAccessories: String {
		return NSLocalizedString("product_post_select_category_motors_and_accessories", bundle: bundle, comment: "")
	}

	public static var productPostSelectCategoryOther: String {
		return NSLocalizedString("product_post_select_category_other", bundle: bundle, comment: "")
	}

	public static var productPostSelectCategoryHousing: String {
		return NSLocalizedString("product_post_select_category_housing", bundle: bundle, comment: "")
	}

	public static var productPostSelectCategoryRealEstate: String {
		return NSLocalizedString("product_post_select_category_real_estate", bundle: bundle, comment: "")
	}

	public static var productReportConfirmMessage: String {
		return NSLocalizedString("product_report_confirm_message", bundle: bundle, comment: "")
	}

	public static var productReportConfirmTitle: String {
		return NSLocalizedString("product_report_confirm_title", bundle: bundle, comment: "")
	}

	public static var productReportProductButton: String {
		return NSLocalizedString("product_report_product_button", bundle: bundle, comment: "")
	}

	public static var productReportedErrorGeneric: String {
		return NSLocalizedString("product_reported_error_generic", bundle: bundle, comment: "")
	}

	public static var productReportedSuccessMessage: String {
		return NSLocalizedString("product_reported_success_message", bundle: bundle, comment: "")
	}

	public static var productReportingLoadingMessage: String {
		return NSLocalizedString("product_reporting_loading_message", bundle: bundle, comment: "")
	}

	public static var productSearchNoProductsBody: String {
		return NSLocalizedString("product_search_no_products_body", bundle: bundle, comment: "")
	}

	public static var productSearchNoProductsTitle: String {
		return NSLocalizedString("product_search_no_products_title", bundle: bundle, comment: "")
	}

	public static var productSellAgainButton: String {
		return NSLocalizedString("product_sell_again_button", bundle: bundle, comment: "")
	}

	public static var productSellAgainConfirmCancelButton: String {
		return NSLocalizedString("product_sell_again_confirm_cancel_button", bundle: bundle, comment: "")
	}

	public static var productSellAgainConfirmMessage: String {
		return NSLocalizedString("product_sell_again_confirm_message", bundle: bundle, comment: "")
	}

	public static var productSellAgainConfirmOkButton: String {
		return NSLocalizedString("product_sell_again_confirm_ok_button", bundle: bundle, comment: "")
	}

	public static var productSellAgainConfirmTitle: String {
		return NSLocalizedString("product_sell_again_confirm_title", bundle: bundle, comment: "")
	}

	public static var productSellAgainErrorGeneric: String {
		return NSLocalizedString("product_sell_again_error_generic", bundle: bundle, comment: "")
	}

	public static var productSellAgainSuccessMessage: String {
		return NSLocalizedString("product_sell_again_success_message", bundle: bundle, comment: "")
	}

	public static var productSellCameraPermissionsError: String {
		return NSLocalizedString("product_sell_camera_permissions_error", bundle: bundle, comment: "")
	}

	public static var productSellCameraRestrictedError: String {
		return NSLocalizedString("product_sell_camera_restricted_error", bundle: bundle, comment: "")
	}

	public static var productSellPhotolibraryPermissionsError: String {
		return NSLocalizedString("product_sell_photolibrary_permissions_error", bundle: bundle, comment: "")
	}

	public static var productSellPhotolibraryRestrictedError: String {
		return NSLocalizedString("product_sell_photolibrary_restricted_error", bundle: bundle, comment: "")
	}

	public static var productShareFullscreenSubtitle: String {
		return NSLocalizedString("product_share_fullscreen_subtitle", bundle: bundle, comment: "")
	}

	public static var productShareNavbarButton: String {
		return NSLocalizedString("product_share_navbar_button", bundle: bundle, comment: "")
	}

	public static var productShareBody: String {
		return NSLocalizedString("product_share_body", bundle: bundle, comment: "")
	}

	public static var productIsMineShareBody: String {
		return NSLocalizedString("product_is_mine_share_body", bundle: bundle, comment: "")
	}

	public static var productIsMineShareBodyFree: String {
		return NSLocalizedString("product_is_mine_share_body_free", bundle: bundle, comment: "")
	}

	public static var productShareCopylinkOk: String {
		return NSLocalizedString("product_share_copylink_ok", bundle: bundle, comment: "")
	}

	public static var productShareEmailError: String {
		return NSLocalizedString("product_share_email_error", bundle: bundle, comment: "")
	}

	public static var productShareGenericOk: String {
		return NSLocalizedString("product_share_generic_ok", bundle: bundle, comment: "")
	}

	public static var productShareSmsError: String {
		return NSLocalizedString("product_share_sms_error", bundle: bundle, comment: "")
	}

	public static var productShareSmsOk: String {
		return NSLocalizedString("product_share_sms_ok", bundle: bundle, comment: "")
	}

	public static var productShareTitleLabel: String {
		return NSLocalizedString("product_share_title_label", bundle: bundle, comment: "")
	}

	public static func productSharePostedBy(_ var1: String) -> String {
		return String(format: NSLocalizedString("product_share_posted_by", bundle: bundle, comment: ""), var1)
	}

	public static func productShareTitleOnLetgo(_ var1: String) -> String {
		return String(format: NSLocalizedString("product_share_title_on_letgo", bundle: bundle, comment: ""), var1)
	}

	public static var productStickersSelectionWoName: String {
		return NSLocalizedString("product_stickers_selection_wo_name", bundle: bundle, comment: "")
	}

	public static var productFavoriteLoginPopupText: String {
		return NSLocalizedString("product_favorite_login_popup_text", bundle: bundle, comment: "")
	}

	public static var productReportLoginPopupText: String {
		return NSLocalizedString("product_report_login_popup_text", bundle: bundle, comment: "")
	}

	public static var professionalDealerAskPhoneIntroText: String {
		return NSLocalizedString("professional_dealer_ask_phone_intro_text", bundle: bundle, comment: "")
	}

	public static var professionalDealerAskPhoneNotNowButton: String {
		return NSLocalizedString("professional_dealer_ask_phone_not_now_button", bundle: bundle, comment: "")
	}

	public static var professionalDealerAskPhoneLetsTalkText: String {
		return NSLocalizedString("professional_dealer_ask_phone_lets_talk_text", bundle: bundle, comment: "")
	}

	public static var professionalDealerAskPhoneTextfieldPlaceholder: String {
		return NSLocalizedString("professional_dealer_ask_phone_textfield_placeholder", bundle: bundle, comment: "")
	}

	public static var professionalDealerAskPhoneSendPhoneButton: String {
		return NSLocalizedString("professional_dealer_ask_phone_send_phone_button", bundle: bundle, comment: "")
	}

	public static func professionalDealerAskPhoneChatMessage(_ var1: String) -> String {
		return String(format: NSLocalizedString("professional_dealer_ask_phone_chat_message", bundle: bundle, comment: ""), var1)
	}

	public static var professionalDealerAskPhoneAddPhoneCellMessage: String {
		return NSLocalizedString("professional_dealer_ask_phone_add_phone_cell_message", bundle: bundle, comment: "")
	}

	public static var professionalDealerAskPhoneAddPhoneCellButton: String {
		return NSLocalizedString("professional_dealer_ask_phone_add_phone_cell_button", bundle: bundle, comment: "")
	}

	public static var professionalDealerAskPhoneThanksPhoneCellMessage: String {
		return NSLocalizedString("professional_dealer_ask_phone_thanks_phone_cell_message", bundle: bundle, comment: "")
	}

	public static var professionalDealerAskPhoneThanksOtherCellMessage: String {
		return NSLocalizedString("professional_dealer_ask_phone_thanks_other_cell_message", bundle: bundle, comment: "")
	}

	public static var professionalDealerAskPhoneAlertEnterPhone: String {
		return NSLocalizedString("professional_dealer_ask_phone_alert_enter_phone", bundle: bundle, comment: "")
	}

	public static var professionalDealerAskPhoneAlertNotValidPhone: String {
		return NSLocalizedString("professional_dealer_ask_phone_alert_not_valid_phone", bundle: bundle, comment: "")
	}

	public static var profileBioAddButton: String {
		return NSLocalizedString("profile_bio_add_button", bundle: bundle, comment: "")
	}

	public static var profileBioShowMoreButton: String {
		return NSLocalizedString("profile_bio_show_more_button", bundle: bundle, comment: "")
	}

	public static var profileBlockedByMeLabel: String {
		return NSLocalizedString("profile_blocked_by_me_label", bundle: bundle, comment: "")
	}

	public static func profileBlockedByMeLabelWName(_ var1: String) -> String {
		return String(format: NSLocalizedString("profile_blocked_by_me_label_w_name", bundle: bundle, comment: ""), var1)
	}

	public static var profileBlockedByOtherLabel: String {
		return NSLocalizedString("profile_blocked_by_other_label", bundle: bundle, comment: "")
	}

	public static var profileFavouritesMyUserNoProductsButton: String {
		return NSLocalizedString("profile_favourites_my_user_no_products_button", bundle: bundle, comment: "")
	}

	public static var profileFavouritesMyUserNoProductsLabel: String {
		return NSLocalizedString("profile_favourites_my_user_no_products_label", bundle: bundle, comment: "")
	}

	public static var profileFavouritesProductsTab: String {
		return NSLocalizedString("profile_favourites_products_tab", bundle: bundle, comment: "")
	}

	public static var profilePermissionsAlertCancel: String {
		return NSLocalizedString("profile_permissions_alert_cancel", bundle: bundle, comment: "")
	}

	public static var profilePermissionsAlertMessage: String {
		return NSLocalizedString("profile_permissions_alert_message", bundle: bundle, comment: "")
	}

	public static var profilePermissionsAlertOk: String {
		return NSLocalizedString("profile_permissions_alert_ok", bundle: bundle, comment: "")
	}

	public static var profilePermissionsAlertTitle: String {
		return NSLocalizedString("profile_permissions_alert_title", bundle: bundle, comment: "")
	}

	public static var profilePermissionsHeaderMessage: String {
		return NSLocalizedString("profile_permissions_header_message", bundle: bundle, comment: "")
	}

	public static var profileReviewsTab: String {
		return NSLocalizedString("profile_reviews_tab", bundle: bundle, comment: "")
	}

	public static var profileReviewsCount: String {
		return NSLocalizedString("profile_reviews_count", bundle: bundle, comment: "")
	}

	public static var profileSellingNoProductsLabel: String {
		return NSLocalizedString("profile_selling_no_products_label", bundle: bundle, comment: "")
	}

	public static var profileSellingOtherUserNoProductsButton: String {
		return NSLocalizedString("profile_selling_other_user_no_products_button", bundle: bundle, comment: "")
	}

	public static var profileSellingProductsTab: String {
		return NSLocalizedString("profile_selling_products_tab", bundle: bundle, comment: "")
	}

	public static var profileSoldNoProductsLabel: String {
		return NSLocalizedString("profile_sold_no_products_label", bundle: bundle, comment: "")
	}

	public static var profileSoldOtherNoProductsButton: String {
		return NSLocalizedString("profile_sold_other_no_products_button", bundle: bundle, comment: "")
	}

	public static var profileSoldProductsTab: String {
		return NSLocalizedString("profile_sold_products_tab", bundle: bundle, comment: "")
	}

	public static var profileVerifiedAccountsOtherUser: String {
		return NSLocalizedString("profile_verified_accounts_other_user", bundle: bundle, comment: "")
	}

	public static var profileVerifiedAccountsTitle: String {
		return NSLocalizedString("profile_verified_accounts_title", bundle: bundle, comment: "")
	}

	public static var profileVerifyEmailButton: String {
		return NSLocalizedString("profile_verify_email_button", bundle: bundle, comment: "")
	}

	public static func profileVerifyEmailMessagePresent(_ var1: String) -> String {
		return String(format: NSLocalizedString("profile_verify_email_message_present", bundle: bundle, comment: ""), var1)
	}

	public static var profileVerifyEmailSuccess: String {
		return NSLocalizedString("profile_verify_email_success", bundle: bundle, comment: "")
	}

	public static var profileVerifyEmailTooManyRequests: String {
		return NSLocalizedString("profile_verify_email_too_many_requests", bundle: bundle, comment: "")
	}

	public static var profileVerifyFacebookButton: String {
		return NSLocalizedString("profile_verify_facebook_button", bundle: bundle, comment: "")
	}

	public static var profileVerifyFacebookTitle: String {
		return NSLocalizedString("profile_verify_facebook_title", bundle: bundle, comment: "")
	}

	public static var profileVerifyGoogleButton: String {
		return NSLocalizedString("profile_verify_google_button", bundle: bundle, comment: "")
	}

	public static var profileVerifyGoogleTitle: String {
		return NSLocalizedString("profile_verify_google_title", bundle: bundle, comment: "")
	}

	public static var profileBuildTrustButton: String {
		return NSLocalizedString("profile_build_trust_button", bundle: bundle, comment: "")
	}

	public static var profileConnectAccountsMessage: String {
		return NSLocalizedString("profile_connect_accounts_message", bundle: bundle, comment: "")
	}

	public static func profileDummyUserInfo(_ var1: String) -> String {
		return String(format: NSLocalizedString("profile_dummy_user_info", bundle: bundle, comment: ""), var1)
	}

	public static var promoteBumpTitle: String {
		return NSLocalizedString("promote_bump_title", bundle: bundle, comment: "")
	}

	public static var promoteBumpSellFasterButton: String {
		return NSLocalizedString("promote_bump_sell_faster_button", bundle: bundle, comment: "")
	}

	public static var promoteBumpLaterButton: String {
		return NSLocalizedString("promote_bump_later_button", bundle: bundle, comment: "")
	}

	public static var quickFilterLocationTitle: String {
		return NSLocalizedString("quick_filter_location_title", bundle: bundle, comment: "")
	}

	public static var rateBuyersMessage: String {
		return NSLocalizedString("rate_buyers_message", bundle: bundle, comment: "")
	}

	public static var rateBuyersSubMessage: String {
		return NSLocalizedString("rate_buyers_sub_message", bundle: bundle, comment: "")
	}

	public static var rateBuyersWillDoLaterTitle: String {
		return NSLocalizedString("rate_buyers_will_do_later_title", bundle: bundle, comment: "")
	}

	public static var rateBuyersWillDoLaterSubtitle: String {
		return NSLocalizedString("rate_buyers_will_do_later_subtitle", bundle: bundle, comment: "")
	}

	public static var rateBuyersNotOnLetgoTitleButton: String {
		return NSLocalizedString("rate_buyers_not_on_letgo_title_button", bundle: bundle, comment: "")
	}

	public static var rateBuyersSeeXMore: String {
		return NSLocalizedString("rate_buyers_see_x_more", bundle: bundle, comment: "")
	}

	public static var rateBuyersSeeLess: String {
		return NSLocalizedString("rate_buyers_see_less", bundle: bundle, comment: "")
	}

	public static var rateBuyersNotOnLetgoButton: String {
		return NSLocalizedString("rate_buyers_not_on_letgo_button", bundle: bundle, comment: "")
	}

	public static var rateUserNegativeNotPolite: String {
		return NSLocalizedString("rate_user_negative_not_polite", bundle: bundle, comment: "")
	}

	public static var rateUserNegativeDidntShowUp: String {
		return NSLocalizedString("rate_user_negative_didnt_show_up", bundle: bundle, comment: "")
	}

	public static var rateUserNegativeSlowResponses: String {
		return NSLocalizedString("rate_user_negative_slow_responses", bundle: bundle, comment: "")
	}

	public static var rateUserNegativeUnfairPrice: String {
		return NSLocalizedString("rate_user_negative_unfair_price", bundle: bundle, comment: "")
	}

	public static var rateUserNegativeNotTrustworthy: String {
		return NSLocalizedString("rate_user_negative_not_trustworthy", bundle: bundle, comment: "")
	}

	public static var rateUserNegativeItemNotAsAdvertised: String {
		return NSLocalizedString("rate_user_negative_item_not_as_advertised", bundle: bundle, comment: "")
	}

	public static var rateUserPositivePolite: String {
		return NSLocalizedString("rate_user_positive_polite", bundle: bundle, comment: "")
	}

	public static var rateUserPositiveShowedUpOnTime: String {
		return NSLocalizedString("rate_user_positive_showed_up_on_time", bundle: bundle, comment: "")
	}

	public static var rateUserPositiveQuickResponses: String {
		return NSLocalizedString("rate_user_positive_quick_responses", bundle: bundle, comment: "")
	}

	public static var rateUserPositiveFairPrices: String {
		return NSLocalizedString("rate_user_positive_fair_prices", bundle: bundle, comment: "")
	}

	public static var rateUserPositiveHelpful: String {
		return NSLocalizedString("rate_user_positive_helpful", bundle: bundle, comment: "")
	}

	public static var rateUserPositiveTrustworthy: String {
		return NSLocalizedString("rate_user_positive_trustworthy", bundle: bundle, comment: "")
	}

	public static var ratingAppEnjoyingAlertTitle: String {
		return NSLocalizedString("rating_app_enjoying_alert_title", bundle: bundle, comment: "")
	}

	public static var ratingAppRateAlertTitle: String {
		return NSLocalizedString("rating_app_rate_alert_title", bundle: bundle, comment: "")
	}

	public static var ratingAppRateAlertYesButton: String {
		return NSLocalizedString("rating_app_rate_alert_yes_button", bundle: bundle, comment: "")
	}

	public static var ratingAppRateAlertNoButton: String {
		return NSLocalizedString("rating_app_rate_alert_no_button", bundle: bundle, comment: "")
	}

	public static var ratingAppFeedbackTitle: String {
		return NSLocalizedString("rating_app_feedback_title", bundle: bundle, comment: "")
	}

	public static var ratingAppFeedbackYesButton: String {
		return NSLocalizedString("rating_app_feedback_yes_button", bundle: bundle, comment: "")
	}

	public static var ratingAppFeedbackNoButton: String {
		return NSLocalizedString("rating_app_feedback_no_button", bundle: bundle, comment: "")
	}

	public static var ratingListActionReportReview: String {
		return NSLocalizedString("rating_list_action_report_review", bundle: bundle, comment: "")
	}

	public static var ratingListActionReportReviewErrorMessage: String {
		return NSLocalizedString("rating_list_action_report_review_error_message", bundle: bundle, comment: "")
	}

	public static var ratingListActionReportReviewSuccessMessage: String {
		return NSLocalizedString("rating_list_action_report_review_success_message", bundle: bundle, comment: "")
	}

	public static var ratingListActionReviewUser: String {
		return NSLocalizedString("rating_list_action_review_user", bundle: bundle, comment: "")
	}

	public static var ratingListLoadingErrorMessage: String {
		return NSLocalizedString("rating_list_loading_error_message", bundle: bundle, comment: "")
	}

	public static func ratingListRatingTypeBuyerTextLabel(_ var1: String) -> String {
		return String(format: NSLocalizedString("rating_list_rating_type_buyer_text_label", bundle: bundle, comment: ""), var1)
	}

	public static func ratingListRatingTypeConversationTextLabel(_ var1: String) -> String {
		return String(format: NSLocalizedString("rating_list_rating_type_conversation_text_label", bundle: bundle, comment: ""), var1)
	}

	public static func ratingListRatingTypeSellerTextLabel(_ var1: String) -> String {
		return String(format: NSLocalizedString("rating_list_rating_type_seller_text_label", bundle: bundle, comment: ""), var1)
	}

	public static var ratingListRatingStatusPending: String {
		return NSLocalizedString("rating_list_rating_status_pending", bundle: bundle, comment: "")
	}

	public static var ratingListTitle: String {
		return NSLocalizedString("rating_list_title", bundle: bundle, comment: "")
	}

	public static var ratingViewRateUsLabel: String {
		return NSLocalizedString("rating_view_rate_us_label", bundle: bundle, comment: "")
	}

	public static var ratingViewRemindLaterButton: String {
		return NSLocalizedString("rating_view_remind_later_button", bundle: bundle, comment: "")
	}

	public static var ratingViewTitleLabelUppercase: String {
		return NSLocalizedString("rating_view_title_label_uppercase", bundle: bundle, comment: "")
	}

	public static var realEstateLocationTitle: String {
		return NSLocalizedString("real_estate_location_title", bundle: bundle, comment: "")
	}

	public static var realEstateLocationNotificationMessage: String {
		return NSLocalizedString("real_estate_location_notification_message", bundle: bundle, comment: "")
	}

	public static var realEstateSummaryTitle: String {
		return NSLocalizedString("real_estate_summary_title", bundle: bundle, comment: "")
	}

	public static var realEstatePriceTitle: String {
		return NSLocalizedString("real_estate_price_title", bundle: bundle, comment: "")
	}

	public static var realEstateOfferTypeTitle: String {
		return NSLocalizedString("real_estate_offer_type_title", bundle: bundle, comment: "")
	}

	public static var realEstateOfferTypeRent: String {
		return NSLocalizedString("real_estate_offer_type_rent", bundle: bundle, comment: "")
	}

	public static var realEstateOfferTypeSale: String {
		return NSLocalizedString("real_estate_offer_type_sale", bundle: bundle, comment: "")
	}

	public static var postingButtonSkip: String {
		return NSLocalizedString("posting_button_skip", bundle: bundle, comment: "")
	}

	public static var realEstateTypePropertyTitle: String {
		return NSLocalizedString("real_estate_type_property_title", bundle: bundle, comment: "")
	}

	public static var realEstateTypePropertyApartment: String {
		return NSLocalizedString("real_estate_type_property_apartment", bundle: bundle, comment: "")
	}

	public static var realEstateTypePropertyHouse: String {
		return NSLocalizedString("real_estate_type_property_house", bundle: bundle, comment: "")
	}

	public static var realEstateTypePropertyRoom: String {
		return NSLocalizedString("real_estate_type_property_room", bundle: bundle, comment: "")
	}

	public static var realEstateTypePropertyCommercial: String {
		return NSLocalizedString("real_estate_type_property_commercial", bundle: bundle, comment: "")
	}

	public static var realEstateTypePropertyBusiness: String {
		return NSLocalizedString("real_estate_type_property_business", bundle: bundle, comment: "")
	}

	public static var realEstateTypePropertyOthers: String {
		return NSLocalizedString("real_estate_type_property_others", bundle: bundle, comment: "")
	}

	public static var realEstateTypePropertyFlat: String {
		return NSLocalizedString("real_estate_type_property_flat", bundle: bundle, comment: "")
	}

	public static var realEstateTypePropertyLand: String {
		return NSLocalizedString("real_estate_type_property_land", bundle: bundle, comment: "")
	}

	public static var realEstateTypePropertyVilla: String {
		return NSLocalizedString("real_estate_type_property_villa", bundle: bundle, comment: "")
	}

	public static var realEstateBathroomsTitle: String {
		return NSLocalizedString("real_estate_bathrooms_title", bundle: bundle, comment: "")
	}

	public static var realEstateBathrooms0: String {
		return NSLocalizedString("real_estate_bathrooms_0", bundle: bundle, comment: "")
	}

	public static var realEstateBathrooms1: String {
		return NSLocalizedString("real_estate_bathrooms_1", bundle: bundle, comment: "")
	}

	public static var realEstateBathrooms15: String {
		return NSLocalizedString("real_estate_bathrooms_1_5", bundle: bundle, comment: "")
	}

	public static var realEstateBathrooms2: String {
		return NSLocalizedString("real_estate_bathrooms_2", bundle: bundle, comment: "")
	}

	public static var realEstateBathrooms25: String {
		return NSLocalizedString("real_estate_bathrooms_2_5", bundle: bundle, comment: "")
	}

	public static var realEstateBathrooms3: String {
		return NSLocalizedString("real_estate_bathrooms_3", bundle: bundle, comment: "")
	}

	public static var realEstateBathrooms35: String {
		return NSLocalizedString("real_estate_bathrooms_3_5", bundle: bundle, comment: "")
	}

	public static var realEstateBathrooms4: String {
		return NSLocalizedString("real_estate_bathrooms_4", bundle: bundle, comment: "")
	}

	public static var realEstateSummaryBathroomTitle: String {
		return NSLocalizedString("real_estate_summary_bathroom_title", bundle: bundle, comment: "")
	}

	public static var realEstateSummaryBathroomsTitle: String {
		return NSLocalizedString("real_estate_summary_bathrooms_title", bundle: bundle, comment: "")
	}

	public static var realEstateBedroomsTitle: String {
		return NSLocalizedString("real_estate_bedrooms_title", bundle: bundle, comment: "")
	}

	public static var realEstateBedrooms0: String {
		return NSLocalizedString("real_estate_bedrooms_0", bundle: bundle, comment: "")
	}

	public static var realEstateBedrooms1: String {
		return NSLocalizedString("real_estate_bedrooms_1", bundle: bundle, comment: "")
	}

	public static var realEstateBedrooms2: String {
		return NSLocalizedString("real_estate_bedrooms_2", bundle: bundle, comment: "")
	}

	public static var realEstateBedrooms3: String {
		return NSLocalizedString("real_estate_bedrooms_3", bundle: bundle, comment: "")
	}

	public static var realEstateBedrooms4: String {
		return NSLocalizedString("real_estate_bedrooms_4", bundle: bundle, comment: "")
	}

	public static var realEstateRoomsTitle: String {
		return NSLocalizedString("real_estate_rooms_title", bundle: bundle, comment: "")
	}

	public static var realEstateRoomsStudio: String {
		return NSLocalizedString("real_estate_rooms_studio", bundle: bundle, comment: "")
	}

	public static var realEstateRoomsOverTen: String {
		return NSLocalizedString("real_estate_rooms_over_ten", bundle: bundle, comment: "")
	}

	public static func realEstateRoomsValue(_ var1: Int, _ var2: Int) -> String {
		return String(format: NSLocalizedString("real_estate_rooms_value", bundle: bundle, comment: ""), var1, var2)
	}

	public static var realEstateSizeSquareMetersTitle: String {
		return NSLocalizedString("real_estate_size_square_meters_title", bundle: bundle, comment: "")
	}

	public static var realEstateSizeSquareMetersPlaceholder: String {
		return NSLocalizedString("real_estate_size_square_meters_placeholder", bundle: bundle, comment: "")
	}

	public static var realEstateSummaryBedroomTitle: String {
		return NSLocalizedString("real_estate_summary_bedroom_title", bundle: bundle, comment: "")
	}

	public static var realEstateSummaryBedroomsTitle: String {
		return NSLocalizedString("real_estate_summary_bedrooms_title", bundle: bundle, comment: "")
	}

	public static var realEstateSummaryRoomsTitle: String {
		return NSLocalizedString("real_estate_summary_rooms_title", bundle: bundle, comment: "")
	}

	public static var realEstateSummaryRoomsEmpty: String {
		return NSLocalizedString("real_estate_summary_rooms_empty", bundle: bundle, comment: "")
	}

	public static var realEstateSummarySizeTitle: String {
		return NSLocalizedString("real_estate_summary_size_title", bundle: bundle, comment: "")
	}

	public static var realEstateSummarySizeEmpty: String {
		return NSLocalizedString("real_estate_summary_size_empty", bundle: bundle, comment: "")
	}

	public static var realEstateSummaryPriceEmpty: String {
		return NSLocalizedString("real_estate_summary_price_empty", bundle: bundle, comment: "")
	}

	public static var realEstateSummaryTypePropertyEmpty: String {
		return NSLocalizedString("real_estate_summary_type_property_empty", bundle: bundle, comment: "")
	}

	public static var realEstateSummaryOfferTypeEmpty: String {
		return NSLocalizedString("real_estate_summary_offer_type_empty", bundle: bundle, comment: "")
	}

	public static var realEstateSummaryBedroomsEmtpy: String {
		return NSLocalizedString("real_estate_summary_bedrooms_emtpy", bundle: bundle, comment: "")
	}

	public static var realEstateSummaryBathroomsEmpty: String {
		return NSLocalizedString("real_estate_summary_bathrooms_empty", bundle: bundle, comment: "")
	}

	public static func realEstateSummaryPriceTitle(_ var1: String) -> String {
		return String(format: NSLocalizedString("real_estate_summary_price_title", bundle: bundle, comment: ""), var1)
	}

	public static var realEstateSummaryLocationEmpty: String {
		return NSLocalizedString("real_estate_summary_location_empty", bundle: bundle, comment: "")
	}

	public static var realEstateTitleGeneratorPropertyTypeApartment: String {
		return NSLocalizedString("real_estate_title_generator_property_type_apartment", bundle: bundle, comment: "")
	}

	public static var realEstateTitleGeneratorPropertyTypeRoom: String {
		return NSLocalizedString("real_estate_title_generator_property_type_room", bundle: bundle, comment: "")
	}

	public static var realEstateTitleGeneratorPropertyTypeHouse: String {
		return NSLocalizedString("real_estate_title_generator_property_type_house", bundle: bundle, comment: "")
	}

	public static var realEstateTitleGeneratorPropertyTypeOther: String {
		return NSLocalizedString("real_estate_title_generator_property_type_other", bundle: bundle, comment: "")
	}

	public static var realEstateTitleGeneratorPropertyTypeCommercial: String {
		return NSLocalizedString("real_estate_title_generator_property_type_commercial", bundle: bundle, comment: "")
	}

	public static var realEstateTitleGeneratorOfferTypeSale: String {
		return NSLocalizedString("real_estate_title_generator_offer_type_sale", bundle: bundle, comment: "")
	}

	public static var realEstateTitleGeneratorOfferTypeRent: String {
		return NSLocalizedString("real_estate_title_generator_offer_type_rent", bundle: bundle, comment: "")
	}

	public static var realEstateTitleGeneratorBedroomsStudio: String {
		return NSLocalizedString("real_estate_title_generator_bedrooms_studio", bundle: bundle, comment: "")
	}

	public static var realEstateTitleGeneratorBedroomsOne: String {
		return NSLocalizedString("real_estate_title_generator_bedrooms_one", bundle: bundle, comment: "")
	}

	public static var realEstateTitleGeneratorBedroomsTwo: String {
		return NSLocalizedString("real_estate_title_generator_bedrooms_two", bundle: bundle, comment: "")
	}

	public static var realEstateTitleGeneratorBedroomsThree: String {
		return NSLocalizedString("real_estate_title_generator_bedrooms_three", bundle: bundle, comment: "")
	}

	public static var realEstateTitleGeneratorBedroomsFour: String {
		return NSLocalizedString("real_estate_title_generator_bedrooms_four", bundle: bundle, comment: "")
	}

	public static var realEstateTitleGeneratorBathrooms0: String {
		return NSLocalizedString("real_estate_title_generator_bathrooms_0", bundle: bundle, comment: "")
	}

	public static var realEstateTitleGeneratorBathrooms1: String {
		return NSLocalizedString("real_estate_title_generator_bathrooms_1", bundle: bundle, comment: "")
	}

	public static var realEstateTitleGeneratorBathrooms15: String {
		return NSLocalizedString("real_estate_title_generator_bathrooms_1_5", bundle: bundle, comment: "")
	}

	public static var realEstateTitleGeneratorBathrooms2: String {
		return NSLocalizedString("real_estate_title_generator_bathrooms_2", bundle: bundle, comment: "")
	}

	public static var realEstateTitleGeneratorBathrooms25: String {
		return NSLocalizedString("real_estate_title_generator_bathrooms_2_5", bundle: bundle, comment: "")
	}

	public static var realEstateTitleGeneratorBathrooms3: String {
		return NSLocalizedString("real_estate_title_generator_bathrooms_3", bundle: bundle, comment: "")
	}

	public static var realEstateTitleGeneratorBathrooms35: String {
		return NSLocalizedString("real_estate_title_generator_bathrooms_3_5", bundle: bundle, comment: "")
	}

	public static var realEstateTitleGeneratorBathrooms4: String {
		return NSLocalizedString("real_estate_title_generator_bathrooms_4", bundle: bundle, comment: "")
	}

	public static var realEstateAttributeTagBathroom0: String {
		return NSLocalizedString("real_estate_attribute_tag_bathroom_0", bundle: bundle, comment: "")
	}

	public static func realEstateCurrentStepOfTotal(_ var1: Int, _ var2: Int) -> String {
		return String(format: NSLocalizedString("real_estate_current_step_of_total", bundle: bundle, comment: ""), var1, var2)
	}

	public static var realEstateRelatedSearchTitle: String {
		return NSLocalizedString("real_estate_related_search_title", bundle: bundle, comment: "")
	}

	public static var realEstateTooltipSellButton: String {
		return NSLocalizedString("real_estate_tooltip_sell_button", bundle: bundle, comment: "")
	}

	public static var realEstateTooltipSellButtonTitle: String {
		return NSLocalizedString("real_estate_tooltip_sell_button_title", bundle: bundle, comment: "")
	}

	public static var realEstateTooltipOverlayExpandableMenu: String {
		return NSLocalizedString("real_estate_tooltip_overlay_expandable_menu", bundle: bundle, comment: "")
	}

	public static var realEstateGalleryViewSubtitle: String {
		return NSLocalizedString("real_estate_gallery_view_subtitle", bundle: bundle, comment: "")
	}

	public static func realEstateGalleryViewSubtitleParams(_ var1: Int) -> String {
		return String(format: NSLocalizedString("real_estate_gallery_view_subtitle_params", bundle: bundle, comment: ""), var1)
	}

	public static var realEstateCameraViewRealEstateMessage: String {
		return NSLocalizedString("real_estate_camera_view_real_estate_message", bundle: bundle, comment: "")
	}

	public static var realEstateEmptyStateSearchTitle: String {
		return NSLocalizedString("real_estate_empty_state_search_title", bundle: bundle, comment: "")
	}

	public static var realEstateEmptyStateSearchSubtitle: String {
		return NSLocalizedString("real_estate_empty_state_search_subtitle", bundle: bundle, comment: "")
	}

	public static var realEstateTutorialNew: String {
		return NSLocalizedString("real_estate_tutorial_new", bundle: bundle, comment: "")
	}

	public static var realEstateTutorialOnePageFirstSectionTitle: String {
		return NSLocalizedString("real_estate_tutorial_one_page_first_section_title", bundle: bundle, comment: "")
	}

	public static var realEstateTutorialOnePageSecondSectionTitle: String {
		return NSLocalizedString("real_estate_tutorial_one_page_second_section_title", bundle: bundle, comment: "")
	}

	public static var realEstateTutorialTwoPagesFirstSectionFirstPageTitle: String {
		return NSLocalizedString("real_estate_tutorial_two_pages_first_section_first_page_title", bundle: bundle, comment: "")
	}

	public static var realEstateTutorialTwoPagesFirstSectionSecondPageTitle: String {
		return NSLocalizedString("real_estate_tutorial_two_pages_first_section_second_page_title", bundle: bundle, comment: "")
	}

	public static var realEstateTutorialThreePagesFirstPageTitle: String {
		return NSLocalizedString("real_estate_tutorial_three_pages_first_page_title", bundle: bundle, comment: "")
	}

	public static var realEstateTutorialThreePagesFirstPageDescription: String {
		return NSLocalizedString("real_estate_tutorial_three_pages_first_page_description", bundle: bundle, comment: "")
	}

	public static var realEstateTutorialThreePagesSecondPageTitle: String {
		return NSLocalizedString("real_estate_tutorial_three_pages_second_page_title", bundle: bundle, comment: "")
	}

	public static var realEstateTutorialThreePagesSecondPageDecription: String {
		return NSLocalizedString("real_estate_tutorial_three_pages_second_page_decription", bundle: bundle, comment: "")
	}

	public static var realEstateTutorialThreePagesThirdPageTitle: String {
		return NSLocalizedString("real_estate_tutorial_three_pages_third_page_title", bundle: bundle, comment: "")
	}

	public static var realEstateTutorialThreePagesThirdPageDescription: String {
		return NSLocalizedString("real_estate_tutorial_three_pages_third_page_description", bundle: bundle, comment: "")
	}

	public static var relatedItemsTitle: String {
		return NSLocalizedString("related_items_title", bundle: bundle, comment: "")
	}

	public static var reportUserCounterfeit: String {
		return NSLocalizedString("report_user_counterfeit", bundle: bundle, comment: "")
	}

	public static var reportUserErrorAlreadyReported: String {
		return NSLocalizedString("report_user_error_already_reported", bundle: bundle, comment: "")
	}

	public static var reportUserInactive: String {
		return NSLocalizedString("report_user_inactive", bundle: bundle, comment: "")
	}

	public static var reportUserMia: String {
		return NSLocalizedString("report_user_mia", bundle: bundle, comment: "")
	}

	public static var reportUserOffensive: String {
		return NSLocalizedString("report_user_offensive", bundle: bundle, comment: "")
	}

	public static var reportUserOthers: String {
		return NSLocalizedString("report_user_others", bundle: bundle, comment: "")
	}

	public static var reportUserProhibitedItems: String {
		return NSLocalizedString("report_user_prohibited_items", bundle: bundle, comment: "")
	}

	public static var reportUserScammer: String {
		return NSLocalizedString("report_user_scammer", bundle: bundle, comment: "")
	}

	public static var reportUserSendButton: String {
		return NSLocalizedString("report_user_send_button", bundle: bundle, comment: "")
	}

	public static var reportUserSendFailure: String {
		return NSLocalizedString("report_user_send_failure", bundle: bundle, comment: "")
	}

	public static var reportUserSendOk: String {
		return NSLocalizedString("report_user_send_ok", bundle: bundle, comment: "")
	}

	public static var reportUserSpammer: String {
		return NSLocalizedString("report_user_spammer", bundle: bundle, comment: "")
	}

	public static var reportUserSuspcious: String {
		return NSLocalizedString("report_user_suspcious", bundle: bundle, comment: "")
	}

	public static var reportUserTextPlaceholder: String {
		return NSLocalizedString("report_user_text_placeholder", bundle: bundle, comment: "")
	}

	public static var reportUserTitle: String {
		return NSLocalizedString("report_user_title", bundle: bundle, comment: "")
	}

	public static var resetPasswordEmailFieldHint: String {
		return NSLocalizedString("reset_password_email_field_hint", bundle: bundle, comment: "")
	}

	public static var resetPasswordInstructions: String {
		return NSLocalizedString("reset_password_instructions", bundle: bundle, comment: "")
	}

	public static var resetPasswordSendButton: String {
		return NSLocalizedString("reset_password_send_button", bundle: bundle, comment: "")
	}

	public static var resetPasswordSendErrorGeneric: String {
		return NSLocalizedString("reset_password_send_error_generic", bundle: bundle, comment: "")
	}

	public static var resetPasswordSendErrorInvalidEmail: String {
		return NSLocalizedString("reset_password_send_error_invalid_email", bundle: bundle, comment: "")
	}

	public static func resetPasswordSendErrorUserNotFoundOrWrongPassword(_ var1: String) -> String {
		return String(format: NSLocalizedString("reset_password_send_error_user_not_found_or_wrong_password", bundle: bundle, comment: ""), var1)
	}

	public static func resetPasswordSendOk(_ var1: String) -> String {
		return String(format: NSLocalizedString("reset_password_send_ok", bundle: bundle, comment: ""), var1)
	}

	public static var resetPasswordSendTooManyRequests: String {
		return NSLocalizedString("reset_password_send_too_many_requests", bundle: bundle, comment: "")
	}

	public static var resetPasswordTitle: String {
		return NSLocalizedString("reset_password_title", bundle: bundle, comment: "")
	}

	public static var sellCategorySelectionLabel: String {
		return NSLocalizedString("sell_category_selection_label", bundle: bundle, comment: "")
	}

	public static var sellChooseCategoryDialogCancelButton: String {
		return NSLocalizedString("sell_choose_category_dialog_cancel_button", bundle: bundle, comment: "")
	}

	public static var sellChooseCategoryDialogTitle: String {
		return NSLocalizedString("sell_choose_category_dialog_title", bundle: bundle, comment: "")
	}

	public static var sellDescriptionFieldHint: String {
		return NSLocalizedString("sell_description_field_hint", bundle: bundle, comment: "")
	}

	public static var sellPictureImageSourceCameraButton: String {
		return NSLocalizedString("sell_picture_image_source_camera_button", bundle: bundle, comment: "")
	}

	public static var sellPictureImageSourceCameraRollButton: String {
		return NSLocalizedString("sell_picture_image_source_camera_roll_button", bundle: bundle, comment: "")
	}

	public static var sellPictureImageSourceCancelButton: String {
		return NSLocalizedString("sell_picture_image_source_cancel_button", bundle: bundle, comment: "")
	}

	public static var sellPictureImageSourceTitle: String {
		return NSLocalizedString("sell_picture_image_source_title", bundle: bundle, comment: "")
	}

	public static var sellPictureLabel: String {
		return NSLocalizedString("sell_picture_label", bundle: bundle, comment: "")
	}

	public static var sellPictureSaveIntoCameraRollErrorGeneric: String {
		return NSLocalizedString("sell_picture_save_into_camera_roll_error_generic", bundle: bundle, comment: "")
	}

	public static var sellPictureSaveIntoCameraRollLoading: String {
		return NSLocalizedString("sell_picture_save_into_camera_roll_loading", bundle: bundle, comment: "")
	}

	public static var sellPictureSaveIntoCameraRollOk: String {
		return NSLocalizedString("sell_picture_save_into_camera_roll_ok", bundle: bundle, comment: "")
	}

	public static var sellPictureSelectedCancelButton: String {
		return NSLocalizedString("sell_picture_selected_cancel_button", bundle: bundle, comment: "")
	}

	public static var sellPictureSelectedDeleteButton: String {
		return NSLocalizedString("sell_picture_selected_delete_button", bundle: bundle, comment: "")
	}

	public static var sellPictureSelectedSaveIntoCameraRollButton: String {
		return NSLocalizedString("sell_picture_selected_save_into_camera_roll_button", bundle: bundle, comment: "")
	}

	public static var sellPictureSelectedTitle: String {
		return NSLocalizedString("sell_picture_selected_title", bundle: bundle, comment: "")
	}

	public static var sellPostFreeLabel: String {
		return NSLocalizedString("sell_post_free_label", bundle: bundle, comment: "")
	}

	public static var sellSendErrorInvalidCategory: String {
		return NSLocalizedString("sell_send_error_invalid_category", bundle: bundle, comment: "")
	}

	public static var sellSendErrorInvalidDescription: String {
		return NSLocalizedString("sell_send_error_invalid_description", bundle: bundle, comment: "")
	}

	public static func sellSendErrorInvalidDescriptionTooLong(_ var1: Int) -> String {
		return String(format: NSLocalizedString("sell_send_error_invalid_description_too_long", bundle: bundle, comment: ""), var1)
	}

	public static var sellSendErrorInvalidImageCount: String {
		return NSLocalizedString("sell_send_error_invalid_image_count", bundle: bundle, comment: "")
	}

	public static var sellSendErrorInvalidPrice: String {
		return NSLocalizedString("sell_send_error_invalid_price", bundle: bundle, comment: "")
	}

	public static var sellSendErrorInvalidTitle: String {
		return NSLocalizedString("sell_send_error_invalid_title", bundle: bundle, comment: "")
	}

	public static var sellSendErrorSharingFacebook: String {
		return NSLocalizedString("sell_send_error_sharing_facebook", bundle: bundle, comment: "")
	}

	public static var sellShareOnFacebookLabel: String {
		return NSLocalizedString("sell_share_on_facebook_label", bundle: bundle, comment: "")
	}

	public static var sellTitleAutogenAutotransLabel: String {
		return NSLocalizedString("sell_title_autogen_autotrans_label", bundle: bundle, comment: "")
	}

	public static var sellTitleAutogenLabel: String {
		return NSLocalizedString("sell_title_autogen_label", bundle: bundle, comment: "")
	}

	public static var sellTitleFieldHint: String {
		return NSLocalizedString("sell_title_field_hint", bundle: bundle, comment: "")
	}

	public static var sellUploadingLabel: String {
		return NSLocalizedString("sell_uploading_label", bundle: bundle, comment: "")
	}

	public static var settingsChangeLocationButton: String {
		return NSLocalizedString("settings_change_location_button", bundle: bundle, comment: "")
	}

	public static var settingsChangePasswordButton: String {
		return NSLocalizedString("settings_change_password_button", bundle: bundle, comment: "")
	}

	public static var settingsChangeProfilePictureButton: String {
		return NSLocalizedString("settings_change_profile_picture_button", bundle: bundle, comment: "")
	}

	public static var settingsChangeProfilePictureErrorGeneric: String {
		return NSLocalizedString("settings_change_profile_picture_error_generic", bundle: bundle, comment: "")
	}

	public static var settingsChangeProfilePictureLoading: String {
		return NSLocalizedString("settings_change_profile_picture_loading", bundle: bundle, comment: "")
	}

	public static var settingsChangeUsernameButton: String {
		return NSLocalizedString("settings_change_username_button", bundle: bundle, comment: "")
	}

	public static var settingsChangeEmailButton: String {
		return NSLocalizedString("settings_change_email_button", bundle: bundle, comment: "")
	}

	public static var settingsChangeUserBioButton: String {
		return NSLocalizedString("settings_change_user_bio_button", bundle: bundle, comment: "")
	}

	public static var settingsHelpButton: String {
		return NSLocalizedString("settings_help_button", bundle: bundle, comment: "")
	}

	public static var settingsInviteFacebookFriendsButton: String {
		return NSLocalizedString("settings_invite_facebook_friends_button", bundle: bundle, comment: "")
	}

	public static var settingsInviteFacebookFriendsError: String {
		return NSLocalizedString("settings_invite_facebook_friends_error", bundle: bundle, comment: "")
	}

	public static var settingsInviteFacebookFriendsOk: String {
		return NSLocalizedString("settings_invite_facebook_friends_ok", bundle: bundle, comment: "")
	}

	public static var settingsLogoutButton: String {
		return NSLocalizedString("settings_logout_button", bundle: bundle, comment: "")
	}

	public static var settingsLogoutAlertMessage: String {
		return NSLocalizedString("settings_logout_alert_message", bundle: bundle, comment: "")
	}

	public static var settingsLogoutAlertOk: String {
		return NSLocalizedString("settings_logout_alert_ok", bundle: bundle, comment: "")
	}

	public static var settingsTitle: String {
		return NSLocalizedString("settings_title", bundle: bundle, comment: "")
	}

	public static var settingsSectionProfile: String {
		return NSLocalizedString("settings_section_profile", bundle: bundle, comment: "")
	}

	public static var settingsSectionPromote: String {
		return NSLocalizedString("settings_section_promote", bundle: bundle, comment: "")
	}

	public static var settingsSectionSupport: String {
		return NSLocalizedString("settings_section_support", bundle: bundle, comment: "")
	}

	public static var settingsMarketingNotificationsSwitch: String {
		return NSLocalizedString("settings_marketing_notifications_switch", bundle: bundle, comment: "")
	}

	public static var settingsMarketingNotificationsAlertMessage: String {
		return NSLocalizedString("settings_marketing_notifications_alert_message", bundle: bundle, comment: "")
	}

	public static var settingsGeneralNotificationsAlertMessage: String {
		return NSLocalizedString("settings_general_notifications_alert_message", bundle: bundle, comment: "")
	}

	public static var settingsMarketingNotificationsAlertActivate: String {
		return NSLocalizedString("settings_marketing_notifications_alert_activate", bundle: bundle, comment: "")
	}

	public static var settingsMarketingNotificationsAlertDeactivate: String {
		return NSLocalizedString("settings_marketing_notifications_alert_deactivate", bundle: bundle, comment: "")
	}

	public static var settingsMarketingNotificationsAlertCancel: String {
		return NSLocalizedString("settings_marketing_notifications_alert_cancel", bundle: bundle, comment: "")
	}

	public static var signUpAcceptanceError: String {
		return NSLocalizedString("sign_up_acceptance_error", bundle: bundle, comment: "")
	}

	public static var signUpEmailFieldHint: String {
		return NSLocalizedString("sign_up_email_field_hint", bundle: bundle, comment: "")
	}

	public static var signUpNewsleter: String {
		return NSLocalizedString("sign_up_newsleter", bundle: bundle, comment: "")
	}

	public static var signUpPasswordFieldHint: String {
		return NSLocalizedString("sign_up_password_field_hint", bundle: bundle, comment: "")
	}

	public static var signUpSendButton: String {
		return NSLocalizedString("sign_up_send_button", bundle: bundle, comment: "")
	}

	public static func signUpSendErrorEmailTaken(_ var1: String) -> String {
		return String(format: NSLocalizedString("sign_up_send_error_email_taken", bundle: bundle, comment: ""), var1)
	}

	public static var signUpSendErrorGeneric: String {
		return NSLocalizedString("sign_up_send_error_generic", bundle: bundle, comment: "")
	}

	public static var signUpSendErrorInvalidDomain: String {
		return NSLocalizedString("sign_up_send_error_invalid_domain", bundle: bundle, comment: "")
	}

	public static var signUpSendErrorInvalidEmail: String {
		return NSLocalizedString("sign_up_send_error_invalid_email", bundle: bundle, comment: "")
	}

	public static func signUpSendErrorInvalidPasswordWithMax(_ var1: Int, _ var2: Int) -> String {
		return String(format: NSLocalizedString("sign_up_send_error_invalid_password_with_max", bundle: bundle, comment: ""), var1, var2)
	}

	public static func signUpSendErrorInvalidUsername(_ var1: Int) -> String {
		return String(format: NSLocalizedString("sign_up_send_error_invalid_username", bundle: bundle, comment: ""), var1)
	}

	public static var signUpTermsConditions: String {
		return NSLocalizedString("sign_up_terms_conditions", bundle: bundle, comment: "")
	}

	public static var signUpTermsConditionsPrivacyPart: String {
		return NSLocalizedString("sign_up_terms_conditions_privacy_part", bundle: bundle, comment: "")
	}

	public static var signUpTermsConditionsTermsPart: String {
		return NSLocalizedString("sign_up_terms_conditions_terms_part", bundle: bundle, comment: "")
	}

	public static var signUpTitle: String {
		return NSLocalizedString("sign_up_title", bundle: bundle, comment: "")
	}

	public static var signUpUsernameFieldHint: String {
		return NSLocalizedString("sign_up_username_field_hint", bundle: bundle, comment: "")
	}

	public static var suggestionsCategory: String {
		return NSLocalizedString("suggestions_category", bundle: bundle, comment: "")
	}

	public static var suggestionsLastSearchesTitle: String {
		return NSLocalizedString("suggestions_last_searches_title", bundle: bundle, comment: "")
	}

	public static var suggestionsLastSearchesClearButton: String {
		return NSLocalizedString("suggestions_last_searches_clear_button", bundle: bundle, comment: "")
	}

	public static var tabBarToolTip: String {
		return NSLocalizedString("tab_bar_tool_tip", bundle: bundle, comment: "")
	}

	public static var tabBarGiveAwayButton: String {
		return NSLocalizedString("tab_bar_give_away_button", bundle: bundle, comment: "")
	}

	public static var tabBarIncentiviseScrollBanner: String {
		return NSLocalizedString("tab_bar_incentivise_scroll_banner", bundle: bundle, comment: "")
	}

	public static var toastErrorInternal: String {
		return NSLocalizedString("toast_error_internal", bundle: bundle, comment: "")
	}

	public static var toastNoNetwork: String {
		return NSLocalizedString("toast_no_network", bundle: bundle, comment: "")
	}

	public static var tourClaimLabel: String {
		return NSLocalizedString("tour_claim_label", bundle: bundle, comment: "")
	}

	public static var tourEmailButton: String {
		return NSLocalizedString("tour_email_button", bundle: bundle, comment: "")
	}

	public static var tourContinueWEmail: String {
		return NSLocalizedString("tour_continue_w_email", bundle: bundle, comment: "")
	}

	public static var tourFacebookButton: String {
		return NSLocalizedString("tour_facebook_button", bundle: bundle, comment: "")
	}

	public static var tourGoogleButton: String {
		return NSLocalizedString("tour_google_button", bundle: bundle, comment: "")
	}

	public static var tourOrLabel: String {
		return NSLocalizedString("tour_or_label", bundle: bundle, comment: "")
	}

	public static var tutorialSkipButtonTitle: String {
		return NSLocalizedString("tutorial_skip_button_title", bundle: bundle, comment: "")
	}

	public static var tutorialAcceptButtonTitle: String {
		return NSLocalizedString("tutorial_accept_button_title", bundle: bundle, comment: "")
	}

	public static var trendingSearchesTitle: String {
		return NSLocalizedString("trending_searches_Title", bundle: bundle, comment: "")
	}

	public static var suggestedSearchesTitle: String {
		return NSLocalizedString("suggested_searches_title", bundle: bundle, comment: "")
	}

	public static var unblockUserErrorGeneric: String {
		return NSLocalizedString("unblock_user_error_generic", bundle: bundle, comment: "")
	}

	public static var userShareTitleTextMine: String {
		return NSLocalizedString("user_share_title_text_mine", bundle: bundle, comment: "")
	}

	public static var userShareTitleTextOther: String {
		return NSLocalizedString("user_share_title_text_other", bundle: bundle, comment: "")
	}

	public static func userShareTitleTextOtherWName(_ var1: String) -> String {
		return String(format: NSLocalizedString("user_share_title_text_other_w_name", bundle: bundle, comment: ""), var1)
	}

	public static var userShareMessageMine: String {
		return NSLocalizedString("user_share_message_mine", bundle: bundle, comment: "")
	}

	public static var userShareMessageOther: String {
		return NSLocalizedString("user_share_message_other", bundle: bundle, comment: "")
	}

	public static func userShareMessageOtherWName(_ var1: String) -> String {
		return String(format: NSLocalizedString("user_share_message_other_w_name", bundle: bundle, comment: ""), var1)
	}

	public static var userShareError: String {
		return NSLocalizedString("user_share_error", bundle: bundle, comment: "")
	}

	public static func userRatingMessageWName(_ var1: String) -> String {
		return String(format: NSLocalizedString("user_rating_message_w_name", bundle: bundle, comment: ""), var1)
	}

	public static var userRatingMessageWoName: String {
		return NSLocalizedString("user_rating_message_wo_name", bundle: bundle, comment: "")
	}

	public static var userRatingSelectATag: String {
		return NSLocalizedString("user_rating_select_a_tag", bundle: bundle, comment: "")
	}

	public static var userRatingReviewButton: String {
		return NSLocalizedString("user_rating_review_button", bundle: bundle, comment: "")
	}

	public static var userRatingAddCommentButton: String {
		return NSLocalizedString("user_rating_add_comment_button", bundle: bundle, comment: "")
	}

	public static var userRatingUpdateCommentButton: String {
		return NSLocalizedString("user_rating_update_comment_button", bundle: bundle, comment: "")
	}

	public static var userRatingSkipButton: String {
		return NSLocalizedString("user_rating_skip_button", bundle: bundle, comment: "")
	}

	public static var userRatingReviewInfo: String {
		return NSLocalizedString("user_rating_review_info", bundle: bundle, comment: "")
	}

	public static var userRatingReviewPlaceholderMandatory: String {
		return NSLocalizedString("user_rating_review_placeholder_mandatory", bundle: bundle, comment: "")
	}

	public static var userRatingReviewPlaceholderOptional: String {
		return NSLocalizedString("user_rating_review_placeholder_optional", bundle: bundle, comment: "")
	}

	public static var userRatingReviewSendSuccess: String {
		return NSLocalizedString("user_rating_review_send_success", bundle: bundle, comment: "")
	}

	public static var userRatingTitle: String {
		return NSLocalizedString("user_rating_title", bundle: bundle, comment: "")
	}

	public static var trendingItemsHeaderBubble: String {
		return NSLocalizedString("trending_items_header_bubble", bundle: bundle, comment: "")
	}

	public static func trendingItemsViewTitle(_ var1: String) -> String {
		return String(format: NSLocalizedString("trending_items_view_title", bundle: bundle, comment: ""), var1)
	}

	public static var trendingItemsViewTitleNoLocation: String {
		return NSLocalizedString("trending_items_view_title_no_location", bundle: bundle, comment: "")
	}

	public static var trendingItemsViewSubtitle: String {
		return NSLocalizedString("trending_items_view_subtitle", bundle: bundle, comment: "")
	}

	public static var trendingItemsViewNumberOfSearchesTitle: String {
		return NSLocalizedString("trending_items_view_number_of_searches_title", bundle: bundle, comment: "")
	}

	public static func trendingItemsViewNumberOfSearchesItem(_ var1: String) -> String {
		return String(format: NSLocalizedString("trending_items_view_number_of_searches_item", bundle: bundle, comment: ""), var1)
	}

	public static var trendingItemsViewPostButton: String {
		return NSLocalizedString("trending_items_view_post_button", bundle: bundle, comment: "")
	}

	public static var trendingItemsViewSearchButton: String {
		return NSLocalizedString("trending_items_view_search_button", bundle: bundle, comment: "")
	}

	public static var trendingItemsCardTitle: String {
		return NSLocalizedString("trending_items_card_title", bundle: bundle, comment: "")
	}

	public static var trendingItemsCardAction: String {
		return NSLocalizedString("trending_items_card_action", bundle: bundle, comment: "")
	}

	public static var trendingItemsProfileTitle: String {
		return NSLocalizedString("trending_items_profile_title", bundle: bundle, comment: "")
	}

	public static var trendingItemsProfileSubtitle: String {
		return NSLocalizedString("trending_items_profile_subtitle", bundle: bundle, comment: "")
	}

	public static var trendingItemsExpandableMenuButton: String {
		return NSLocalizedString("trending_items_expandable_menu_button", bundle: bundle, comment: "")
	}

	public static var trendingItemIphone: String {
		return NSLocalizedString("trending_item_iPhone", bundle: bundle, comment: "")
	}

	public static var trendingItemAtv: String {
		return NSLocalizedString("trending_item_atv", bundle: bundle, comment: "")
	}

	public static var trendingItemSmartphone: String {
		return NSLocalizedString("trending_item_smartphone", bundle: bundle, comment: "")
	}

	public static var trendingItemSedan: String {
		return NSLocalizedString("trending_item_sedan", bundle: bundle, comment: "")
	}

	public static var trendingItemScooter: String {
		return NSLocalizedString("trending_item_scooter", bundle: bundle, comment: "")
	}

	public static var trendingItemComputer: String {
		return NSLocalizedString("trending_item_computer", bundle: bundle, comment: "")
	}

	public static var trendingItemCoupe: String {
		return NSLocalizedString("trending_item_coupe", bundle: bundle, comment: "")
	}

	public static var trendingItemTablet: String {
		return NSLocalizedString("trending_item_tablet", bundle: bundle, comment: "")
	}

	public static var trendingItemMotorcycle: String {
		return NSLocalizedString("trending_item_motorcycle", bundle: bundle, comment: "")
	}

	public static var trendingItemTruck: String {
		return NSLocalizedString("trending_item_truck", bundle: bundle, comment: "")
	}

	public static var trendingItemGadget: String {
		return NSLocalizedString("trending_item_gadget", bundle: bundle, comment: "")
	}

	public static var trendingItemTrailer: String {
		return NSLocalizedString("trending_item_trailer", bundle: bundle, comment: "")
	}

	public static var trendingItemController: String {
		return NSLocalizedString("trending_item_controller", bundle: bundle, comment: "")
	}

	public static var trendingItemDresser: String {
		return NSLocalizedString("trending_item_dresser", bundle: bundle, comment: "")
	}

	public static var trendingItemSubwoofer: String {
		return NSLocalizedString("trending_item_subwoofer", bundle: bundle, comment: "")
	}

	public static var trendingItemsExpandableMenuSubsetTitle: String {
		return NSLocalizedString("trending_items_expandable_menu_subset_title", bundle: bundle, comment: "")
	}
}
