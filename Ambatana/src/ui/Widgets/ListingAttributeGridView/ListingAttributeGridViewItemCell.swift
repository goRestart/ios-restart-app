import UIKit

final class ListingAttributeGridViewItemCell: UICollectionViewCell, ReusableCell {
    
    private struct Layout {
        static let iconImageViewVerticalInset: CGFloat = 12.0
        static let iconImageViewHorizontalInset: CGFloat = 12.0
        static let titleLabelVerticalInset: CGFloat = 12.0
        static let titleLabelToIconImageView: CGFloat = 4.0
        static let titleLabelHorizontalInset: CGFloat = 2.0
        static let titleLabelFontSize: CGFloat = 13.0
    }
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: Layout.titleLabelFontSize)
        
        return titleLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(withItem item: ListingAttributeGridItem,
               theme: ListingAttributeGridTheme,
               isSelected: Bool) {
        backgroundColor = .clear
        titleLabel.text = item.title
        iconImageView.image = item.icon
        updateSelectedState(isSelected: isSelected,
                            theme: theme)
    }
    
    func updateSelectedState(isSelected: Bool,
                             theme: ListingAttributeGridTheme,
                             performSelectionAnimation: Bool = false) {
        
        if performSelectionAnimation {
            performIconSelectionAnimation()
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.updateTintColour(isSelected: isSelected,
                                       theme: theme)
            }
        } else {
            updateTintColour(isSelected: isSelected,
                             theme: theme)
        }
    }
    
    private func updateTintColour(isSelected: Bool,
                                  theme: ListingAttributeGridTheme) {
        if isSelected {
            iconImageView.tintColor = theme.selectedTintColour
            titleLabel.textColor = theme.selectedTintColour
        } else {
            iconImageView.tintColor = theme.defaultTintColour
            titleLabel.textColor = theme.defaultTintColour
        }
    }

    private func setupConstraints() {
        addSubviewsForAutoLayout([iconImageView, titleLabel])
        
        titleLabel.layout(with: self)
            .fillHorizontal(by: Layout.titleLabelHorizontalInset)
            .bottom(by: -Layout.titleLabelVerticalInset)
        
        iconImageView.layout(with: self)
            .fillHorizontal(by: Layout.iconImageViewHorizontalInset)
            .top(by: Layout.iconImageViewVerticalInset)
        
        iconImageView.layout(with: titleLabel)
            .bottom(to: .top, by: -Layout.titleLabelToIconImageView)
    }
    
    private func performIconSelectionAnimation() {
        let startYPosition = iconImageView.layer.position.y
        let yOff: CGFloat = startYPosition-12
        let hopUpAnimationDuration: Double = 0.13
        let hopUpAnimation = CABasicAnimation(keyPath: "position.y")
        hopUpAnimation.beginTime = CACurrentMediaTime()
        hopUpAnimation.duration = hopUpAnimationDuration
        hopUpAnimation.fromValue = startYPosition
        hopUpAnimation.toValue = yOff
        hopUpAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        iconImageView.layer.add(hopUpAnimation, forKey: "hopUpAnimation")
        
        let returnAnimation = CABasicAnimation(keyPath: "position.y")
        returnAnimation.beginTime = CACurrentMediaTime() + hopUpAnimation.duration
        returnAnimation.duration = hopUpAnimationDuration/2
        returnAnimation.fromValue = yOff
        returnAnimation.toValue = startYPosition
        returnAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        iconImageView.layer.add(returnAnimation,
                                forKey: "returnAnimation")
    }
}
