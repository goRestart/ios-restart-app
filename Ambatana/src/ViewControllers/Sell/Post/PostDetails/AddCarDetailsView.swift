//
//  AddCarDetailsView.swift
//  LetGo
//
//  Created by Nestor on 06/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

struct CarDetail {
    let title: String
    let value: String
    let action: () -> ()
}

class AddCarDetailsView: UIView {
    private let titleLabel = UILabel()
    private let progressView = AddDetailProgressView()
    let carDetails: [AddDetailSelectionView]
    private let doneButton: UIButton
    
    // MARK: - Lifecycle
    
    init(withCarDetail carDetail: [CarDetail]) {
        var carDetails: [AddDetailSelectionView] = []
        for detail in carDetail {
            carDetails.append(AddDetailSelectionView(withTitle: detail.title,
                                                     value: detail.value,
                                                     action: detail.action))
        }
        self.carDetails = carDetails
        
        super.init(frame: CGRect.zero)
        
        setupUI()
        setupAccessibilityIds()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setupUI() {
        titleLabel.font = UIFont.systemSemiBoldFont(size: 27)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        titleLabel.text = LGLocalizedString.carPostAddDetailsTitle
        
        
        
    }
    
    private func setupLayout() {
        let subviews = [titleLabel, progressView, doneButton]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        addSubviews(subviews)
        
        
    }
    
    // MARK: - Accessibility
    
    private func setupAccessibilityIds() {
        
    }
}
