//
//  PostCarDetailsView.swift
//  LetGo
//
//  Created by Nestor on 06/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit
import RxSwift

class PostCarDetailsView: UIView {
    private let navigationTitle = UILabel()
    private let navigationMakeButton = UIButton()
    private let navigationModelButton = UIButton()
    private let navigationYearButton = UIButton()
    private let descriptionLabel = UILabel()
    private let progressView = PostCategoryDetailProgressView()
    let makeRowView = PostCategoryDetailRowView(withTitle: LGLocalizedString.postCategoryDetailCarMake)
    let modelRowView = PostCategoryDetailRowView(withTitle: LGLocalizedString.postCategoryDetailCarModel)
    let yearRowView = PostCategoryDetailRowView(withTitle: LGLocalizedString.postCategoryDetailCarYear)
    let doneButton = UIButton(type: .custom)
    
    // MARK: - Lifecycle

    init() {
        super.init(frame: CGRect.zero)
        
        setupUI()
        setupAccessibilityIds()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        doneButton.rounded = true
    }
    
    private func setupUI() {
        navigationTitle.font = UIFont.systemSemiBoldFont(size: 17)
        navigationTitle.textAlignment = .center
        navigationTitle.textColor = UIColor.white
        navigationTitle.text = LGLocalizedString.postCategoryDetailsNavigationTitle
        
        navigationMakeButton.setTitleColor(UIColor.white, for: .normal)
        navigationMakeButton.setTitle(LGLocalizedString.postCategoryDetailCarMake, for: .normal)
        
        
        descriptionLabel.font = UIFont.systemSemiBoldFont(size: 27)
        descriptionLabel.textAlignment = .left
        descriptionLabel.textColor = UIColor.white
        descriptionLabel.text = LGLocalizedString.postCategoryDetailsDescription
        descriptionLabel.numberOfLines = 0

        progressView.setPercentage(0)
        
        makeRowView.enabled = true
        modelRowView.enabled = false
        yearRowView.enabled = true
        
        doneButton.setStyle(.primary(fontSize: .big))
        doneButton.setTitle(LGLocalizedString.productPostDone, for: .normal)
    }
    
    private func setupLayout() {
        let subviews = [navigationTitle, descriptionLabel, progressView, makeRowView, modelRowView, yearRowView, doneButton]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        addSubviews(subviews)
        
        layoutMargins = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        
        descriptionLabel.layout(with: self).leadingMargin().trailingMargin()
        descriptionLabel.layout(with: progressView).above(by: -Metrics.margin*2)
        
        progressView.layout(with: self).centerX().centerY(by: frame.height*1/3)
        progressView.layout(with: makeRowView).above(by: -Metrics.margin*2)
        
        makeRowView.layout().height(50)
        makeRowView.layout(with: self).leadingMargin().trailingMargin()
        makeRowView.layout(with: modelRowView).above()
        modelRowView.layout().height(50)
        modelRowView.layout(with: self).leadingMargin().trailingMargin()
        modelRowView.layout(with: yearRowView).above()
        yearRowView.layout().height(50)
        yearRowView.layout(with: self).leadingMargin().trailingMargin()
        yearRowView.layout(with: doneButton).above(by: -Metrics.margin)
        
        doneButton.layout().height(Metrics.buttonHeight)
        doneButton.layout(with: self).leadingMargin().trailingMargin()
    }
    
    // MARK: - Accessibility
    
    private func setupAccessibilityIds() {
        
    }
    
    // MARK: - Helpers
    
    func updateMake(_ make: String?) {
        if let make = make, !make.isEmpty {
            navigationMakeButton.setTitle(make, for: .normal)
            
        } else {
            navigationMakeButton.setTitle(LGLocalizedString.postCategoryDetailCarMake,
                                          for: .normal)
        }
        makeRowView.value = make
    }
    
    func updateModel(_ model: String?) {
        if let model = model, !make.isEmpty {
            navigationMakeButton.setTitle(model, for: .normal)
        } else {
            navigationMakeButton.setTitle(LGLocalizedString.postCategoryDetailCarModel, for: .normal)
        }
    }
    
    func updateYear(_ year: String?) {
        if let year = year, !make.isEmpty {
            navigationMakeButton.setTitle(year, for: .normal)
        } else {
            navigationMakeButton.setTitle(LGLocalizedString.postCategoryDetailCarYear, for: .normal)
        }
    }
    
 /*   static private func getProgress(forCategoryDetails details: [PostCategoryDetailRow]) -> Int {
        guard details.count > 0 else { return 100 }
        var detailsFilled = 0
        details.forEach { (detail) in
            if detail.isFilled {
                detailsFilled += detailsFilled
            }
        }
        return Int(detailsFilled / details.count)
    }
 */
}
