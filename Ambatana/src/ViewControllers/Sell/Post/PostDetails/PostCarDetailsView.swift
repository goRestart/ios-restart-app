//
//  PostCarDetailsView.swift
//  LetGo
//
//  Created by Nestor on 06/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit
import RxSwift

enum PostCarDetail {
    case make
    case model
    case year
}

class PostCarDetailsView: UIView {
    let navigationBackButton = UIButton()
    private let navigationTitle = UILabel()
    private let navigationMakeButton = UIButton()
    private let navigationModelButton = UIButton()
    private let navigationYearButton = UIButton()
    let navigationOkButton = UIButton()
    private let descriptionLabel = UILabel()
    private let progressView = PostCategoryDetailProgressView()
    let makeRowView = PostCategoryDetailRowView(withTitle: LGLocalizedString.postCategoryDetailCarMake)
    let modelRowView = PostCategoryDetailRowView(withTitle: LGLocalizedString.postCategoryDetailCarModel)
    let yearRowView = PostCategoryDetailRowView(withTitle: LGLocalizedString.postCategoryDetailCarYear)
    let doneButton = UIButton(type: .custom)
    
    private var progressTopConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private static let progressConstantSelectDetail = UIScreen.main.bounds.height*2/5
    private static let progressConstantSelectDetailValue = 44 + Metrics.margin
    
    private let tableView = PostCategoryDetailTableView()
    
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
        navigationBackButton.setImage(UIImage(named: "ic_post_back"), for: .normal)
        
        navigationTitle.font = UIFont.systemSemiBoldFont(size: 17)
        navigationTitle.textAlignment = .center
        navigationTitle.textColor = UIColor.white
        navigationTitle.text = LGLocalizedString.postCategoryDetailsNavigationTitle
        
        navigationMakeButton.setTitleColor(UIColor.white, for: .normal)
        navigationMakeButton.titleLabel?.adjustsFontSizeToFitWidth = false
        navigationMakeButton.titleLabel?.lineBreakMode = .byTruncatingTail
        updateMake(nil)
        navigationModelButton.setTitleColor(UIColor.white, for: .normal)
        navigationModelButton.titleLabel?.adjustsFontSizeToFitWidth = false
        navigationModelButton.titleLabel?.lineBreakMode = .byTruncatingTail
        updateModel(nil)
        navigationYearButton.setTitleColor(UIColor.white, for: .normal)
        navigationYearButton.titleLabel?.adjustsFontSizeToFitWidth = false
        navigationYearButton.titleLabel?.lineBreakMode = .byTruncatingTail
        updateYear(nil)
        
        navigationOkButton.setTitleColor(UIColor.white, for: .normal)
        navigationOkButton.setTitle(LGLocalizedString.postCategoryDetailOkButton, for: .normal)
        
        descriptionLabel.font = UIFont.systemSemiBoldFont(size: 27)
        descriptionLabel.textAlignment = .left
        descriptionLabel.textColor = UIColor.white
        descriptionLabel.text = LGLocalizedString.postCategoryDetailsDescription
        descriptionLabel.numberOfLines = 0

        updateProgress()
        
        makeRowView.enabled = true
        modelRowView.enabled = false
        yearRowView.enabled = true
        
        doneButton.setStyle(.primary(fontSize: .big))
        doneButton.setTitle(LGLocalizedString.productPostDone, for: .normal)
        
