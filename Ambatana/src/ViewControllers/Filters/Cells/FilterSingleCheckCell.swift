import UIKit
import LGComponents

class FilterSingleCheckCell: UICollectionViewCell, ReusableCell {
    struct Metrics {
        static let marginHeight: CGFloat = 12
        static let separatorColor: UIColor = UIColor.separatorFilters
        static let cellSmallMargin: CGFloat = 8
        static let cellBigMargin: CGFloat = 16
        static let tickIconWidth: CGFloat = 13
        static let tickIconHeight: CGFloat = 10
    }

    var titleLabel = UILabel()
    var bottomSeparator = UIView()
    var topSeparator = UIView()
    private var tickIcon = UIImageView()
    fileprivate var mainView = UIView()

    private var bottomMarginConstraint = NSLayoutConstraint()
    private var topMarginConstraint = NSLayoutConstraint()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
        self.resetUI()
        setAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }

    override var isSelected: Bool {
        get { return super.isSelected }
        set {
            super.isSelected = newValue
            self.tickIcon.isHidden = !newValue
        }
    }

    func setMargin(top: Bool = false, bottom: Bool = false) {
        bottomMarginConstraint.constant = bottom ? -FilterSingleCheckCell.Metrics.marginHeight : 0
        topMarginConstraint.constant = top ? FilterSingleCheckCell.Metrics.marginHeight : 0
    }

    // MARK: - Private methods

    private func setupUI() {
        titleLabel.highlightedTextColor = .primaryColor
        titleLabel.font = UIFont.systemFont(size: 16)
        titleLabel.textColor = UIColor.lgBlack

        topSeparator.backgroundColor = FilterSingleCheckCell.Metrics.separatorColor
        bottomSeparator.backgroundColor = FilterSingleCheckCell.Metrics.separatorColor

        mainView.backgroundColor = .white
        contentView.backgroundColor = .clear
        tickIcon.image = R.Asset.IconsButtons.icCheckmark.image

        contentView.addSubview(mainView)
        mainView.addSubviews([titleLabel, tickIcon, bottomSeparator, topSeparator])

        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: [mainView, titleLabel, tickIcon, bottomSeparator, topSeparator])

        mainView.layout(with: contentView).fillHorizontal().top{ [weak self] constraint in
            self?.topMarginConstraint = constraint
            }.bottom{ [weak self] constraint in
                self?.bottomMarginConstraint = constraint
        }

        topSeparator.layout(with: mainView).fillHorizontal()
        topSeparator.layout(with: mainView).top()
        topSeparator.layout().height(LGUIKitConstants.onePixelSize)
        bottomSeparator.layout(with: mainView).fillHorizontal()
        bottomSeparator.layout(with: mainView).bottom()
        bottomSeparator.layout().height(LGUIKitConstants.onePixelSize)

        titleLabel.layout(with: mainView)
            .top(by: FilterSingleCheckCell.Metrics.cellSmallMargin)
            .left(by: FilterSingleCheckCell.Metrics.cellBigMargin)
            .bottom(by: -FilterSingleCheckCell.Metrics.cellSmallMargin)
        titleLabel.layout(with: tickIcon).right(to: .left, by: FilterSingleCheckCell.Metrics.cellBigMargin)

        tickIcon.layout()
            .height(FilterSingleCheckCell.Metrics.tickIconHeight)
            .width(FilterSingleCheckCell.Metrics.tickIconWidth)
        tickIcon.layout(with: mainView)
            .right(by: -FilterSingleCheckCell.Metrics.cellBigMargin)
        tickIcon.layout(with: mainView).centerY()
    }

    // Resets the UI to the initial state
    private func resetUI() {
        tickIcon.isHidden = true
        titleLabel.text = ""
        bottomSeparator.isHidden = true
        setMargin()
    }

    private func setAccessibilityIds() {
        set(accessibilityId: .filterSingleCheckCell)
        tickIcon.set(accessibilityId: .filterSingleCheckCellTickIcon)
        titleLabel.set(accessibilityId: .filterSingleCheckCellTitleLabel)
    }
}
