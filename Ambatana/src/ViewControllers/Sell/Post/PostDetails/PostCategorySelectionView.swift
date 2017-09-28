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
    case car, unassigned, motorsAndAccessories, realEstate
    
    var listingCategory: ListingCategory {
        switch self {
        case .car:
            return .cars
        case .unassigned:
            return .unassigned
        case .motorsAndAccessories:
            return .motorsAndAccessories
        case .realEstate:
            return .realEstate
        }
    }
}

final class PostCategorySelectionView: UIView {
    fileprivate let categoryButtonHeight: CGFloat = 55

    fileprivate let titleLabel = UILabel()
    fileprivate let categoriesContainerView = UIView()
    fileprivate let carsCategoryButton = UIButton()
    fileprivate let motorsAndAccessoriesButton = UIButton()
    fileprivate let otherCategoryButton = UIButton()
    fileprivate let realEstateCategoryButton = UIButton()
    
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
        carsCategoryButton.titleLabel?.font = UIFont.systemBoldFont(size: 23)
        carsCategoryButton.setTitle(LGLocalizedString.productPostSelectCategoryCars, for: .normal)
        carsCategoryButton.setTitleColor(UIColor.white, for: .normal)
        carsCategoryButton.setTitleColor(UIColor.whiteTextHighAlpha, for: .highlighted)
        carsCategoryButton.setImage(UIImage(named: "categories_cars_inactive"), for: .normal)
        carsCategoryButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: Metrics.bigMargin, bottom: 0, right: 0)
        carsCategoryButton.titleLabel?.lineBreakMode = .byWordWrapping
        carsCategoryButton.contentHorizontalAlignment = .left
        carsCategoryButton.rx.tap.subscribeNext { [weak self] _ in
            self?.selectedCategoryPublishSubject.onNext(.car)
        }.addDisposableTo(disposeBag)
        categoriesContainerView.addSubview(carsCategoryButton)
        
        realEstateCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        realEstateCategoryButton.titleLabel?.font = UIFont.systemBoldFont(size: 23)
        realEstateCategoryButton.setTitle(LGLocalizedString.productPostSelectCategoryHousing, for: .normal)
        realEstateCategoryButton.setTitleColor(UIColor.white, for: .normal)
        realEstateCategoryButton.setTitleColor(UIColor.whiteTextHighAlpha, for: .highlighted)
        realEstateCategoryButton.setImage(#imageLiteral(resourceName: "categories_realestate_inactive"), for: .normal)
        realEstateCategoryButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: Metrics.bigMargin, bottom: 0, right: 0)
        realEstateCategoryButton.titleLabel?.lineBreakMode = .byWordWrapping
        realEstateCategoryButton.contentHorizontalAlignment = .left
        realEstateCategoryButton.rx.tap.subscribeNext { [weak self] _ in
            self?.selectedCategoryPublishSubject.onNext(.realEstate)
            }.addDisposableTo(disposeBag)
        categoriesContainerView.addSubview(realEstateCategoryButton)

        motorsAndAccessoriesButton.translatesAutoresizingMaskIntoConstraints = false
        motorsAndAccessoriesButton.titleLabel?.font = UIFont.systemBoldFont(size: 23)
        motorsAndAccessoriesButton.setTitle(LGLocalizedString.productPostSelectCategoryMotorsAndAccessories, for: .normal)
        motorsAndAccessoriesButton.setTitleColor(UIColor.white, for: .normal)
        motorsAndAccessoriesButton.setTitleColor(UIColor.whiteTextHighAlpha, for: .highlighted)
        motorsAndAccessoriesButton.setImage(UIImage(named: "categories_motors_inactive"), for: .normal)
        motorsAndAccessoriesButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: Metrics.bigMargin, bottom: 0, right: 0)
        motorsAndAccessoriesButton.titleLabel?.lineBreakMode = .byWordWrapping
        motorsAndAccessoriesButton.contentHorizontalAlignment = .left
        motorsAndAccessoriesButton.rx.tap.subscribeNext { [weak self] _ in
            self?.selectedCategoryPublishSubject.onNext(.motorsAndAccessories)
            }.addDisposableTo(disposeBag)
        categoriesContainerView.addSubview(motorsAndAccessoriesButton)
        
        otherCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        otherCategoryButton.titleLabel?.font = UIFont.systemBoldFont(size: 23)
        otherCategoryButton.setTitle(LGLocalizedString.productPostSelectCategoryOther, for: .normal)
        otherCategoryButton.setTitleColor(UIColor.white, for: .normal)
        otherCategoryButton.setTitleColor(UIColor.whiteTextHighAlpha, for: .highlighted)
        otherCategoryButton.setImage(UIImage(named: "categories_other_items"), for: .normal)
        otherCategoryButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: Metrics.bigMargin, bottom: 0, right: 0)
        otherCategoryButton.titleLabel?.lineBreakMode = .byWordWrapping
        otherCategoryButton.contentHorizontalAlignment = .left
        otherCategoryButton.rx.tap.subscribeNext { [weak self] _ in
            self?.selectedCategoryPublishSubject.onNext(.unassigned)
        }.addDisposableTo(disposeBag)
        categoriesContainerView.addSubview(otherCategoryButton)
    }
    
    func setupAccessibilityIds() {
        carsCategoryButton.accessibilityId = .postingCategorySelectionCarsButton
        motorsAndAccessoriesButton.accessibilityId = .postingCategorySelectionMotorsAndAccessoriesButton
        otherCategoryButton.accessibilityId = .postingCategorySelectionOtherButton
        realEstateCategoryButton.accessibilityId = .postingCategorySelectionRealEstateButton
        
    }
    
    func setupLayout() {
        titleLabel.layout(with: self)
            .leading(by: Metrics.margin)
            .trailing(by: -Metrics.margin)
            .top(by: 14)
        
        categoriesContainerView.layout(with: self)
            .leading()
            .trailing()
            .centerY()
        
        carsCategoryButton.layout()
            .height(categoryButtonHeight)
        carsCategoryButton.layout(with: categoriesContainerView)
            .leading(by: Metrics.bigMargin)
            .trailing(by: -Metrics.bigMargin)
            .top()
        carsCategoryButton.layout(with: realEstateCategoryButton)
            .above(by: -Metrics.bigMargin)
        
        realEstateCategoryButton.layout()
            .height(categoryButtonHeight)
        realEstateCategoryButton.layout(with: categoriesContainerView)
            .leading(by: Metrics.bigMargin)
            .trailing(by: -Metrics.bigMargin)
        realEstateCategoryButton .layout(with: motorsAndAccessoriesButton)
            .above(by: -Metrics.bigMargin)
        
        motorsAndAccessoriesButton.layout()
            .height(categoryButtonHeight)
        motorsAndAccessoriesButton.layout(with: categoriesContainerView)
            .leading(by: Metrics.bigMargin)
            .trailing(by: -Metrics.bigMargin)
        motorsAndAccessoriesButton.layout(with: otherCategoryButton)
            .above(by: -Metrics.bigMargin)
        
        otherCategoryButton.layout()
            .height(categoryButtonHeight)
        otherCategoryButton.layout(with: categoriesContainerView)
            .leading(by: Metrics.bigMargin)
            .trailing(by: -Metrics.bigMargin)
            .bottom()
    }
}
