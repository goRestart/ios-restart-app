//
//  ExpandableCategorySelectionView.swift
//  LetGo
//
//  Created by Juan Iglesias on 29/08/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

import LGCoreKit
import UIKit
import RxSwift


class ExpandableCategorySelectionView: UIView, UIGestureRecognizerDelegate , TagCollectionViewModelSelectionDelegate {
    
    static let distanceBetweenButtons: CGFloat = 10
    static let multipleRowTagsCollectionViewHeightThreshold: CGFloat = 400
    static let singleRowTagsCollectionViewHeight: CGFloat = 40
    
    fileprivate let viewModel: ExpandableCategorySelectionViewModel
    fileprivate var buttons: [UIButton] = []
    fileprivate var closeButton: UIButton = UIButton()
    
    fileprivate let tagCollectionViewModel: TagCollectionViewModel
    fileprivate let tagsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    fileprivate let titleTagsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemSemiBoldFont(size: 13)
        label.text = LGLocalizedString.trendingItemsExpandableMenuSubsetTitle
        label.textAlignment = .center
        return label
    }()
    fileprivate var tagCollectionView: TagCollectionView?
    
    fileprivate let buttonSpacing: CGFloat
    fileprivate let bottomDistance: CGFloat
    fileprivate let buttonHeight: CGFloat = 50
    fileprivate let buttonCloseSide: CGFloat = 60
    let expanded = Variable<Bool>(false)
    
    fileprivate var topConstraints: [NSLayoutConstraint] = []
    fileprivate let disposeBag: DisposeBag = DisposeBag()
    fileprivate var canLayoutMultipleRowTagCollectionView: Bool {
        return tagsView.height > ExpandableCategorySelectionView.multipleRowTagsCollectionViewHeightThreshold
    }
    
    
    // MARK: - Lifecycle
    
    init(frame: CGRect, buttonSpacing: CGFloat, bottomDistance: CGFloat,
         viewModel: ExpandableCategorySelectionViewModel) {
        self.buttonSpacing = buttonSpacing
        self.bottomDistance = bottomDistance
        self.viewModel = viewModel
        self.tagCollectionViewModel = TagCollectionViewModel(tags: viewModel.tags, cellStyle: .whiteBackground)
        
        super.init(frame: frame)
        setupUI()
        setupTagsView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        closeButton.setRoundedCorners()
        buttons.forEach { (button) in button.setRoundedCorners() }
    }
    

    // MARK: - UI

    private func addButtons() {
        guard !expanded.value else { return }
        
        viewModel.categoriesAvailable.forEach({ (category) in
            guard let actionIndex = viewModel.categoriesAvailable.index(of: category) else { return }
            
            let button = UIButton(type: .custom)
            switch category.style {
            case .redBackground:
                button.setStyle(.primary(fontSize: .medium))
            case .whiteBackground:
                button.setStyle(.secondary(fontSize: .medium, withBorder: false))
            }
            button.tag = actionIndex
            button.setImage(category.icon, for: .normal)
            button.setTitle(category.title, for: .normal)
            button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
            button.accessibilityId = .expandableCategorySelectionButton
            button.translatesAutoresizingMaskIntoConstraints = false
            button.centerTextAndImage(spacing: 10)
            addSubview(button)
            
            button.layout(with: self).centerX()
            button.layout(with: closeButton).above(by: -marginForButtonAtIndex(actionIndex, expanded: expanded.value), constraintBlock: { [weak self] constraint in
                self?.topConstraints.append(constraint)
            })
            button.layout().height(buttonHeight)
            buttons.append(button)
        })
    }

    fileprivate func setupUI() {
        alpha = 0
        clipsToBounds = true
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let button = UIButton(type: .custom)
        button.setStyle(.secondary(fontSize: .medium, withBorder: false))
        button.setImage(#imageLiteral(resourceName: "ic_close_red"), for: .normal)
        button.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        closeButton = button
        
        addSubview(closeButton)
        closeButton.alpha = 0
        closeButton.layout(with: self).bottom(by: bottomDistance).centerX()
        closeButton.layout().width(buttonCloseSide)
        closeButton.layout().height(buttonCloseSide)
        
        addButtons()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOutside))
        tapRecognizer.delegate = self
        addGestureRecognizer(tapRecognizer)
        setAccesibilityIds()
    }
    
    fileprivate func updateExpanded(_ expanded: Bool, animated: Bool) {
        self.expanded.value = expanded
        
        (0..<buttons.count).forEach {
            let idx = $0
            let margin = marginForButtonAtIndex(idx, expanded: expanded)
            topConstraints[idx].constant = -margin
        }
        
        let modifyView = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.alpha = expanded ? 1.0 : 0.0
            strongSelf.closeButton.alpha = expanded ? 1.0 : 0.0
            strongSelf.layoutIfNeeded()
        }
        if animated {
            if expanded {
                UIView.animate(withDuration: 0.3, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 4,
                               options: [], animations: modifyView, completion: nil)
            } else {
                UIView.animate(withDuration: 0.2, animations: modifyView, completion: nil)
            }
        } else {
            modifyView()
        }
    }
    
    fileprivate func marginForButtonAtIndex(_ index: Int, expanded: Bool) -> CGFloat {
         return expanded ? (buttonSpacing * CGFloat(index+1) + buttonHeight * CGFloat(index)) : 0
    }
    
    fileprivate func setAccesibilityIds() {
        accessibilityId = .expandableCategorySelectionView
        closeButton.accessibilityId = .expandableCategorySelectionCloseButton
    }
    
    /// We choose the layout depending on the content size
    private func collectionViewlayout() -> TagCollectionViewFlowLayout {
        layoutIfNeeded()
        
        let flowLayout: TagCollectionViewFlowLayout
        if canLayoutMultipleRowTagCollectionView {
            flowLayout = TagCollectionViewFlowLayout.centerAligned
        } else {
            flowLayout = TagCollectionViewFlowLayout.singleRowWithScroll
        }
        return flowLayout
    }
    
    fileprivate func setupTagsView() {
        guard viewModel.tagsEnabled else { return }
        tagCollectionViewModel.selectionDelegate = self

        tagsView.addSubview(titleTagsLabel)
        addSubview(tagsView)
        
        tagsView.layout(with: self).top().fillHorizontal()
        if let highestButton = buttons.last {
            tagsView.layout(with: highestButton).above(by: -Metrics.bigMargin)
        }
        titleTagsLabel.layout(with: tagsView).top(by: 40).fillHorizontal(by: Metrics.bigMargin)
        titleTagsLabel.layout().height(15)

        tagCollectionView = TagCollectionView(viewModel: tagCollectionViewModel, flowLayout: collectionViewlayout())
        if let tagCollectionView = self.tagCollectionView {
            tagsView.addSubview(tagCollectionView)
            tagCollectionView.layout(with: tagsView).fillHorizontal()
            if canLayoutMultipleRowTagCollectionView {
                tagCollectionView.layout(with: titleTagsLabel).below(by: Metrics.bigMargin)
                tagCollectionView.layout(with: tagsView).bottom(by: -Metrics.bigMargin)
            } else {
                tagCollectionView.layout(with: titleTagsLabel).below(by: Metrics.margin)
                tagCollectionView.layout().height(ExpandableCategorySelectionView.singleRowTagsCollectionViewHeight)
            }
        }
    }
    
    
    // MARK: - Actions
    
    func expand(animated: Bool) {
        updateExpanded(true, animated: animated)
    }
    
    func shrink(animated: Bool) {
        updateExpanded(false, animated: animated)
    }
    
    func switchExpanded(animated: Bool) {
        if expanded.value {
            shrink(animated: animated)
        } else {
            expand(animated: animated)
        }
    }
    
    @objc fileprivate dynamic func tapOutside() {
        closeButtonPressed()
    }
    
    @objc fileprivate dynamic func closeButtonPressed() {
        shrink(animated: true)
        viewModel.closeButtonAction()
    }

    @objc fileprivate dynamic func buttonPressed(_ button: UIButton) {
        let buttonIndex = button.tag
        guard 0..<viewModel.categoriesAvailable.count ~= buttonIndex else { return }
        shrink(animated: true)
        viewModel.pressCategoryAction(category: viewModel.categoriesAvailable[buttonIndex])
    }
    
    
    // MARK: - TapGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let touchView = touch.view,
            let tagCollectionView = tagCollectionView else { return true }
        // Ignore touches explicitly in tagCollectionView cells
        return touchView.isEqual(tagCollectionView) ||
            !touchView.isDescendant(of: tagCollectionView)
    }
    
    
    // MARK: - TagCollectionViewModelSelectionDelegate
    
    func vm(_ vm: TagCollectionViewModel, didSelectTagAtIndex index: Int) {
        shrink(animated: true)
        viewModel.pressTagAtIndex(index)
    }
}

