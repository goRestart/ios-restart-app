import Foundation

protocol ReportNavigator: class {
    func openNextStep(with options: ReportOptionsGroup)
    func openReportSentScreen(type: ReportSentType)
    func closeReporting()
}
