import Foundation
import LGCoreKit
import UIKit
import RxSwift
import LGComponents

class ExpandableCategorySelectionView: UIView, UIGestureRecognizerDelegate {
    
    static let distanceBetweenButtons: CGFloat = 10
    
    private let viewModel: ExpandableCategorySelectionViewModel
    private var buttons: [UIButton] = []
    private var closeButton: UIButton = UIButton()
    private let newBadgeView: UIView = UIView()
    
    private let titleTagsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemSemiBoldFont(size: 13)
        label.text = R.Strings.trendingItemsExpandableMenuSubsetTitle
        label.textAlignment = .center
        return label
    }()
    private var tagCollectionView: TagCollectionView?
    
    private let buttonSpacing: CGFloat
    private let bottomDistance: CGFloat
    private let buttonHeight: CGFloat = 50
    private let buttonCloseSide: CGFloat = 60
    let expanded = Variable<Bool>(false)
    
    private var topConstraints: [NSLayoutConstraint] = []
    private let disposeBag: DisposeBag = DisposeBag()
    
    
    // MARK: - Lifecycle
    
    init(frame: CGRect, buttonSpacing: CGFloat, bottomDistance: CGFloat,
         viewModel: ExpandableCategorySelectionViewModel) {
        self.buttonSpacing = buttonSpacing
        self.bottomDistance = bottomDistance
        self.viewModel = viewModel
        
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        closeButton.setRoundedCorners()
        buttons.forEach { (button) in button.setRoundedCorners() }
        newBadgeView.setRoundedCorners()
    }
    

    // MARK: - UI
    
    private func setupNewBadge() {
        guard let newBadgeCategory = viewModel.newBadgeCategory,
            let position = viewModel.categoriesAvailable.index(of: newBadgeCategory) else { return }
        
        newBadgeView.backgroundColor = .white
        
        let labelNew = UILabel()
        labelNew.text = R.Strings.commonNew
        labelNew.font = UIFont.boldSystemFont(ofSize: 12)
        labelNew.textColor = UIColor.lgBlack
        newBadgeView.addSubviewForAutoLayout(labelNew)
        labelNew.layout(with: newBadgeView).fillVertical(by: 3).fillHorizontal(by: Metrics.shortMargin)
        
        newBadgeView.clipsToBounds = true
        newBadgeView.applyDefaultShadow()
        addSubviewForAutoLayout(newBadgeView)

        newBadgeView.layout(with: buttons[position])
            .right(by: Metrics.veryShortMargin)
            .top(by: -Metrics.veryShortMargin)
    }

    private func addButtons() {
        guard !expanded.value else { return }
        
        viewModel.categoriesAvailable.forEach({ (category) in
            guard let actionIndex = viewModel.categoriesAvailable.index(of: category) else { return }
            
            let button = LetgoButton()
            button.setStyle(.primary(fontSize: .medium))
            button.tag = actionIndex
            button.setImage(category.icon, for: .normal)
            button.setTitle(category.title, for: .normal)
            button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
            button.set(accessibilityId: .expandableCategorySelectionButton)
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

    private func setupUI() {
        alpha = 0
        clipsToBounds = true
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let button = LetgoButton(withStyle: .secondary(fontSize: .medium, withBorder: false))
        button.setImage(R.Asset.CongratsScreenImages.icCloseRed.image, for: .normal)
        button.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        closeButton = button
        
        addSubview(closeButton)
        closeButton.alpha = 0
        closeButton.layout(with: self).bottom(by: bottomDistance).centerX()
        closeButton.layout().width(buttonCloseSide)
        closeButton.layout().height(buttonCloseSide)
        
        addButtons()
        if viewModel.newBadgeCategory != nil {
            setupNewBadge()
        }
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOutside))
        tapRecognizer.delegate = self
        addGestureRecognizer(tapRecognizer)
        setAccesibilityIds()
    }
    
    private func updateExpanded(_ expanded: Bool, animated: Bool) {
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
    
    private func marginForButtonAtIndex(_ index: Int, expanded: Bool) -> CGFloat {
         return expanded ? (buttonSpacing * CGFloat(index+1) + buttonHeight * CGFloat(index)) : 0
    }
    
    private func setAccesibilityIds() {
        set(accessibilityId: .expandableCategorySelectionView)
        closeButton.set(accessibilityId: .expandableCategorySelectionCloseButton)
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
        viewModel.pressCategoryAction(listingCategory: viewModel.categoriesAvailable[buttonIndex])
    }
    
    
    // MARK: - TapGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let touchView = touch.view,
            let tagCollectionView = tagCollectionView else { return true }
        // Ignore touches explicitly in tagCollectionView cells
        return touchView.isEqual(tagCollectionView) ||
            !touchView.isDescendant(of: tagCollectionView)
    }
}

fileprivate extension ListingCategory {
    var title: String {
        switch self {
        case .unassigned:
            return R.Strings.categoriesUnassignedItems
        case .motorsAndAccessories, .cars, .homeAndGarden, .babyAndChild, .electronics, .fashionAndAccesories, .moviesBooksAndMusic, .other, .sportsLeisureAndGames, .services:
            return name
        case .realEstate:
            return FeatureFlags.sharedInstance.realEstateNewCopy.isActive ? R.Strings.productPostSelectCategoryRealEstate : R.Strings.productPostSelectCategoryHousing
        }
    }
    var icon: UIImage? {
        switch self {
        case .unassigned:
            return R.Asset.IconsButtons.items.image
        case .cars:
            return R.Asset.IconsButtons.carIcon.image
        case .motorsAndAccessories:
            return R.Asset.IconsButtons.motorsAndAccesories.image
        case .realEstate:
            return R.Asset.IconsButtons.housingIcon.image
        case .services:
            return R.Asset.IconsButtons.servicesIcon.image
        case .homeAndGarden, .babyAndChild, .electronics, .fashionAndAccesories, .moviesBooksAndMusic, .other, .sportsLeisureAndGames:
            return image
        }
    }
}
