
import UIKit

final class ListingAttributeTableViewCell: UITableViewCell, ReusableCell {

    private struct Layout {
        static let titleFontSize: CGFloat = 13.0
        static let valueFontSize: Int = 17
        
        static let horizontalInset: CGFloat = 16.0
        static let bottomInset: CGFloat = 16.0
        static let titleLabelBottomInset: CGFloat = 20.0
        static let verticalInset: CGFloat = 16.0
        static let valueLabelHeight: CGFloat = 20.0
        static let iconSize: CGSize = CGSize(width: 40.0, height: 40.0)
    }
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = .grayDark
        titleLabel.font = UIFont.systemFont(ofSize: Layout.titleFontSize)
        titleLabel.numberOfLines = 0
        
        return titleLabel
    }()
    
    private let valueLabel: UILabel = {
        let valueLabel = UILabel()
        valueLabel.textColor = .white
        valueLabel.font = UIFont.systemMediumFont(size: Layout.valueFontSize)
        valueLabel.numberOfLines = 0
        
        return valueLabel
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleToFill 
        
        return imageView
    }()
    
    override init(style: UITableViewCellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(withItem item: ListingAttributeGridItem) {
        titleLabel.text = item.typeName
        valueLabel.text = item.title
        iconImageView.image = item.icon
    }
}


// MARK: - Setup

extension ListingAttributeTableViewCell {
    
    private func setupUI() {
        backgroundColor = .clear
        setupConstraints()
    }
    
    private func setupConstraints() {
        addSubviewsForAutoLayout([titleLabel, valueLabel, iconImageView])
        
        iconImageView.layout()
            .width(Layout.iconSize.width)
            .height(Layout.iconSize.height)
        
        iconImageView.layout(with: self)
            .right(by: -Layout.horizontalInset)
            .centerY()
        
        valueLabel.layout(with: self)
            .left(by: Layout.horizontalInset)
            .bottom(by: -Layout.bottomInset)
        
        valueLabel.layout(with: self)
            .right(by: -Layout.horizontalInset)
        
        valueLabel.layout()
            .height(Layout.valueLabelHeight)
        
        titleLabel.layout(with: self)
            .left(by: Layout.horizontalInset)
            .top(by: Layout.verticalInset)
        
        titleLabel.layout(with: valueLabel)
            .bottom(by: -Layout.titleLabelBottomInset)
        
        titleLabel.layout(with: iconImageView)
            .right(by: -Layout.horizontalInset)
    }
}
