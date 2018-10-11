import UIKit
import LGComponents

protocol SectionTitleHeaderViewDelegate: class {
    func didTapViewAll()
}

final class SectionTitleHeaderView: UICollectionReusableView {

    private var updatedHeight: CGFloat = 0.0
    private weak var centerButtonConstraint: NSLayoutConstraint?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.isOpaque = true
        label.textColor = Style.titleTextColor
        label.font = Style.titleFont
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
        
        enum Constants {
            static let minTitleFontSize: CGFloat = DeviceFamily.current.isWiderOrEqualThan(.iPhone6Plus) ? 20.0 : 18.0
            static let titleFontSize: CGFloat = DeviceFamily.current.isWiderOrEqualThan(.iPhone6Plus) ? 23.0 : 21.0
            static let buttonFontSize: CGFloat = 15.0
            static let reducerSize: CGFloat = 10.0
            
            static let smallHeight: CGFloat = 27
            static let maxCharactersPerLine: Int = 26
        }
        
        static let buttonTintColor = UIColor(red: 255, green: 63, blue: 55)
        static let titleTextColor = UIColor.lgBlack
        static let buttonFont = UIFont.systemFont(ofSize: Constants.buttonFontSize, weight: .bold)
        static let titleFont = UIFont.systemFont(ofSize: Constants.titleFontSize, weight: .bold)
    }
    
    enum Layout {
        static let sideMargin: CGFloat = 15
        static let titleWidthMultiplier: CGFloat = 0.65
        static let verticalMargin: CGFloat = Metrics.bigMargin
        
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
        
        static func headerSize(with title: String, containerWidth: CGFloat, maxLines: Int?) -> CGSize{
            let height = title.heightForWidth(width: containerWidth,
                                                     maxLines: maxLines,
                                                     withFont: SectionTitleHeaderView.Style.titleFont)
            return CGSize(width: containerWidth,
                          height: height + 2 * Metrics.shortMargin)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatedHeight = frame.height
    }

    private func setupConstraints() {
        let constraints = [
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: Layout.sideMargin),
            titleLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: Layout.titleWidthMultiplier),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            hitboxArea.rightAnchor.constraint(equalTo: rightAnchor),
            hitboxArea.heightAnchor.constraint(equalToConstant: Layout.Hitbox.height),
            hitboxArea.widthAnchor.constraint(equalToConstant: Layout.Hitbox.width),
            hitboxArea.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            arrowIcon.rightAnchor.constraint(equalTo: hitboxArea.rightAnchor, constant: -Layout.sideMargin),
            arrowIcon.centerYAnchor.constraint(equalTo: hitboxArea.centerYAnchor),
            
            arrowIcon.leftAnchor.constraint(
                equalTo: buttonTitle.rightAnchor, constant: Layout.ArrowIcon.leftMargin),
            buttonTitle.centerYAnchor.constraint(equalTo: arrowIcon.centerYAnchor)
        ]
        centerButtonConstraint = constraints[2]
        constraints.activate()
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
    
    // Scale factor calculation:
    // R = MaxSize - MinSize
    // FinalSize = (R * ScaleFactor) + MinSize
    func setScale(factor: CGFloat) {
        let sizeDiff = Style.Constants.titleFontSize - Style.Constants.minTitleFontSize
        titleLabel.font = titleLabel.font.withSize(
            (sizeDiff * (1.0 - factor)) + Style.Constants.minTitleFontSize
        )
        
        guard let text = titleLabel.text, text.count <= Style.Constants.maxCharactersPerLine
            else { return }
        frame = CGRect(x: frame.origin.x,
                       y: -(Style.Constants.reducerSize * factor),
                       width: frame.width,
                       height: frame.height)
        centerButtonConstraint?.constant = (Style.Constants.reducerSize / 2) * factor
    }
}

