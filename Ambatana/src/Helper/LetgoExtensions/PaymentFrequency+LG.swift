
import LGCoreKit
import LGComponents

extension PaymentFrequency {
    
    static var allCases: [PaymentFrequency] {
        return [.hourly, .daily, .weekly, .biweekly, .monthly, .yearly, .oneOff]
    }
    
    var localizedDisplayName: String {
        switch self {
        case .hourly:
            return R.Strings.priceTypeHourly
        case .daily:
            return R.Strings.priceTypeDaily
        case .biweekly:
            return R.Strings.priceTypeBiweekly
        case .weekly:
            return R.Strings.priceTypeWeekly
        case .monthly:
            return R.Strings.priceTypeMonthly
        case .yearly:
            return R.Strings.priceTypeYearly
        case .oneOff:
            return R.Strings.priceTypeOneOff
        }
    }
    
    var perValueDisplayName: String? {
        switch self {
        case .hourly:
            return "/"+R.Strings.paymentFrequencyPerHour
        case .daily:
            return "/"+R.Strings.paymentFrequencyPerDay
        case .biweekly:
            return "/"+R.Strings.paymentFrequencyPerBiweek
        case .weekly:
            return "/"+R.Strings.paymentFrequencyPerWeek
        case .monthly:
            return "/"+R.Strings.paymentFrequencyPerMonth
        case .yearly:
            return "/"+R.Strings.paymentFrequencyPerYear
        case .oneOff:
            return nil
        }
    }
}
