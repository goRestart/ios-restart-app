import UIKit
import LGComponents

class EditOptionDisclosureView: UIView {
    
    var titleLabel = UILabel()
    var currentValueLabel = UILabel()
    var disclosureImageView = UIImageView()
    
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    func setupWith(title: String, currentValue: String) {
        titleLabel.text = title
        currentValueLabel.text = currentValue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Private methods
    
    private func setupUI() {
        
        backgroundColor = .white
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(size: 16)
        
        currentValueLabel.textColor = UIColor.grayText
        currentValueLabel.font = UIFont.systemFont(size: 16)
        
        disclosureImageView.image = R.Asset.IconsButtons.icDisclosure.image
        disclosureImageView.contentMode = .scaleAspectFit
    }
    
    private func setupLayout() {
        
        let subviews: [UIView] = [titleLabel, disclosureImageView, currentValueLabel]
        addSubviews(subviews)
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        
        titleLabel.layout(with: self).left(by: Metrics.margin).centerY()
        disclosureImageView.layout(with: self).right(by: -Metrics.margin).centerY()
        currentValueLabel.layout(with: disclosureImageView).right(to: .left, by: -Metrics.shortMargin)
        currentValueLabel.layout(with: titleLabel).left(to: .right, by: Metrics.margin)
    }
    
    private func setAccessibilityIds() {
        set(accessibilityId: .editListingOptionSelector)
        titleLabel.set(accessibilityId: .editListingOptionSelectorTitleLabel)
        currentValueLabel.set(accessibilityId: .editListingOptionSelectorCurrentValueLabel)
    }
}
