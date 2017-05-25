//
//  FilterDistanceCell.swift
//  LetGo
//
//  Created by Eli Kohen on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit

class FilterDistanceCell: UICollectionViewCell {
    
    @IBOutlet weak var separatorHeight: NSLayoutConstraint!
    private let filterDistanceSlider = FilterDistanceSlider()

    var distanceType: DistanceType {
        set {
            filterDistanceSlider.distanceType = newValue
        }
        get {
            return filterDistanceSlider.distanceType
        }
    }
    
    var delegate: FilterDistanceSliderDelegate? {
        set {
            filterDistanceSlider.delegate = newValue
        }
        get {
            return filterDistanceSlider.delegate
        }
    }
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
        self.resetUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }
    
    // MARK: - Public methods
    
    func setupWithDistance(_ initialDistance: Int) {
        filterDistanceSlider.setDistance(initialDistance)
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        separatorHeight.constant = LGUIKitConstants.onePixelSize
        filterDistanceSlider.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(filterDistanceSlider)
        filterDistanceSlider.layout(with: contentView).fill()
    }
    
    private func resetUI() {
        filterDistanceSlider.resetUI()
    }
}
