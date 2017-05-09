//
//  FilterCarInfoYearCell.swift
//  LetGo
//
//  Created by Dídac on 03/05/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit
//import SwiftRangeSlider

protocol FilterCarInfoYearCellDelegate: class {
    func filterYearChanged(withStartYear startYear: Int?, endYear: Int?)
}

class FilterCarInfoYearCell: UICollectionViewCell {

    static let filterMinCarYear: Double = 1950

    var currentYear: Double {
        return Double(Calendar.current.component(.year, from: Date()))
    }

    @IBOutlet weak var yearRangeSlider: NHRangeSliderView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!

    @IBOutlet weak var bottomSeparatorHeight: NSLayoutConstraint!
    @IBOutlet weak var topSeparatorHeight: NSLayoutConstraint!

    weak var delegate: FilterCarInfoYearCellDelegate?


    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
        self.resetUI()
        setAccessibilityIds()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }

    func drawSlider(withStartingYear startYear: Int?, endYear: Int?) {
        if let startYear = startYear {
            yearRangeSlider.lowerValue = Double(startYear)
        }
        if let endYear = endYear {
            yearRangeSlider.upperValue = Double(endYear)
        }
        updateInfoLabel(lowerValue: yearRangeSlider.lowerValue, upperValue: yearRangeSlider.upperValue)
    }

    
    // MARK: - Private methods

    private func setupUI() {
        yearRangeSlider.maximumValue = currentYear
        yearRangeSlider.minimumValue = FilterCarInfoYearCell.filterMinCarYear
        yearRangeSlider.upperValue = currentYear
        yearRangeSlider.lowerValue = FilterCarInfoYearCell.filterMinCarYear
        yearRangeSlider.stepValue = 1.0
        yearRangeSlider.gapBetweenThumbs = 0
        yearRangeSlider.delegate = self
        
        bottomSeparatorHeight.constant = LGUIKitConstants.onePixelSize
        topSeparatorHeight.constant = LGUIKitConstants.onePixelSize
    }

    // Resets the UI to the initial state
    private func resetUI() {
        updateInfoLabel(lowerValue: FilterCarInfoYearCell.filterMinCarYear, upperValue: currentYear)
    }


    private func setAccessibilityIds() {
        self.accessibilityId = .filterCarInfoYearCell
        titleLabel.accessibilityId = .filterCarInfoYearCellTitleLabel
        infoLabel.accessibilityId = .filterCarInfoYearCellInfoLabel
    }

    fileprivate func updateInfoLabel(lowerValue: Double, upperValue: Double) {

        if lowerValue == FilterCarInfoYearCell.filterMinCarYear,
           upperValue == currentYear {
            infoLabel.text = LGLocalizedString.filtersCarYearAnyYear
        } else if lowerValue == FilterCarInfoYearCell.filterMinCarYear,
            upperValue == FilterCarInfoYearCell.filterMinCarYear {
            infoLabel.text = String(format: LGLocalizedString.filtersCarYearBeforeYear, Int(lowerValue)) //"_Before \(Int(yearRangeSlider.lowerValue))"
        } else if lowerValue == FilterCarInfoYearCell.filterMinCarYear,
            upperValue > FilterCarInfoYearCell.filterMinCarYear {
            infoLabel.text = String(format: LGLocalizedString.filtersCarYearBeforeYear, Int(lowerValue))
                + " - \(Int(upperValue))" //"_Before \(Int(lowerValue)) - \(Int(upperValue))"
        } else if lowerValue == upperValue {
            infoLabel.text = "\(Int(lowerValue))"
        } else {
            infoLabel.text = "\(Int(lowerValue)) - \(Int(upperValue))"
        }
    }
}

extension FilterCarInfoYearCell: NHRangeSliderViewDelegate {
    func sliderValueChanged(lowerValue: Double, upperValue: Double) {
        updateInfoLabel(lowerValue: lowerValue, upperValue: upperValue)
    }

    func sliderInteractionFinished(lowerValue: Double, upperValue: Double) {
        var startYear: Int? = nil
        var endYear: Int? = nil
        if lowerValue > FilterCarInfoYearCell.filterMinCarYear {
            startYear = Int(lowerValue)
        }
        if upperValue < currentYear {
            endYear = Int(upperValue)
        }
        delegate?.filterYearChanged(withStartYear: startYear, endYear: endYear)
    }
}
