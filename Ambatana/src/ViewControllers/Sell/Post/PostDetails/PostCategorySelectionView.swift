//
//  PostCategorySelectionView.swift
//  LetGo
//
//  Created by Albert Hernández López on 20/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift
import UIKit

enum PostCategory {
    case car, other
}

final class PostCategorySelectionView: UIView {
    fileprivate let titleLabel = UILabel()
    fileprivate let categoriesContainerView = UIView()
    fileprivate let carsCategoryButton = UIButton()
    fileprivate let orLeftView = UIView()
    fileprivate let orLabel = UILabel()
    fileprivate let orRightView = UIView()
    fileprivate let otherCategoryButton = UIButton()
    
    fileprivate var lines: [CALayer] = []
    
    fileprivate let disposeBag = DisposeBag()
    
    var selectedCategory: Observable<PostCategory> {
        return selectedCategoryPublishSubject.asObservable()
    }
    fileprivate let selectedCategoryPublishSubject = PublishSubject<PostCategory>()
        
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        updateUI()
    }
}


// MARK: - Private methods

fileprivate extension PostCategorySelectionView {
    func setupUI() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemSemiBoldFont(size: 17)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        titleLabel.text = LGLocalizedString.productPostSelectCategoryTitle
        addSubview(titleLabel)
        
        categoriesContainerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(categoriesContainerView)
        
        carsCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        carsCategoryButton.titleLabel?.font = UIFont.systemBoldFont(size: 30)
        carsCategoryButton.setTitle(LGLocalizedString.productPostSelectCategoryCars, for: .normal)
        carsCategoryButton.setTitleColor(UIColor.white, for: .normal)
        carsCategoryButton.rx.tap.subscribeNext { [weak self] _ in
            self?.selectedCategoryPublishSubject.onNext(.car)
        }.addDisposableTo(disposeBag)
        categoriesContainerView.addSubview(carsCategoryButton)
        
        orLeftView.translatesAutoresizingMaskIntoConstraints = false
        categoriesContainerView.addSubview(orLeftView)
        
        orLabel.translatesAutoresizingMaskIntoConstraints = false
        orLabel.font = UIFont.systemRegularFont(size: 13)
        orLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        orLabel.text = LGLocalizedString.productPostSelectCategoryOr
        categoriesContainerView.addSubview(orLabel)
        
        orRightView.translatesAutoresizingMaskIntoConstraints = false
        categoriesContainerView.addSubview(orRightView)
        
        otherCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        otherCategoryButton.titleLabel?.font = UIFont.systemBoldFont(size: 30)
        otherCategoryButton.setTitle(LGLocalizedString.productPostSelectCategoryOther, for: .normal)
        otherCategoryButton.setTitleColor(UIColor.white, for: .normal)
        otherCategoryButton.rx.tap.subscribeNext { [weak self] _ in
            self?.selectedCategoryPublishSubject.onNext(.other)
        }.addDisposableTo(disposeBag)
        categoriesContainerView.addSubview(otherCategoryButton)
    }
    
    func setupAccessibilityIds() {
        carsCategoryButton.accessibilityId = .postingCategorySelectionCarsButton
        otherCategoryButton.accessibilityId = .postingCategorySelectionOtherButton
    }
    
    func setupLayout() {
        titleLabel.layout(with: self)
            .leading(by: Metrics.margin)
            .trailing(by: -Metrics.margin)
            .top(by: 14)
        
        categoriesContainerView.layout(with: self)
            .leading(by: Metrics.margin)
            .trailing(by: -Metrics.margin)
            .centerY()
        
        carsCategoryButton.layout(with: categoriesContainerView)
            .leading()
            .trailing()
            .top()
        
        orLeftView.layout().width(36)
        orLeftView.layout(with: orLabel)
            .top(to: .centerY)
            .bottom()
            .toRight(by: -15)
        
        orLabel.layout(with: categoriesContainerView).centerX()
        orLabel.layout(with: carsCategoryButton).below(by: 36)
        
        orRightView.layout().width(36)
        orRightView.layout(with: orLabel)
            .top(to: .centerY)
            .bottom()
            .toLeft(by: 15)
        
        otherCategoryButton.layout(with: orLabel).below(by: 36)
        otherCategoryButton.layout(with: categoriesContainerView)
            .leading()
            .trailing()
            .bottom()
    }
    
    func updateUI() {
        // Redraw the lines
        lines.forEach { $0.removeFromSuperlayer() }
        lines = []
        lines.append(orLeftView.addTopBorderWithWidth(1, color: UIColor.white.withAlphaComponent(0.5)))
        lines.append(orRightView.addTopBorderWithWidth(1, color: UIColor.white.withAlphaComponent(0.5)))
    }
}
