
struct FormattedUnitRange {
    let minimumValue: Int
    let maximumValue: Int
    let unitSuffix: String
    let numberFormatter: NumberFormatter
    
    func toString() -> String? {
        guard let formattedMin = numberFormatter.string(from: NSNumber(value: minimumValue)),
            let formattedMax = numberFormatter.string(from: NSNumber(value: maximumValue)) else {
                return nil
        }
        
        return "\(formattedMin) - \(formattedMax) \(unitSuffix)"
    }
}
