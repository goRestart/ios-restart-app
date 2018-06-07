import UIKit
import LGComponents

final class TagCollectionViewWithCloseCell: UICollectionViewCell, ReusableCell, TagCollectionConfigurable {
    
    var style: TagCollectionViewCellStyle = TagCollectionViewCellStyle.blackBackground
    
    private let tagLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.clipsToBounds = true
        return label
    }()
    
    private let crossImageView: UIImageView = {
        let imageView = UIImageView(image: R.Asset.IconsButtons.icCrossTags.image)
        imageView.clipsToBounds = true
        return imageView
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
        contentView.backgroundColor = style.backgroundColor
        contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        tagLabel.font = style.font
        tagLabel.textColor = style.textColor
    }
    
    private func setupViews() {
        contentView.addSubviewsForAutoLayout([tagLabel, crossImageView])
    }
    
    private func setupConstraints() {
        let constraints: [NSLayoutConstraint] = [
            tagLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.margin),
            tagLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            crossImageView.leadingAnchor.constraint(equalTo: tagLabel.trailingAnchor, constant: Layout.imageLeft),
            crossImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metrics.shortMargin),
            crossImageView.widthAnchor.constraint(equalToConstant: Layout.crossSize),
            crossImageView.heightAnchor.constraint(equalToConstant: Layout.crossSize),
            crossImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.setRoundedCorners()
    }
    
    func configure(with tag: String) {
        tagLabel.text = tag
    }
    
    static func cellSizeForText(text: String, style: TagCollectionViewCellStyle) -> CGSize {
        let widthCell = text.widthFor(height: Layout.cellHeigth, font: style.font) +
            Metrics.margin*2 +
            Metrics.shortMargin +
            Layout.crossSize
        return CGSize(width: widthCell, height: Layout.cellHeigth)
    }
    
    private struct Layout {
        static let cellHeigth: CGFloat = 33
        static let crossSize: CGFloat = 18
        static let imageLeft: CGFloat = 7
    }
    
}
