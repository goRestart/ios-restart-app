import Foundation
import LGComponents

enum ReportSentType {

    private static let lawEnforcementEmail = "lawenforcement@letgo.com"

    case productBasic
    case userBasic
    case userBlockA
    case userBlockB
    case userBlockAndReviewA
    case userBlockAndReviewB
    case userLawEnforcement
    case userLawEnforcementBlock

    var allowsBlockUser: Bool {
        switch self {
            case .userBlockA, .userBlockB, .userBlockAndReviewA,
                 .userBlockAndReviewB, .userLawEnforcementBlock:
            return true
        default:
            return false
        }
    }

    var title: String {
        switch self {
        case .productBasic: return R.Strings.reportingListingReportSentTitle
        case .userBasic, .userBlockA, .userBlockB, .userBlockAndReviewA,
             .userBlockAndReviewB, .userLawEnforcement, .userLawEnforcementBlock:
            return R.Strings.reportingUserReportSentTitle
        }
    }

    func attributedMessage(userName: String) -> NSAttributedString {
        let messageString = message(userName: userName)
        let string = NSMutableAttributedString(string: messageString,
                                               attributes: [.foregroundColor: UIColor.lgBlack,
                                                            .font: UIFont.bigBodyFont])

        let emailRange = (messageString as NSString).range(of: ReportSentType.lawEnforcementEmail)
        string.addAttributes([.foregroundColor: UIColor.primaryColor], range: emailRange)

        let userRange = (messageString as NSString).range(of: userName)
        string.addAttributes([.font: UIFont.reportSentUserNameText], range: userRange)

        return string
    }

    private func message(userName: String) -> String {
        switch self {
        case .productBasic:
            return R.Strings.reportingListingReportSentText
        case .userBasic:
            return R.Strings.reportingUserReportSentRedirectItemText
        case .userBlockA:
            return R.Strings.reportingUserReportSentBlockUserAText
        case .userBlockB:
            return R.Strings.reportingUserReportSentBlockUserBText
        case .userBlockAndReviewA:
            return R.Strings.reportingUserReportSentBlockUserAWithReviewText
        case .userBlockAndReviewB:
            return R.Strings.reportingUserReportSentBlockUserBWithReviewText
        case .userLawEnforcement:
            return R.Strings.reportingUserReportSentLawEnforcementText(userName)
        case .userLawEnforcementBlock:
            return R.Strings.reportingUserReportSentLawEnforcementAndBlockText(userName)
        }
    }
}
