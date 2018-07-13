
struct FormattedUnitRange {
    let minimumValue: Int
    let maximumValue: Int
    let unitSuffix: String
    let numberFormatter: NumberFormatter
    let isUnboundedUpperValue: Bool
    
    func toString() -> String? {
        guard let formattedMin = numberFormatter.string(from: NSNumber(value: minimumValue)),
            let formattedMax = numberFormatter.string(from: NSNumber(value: maximumValue)) else {
                return nil
        }
        let upperValuePostfix = FormattedUnitRange.upperValuePostfixString(shouldAppendPostfixString: isUnboundedUpperValue)
        return "\(formattedMin) - \(formattedMax)" + "\(upperValuePostfix)" + " \(unitSuffix)"
    }
    
    static func upperValuePostfixString(shouldAppendPostfixString: Bool) -> String {
        return shouldAppendPostfixString ? "+" : ""
    }
}
