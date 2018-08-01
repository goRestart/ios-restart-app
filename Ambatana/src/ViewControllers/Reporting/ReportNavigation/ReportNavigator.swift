import Foundation

protocol ReportNavigator: class {
    func openNextStep(with options: ReportOptionsGroup, from: ReportOptionType)
    func openReportSentScreen(type: ReportSentType)
    func closeReporting()
}
