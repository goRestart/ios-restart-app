//
//  PostCarDetailsView.swift
//  LetGo
//
//  Created by Nestor on 06/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit
import RxSwift

enum PostCarDetailState {
    case selectDetail
    case selectDetailValue(forDetail: CarDetailType)
}

func ==(lhs: PostCarDetailState, rhs: PostCarDetailState) -> Bool {
    switch (lhs, rhs) {
    case (.selectDetail, .selectDetail):
        return true
    case (.selectDetailValue(let lhsDetail), .selectDetailValue(let rhsDetail)):
        return lhsDetail == rhsDetail
    default:
        return false
    }
}

class PostCarDetailsView: UIView, UIGestureRecognizerDelegate {
    let navigationView = UIView()
    let contentView = UIView()
    
    let navigationBackButton = UIButton()
    private let navigationTitle = UILabel()
    let navigationMakeButton = UIButton()
    let navigationModelButton = UIButton()
    let navigationYearButton = UIButton()
    private let navigationOkButton = UIButton()
    private let descriptionLabel = UILabel()
    private let progressView = PostCategoryDetailProgressView()
    let makeRowView = PostCategoryDetailRowView(withTitle: LGLocalizedString.postCategoryDetailCarMake)
    let modelRowView = PostCategoryDetailRowView(withTitle: LGLocalizedString.postCategoryDetailCarModel)
    let yearRowView = PostCategoryDetailRowView(withTitle: LGLocalizedString.postCategoryDetailCarYear)
    let priceRowView = PostCategoryDetailRowView(withTitle: "", type: .textEntryRow)
    let doneButton = UIButton(type: .custom)
    private let priceRowEnabled: Bool
    
    private var progressTopConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private static var progressTopConstraintConstantSelectDetail = Metrics.screenHeight/3.5
    
    var state: PostCarDetailState = .selectDetail
    
    let tableView = CategoryDetailTableView(withStyle: .lightContent)
    
    // MARK: - Lifecycle