        selectDetailVisibleViews().forEach { $0.alpha = 1 }
        selectDetailValueVisibleViews().forEach { $0.alpha = 0 }
    }
    
    private func setupLayout() {
        let subviews = [navigationBackButton, navigationTitle, navigationMakeButton, navigationModelButton,
                        navigationYearButton, navigationOkButton, descriptionLabel, progressView, makeRowView,
                        modelRowView, yearRowView, doneButton]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        addSubviews(subviews)
        
        layoutMargins = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        
        navigationBackButton.layout(with: self).left(by: 8).top(by: 9)
        navigationTitle.layout(with: self)
            .leading(to: .leadingMargin, by: Metrics.margin)
            .trailing(to: .trailingMargin, by: -Metrics.margin)
            .top(by: 14)
        navigationMakeButton.setTitle("asdfasdfsafasdfsdafsdafsadfsadfdsafd", for: .normal)
        navigationMakeButton.layout(with: self)
            .leading(to: .leadingMargin, by: Metrics.margin, relatedBy: .greaterThanOrEqual)
            .top(by: 9)
        navigationMakeButton.layout(with: navigationModelButton).trailing(to: .leading, by: -Metrics.margin)
        navigationModelButton.setTitle("21343214231423143214321432142314132", for: .normal)
        navigationModelButton.layout().width(UIScreen.main.bounds.width*2/5, relatedBy: .lessThanOrEqual)
        navigationModelButton.layout(with: self)
            .top(by: 9).centerX()
        navigationModelButton.layout(with: navigationYearButton).trailing(to: .leading, by: -Metrics.margin)
        navigationYearButton.setTitle("2009", for: .normal)
        navigationYearButton.layout(with: self).top(by: 9)
        navigationYearButton.layout(with: navigationOkButton)
            .trailing(to: .leading, by: -Metrics.margin, relatedBy: .lessThanOrEqual)
        
        navigationOkButton.layout(with: self).right(by: -8).top(by: 9)
        
        descriptionLabel.layout(with: self).leadingMargin().trailingMargin()
        progressView.layout(with: descriptionLabel).below(by: Metrics.margin*2)
        progressView.layout(with: self)
            .centerX()
            .top(by: PostCarDetailsView.progressConstantSelectDetail, constraintBlock: { [weak self] in
                self?.progressTopConstraint = $0
            })
        
        makeRowView.layout(with: progressView).below(by: Metrics.margin*2)
        makeRowView.layout().height(50)
        makeRowView.layout(with: self).leadingMargin().trailingMargin()
        modelRowView.layout(with: makeRowView).below()
        modelRowView.layout().height(50)
        modelRowView.layout(with: self).leadingMargin().trailingMargin()
        yearRowView.layout(with: modelRowView).below()
        yearRowView.layout().height(50)
        yearRowView.layout(with: self).leadingMargin().trailingMargin()
        
        doneButton.layout(with: yearRowView).below(by: Metrics.margin)
        doneButton.layout().height(Metrics.buttonHeight)
        doneButton.layout(with: self).leadingMargin().trailingMargin()
    }
    
    // MARK: - Accessibility
    
    private func setupAccessibilityIds() {
        
    }
    
    // MARK: - Helpers
    
    func updateMake(_ make: String?) {
        var buttomTitle = LGLocalizedString.postCategoryDetailCarMake
        if let make = make, !make.isEmpty {
            buttomTitle = make
        }
        navigationMakeButton.setTitle(buttomTitle, for: .normal)
        makeRowView.value = make
        updateProgress()
    }
    
    func updateModel(_ model: String?) {
        var buttomTitle = LGLocalizedString.postCategoryDetailCarModel
        if let model = model, !model.isEmpty {
            buttomTitle = model
        }
        navigationModelButton.setTitle(buttomTitle, for: .normal)
        modelRowView.value = model
        updateProgress()
    }
    
    func updateYear(_ year: String?) {
        var buttomTitle = LGLocalizedString.postCategoryDetailCarYear
        if let year = year, !year.isEmpty {
            buttomTitle = year
        }
        navigationYearButton.setTitle(buttomTitle, for: .normal)
        yearRowView.value = year
        updateProgress()
    }
    
    private func updateProgress() {
        progressView.setPercentage(getCurrentProgress())
    }
    
    private func getCurrentProgress() -> Int {
        let details = [makeRowView, modelRowView, yearRowView]
        var detailsFilled = 0
        details.forEach { (detail) in
            if detail.isFilled() {
                detailsFilled += detailsFilled
            }
        }
        guard details.count > 0 else { return 100 }
        return Int(detailsFilled / details.count)
    }
    
    private func updateNavigationButtons(forDetail detail: PostCarDetail) {
        switch detail {
        case .make:
            navigationMakeButton.setTitleColor(UIColor.white, for: .normal)
            navigationModelButton.setTitleColor(UIColor.white.withAlphaComponent(0.3), for: .normal)
            navigationYearButton.setTitleColor(UIColor.white.withAlphaComponent(0.3), for: .normal)
        case .model:
            navigationMakeButton.setTitleColor(UIColor.white.withAlphaComponent(0.3), for: .normal)
            navigationModelButton.setTitleColor(UIColor.white, for: .normal)
            navigationYearButton.setTitleColor(UIColor.white.withAlphaComponent(0.3), for: .normal)
        case .year:
            navigationMakeButton.setTitleColor(UIColor.white.withAlphaComponent(0.3), for: .normal)
            navigationModelButton.setTitleColor(UIColor.white.withAlphaComponent(0.3), for: .normal)
            navigationYearButton.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    // MARK: Animations
    
    private func selectDetailVisibleViews() -> [UIView] {
        return [navigationTitle, descriptionLabel, makeRowView, modelRowView, yearRowView, doneButton]
    }
    
    private func selectDetailValueVisibleViews() -> [UIView] {
        return [tableView, navigationMakeButton, navigationModelButton, navigationYearButton]
    }
    
    func showSelectDetail() {
        self.progressTopConstraint.constant = PostCarDetailsView.progressConstantSelectDetail
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.layoutIfNeeded()
            self.navigationBackButton.transform = CGAffineTransform(rotationAngle: CGFloat(0))
        }, completion: nil)

        UIView.animate(withDuration: 0.15, delay: 0.05, options: .curveEaseIn, animations: {
            self.selectDetailVisibleViews().forEach { $0.alpha = 1 }
            self.selectDetailValueVisibleViews().forEach { $0.alpha = 0 }
        }, completion: nil)
    }
    
    func showSelectDetailValue(forDetail detail: PostCarDetail, values: [String], selectedValue: Int?) {
        updateNavigationButtons(forDetail: detail)
        
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
            self.selectDetailVisibleViews().forEach { $0.alpha = 0 }
            self.selectDetailValueVisibleViews().forEach { $0.alpha = 1 }
        }, completion: nil)
        
        self.progressTopConstraint.constant = PostCarDetailsView.progressConstantSelectDetailValue
        UIView.animate(withDuration: 0.2, delay: 0.05, options: .curveEaseIn, animations: {
            self.layoutIfNeeded()
            self.navigationBackButton.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
        }, completion: nil)
    }
}
