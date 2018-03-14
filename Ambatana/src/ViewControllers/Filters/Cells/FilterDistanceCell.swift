//
//  FilterDistanceCell.swift
//  LetGo
//
//  Created by Eli Kohen on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit

class FilterDistanceCell: UICollectionViewCell, ReusableCell, FilterCell {
    var topSeparator: UIView?
    var bottomSeparator: UIView?
    var rightSeparator: UIView?

    private let filterDistanceSlider = FilterDistanceSlider()

    var distanceType: DistanceType {
        set { filterDistanceSlider.distanceType = newValue }
        get { return filterDistanceSlider.distanceType }
    }
    
    var delegate: FilterDistanceSliderDelegate? {
        set { filterDistanceSlider.delegate = newValue }
        get { return filterDistanceSlider.delegate }
    }
    
    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        resetUI()
        setAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }
    
    // MARK: - Public methods
    
    func setupWithDistance(_ initialDistance: Int) {
        filterDistanceSlider.distance = initialDistance
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        addTopSeparator(toContainerView: contentView)

        filterDistanceSlider.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(filterDistanceSlider)
        filterDistanceSlider.layout(with: contentView).top(by: 1).right().left().bottom()
    }
    
    private func resetUI() {
        filterDistanceSlider.resetUI()
    }
    
    private func setAccessibilityIds() {
        set(accessibilityId: .filterDistanceCell)
    }
}
