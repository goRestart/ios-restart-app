import Foundation
import LGComponents

struct ReportOption {
    let type: ReportOptionType
    let childOptions: ReportOptionsGroup?

    init(type: ReportOptionType, childOptions: ReportOptionsGroup? = nil) {
        self.type = type
        self.childOptions = childOptions
    }
}

struct ReportOptionsGroup {
    var title: String
    var options: [ReportOption]
}

final class ReportOptionsBuilder {

    // MARK: - Report User Options

    static func reportProductOptions() -> ReportOptionsGroup {
        return reportProductOptionsStep1()
    }

    // MARK: Step 1

    private static func reportProductOptionsStep1() -> ReportOptionsGroup {
        return ReportOptionsGroup(
            title: R.Strings.reportingListingListHeader,
            options: [
                ReportOption(type: .itShouldntBeOnLetgo, childOptions: reportProductOptionsStep2()),
                ReportOption(type: .iThinkItsAScam),
                ReportOption(type: .iTsADuplicateListing),
                ReportOption(type: .itsInTheWrongCategory)
            ]
        )
    }

    // MARK: Step 2

    private static func reportProductOptionsStep2() -> ReportOptionsGroup {
        return ReportOptionsGroup(
            title: R.Strings.reportingListingShouldntBeOnLetgoHeader,
            options: [
                ReportOption(type: .sexualContent),
                ReportOption(type: .drugsAlcoholOrTobacco),
                ReportOption(type: .weaponsOrViolentContent),
                ReportOption(type: .otherReasonItShouldntBeOnLetgo)]
        )
    }

    // MARK: - Report Product Options

    static func reportUserOptions() -> ReportOptionsGroup {
        return reportUserOptionsStep1()
    }

    // MARK: Step 1

    private static func reportUserOptionsStep1() -> ReportOptionsGroup {
        return ReportOptionsGroup(
            title: R.Strings.reportingUserListHeader,
            options: [
                ReportOption(type: .sellingSomethingInappropriate),
                ReportOption(type: .suspiciousBehaviour, childOptions: reportUserOptionsStep2A()),
                ReportOption(type: .inappropriateProfilePhotoOrBio, childOptions: reportUserOptionsStep2B()),
                ReportOption(type: .problemDuringMeetup, childOptions: reportUserOptionsStep2C()),
                ReportOption(type: .inappropriateChatMessages, childOptions: reportUserOptionsStep2D()),
                ReportOption(type: .unrealisticPriceOrOffers)]
        )
    }

    // MARK: Step 2A

    private static func reportUserOptionsStep2A() -> ReportOptionsGroup {
        return ReportOptionsGroup(
            title: R.Strings.reportingUserSuspiciousBehaviorHeader,
            options: [
                ReportOption(type: .notRespondingToMessages),
                ReportOption(type: .offeringToTradeInsteadOfPayingInCash),
                ReportOption(type: .offeringRoPayWithWesternUnionOrPaypal),
                ReportOption(type: .spamAccount),
                ReportOption(type: .otherSuspiciousBehaviour)]
        )
    }

    // MARK: Step 2B

    private static func reportUserOptionsStep2B() -> ReportOptionsGroup {
        return ReportOptionsGroup(
            title: R.Strings.reportingUserInappropriatePhotoOrBioHeader,
            options: [
                ReportOption(type: .inappropriateProfilePhoto),
                ReportOption(type: .inappropriateBio)]
        )
    }

    // MARK: Step 2C

    private static func reportUserOptionsStep2C() -> ReportOptionsGroup {
        return ReportOptionsGroup(
            title: R.Strings.reportingUserProblemMeetupHeader,
            options: [
                ReportOption(type: .robberyOrViolentIncident),
                ReportOption(type: .paidWithCounterfeitMoney),
                ReportOption(type: .didntShowUp),
                ReportOption(type: .itemDefectiveOrNotAsDescribed),
                ReportOption(type: .otherProblemDuringMeetup)]
        )
    }

    // MARK: Step 2D

    private static func reportUserOptionsStep2D() -> ReportOptionsGroup {
        return ReportOptionsGroup(
            title: R.Strings.reportingUserInappropriateChatHeader,
            options: [
                ReportOption(type: .threateningViolence),
                ReportOption(type: .rudeOrOffensiveLanguage),
                ReportOption(type: .suspiciousOrScammyBehavior),
                ReportOption(type: .sexualOrObsceneLanguage),
                ReportOption(type: .otherReasonInnappropriateChatMessages)]
        )
    }

}
