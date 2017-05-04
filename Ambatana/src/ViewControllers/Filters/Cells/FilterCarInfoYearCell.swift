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
    func filterYearChanged(withMinValue minValue: Double, maxValue: Double)
}

class FilterCarInfoYearCell: UICollectionViewCell {

    static let filterMinCarYear: Double = 1950

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


    // MARK: - Actions

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        updateInfoLabel()
    }

    @IBAction func sliderDidEnd(_ sender: UISlider) {
        delegate?.filterYearChanged(withMinValue: yearRangeSlider.lowerValue, maxValue: yearRangeSlider.upperValue)
    }


    // MARK: - Private methods

    private func setupUI() {
        let currentYear = Calendar.current.component(.year, from: Date())

        yearRangeSlider.minimumValue = Double(FilterCarInfoYearCell.filterMinCarYear)
        yearRangeSlider.maximumValue = Double(currentYear)
        yearRangeSlider.lowerValue = Double(FilterCarInfoYearCell.filterMinCarYear)
        yearRangeSlider.upperValue = Double(currentYear)

        bottomSeparatorHeight.constant = LGUIKitConstants.onePixelSize
        topSeparatorHeight.constant = LGUIKitConstants.onePixelSize
    }

    // Resets the UI to the initial state
    private func resetUI() {
        infoLabel.text = "_Any Year"
    }


    private func setAccessibilityIds() {
        self.accessibilityId = .filterCarInfoYearCell
        titleLabel.accessibilityId = .filterCarInfoYearCellTitleLabel
        infoLabel.accessibilityId = .filterCarInfoYearCellInfoLabel
    }

    private func updateInfoLabel() {
        if yearRangeSlider.lowerValue == FilterCarInfoYearCell.filterMinCarYear,
            yearRangeSlider.upperValue == FilterCarInfoYearCell.filterMinCarYear {
            infoLabel.text = "_Before \(Int(yearRangeSlider.lowerValue))"
        } else if yearRangeSlider.upperValue > FilterCarInfoYearCell.filterMinCarYear {
            infoLabel.text = "_Before \(Int(yearRangeSlider.lowerValue)) - \(Int(yearRangeSlider.upperValue))"
        } else {
            infoLabel.text = "\(Int(yearRangeSlider.lowerValue)) - \(Int(yearRangeSlider.upperValue))"
        }
    }
}
