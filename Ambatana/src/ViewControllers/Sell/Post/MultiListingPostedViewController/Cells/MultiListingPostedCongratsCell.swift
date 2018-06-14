
import UIKit
import LGComponents

final class MultiListingPostedCongratsCell: UICollectionViewCell, ReusableCell {
    
    private struct Layout {
        static let actionButtonHeight: CGFloat = 50.0
        static let actionButtonWidth: CGFloat = 240.0
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.blackText
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.boldSystemFont(ofSize: 27.0)
        label.numberOfLines = 1
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.grayDark
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.systemFont(ofSize: 15.0)
        label.numberOfLines = 2
        return label
    }()
    
    private let actionButton: LetgoButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: ButtonFontSize.medium))
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
        return button
    }()
    
    private var tapAction: (() -> Void)?
    
    
    // MARK:- Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupActionButton()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK:- Public methods
    
    func setup(withTitle title: String?,
               subtitle: String?,
               actionButtonText: String?,
               tapAction: @escaping (() -> Void)) {
        self.tapAction = tapAction
        titleLabel.text = title
        subtitleLabel.text = subtitle
        actionButton.setTitle(actionButtonText,
                              for: .normal)
    }
    
    
    // MARK:- Layout & Friends
    
    private func setupActionButton() {
        actionButton.addTarget(self,
                               action: #selector(actionButtonTapped),
                               for: .touchUpInside)
        actionButton.set(accessibilityId: .postingInfoMainButton)
    }
    
    private func setupConstraints() {
        addSubviewsForAutoLayout([
            titleLabel,
            subtitleLabel,
            actionButton
            ])
        
        titleLabel.layout(with: self)
            .fillHorizontal(by: Metrics.shortMargin)
            .top(to: .top, by: Metrics.margin)
        
        subtitleLabel.layout(with: self)
            .fillHorizontal(by: Metrics.shortMargin)
        
        subtitleLabel.layout(with: titleLabel)
            .top(to: .bottom, by: Metrics.shortMargin)
        
        actionButton.layout(with: self)
            .centerX(to: .centerX)
            .bottom(to: .bottom, by: -(Metrics.veryBigMargin*2))
        
        actionButton.layout()
            .height(Layout.actionButtonHeight)
            .width(Layout.actionButtonWidth)
        
        actionButton.layout(with: subtitleLabel).top(to: .bottom,
                                                     by: (Metrics.veryBigMargin*2),
                                                     relatedBy: .greaterThanOrEqual,
                                                     priority: .defaultLow)
    }
    
    @objc private func actionButtonTapped() {
        tapAction?()
    }
}