fileprivate extension ExpandableCategory {
    var title: String {
        switch self {
            case .listingCategory(let listingCategory):
            switch listingCategory {
            case .unassigned:
                return LGLocalizedString.categoriesUnassignedItems
            case .motorsAndAccessories, .cars, .homeAndGarden, .babyAndChild, .electronics, .fashionAndAccesories, .moviesBooksAndMusic, .other, .sportsLeisureAndGames:
                return listingCategory.name
            case .realEstate:
                return FeatureFlags.sharedInstance.realEstateNewCopy.isActive ? LGLocalizedString.productPostSelectCategoryRealEstate : LGLocalizedString.productPostSelectCategoryHousing
            }
        case .mostSearchedItems:
            return LGLocalizedString.trendingItemsExpandableMenuButton
        }
    }
    var icon: UIImage? {
        switch self {
        case .listingCategory(let listingCategory):
            switch listingCategory {
            case .unassigned:
                return #imageLiteral(resourceName: "items")
            case .cars:
                return #imageLiteral(resourceName: "carIcon")
            case .motorsAndAccessories:
                return #imageLiteral(resourceName: "motorsAndAccesories")
            case .realEstate:
                return #imageLiteral(resourceName: "housingIcon")
            case .homeAndGarden, .babyAndChild, .electronics, .fashionAndAccesories, .moviesBooksAndMusic, .other, .sportsLeisureAndGames:
                return listingCategory.image
            }
        case .mostSearchedItems:
            return UIImage(named: "trending_expandable")
        }
    }
}
