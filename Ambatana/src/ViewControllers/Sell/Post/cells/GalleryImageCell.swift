import UIKit
import LGComponents

final class GalleryImageCell: UICollectionViewCell, ReusableCell {

    let image: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.cornerRadius = LGUIKitConstants.mediumCornerRadius
        return image
    }()
    let multipleSelectionCountLabel: UILabel = {
        let label = UILabel()
        label.layer.borderWidth = 2
        label.cornerRadius = LGUIKitConstants.mediumCornerRadius
        label.layer.borderColor = UIColor.white.cgColor
        label.font = UIFont.systemSemiBoldFont(size: 21)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    let disabledView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.6
        return view
    }()

    var disabled: Bool = false {
        didSet {
            disabledView.isHidden = !disabled
        }
    }
    
    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
        self.resetUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }

    override var isSelected: Bool {
        didSet {
            multipleSelectionCountLabel.isHidden = !isSelected
            if multipleSelectionCountLabel.isHidden {
                multipleSelectionCountLabel.text = nil
            }
        }
    }

    // MARK: - Private methods

    private func setupUI() {
        contentView.addSubviewsForAutoLayout([image, multipleSelectionCountLabel, disabledView])
        [
            image.topAnchor.constraint(equalTo: contentView.topAnchor),
            image.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            image.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

            multipleSelectionCountLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            multipleSelectionCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            multipleSelectionCountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            multipleSelectionCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

            disabledView.topAnchor.constraint(equalTo: contentView.topAnchor),
            disabledView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            disabledView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            disabledView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        ].activate()
    }

    private func resetUI() {
        image.image = nil

        multipleSelectionCountLabel.text = nil
        multipleSelectionCountLabel.isHidden = true
        disabled = false

        contentView.clipsToBounds = true
        contentView.cornerRadius = LGUIKitConstants.mediumCornerRadius
    }
}
