//
//  FilterCarInfoYearCell.swift
//  LetGo
//
//  Created by Dídac on 03/05/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit
import SwiftRangeSlider

protocol FilterCarInfoYearCellDelegate: class {
    func filterYearChanged(withStartYear startYear: Int?, endYear: Int?)
}

class FilterCarInfoYearCell: UICollectionViewCell {

    static let filterMinCarYear: Double = 1950

    var currentYear: Double {
        return Double(Calendar.current.component(.year, from: Date()))
    }

    @IBOutlet weak var yearRangeSlider: RangeSlider!
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
        updateInfoLabel()
    }

    // MARK: - Actions

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        updateInfoLabel()
    }

    @IBAction func sliderDidEnd(_ sender: UISlider) {
        var startYear: Int? = nil
        var endYear: Int? = nil
        if yearRangeSlider.lowerValue > FilterCarInfoYearCell.filterMinCarYear {
            startYear = Int(yearRangeSlider.lowerValue)
        }
        if yearRangeSlider.upperValue < currentYear {
            endYear = Int(yearRangeSlider.upperValue)
        }
        delegate?.filterYearChanged(withStartYear: startYear, endYear: endYear)
    }


    // MARK: - Private methods

    private func setupUI() {
        yearRangeSlider.stepValue = 1
        yearRangeSlider.minimumValue = FilterCarInfoYearCell.filterMinCarYear
        yearRangeSlider.maximumValue = currentYear
        yearRangeSlider.lowerValue = FilterCarInfoYearCell.filterMinCarYear
        yearRangeSlider.upperValue = currentYear
        yearRangeSlider.trackThickness = 0.05

        bottomSeparatorHeight.constant = LGUIKitConstants.onePixelSize
        topSeparatorHeight.constant = LGUIKitConstants.onePixelSize
    }

    // Resets the UI to the initial state
    private func resetUI() {
        updateInfoLabel()
    }


    private func setAccessibilityIds() {
        self.accessibilityId = .filterCarInfoYearCell
        titleLabel.accessibilityId = .filterCarInfoYearCellTitleLabel
        infoLabel.accessibilityId = .filterCarInfoYearCellInfoLabel
    }

    private func updateInfoLabel() {
        if yearRangeSlider.lowerValue == FilterCarInfoYearCell.filterMinCarYear,
            yearRangeSlider.upperValue == currentYear {
            infoLabel.text = LGLocalizedString.filtersCarYearAnyYear
        } else if yearRangeSlider.lowerValue == FilterCarInfoYearCell.filterMinCarYear,
            yearRangeSlider.upperValue == FilterCarInfoYearCell.filterMinCarYear {
            infoLabel.text = String(format: LGLocalizedString.filtersCarYearBeforeYear, Int(yearRangeSlider.lowerValue)) //"_Before \(Int(yearRangeSlider.lowerValue))"
        } else if yearRangeSlider.lowerValue == FilterCarInfoYearCell.filterMinCarYear,
            yearRangeSlider.upperValue > FilterCarInfoYearCell.filterMinCarYear {
            infoLabel.text = String(format: LGLocalizedString.filtersCarYearBeforeYear, Int(yearRangeSlider.lowerValue))
                + " - \(Int(yearRangeSlider.upperValue))" //"_Before \(Int(yearRangeSlider.lowerValue)) - \(Int(yearRangeSlider.upperValue))"
        } else if yearRangeSlider.lowerValue == yearRangeSlider.upperValue {
            infoLabel.text = "\(Int(yearRangeSlider.lowerValue))"
        } else {
            infoLabel.text = "\(Int(yearRangeSlider.lowerValue)) - \(Int(yearRangeSlider.upperValue))"
        }
    }
}
