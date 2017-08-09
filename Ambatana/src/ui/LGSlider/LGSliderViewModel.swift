//
//  LGSliderViewModel.swift
//  LetGo
//
//  Created by Nestor on 04/08/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

class LGSliderViewModel {
    let title: String
    
    private let minimumValueNotSelectedText: String
    private let maximumValueNotSelectedText: String
    private let minimumAndMaximumValuesNotSelectedText: String
    
    private let minimumValue: Int
    private let maximumValue: Int
    
    var minimumValueSelected: Int
    var maximumValueSelected: Int
    
    init(title: String,
         minimumValueNotSelectedText: String,
         maximumValueNotSelectedText: String,
         minimumAndMaximumValuesNotSelectedText: String,
         minimumValue: Int,
         maximumValue: Int) {
        
        self.title = title
        self.minimumValueNotSelectedText = minimumValueNotSelectedText
        self.maximumValueNotSelectedText = maximumValueNotSelectedText
        self.minimumAndMaximumValuesNotSelectedText = minimumAndMaximumValuesNotSelectedText
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        
        minimumValueSelected = minimumValue
        maximumValueSelected = maximumValue
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
        if minimumValueSelected == maximumValueSelected {
            return "\(minimumValueSelected)"
        } else {
            if minimumValueSelected == minimumValue {
                if maximumValueSelected == maximumValue {
                    return minimumAndMaximumValuesNotSelectedText
                } else {
                    return "\(minimumValueNotSelectedText) - \(maximumValueSelected)"
                }
            } else {
                if maximumValueSelected == maximumValue {
                    return "\(minimumValueSelected) - \(maximumValueNotSelectedText)"
                } else {
                    return "\(minimumValueSelected) - \(maximumValueSelected)"
                }
            }
        }
    }
}
