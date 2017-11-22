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
    
    static func categoriesAvailable(realEstateEnabled: Bool) -> [PostCategory] {
        return realEstateEnabled ? [.car, PostCategory.realEstate, PostCategory.motorsAndAccessories, PostCategory.unassigned] : [PostCategory.car, PostCategory.motorsAndAccessories, PostCategory.unassigned]
    }
    
    func numberOfSteps(shouldShowPrice: Bool) -> CGFloat {
        switch self {
        case .car:
            return shouldShowPrice ? 3 : 2
        case .realEstate:
            return shouldShowPrice ? 5 : 4
        case .unassigned, .motorsAndAccessories:
            return 0
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
    fileprivate let realEstateEnabled: Bool
    fileprivate let categoriesAvailables: [PostCategory]
    
    fileprivate let disposeBag = DisposeBag()
    
    var selectedCategory: Observable<PostCategory> {
        return selectedCategoryPublishSubject.asObservable()
    }
    fileprivate let selectedCategoryPublishSubject = PublishSubject<PostCategory>()
        
    
    // MARK: - Lifecycle
    
    init(realEstateEnabled: Bool) {
        self.realEstateEnabled = realEstateEnabled
        categoriesAvailables = PostCategory.categoriesAvailable(realEstateEnabled: realEstateEnabled)
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
    
    func addButton(button: UIButton, title: String, image: UIImage, postCategoryLink: PostCategory) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemBoldFont(size: 23)
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor.whiteTextHighAlpha, for: .highlighted)
        button.setImage(image, for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: Metrics.bigMargin, bottom: 0, right: 0)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.contentHorizontalAlignment = .left
        button.rx.tap.subscribeNext { [weak self] _ in
            self?.selectedCategoryPublishSubject.onNext(postCategoryLink)
            }.addDisposableTo(disposeBag)
        categoriesContainerView.addSubview(button)
    }
    
    func setupUI() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemSemiBoldFont(size: 17)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        titleLabel.text = LGLocalizedString.productPostSelectCategoryTitle
        addSubview(titleLabel)
        
        categoriesContainerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(categoriesContainerView)
        
        categoriesAvailables.forEach { (category) in
            switch category {
            case .car:
                addButton(button: carsCategoryButton,
                          title: LGLocalizedString.productPostSelectCategoryCars,
                          image: #imageLiteral(resourceName: "categories_cars_inactive"),
                          postCategoryLink: .car)
            case .unassigned:
                addButton(button: otherCategoryButton,
                          title: LGLocalizedString.productPostSelectCategoryOther,
                          image: #imageLiteral(resourceName: "categories_other_items"),
                          postCategoryLink: .unassigned)
            case .motorsAndAccessories:
                addButton(button: motorsAndAccessoriesButton,
                          title: LGLocalizedString.productPostSelectCategoryMotorsAndAccessories,
                          image: #imageLiteral(resourceName: "categories_motors_inactive"),
                          postCategoryLink: .motorsAndAccessories)
            case .realEstate:
                addButton(button: realEstateCategoryButton,
                          title: LGLocalizedString.productPostSelectCategoryHousing,
                          image: #imageLiteral(resourceName: "categories_realestate_inactive"),
                          postCategoryLink: .realEstate)
            }
        }
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
        carsCategoryButton.layout(with: realEstateEnabled ? realEstateCategoryButton : motorsAndAccessoriesButton)
            .above(by: -Metrics.bigMargin)
        
        if realEstateEnabled {
            realEstateCategoryButton.layout()
                .height(categoryButtonHeight)
            realEstateCategoryButton.layout(with: categoriesContainerView)
                .leading(by: Metrics.bigMargin)
                .trailing(by: -Metrics.bigMargin)
            realEstateCategoryButton .layout(with: motorsAndAccessoriesButton)
                .above(by: -Metrics.bigMargin)
        }

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
