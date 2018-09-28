import UIKit
import LGComponents
import RxSwift

final class LGTapToActionView: UIControl {
    
    static let viewHeight: CGFloat = CGFloat(44)
    
    // MARK: - Subviews
    
    private let icon: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .center
        return icon
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: Layout.titleFontSize,
                                       weight: UIFont.Weight.bold)
        label.textColor = .grayLighter
        label.minimumScaleFactor = 0.7
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let disclosure: UIView = {
        let disclosure = UIImageView(image: R.Asset.IconsButtons.icDisclosureTapToAction.image)
        disclosure.tintColor = .white
        return disclosure
    }()
    
    // MARK: - Lifecycle
    
    init(viewModel: TapToActionViewModel,
         configuration: TapToActionUIConfiguration) {
        super.init(frame: .zero)
        populate(viewModel)
        setupUI(with: configuration)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private
    
    private func populate(_ viewModel: TapToActionViewModel) {
        icon.image = viewModel.icon
        titleLabel.text = viewModel.title
    }
    
    private func setupUI(with configuration: TapToActionUIConfiguration) {
        cornerRadius = Layout.cornerRadius
        backgroundColor = configuration.backgroundColor
        titleLabel.textColor = configuration.titleColor
        addSubViews()
        addConstraints()
    }
    
    private func addSubViews() {
        addSubviewsForAutoLayout([icon, titleLabel, disclosure])
    }
    
    private func addConstraints() {
        let constraints = [icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.bigMargin),
                           icon.widthAnchor.constraint(equalToConstant: Layout.iconSize),
                           icon.centerYAnchor.constraint(equalTo: centerYAnchor),
                           
                           titleLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: Metrics.margin),
                           titleLabel.trailingAnchor.constraint(equalTo: disclosure.leadingAnchor, constant: -Metrics.margin),
                           titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                           
                           disclosure.widthAnchor.constraint(equalToConstant: Layout.disclosureSize),
                           disclosure.heightAnchor.constraint(equalToConstant: Layout.disclosureSize),
                           disclosure.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.shortMargin),
                           disclosure.centerYAnchor.constraint(equalTo: centerYAnchor)]
        constraints.activate()
    }
    
}

private enum Layout {
    static let cornerRadius = CGFloat(6)
    static let iconSize = CGFloat(35)
    static let disclosureSize = CGFloat(16)
    static let titleFontSize = CGFloat(16)
}
