import LGComponents

//  MARK: - ClickToTalk

extension ClickToTalk {
    var plans: [SmokeTestSubscriptionPlan]? {
        switch self {
        case .baseline, .control:
            return nil
        case .variantA:
            return plans(monthPrice: 4.99, yearPrice: 49.99)
         case .variantB:
            return plans(monthPrice: 9.99, yearPrice: 99.99)
            case .variantC:
                return plans(monthPrice: 14.99, yearPrice: 149.99)
        }
    }
    
    private func plans(monthPrice: Double, yearPrice: Double) -> [SmokeTestSubscriptionPlan] {
        let monthTitle = "$\(monthPrice) / " + R.Strings.paymentFrequencyPerMonth.capitalizedFirstLetterOnly
        let yearTitle = "$\(yearPrice) / " + R.Strings.paymentFrequencyPerYear.capitalizedFirstLetterOnly + " (\(R.Strings.clickToTalkSmoketestTwoMonthsFree))"
        let subtitle = R.Strings.clickToTalkSmoketestSevenDaysFree
        return [SmokeTestSubscriptionPlan(title: monthTitle, subtitle: subtitle, isRecomended: false, variant: rawValue),
                SmokeTestSubscriptionPlan(title: yearTitle, subtitle: subtitle, isRecomended: true, variant: rawValue)]
    }
}
