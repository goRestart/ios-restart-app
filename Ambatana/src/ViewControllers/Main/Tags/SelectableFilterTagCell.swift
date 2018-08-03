import UIKit
import LGCoreKit
import LGComponents

class SelectableFilterTagCell: UICollectionViewCell {
    
    private static let cellHeight: CGFloat = 32.0
    private var tagLabel: UILabel!
    private var filterTag : FilterTag?
    
    
    // MARK: - Static methods
    
    static func cellSizeForTag(_ tag: FilterTag) -> CGSize {
        switch tag {
            case .secondaryTaxonomyChild(let secondaryTaxonomyChild):
            return SelectableFilterTagCell.sizeForText(secondaryTaxonomyChild.name)
        default:
            return CGSize(width: 0, height: 0)
        }
    }
    
    private static func sizeForText(_ text: String) -> CGSize {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: SelectableFilterTagCell.cellHeight)
        let boundingBox = text.boundingRect(with: constraintRect,
                                            options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                            attributes: [NSAttributedStringKey.font: UIFont.mediumBodyFont], context: nil)
        return CGSize(width: boundingBox.width + Metrics.margin * 2, height: SelectableFilterTagCell.cellHeight)
    }
    
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        resetUI()
        setAccessibilityIds()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }

    private func setupUI() {
        contentView.layer.borderColor = UIColor.lineGray.cgColor
        contentView.layer.borderWidth = LGUIKitConstants.onePixelSize
        contentView.layer.backgroundColor = UIColor.white.cgColor
        
        tagLabel = UILabel()
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        tagLabel.textColor = .black
        tagLabel.font = UIFont.mediumBodyFont
        tagLabel.textAlignment = .center
        contentView.addSubview(tagLabel)
        tagLabel.layout(with: contentView).fillVertical().trailing().leading()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.setRoundedCorners()
    }
    
    private func resetUI() {
        tagLabel.text = nil
    }
    
    private func setAccessibilityIds() {
        tagLabel.set(accessibilityId: .selectableFilterTagCellTagLabel)
    }
    
    
    // MARK: - Public methods
    
    func setupWithTag(_ tag : FilterTag) {
        filterTag = tag
        
        switch tag {
        case .secondaryTaxonomyChild(let secondaryTaxonomyChild):
            tagLabel.text = secondaryTaxonomyChild.name
        default:
            break
        }
        set(accessibilityId: .filterTagCell(tag: tag))
    }
}

