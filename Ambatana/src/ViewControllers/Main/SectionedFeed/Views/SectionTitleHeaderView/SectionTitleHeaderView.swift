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
    
    private let hitboxArea: UIView = UIView()
    
    private let arrowIcon: UIImageView = {
        let arrowIcon = UIImageView()
        arrowIcon.image = R.Asset.IconsButtons.icDisclosure.image.withRenderingMode(.alwaysTemplate)
        arrowIcon.tintColor = Style.buttonTintColor
        return arrowIcon
    }()
    
    private let buttonTitle: UILabel = {
        let text = UILabel()
        text.font = Style.buttonFont
        text.textColor = Style.buttonTintColor
        return text
    }()

    enum Style {
        static let buttonTintColor = UIColor(red: 255, green: 63, blue: 55)
        static let titleTextColor = UIColor.lgBlack
        static let buttonFont = UIFont.systemFont(ofSize: 15, weight: .bold)
        static let titleFont = UIFont.systemFont(ofSize: 23, weight: .bold)
    }
    
    enum Layout {
        static let sideMargin: CGFloat = 15
        static let titleWidthMultiplier: CGFloat = 0.6
        
        enum Hitbox {
            static let rightPadding: CGFloat = 14.0
            static let height: CGFloat = 45.0
            static let width: CGFloat = 145.0
        }
        
        enum ArrowIcon {
            static let leftMargin: CGFloat = 5.0
            static let height: CGFloat = 15.0
            static let width: CGFloat = 15.0
        }
    }

    weak var sectionHeaderDelegate: SectionTitleHeaderViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .grayBackground
        isOpaque = true
        addSubviewsForAutoLayout([titleLabel, hitboxArea])
        setupHitbox()
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: Layout.sideMargin),
            titleLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: Layout.titleWidthMultiplier),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            hitboxArea.rightAnchor.constraint(equalTo: rightAnchor),
            hitboxArea.heightAnchor.constraint(equalToConstant: Layout.Hitbox.height),
            hitboxArea.widthAnchor.constraint(equalToConstant: Layout.Hitbox.width),
            
            arrowIcon.rightAnchor.constraint(equalTo: hitboxArea.rightAnchor, constant: -Layout.sideMargin),
            arrowIcon.centerYAnchor.constraint(equalTo: hitboxArea.centerYAnchor),
            
            arrowIcon.leftAnchor.constraint(
                equalTo: buttonTitle.rightAnchor, constant: Layout.ArrowIcon.leftMargin),
            buttonTitle.centerYAnchor.constraint(equalTo: arrowIcon.centerYAnchor)
        ])
    }

    private func setupHitbox() {
        hitboxArea.addSubviewsForAutoLayout([arrowIcon, buttonTitle])
        hitboxArea.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(handleTap)))
    }
    
    @objc private func handleTap() { sectionHeaderDelegate?.didTapViewAll() }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    func configure(with titleText: String?,
                   buttonText: String?,
                   shouldShowSeeAllButton: Bool = true) {
        titleLabel.text = titleText
        buttonTitle.text = buttonText
        hitboxArea.isHidden = !shouldShowSeeAllButton
    }
}

