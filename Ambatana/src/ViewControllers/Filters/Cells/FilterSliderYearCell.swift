//
//  FilterSliderYearCell.swift
//  LetGo
//
//  Created by Nestor on 04/08/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

protocol FilterCarInfoYearCellDelegate: class {
    func filterYearChanged(withStartYear startYear: Int?, endYear: Int?)
}

class FilterSliderYearCell: UICollectionViewCell, LGSliderDelegate {
    
    var slider: LGSlider?
    
    weak var delegate: FilterCarInfoYearCellDelegate?
    
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setAccessibilityIds()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }

    func setupSlider(minimumValue: Int?, maximumValue: Int?) {
        let minimumValue = minimumValue ?? Constants.filterMinCarYear
        let maximumValue = maximumValue ?? Date().year
        let vm = LGSliderViewModel(title: LGLocalizedString.postCategoryDetailCarYear,
                                   minimumValueNotSelectedText: String(format: LGLocalizedString.filtersCarYearBeforeYear, minimumValue),
                                   maximumValueNotSelectedText: String(maximumValue),
                                   minimumAndMaximumValuesNotSelectedText: LGLocalizedString.filtersCarYearAnyYear,
                                   minimumValue: minimumValue,
                                   maximumValue: maximumValue)
        slider = LGSlider(viewModel: vm)
        guard let slider = self.slider else { return }
        slider.delegate = self
        slider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(slider)
        slider.layout(with: contentView)
            .left(by: Metrics.margin)
            .right(by: -Metrics.margin)
            .top()
            .bottom()
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        // add borders
        backgroundColor = UIColor.white
    }
    
    private func resetUI() {
        slider?.resetSelection()
    }
    
    
    private func setAccessibilityIds() {
        accessibilityId = .filterCarInfoYearCell
//        titleLabel.accessibilityId = .filterCarInfoYearCellTitleLabel
//        infoLabel.accessibilityId = .filterCarInfoYearCellInfoLabel
    }
    
    
    // MARK: - LGSLiderDelegate

    func slider(_ slider: LGSlider, didSelectMinimumValue minimumValue: Int) {
        delegate?.filterYearChanged(withStartYear: minimumValue, endYear: nil)
    }
    
    func slider(_ slider: LGSlider, didSelectMaximumValue maximumValue: Int) {
        delegate?.filterYearChanged(withStartYear: nil, endYear: maximumValue)
    }
}
