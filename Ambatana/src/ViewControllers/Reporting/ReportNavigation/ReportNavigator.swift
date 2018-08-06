import Foundation
import LGCoreKit

protocol ReportNavigator: class {
    func openNextStep(with options: ReportOptionsGroup, from: ReportOptionType)
    func openReportSentScreen(type: ReportSentType)
    func openReviewUser(userId: String, userAvatar: File?, userName: String?)
    func closeReporting()
}