    init(withPriceRow priceRowEnabled: Bool) {
        self.priceRowEnabled = priceRowEnabled
        
        super.init(frame: CGRect.zero)
        
        setupUI()
        setupAccessibilityIds()
        setupLayout()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gesture.delegate = self
        contentView.addGestureRecognizer(gesture)
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
        contentView.clipsToBounds = true
        
        navigationBackButton.setImage(UIImage(named: "ic_back"), for: .normal)
        
        navigationTitle.font = UIFont.systemSemiBoldFont(size: 17)
        navigationTitle.textAlignment = .center
        navigationTitle.textColor = UIColor.white
        navigationTitle.text = LGLocalizedString.postCategoryDetailsNavigationTitle
        
        navigationMakeButton.setTitleColor(UIColor.white, for: .normal)
        navigationMakeButton.setTitleColor(UIColor.whiteTextHighAlpha, for: .highlighted)
        navigationMakeButton.titleLabel?.adjustsFontSizeToFitWidth = false
        navigationMakeButton.titleLabel?.lineBreakMode = .byTruncatingTail
        updateMake(withMake: nil)
        navigationModelButton.setTitleColor(UIColor.white, for: .normal)
        navigationModelButton.setTitleColor(UIColor.whiteTextHighAlpha, for: .highlighted)
        navigationModelButton.titleLabel?.adjustsFontSizeToFitWidth = false
        navigationModelButton.titleLabel?.lineBreakMode = .byTruncatingTail
        updateModel(withModel: nil)
        navigationYearButton.setTitleColor(UIColor.white, for: .normal)
        navigationYearButton.setTitleColor(UIColor.whiteTextHighAlpha, for: .highlighted)
        navigationYearButton.titleLabel?.adjustsFontSizeToFitWidth = false
        navigationYearButton.titleLabel?.lineBreakMode = .byTruncatingTail
        updateYear(withYear: nil)
        
        navigationOkButton.setTitleColor(UIColor.white, for: .normal)
        navigationOkButton.setTitleColor(UIColor.whiteTextHighAlpha, for: .highlighted)
        navigationOkButton.setTitle(LGLocalizedString.postCategoryDetailOkButton, for: .normal)
        navigationOkButton.titleLabel?.font = UIFont.boldBarButtonFont
        navigationOkButton.addTarget(self, action: #selector(navigationButtonOkPressed), for: .touchUpInside)
        
        if DeviceFamily.current == .iPhone4 || DeviceFamily.current == .iPhone5 {
            descriptionLabel.font = UIFont.systemBoldFont(size: 19)
        } else {
            descriptionLabel.font = UIFont.systemBoldFont(size: 27)
        }
        descriptionLabel.textAlignment = .left
        descriptionLabel.textColor = UIColor.white
        descriptionLabel.text = LGLocalizedString.postCategoryDetailsDescription
        descriptionLabel.numberOfLines = 0
        
        priceRowView.isHidden = !priceRowEnabled
        priceRowView.placeholder = LGLocalizedString.productNegotiablePrice
        
        doneButton.setStyle(.primary(fontSize: .big))
        doneButton.setTitle(LGLocalizedString.productPostDone, for: .normal)
        doneButton.isEnabled = false
        
        selectDetailVisibleViews().forEach { $0.alpha = 1 }
        selectDetailValueVisibleViews().forEach { $0.alpha = 0 }
    }
    
    private func setupLayout() {
        let rootViews = [navigationView, contentView]
        let navigationSubviews = [navigationBackButton, navigationTitle, navigationMakeButton, navigationModelButton,
                                  navigationYearButton, navigationOkButton]
        let contentSubviews = [descriptionLabel, progressView, makeRowView,
                               modelRowView, yearRowView, priceRowView, doneButton, tableView]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: rootViews)
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: navigationSubviews)
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: contentSubviews)
        addSubviews(rootViews)
        navigationView.addSubviews(navigationSubviews)
        contentView.addSubviews(contentSubviews)
        
        navigationView.layoutMargins = UIEdgeInsets(top: 0, left: Metrics.margin*2, bottom: 0, right: Metrics.margin*2)
        contentView.layoutMargins = UIEdgeInsets(top: 0, left: Metrics.margin*2, bottom: 0, right: Metrics.margin*2)
        
        navigationView.layout()
            .height(44)
        navigationView.layout(with: self)
            .left()
            .right()
            .top()
        navigationView.layout(with: contentView)
            .bottom(to: .top)
        contentView.layout(with: self)
            .left()
            .right()
            .bottom()
        
        navigationBackButton.layout(with: navigationView)
            .left(by: Metrics.margin)
            .top(by: Metrics.margin)
        navigationTitle.layout(with: navigationView)
            .leading(to: .leadingMargin, by: Metrics.margin)
            .trailing(to: .trailingMargin, by: -Metrics.margin)
        navigationTitle.layout(with: navigationMakeButton)
            .centerY()
        navigationMakeButton.layout(with: navigationView)
            .leading(to: .leadingMargin, by: Metrics.margin, relatedBy: .greaterThanOrEqual)
            .top(by: Metrics.shortMargin)
        navigationMakeButton.layout(with: navigationModelButton)
            .trailing(to: .leading, by: -Metrics.margin)
        navigationModelButton.layout()
            .width(UIScreen.main.bounds.width*2/5, relatedBy: .lessThanOrEqual)
        navigationModelButton.layout(with: navigationView)
            .top(by: Metrics.shortMargin)
            .centerX()
        navigationModelButton.layout(with: navigationYearButton)
            .trailing(to: .leading, by: -Metrics.margin)
        navigationYearButton.layout(with: navigationView)
            .top(by: Metrics.shortMargin)
        navigationYearButton.layout(with: navigationOkButton)
            .trailing(to: .leading, by: -Metrics.margin, relatedBy: .lessThanOrEqual)
        navigationYearButton.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        
        navigationOkButton.layout(with: navigationView)
            .right(by: -Metrics.margin)
            .top(by: Metrics.shortMargin)
        navigationOkButton.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        
        descriptionLabel.layout(with: contentView)
            .leadingMargin()
            .trailingMargin()
        progressView.layout(with: descriptionLabel)
            .below(by: Metrics.bigMargin)
        progressView.layout(with: contentView)
            .centerX()
            .top(by: PostCarDetailsView.progressTopConstraintConstantSelectDetail, relatedBy: .equal, constraintBlock: { [weak self] in
                self?.progressTopConstraint = $0
            })
        
        makeRowView.layout(with: progressView)
            .below(by: Metrics.bigMargin)
        makeRowView.layout()
            .height(50)
        makeRowView.layout(with: contentView)
            .leadingMargin()
            .trailingMargin()
        modelRowView.layout(with: makeRowView)
            .below()
        modelRowView.layout()
            .height(50)
        modelRowView.layout(with: contentView)
            .leadingMargin()
            .trailingMargin()
        yearRowView.layout(with: modelRowView)
            .below()
        yearRowView.layout()
            .height(50)
        yearRowView.layout(with: contentView)
            .leadingMargin()
            .trailingMargin()
        
        if priceRowEnabled {
            priceRowView.layout(with: yearRowView)
                .below()
            priceRowView.layout()
                .height(50)
            priceRowView.layout(with: contentView)
                .leadingMargin()
                .trailingMargin()
            doneButton.layout(with: priceRowView)
                .below(by: Metrics.margin)
        } else {
            doneButton.layout(with: yearRowView)
                .below(by: Metrics.margin)
        }
        
        doneButton.layout()
            .height(Metrics.buttonHeight)
        doneButton.layout(with: contentView)
            .leadingMargin()
            .trailingMargin()
        
        tableView.layout(with: progressView)
            .below(by: Metrics.bigMargin)
        tableView.layout(with: contentView)
            .leading()
            .trailing()
            .bottom()
    }
    
    // MARK: - Accessibility
    
    private func setupAccessibilityIds() {
        navigationBackButton.accessibilityId = .postingCategoryDeatilNavigationBackButton
        navigationMakeButton.accessibilityId = .postingCategoryDeatilNavigationMakeButton
        navigationModelButton.accessibilityId = .postingCategoryDeatilNavigationModelButton
        navigationYearButton.accessibilityId = .postingCategoryDeatilNavigationYearButton
        navigationOkButton.accessibilityId = .postingCategoryDeatilNavigationOkButton
        doneButton.accessibilityId = .postingCategoryDeatilDoneButton
    }
    
    // MARK: - Helpers
    
    func updateMake(withMake make: String?) {
        var buttonTitle = LGLocalizedString.postCategoryDetailCarMake
        if let make = make, !make.isEmpty {
            buttonTitle = make
            doneButton.isEnabled = true
            modelRowView.isEnabled = true
            yearRowView.isEnabled = true
        } else {
            doneButton.isEnabled = false
            modelRowView.isEnabled = false
            yearRowView.isEnabled = false
        }
        navigationMakeButton.setTitle(buttonTitle, for: .normal)
        makeRowView.value = make
    }
    
    func updateModel(withModel model: String?) {
        var buttonTitle = LGLocalizedString.postCategoryDetailCarModel
        if let model = model, !model.isEmpty {
            buttonTitle = model
        }
        navigationModelButton.setTitle(buttonTitle, for: .normal)
        modelRowView.value = model
    }
    
    func updateYear(withYear year: String?) {
        var buttonTitle = LGLocalizedString.postCategoryDetailCarYear
        if let year = year, !year.isEmpty {
            buttonTitle = year
        }
        navigationYearButton.setTitle(buttonTitle, for: .normal)
        yearRowView.value = year
    }
    
    func hideKeyboard() {
        tableView.hideKeyboard()
        priceRowView.hideKeyboard()
    }
    
    func setCurrencySymbol(_ symbol: String?) {
        priceRowView.title = symbol
    }
    
    func updateProgress(withPercentage percentage: Float) {
        progressView.setPercentage(percentage)
    }
    
    private func updateNavigationButtons(forDetail detail: CarDetailType) {
        switch detail {
        case .make:
            navigationMakeButton.setTitleColor(UIColor.white, for: .normal)
            navigationModelButton.setTitleColor(UIColor.whiteTextLowAlpha, for: .normal)
            navigationYearButton.setTitleColor(UIColor.whiteTextLowAlpha, for: .normal)
        case .model:
            navigationMakeButton.setTitleColor(UIColor.whiteTextLowAlpha, for: .normal)
            navigationModelButton.setTitleColor(UIColor.white, for: .normal)
            navigationYearButton.setTitleColor(UIColor.whiteTextLowAlpha, for: .normal)
        case .year:
            navigationMakeButton.setTitleColor(UIColor.whiteTextLowAlpha, for: .normal)
            navigationModelButton.setTitleColor(UIColor.whiteTextLowAlpha, for: .normal)
            navigationYearButton.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    private func updateTableView(withDetailType type: CarDetailType, values: [CarInfoWrapper],
                                 selectedValueIndex: Int?, addOtherString: String?) {
        tableView.setupTableView(withDetailType: type, values: values,
                                 selectedValueIndex: selectedValueIndex,
                                 addOtherString: addOtherString)
    }
    
    func backButtonHidden(_ hidden: Bool) {
        navigationBackButton.isHidden = hidden
    }
    
    // MARK: UI Actions
    
    dynamic func navigationButtonOkPressed() {
        tableView.hideKeyboard()
        priceRowView.hideKeyboard()
        showSelectDetail()
    }
    
    // MARK: Animations
    
    func moveContentUpward(by constant: CGFloat) {
        if constant < 0 {
            let constantNeeded = constant + (Metrics.screenHeight - doneButton.frame.maxY - navigationView.frame.maxY)
            progressTopConstraint.constant = PostCarDetailsView.progressTopConstraintConstantSelectDetail + constantNeeded
        } else {
            progressTopConstraint.constant = PostCarDetailsView.progressTopConstraintConstantSelectDetail
        }
    }
    
    private func selectDetailVisibleViews() -> [UIView] {
        return [navigationTitle, descriptionLabel, makeRowView, modelRowView, yearRowView, priceRowView, doneButton]
    }
    
    private func selectDetailValueVisibleViews() -> [UIView] {
        return [tableView, navigationMakeButton, navigationModelButton, navigationYearButton, navigationOkButton]
    }
    
    func showSelectDetail() {
        state = .selectDetail
        
        layoutIfNeeded()
        self.progressTopConstraint.constant = PostCarDetailsView.progressTopConstraintConstantSelectDetail
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.layoutIfNeeded()
        }, completion: nil)

        UIView.animate(withDuration: 0.15, delay: 0.05, options: .curveEaseIn, animations: {
            self.selectDetailVisibleViews().forEach { $0.alpha = 1 }
            self.selectDetailValueVisibleViews().forEach { $0.alpha = 0 }
        }, completion: nil)
    }
    
    func showSelectDetailValue(forDetail detail: CarDetailType, values: [CarInfoWrapper], selectedValueIndex: Int?) {
        defer {
            state = .selectDetailValue(forDetail: detail)
        }
        
        updateNavigationButtons(forDetail: detail)
        
        updateTableView(withDetailType: detail, values: values,
                        selectedValueIndex: selectedValueIndex,
                        addOtherString: detail.addOtherString)
        
        guard state == .selectDetail else { return }
        
        layoutIfNeeded()
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
            self.selectDetailVisibleViews().forEach { $0.alpha = 0 }
            self.selectDetailValueVisibleViews().forEach { $0.alpha = 1 }
        }, completion: nil)
        
        self.progressTopConstraint.constant = Metrics.veryBigMargin
        UIView.animate(withDuration: 0.2, delay: 0.05, options: .curveEaseIn, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    // MARK: UIGestureRecognizer delegate
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: self)
        if tableView.frame.contains(point) {
            return false
        }
        return true
    }
}
