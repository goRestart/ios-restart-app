import Foundation
import UIKit

enum TagCollectionViewCellStyle {
    case blackBackground
    case whiteBackground
    case grayBorder
    
    var backgroundColor: UIColor {
        switch self {
        case .blackBackground:
            return UIColor.black.withAlphaComponent(0.54)
        case .whiteBackground, .grayBorder:
            return UIColor.white
        }
    }
    
    var font: UIFont {
        switch self {
        case .blackBackground:
            return UIFont.systemFont(size: 13)
        case .whiteBackground:
            return UIFont.systemSemiBoldFont(size: 15)
        case .grayBorder:
            return UIFont.systemMediumFont(size: 13)
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .blackBackground:
            return UIColor.white
        case .whiteBackground:
            return UIColor.darkGrayText
        case .grayBorder:
            return UIColor.gray
        }
    }
    
    var borderColor: UIColor {
        switch self {
        case .blackBackground, .whiteBackground:
            return .clear
        case .grayBorder:
            return .grayLight
        }
    }
    
    var padding: UIEdgeInsets {
        switch self {
        case .blackBackground:
            return UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)
        case .whiteBackground:
            return UIEdgeInsets(top: 6, left: 15, bottom: 6, right: 15)
        case .grayBorder:
            return UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        }
    }
}

class TagCollectionViewCell: UICollectionViewCell, ReusableCell {
    
    var style: TagCollectionViewCellStyle = TagCollectionViewCellStyle.blackBackground
    let tagLabel: UIRoundedLabelWithPadding = {
        let label = UIRoundedLabelWithPadding(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        return label
    }()
    
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI
    
    func setupWith(style: TagCollectionViewCellStyle) {
        self.style = style
        tagLabel.backgroundColor = style.backgroundColor
        tagLabel.font = style.font
        tagLabel.textColor = style.textColor
        tagLabel.padding = style.padding
        if style == .grayBorder {
            tagLabel.layer.borderWidth = 1
            tagLabel.layer.borderColor = style.borderColor.cgColor
        }
    }
    
    private func setupViews() {
        contentView.addSubview(tagLabel)
    }
    
    private func setupConstraints() {
        let constraints = [
            tagLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tagLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tagLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            tagLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func configure(with tag: String) {
        tagLabel.text = tag
    }
}
