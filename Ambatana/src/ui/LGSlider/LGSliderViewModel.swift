
import UIKit

final class LGSliderViewModel {
    
    let title: String
    
    private let minimumValueNotSelectedText: String
    private let maximumValueNotSelectedText: String
    private let minimumAndMaximumValuesNotSelectedText: String
    
    private let minimumValue: Int
    private let maximumValue: Int
    
    var minimumValueSelected: Int
    var maximumValueSelected: Int
    
    private var unitSuffix: String?
    private var numberFormatter: NumberFormatter?
    
    convenience init(title: String,
                     minimumValueNotSelectedText: String,
                     maximumValueNotSelectedText: String,
                     minimumAndMaximumValuesNotSelectedText: String,
                     minimumValue: Int,
                     maximumValue: Int,
                     minimumValueSelected: Int?,
                     maximumValueSelected: Int?) {
        self.init(title: title,
                  minimumValueNotSelectedText: minimumValueNotSelectedText,
                  maximumValueNotSelectedText: maximumValueNotSelectedText,
                  minimumAndMaximumValuesNotSelectedText: minimumAndMaximumValuesNotSelectedText,
                  minimumValue: minimumValue,
                  maximumValue: maximumValue,
                  minimumValueSelected: minimumValueSelected,
                  maximumValueSelected: maximumValueSelected,
                  unitSuffix: nil,
                  numberFormatter: nil)
    }
    
    init(title: String,
         minimumValueNotSelectedText: String,
         maximumValueNotSelectedText: String,
         minimumAndMaximumValuesNotSelectedText: String,
         minimumValue: Int,
         maximumValue: Int,
         minimumValueSelected: Int?,
         maximumValueSelected: Int?,
         unitSuffix: String?,
         numberFormatter: NumberFormatter?) {
        
        self.title = title
        self.minimumValueNotSelectedText = minimumValueNotSelectedText
        self.maximumValueNotSelectedText = maximumValueNotSelectedText
        self.minimumAndMaximumValuesNotSelectedText = minimumAndMaximumValuesNotSelectedText
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        
        self.minimumValueSelected = minimumValueSelected ?? minimumValue
        self.maximumValueSelected = maximumValueSelected ?? maximumValue
        self.unitSuffix = unitSuffix
        self.numberFormatter = numberFormatter
    }
    
    
    // MARK: - Helpers
    
    func resetSelection() {
        minimumValueSelected = minimumValue
        maximumValueSelected = maximumValue
    }
    
    func value(forConstant constant: CGFloat, minimumConstant: CGFloat, maximumConstant: CGFloat) -> Int {
        guard maximumConstant >= minimumConstant && minimumConstant..<maximumConstant ~= constant else {
            if abs(minimumConstant.distance(to: constant)) < abs(maximumConstant.distance(to: constant)) {
                return minimumValue
            }
            return maximumValue
        }
        let constantRange = maximumConstant - minimumConstant
        let valuesRange = maximumValue - minimumValue
        guard constantRange > 0 && valuesRange > 0 else { return minimumValue }
        let translatedConstant = constant - minimumConstant
        let translatedValue = translatedConstant * CGFloat(valuesRange) / constantRange
        let value = translatedValue + CGFloat(minimumValue)
        return Int(round(value))
    }
    
    func constant(forValue value: Int, minimumConstant: CGFloat, maximumConstant: CGFloat) -> CGFloat {
        guard maximumValue >= minimumValue && minimumValue..<maximumValue ~= value else {
            if abs(minimumValue.distance(to: value)) < abs(maximumValue.distance(to: value)) {
                return minimumConstant
            }
            return maximumConstant
        }
        let constantRange = maximumConstant - minimumConstant
        let valuesRange = maximumValue - minimumValue
        guard constantRange > 0 && valuesRange > 0 else { return minimumConstant }
        let translatedValue = value - minimumValue
        let translatedConstant = CGFloat(translatedValue) * constantRange / CGFloat(valuesRange)
        let constant = translatedConstant + minimumConstant
        return round(constant)
    }
    
    func selectionLabelText() -> String {
        if minimumValueSelected == maximumValueSelected && (minimumValueSelected == minimumValue) {
            return minimumValueNotSelectedText
        } else if minimumValueSelected == maximumValueSelected {
            return formattedString(forValue: minimumValueSelected)
        } else {
            if minimumValueSelected == minimumValue {
                if maximumValueSelected == maximumValue {
                    return minimumAndMaximumValuesNotSelectedText
                } else {
                    let suffix = selectionTextSuffix()
                    return minimumValueNotSelectedText +
                        " - " +
                        formattedString(forValue: maximumValueSelected)
                        + suffix
                }
            } else {
                let suffix = selectionTextSuffix()
                if maximumValueSelected == maximumValue {
                    return formattedString(forValue: minimumValueSelected)
                        + " - "
                        + maximumValueNotSelectedText
                        + suffix
                } else {
                    return formattedString(forValue: minimumValueSelected)
                        + " - "
                        + formattedString(forValue: maximumValueSelected)
                        + suffix
                }
            }
        }
    }
    
    private func selectionTextSuffix() -> String {
        if let unitSuffix = unitSuffix {
            return " \(unitSuffix)"
        }
        return ""
    }
    
    private func formattedString(forValue value: Int) -> String {
        guard let numberFormatter = numberFormatter,
            let formattedString = numberFormatter.string(from: NSNumber(value: value))
            else { return "\(value)" }
        return formattedString
    }
}
