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
    
    init(frame: CGRect,
         buttonSpacing: CGFloat,
         bottomDistance: CGFloat,
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
        guard let badgePosition = viewModel.newBadgePosition else { return }
        
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

        newBadgeView.layout(with: buttons[badgePosition])
            .right(by: Metrics.veryShortMargin)
            .top(by: -Metrics.veryShortMargin)
    }

    private func addButtons() {
        guard !expanded.value else { return }
        
        viewModel.postCategories.enumerated().forEach { index, category in
            
            let button = LetgoButton()
            button.setStyle(.primary(fontSize: .medium))
            button.tag = index
            
            button.setImage(category.menuIcon, for: .normal)
            button.setTitle(category.menuName, for: .normal)
            button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
            button.set(accessibilityId: .expandableCategorySelectionButton)
            button.centerTextAndImage(spacing: 10)
            addSubviewForAutoLayout(button)
            
            button.layout(with: self).centerX()
            button.layout(with: closeButton).above(by: -marginForButtonAtIndex(index, expanded: expanded.value)) { [weak self] in
                self?.topConstraints.append($0)
            }
           
            button.layout().height(buttonHeight)
            buttons.append(button)
        }
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
        setupNewBadge()
        
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
        shrink(animated: true)
        viewModel.tapOutside()
    }
    
    @objc fileprivate dynamic func closeButtonPressed() {
        shrink(animated: true)
        viewModel.closeButtonAction()
    }

    @objc private dynamic func buttonPressed(_ button: UIButton) {
        shrink(animated: true)
        viewModel.pressCategoryAction(index: button.tag)
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
