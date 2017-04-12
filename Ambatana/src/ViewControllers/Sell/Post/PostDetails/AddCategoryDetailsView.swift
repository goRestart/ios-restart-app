//
//  AddCategoryDetailsView.swift
//  LetGo
//
//  Created by Nestor on 06/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit
import RxSwift

struct CategoryDetailTable {
    // table
    var values: [String] = []
    
    let selectAction: () -> ()
}

class AddCategoryDetailsView: UIView {
    private let titleLabel = UILabel()
    private let progressView: AddDetailProgressView
    private var detailRowViews: [AddCategoryDetailRowView] = []
    private let doneButton = UIButton()
    
    private let categoryDetails: [CategoryDetailRow]
    
    // MARK: - Lifecycle
    
    init(withCategoryDetails categoryDetails: [CategoryDetailRow]) {
        self.categoryDetails = categoryDetails
        let percentage = AddCategoryDetailsView.getProgress(forCategoryDetails: categoryDetails)
        progressView = AddDetailProgressView(withInitialPercentage: percentage)
        
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

        var details: [AddCategoryDetailRowView] = []
        for detail in categoryDetails {
            details.append(AddCategoryDetailRowView(withCategoryDetailRow: detail))
        }
    }
    
    private func setupLayout() {
        let subviews = [titleLabel, progressView, doneButton]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        addSubviews(subviews)
        
        
    }
    
    // MARK: - Accessibility
    
    private func setupAccessibilityIds() {
        
    }
    
    // MARK: - Helpers
    
    static private func getProgress(forCategoryDetails details: [CategoryDetailRow]) -> Int {
        guard details.count > 0 else { return 100 }
        var detailsFilled = 0
        details.forEach { (detail) in
            if detail.isFilled {
                detailsFilled += detailsFilled
            }
        }
        return Int(detailsFilled / details.count)
    }
}
