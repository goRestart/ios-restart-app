
extension NumberFormatter {
    
    static func newMileageNumberFormatter() -> NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale.autoupdatingCurrent
        numberFormatter.usesGroupingSeparator = true
        
        return numberFormatter
    }
    
    static func formattedMileage(forValue value: Int?,
                                 distanceUnit: String?) -> String? {
        let numberFormatter = newMileageNumberFormatter()
        
        guard let value = value,
            let distanceUnit = distanceUnit,
            let formattedValue = numberFormatter.string(from: NSNumber(value: value)) else {
            return nil
        }
        
        return "\(formattedValue) \(distanceUnit)"
    }
}
