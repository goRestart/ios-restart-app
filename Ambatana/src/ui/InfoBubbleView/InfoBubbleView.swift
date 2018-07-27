import UIKit
import LGComponents

final class InfoBubbleView: UIView {
    
    enum Style {
        case light
        case reddish
    }
    
    
    static let bubbleHeight: CGFloat = 30
    
    let style: Style
    
    //  MARK: - Subviews
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.spacing = Metrics.shortMargin
        return stackView
    }()
    
    let title: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(size: 14)
        label.textAlignment = .center
        label.set(accessibilityId: .mainListingsInfoBubbleLabel)
        return label
    }()
    
    private let arrow: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()
    
    init(style: Style) {
        self.style = style
        super.init(frame: .zero)
        setupView()
        setupSubviews()
        setupConstraints()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //  MARK: - Private methods
    
    private func setupView() {
        switch style {
        case .light:
            backgroundColor = .white
            title.textColor = .black
            arrow.image = R.Asset.IconsButtons.downChevronRed.image
        case .reddish:
            backgroundColor = .primaryColor
            title.textColor = .white
            arrow.image = R.Asset.Monetization.grayChevronUp.image // TODO RETENTION: asset change when zeplin ready
        }
        layer.cornerRadius = InfoBubbleView.bubbleHeight/2
        applyShadow(withOpacity: 0.12, radius: 8.0)
    }
    
    private func setupSubviews() {
        addSubviewForAutoLayout(stackView)
        stackView.addArrangedSubview(title)
        stackView.addArrangedSubview(arrow)
    }
    
    private func setupConstraints() {
        stackView.layout(with: self).fillVertical().fillHorizontal(by: Metrics.bigMargin)
    }
    
    override var intrinsicContentSize: CGSize {
        let width = title.intrinsicContentSize.width + arrow.intrinsicContentSize.width + Metrics.shortMargin + 2*Metrics.bigMargin
        return CGSize(width: width, height: InfoBubbleView.bubbleHeight)
    }
}
