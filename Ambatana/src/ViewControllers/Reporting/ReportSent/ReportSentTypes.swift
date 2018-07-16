import Foundation
import LGComponents

enum ReportSentType {

    private static let lawEnforcementEmail = "lawenforcement@letgo.com"

    case productBasic
    case userBasic
    case userBlockA
    case userBlockB
    case userLawEnforcement
    case userLawEnforcementBlock

    var allowsBlockUser: Bool {
        switch self {
            case .userBlockA, .userBlockB, .userLawEnforcementBlock:
            return true
        default:
            return false
        }
    }

    var title: String {
        switch self {
        case .productBasic: return R.Strings.reportingListingReportSentTitle
        case .userBasic, .userBlockA, .userBlockB, .userLawEnforcement, .userLawEnforcementBlock:
            return R.Strings.reportingUserReportSentTitle
        }
    }

    func attributedMessage(includingReviewText: Bool, userName: String) -> NSAttributedString {
        let messageString = message(includingReviewText: includingReviewText, userName: userName)
        let string = NSMutableAttributedString(string: messageString,
                                               attributes: [.foregroundColor: UIColor.lgBlack,
                                                            .font: UIFont.bigBodyFont])

        let emailRange = (messageString as NSString).range(of: ReportSentType.lawEnforcementEmail)
        string.addAttributes([.foregroundColor: UIColor.primaryColor], range: emailRange)

        let userRange = (messageString as NSString).range(of: userName)
        string.addAttributes([.font: UIFont.reportSentUserNameText], range: userRange)

        return string
    }

    private func message(includingReviewText: Bool, userName: String) -> String {
        switch self {
        case .productBasic:
            return R.Strings.reportingListingReportSentText
        case .userBasic:
            return R.Strings.reportingUserReportSentRedirectItemText
        case .userBlockA:
            return includingReviewText ?
                R.Strings.reportingUserReportSentBlockUserAWithReviewText : R.Strings.reportingUserReportSentBlockUserAText
        case .userBlockB:
            return includingReviewText ?
                R.Strings.reportingUserReportSentBlockUserBWithReviewText : R.Strings.reportingUserReportSentBlockUserBText
        case .userLawEnforcement:
            return R.Strings.reportingUserReportSentLawEnforcementText(userName)
        case .userLawEnforcementBlock:
            return R.Strings.reportingUserReportSentLawEnforcementAndBlockText(userName)
        }
    }
}
