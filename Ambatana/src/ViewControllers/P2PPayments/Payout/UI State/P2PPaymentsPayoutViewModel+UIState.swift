import Foundation
import LGCoreKit
import LGComponents

// MARK: - PayoutInfo

extension P2PPaymentsPayoutViewModel {
    struct PayoutInfo {
        let feeText: String
        let standardFundsAvailableText: String
        let instantFundsAvailableText: String
    }
}

// MARK: - UI State

extension P2PPaymentsPayoutViewModel {
    enum UIState {
        case loading
        case errorRetry
        case register
        case payout(info: PayoutInfo)
    }
}

// MARK: - UIState + Outputs

extension P2PPaymentsPayoutViewModel.UIState {
    private static let percentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.multiplier = 1
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    var showLoadingIndicator: Bool {
        switch self {
        case .loading: return true
        default: return false
        }
    }

    var errorRetryIsHidden: Bool {
        switch self {
        case .errorRetry: return false
        case .loading, .register, .payout: return true
        }
    }

    var registerIsHidden: Bool {
        switch self {
        case .register: return false
        default: return true
        }
    }

    var payoutIsHidden: Bool {
        switch self {
        case .payout: return false
        default: return true
        }
    }

    var payoutInfo: P2PPaymentsPayoutViewModel.PayoutInfo? {
        guard case let .payout(info: info) = self else { return nil }
        return info
    }

    var feeText: String? {
        guard let payoutInfo = payoutInfo else { return nil }
        return payoutInfo.feeText
    }

    var standardFundsAvailableText: String? {
        guard let payoutInfo = payoutInfo else { return nil }
        return payoutInfo.standardFundsAvailableText
    }

    var instantFundsAvailableText: String? {
        guard let payoutInfo = payoutInfo else { return nil }
        return payoutInfo.instantFundsAvailableText
    }
}

// MARK: - UIState + Creation

extension P2PPaymentsPayoutViewModel.UIState {
    static func createPayout(priceBreakdown: P2PPaymentPayoutPriceBreakdown, fundsAvailableDate: Date) -> P2PPaymentsPayoutViewModel.UIState {
        let daysOffset = calculateFundsAvailableOffsetDays(fundsAvailableDate: fundsAvailableDate)
        let feeText = getFeeText(priceBreakdown: priceBreakdown)
        let standardFundsAvailableText = getStandardFundsAvailableText(daysOffset: daysOffset)
        let instantFundsAvailableText = getInstantFundsAvailableText(daysOffset: daysOffset)
        let payoutInfo = P2PPaymentsPayoutViewModel.PayoutInfo(feeText: feeText,
                                                               standardFundsAvailableText: standardFundsAvailableText,
                                                               instantFundsAvailableText: instantFundsAvailableText)
        return .payout(info: payoutInfo)
    }

    private static let currencyHelper = Core.currencyHelper
    private enum Constants {
        static let secondsInADay: Double = 3600 * 24
        static let minDays: Int = 3
        static let maxDays: Int = 7
    }

    private static func calculateFundsAvailableOffsetDays(fundsAvailableDate: Date) -> Int {
        guard fundsAvailableDate.timeIntervalSinceNow > 0 else { return 0 }
        let daysOffset = Int(fundsAvailableDate.timeIntervalSinceNow / Constants.secondsInADay)
        return daysOffset
    }

    private static func getFeeText(priceBreakdown: P2PPaymentPayoutPriceBreakdown) -> String {
        let fee = (priceBreakdown.fee as NSDecimalNumber).doubleValue
        let percentageText = percentageFormatter.string(from: NSNumber(value: priceBreakdown.feePercentage))
        let feeAmountText = currencyHelper.formattedAmountWithCurrencyCode(priceBreakdown.currency.code,
                                                                           amount: fee)
        return R.Strings.paymentPayoutPaymentInstantTitleLabel + " (\(percentageText ?? "")) — \(feeAmountText)"
    }

    private static func getStandardFundsAvailableText(daysOffset: Int) -> String {
        guard daysOffset > 0 else { return "3-7 days" }
        let minDays = Constants.minDays + daysOffset
        let maxDays = Constants.maxDays + daysOffset
        return "\(minDays)-\(maxDays) days"
    }

    private static func getInstantFundsAvailableText(daysOffset: Int) -> String {
        guard daysOffset > 0 else { return "under 1 hour" }
        if daysOffset > 1 {
            return "\(daysOffset) days"
        } else {
            return "1 day"
        }
    }
}
