import Foundation
import UIKit

enum TagCollectionViewCellStyle {
    case blackBackground
    case whiteBackground
    
    var backgroundColor: UIColor {
        switch self {
        case .blackBackground:
            return UIColor.black.withAlphaComponent(0.54)
        case .whiteBackground:
            return UIColor.white
        }
    }
    
    var font: UIFont {
        switch self {
        case .blackBackground:
            return UIFont.systemFont(size: 13)
        case .whiteBackground:
            return UIFont.systemSemiBoldFont(size: 15)
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .blackBackground:
            return UIColor.white
        case .whiteBackground:
            return UIColor.darkGrayText
        }
    }
}

class TagCollectionViewCell: UICollectionViewCell, ReusableCell {
    
    var style: TagCollectionViewCellStyle = TagCollectionViewCellStyle.blackBackground
    let tagLabel: UIRoundedLabelWithPadding = {
        //let label = UIRoundedLabelWithPadding(frame: .zero, padding: UIEdgeInsets(top: 6, left: 15, bottom: 6, right: 15))
        let label = UIRoundedLabelWithPadding(frame: .zero, padding: UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12))
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
    
    override func prepareForReuse() {
        tagLabel.text = nil
        super.prepareForReuse()
    }
    
    
    // MARK: - UI
    
    func setupWith(style: TagCollectionViewCellStyle) {
        self.style = style
        tagLabel.backgroundColor = style.backgroundColor
        tagLabel.font = style.font
        tagLabel.textColor = style.textColor
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
