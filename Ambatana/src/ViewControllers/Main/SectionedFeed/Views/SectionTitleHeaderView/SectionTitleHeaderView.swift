import UIKit
import LGComponents

protocol SectionTitleHeaderViewDelegate: class {
    func didTapViewAll()
}

final class SectionTitleHeaderView: UICollectionReusableView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.isOpaque = true
        label.textColor = Style.titleTextColor
        label.font = Style.titleFont
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private let seeAllButton: UIButton = {
        let bn = UIButton(type: .custom)
        bn.titleLabel?.font = Style.buttonFont
        let disclosureImage = R.Asset.IconsButtons.icDisclosure.image.withRenderingMode(.alwaysTemplate)
        bn.imageView?.tintColor = Style.buttonTintColor
        bn.setImage(disclosureImage, for: .normal)
        bn.setTitleColor(Style.buttonTintColor, for: .normal)
        bn.contentHorizontalAlignment = .right
        bn.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        bn.semanticContentAttribute = .forceRightToLeft
        bn.imageEdgeInsets = UIEdgeInsets(top: Layout.buttonVerticalInset, left: 0, bottom: Layout.buttonVerticalInset, right: Layout.buttonRightInset)
        return bn
    }()

    enum Style {
        static let buttonTintColor = UIColor(red: 255, green: 63, blue: 55)
        static let titleTextColor = UIColor.lgBlack
        static let buttonFont = UIFont.systemFont(ofSize: 15, weight: .bold)
        static let titleFont = UIFont.systemFont(ofSize: 23, weight: .bold)
    }
    
    enum Layout {
        static let sideMargin: CGFloat = 15
        static let titleHeightMultiplier: CGFloat = 0.9
        static let titleWidthMultiplier: CGFloat = 0.6
        static let buttonWidthMultiplier: CGFloat = 0.25
        static let buttonRightInset: CGFloat = -6
        static let buttonVerticalInset: CGFloat = 2
    }

    weak var sectionHeaderDelegate: SectionTitleHeaderViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .grayBackground
        isOpaque = true
        addSubviewsForAutoLayout([titleLabel, seeAllButton])
        setupConstraints()
        setupButtonAction()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: Layout.sideMargin),
            titleLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: Layout.titleWidthMultiplier),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            seeAllButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -Layout.sideMargin + Layout.buttonRightInset),
            seeAllButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            seeAllButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: Layout.buttonWidthMultiplier),
            ])
    }

    private func setupButtonAction() {
        seeAllButton.addTarget(self, action: #selector(handleButtonClick), for: .touchUpInside)
    }

    @objc private func handleButtonClick() {
        sectionHeaderDelegate?.didTapViewAll()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with titleText: String?, buttonText: String?) {
        titleLabel.text = titleText
        guard let buttonTextString = buttonText else { return }
        seeAllButton.setTitle(buttonTextString, for: .normal)
    }
}

