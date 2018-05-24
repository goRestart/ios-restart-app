import Foundation
import LGComponents

class MLPostingOnboardingView: UIView {
    private let contentView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let spacerView = UIView()
    private let button = LetgoButton()
    
    var buttonBlock: (() -> ())?
    
    init() {
        super.init(frame: CGRect.zero)
        setupUI()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners()
    }
    
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        contentView.backgroundColor = UIColor.white
        iconImageView.image = #imageLiteral(resourceName: "ml_icon_red_big")
        titleLabel.font = UIFont.boldSystemFont(ofSize: 23)
        titleLabel.textColor = UIColor.primaryColor
        titleLabel.text = R.Strings.mlOnboardingNewText
        titleLabel.textAlignment = .center
        descriptionLabel.font = UIFont.boldSystemFont(ofSize: 23)
        descriptionLabel.text = R.Strings.mlOnboardingDescriptionText
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        spacerView.backgroundColor = UIColor.grayLight
        button.setStyle(.primary(fontSize: .big))
        button.setTitle(R.Strings.mlOnboardingOkText, for: .normal)
        button.addTarget(self, action: #selector(didPressedButton), for: .touchUpInside)
    }
    
    private func setupLayout() {
        addSubviewForAutoLayout(contentView)
        contentView.addSubviewsForAutoLayout([iconImageView, titleLabel, descriptionLabel, spacerView, button])
        
        contentView.layout(with: self)
            .centerX()
            .centerY()
            .leading(by: Metrics.veryBigMargin*2, relatedBy: .greaterThanOrEqual)
            .trailing(by: -Metrics.veryBigMargin*2, relatedBy: .lessThanOrEqual)
            .top(by: Metrics.veryBigMargin*2, relatedBy: .greaterThanOrEqual)
            .bottom(by: -Metrics.veryBigMargin*2, relatedBy: .lessThanOrEqual)
        
        iconImageView.layout(with: contentView)
            .centerX()
            .top(by: 30)
        
        titleLabel.layout(with: iconImageView).below(by: 30)
        titleLabel.layout(with: contentView)
            .leading(by: Metrics.veryBigMargin)
            .trailing(by: -Metrics.veryBigMargin)
        
        descriptionLabel.layout(with: titleLabel).below()
        descriptionLabel.layout(with: contentView)
            .leading(by: Metrics.veryBigMargin)
            .trailing(by: -Metrics.veryBigMargin)
        
        spacerView.layout().height(1)
        spacerView.layout(with: descriptionLabel).below(by: Metrics.veryBigMargin)
        spacerView.layout(with: contentView)
            .leading(by: Metrics.veryBigMargin)
            .trailing(by: -Metrics.veryBigMargin)
        
        button.layout().height(44)
        button.layout(with: spacerView).below(by: Metrics.veryBigMargin)
        button.layout(with: contentView)
            .leading(by: Metrics.veryBigMargin)
            .trailing(by: -Metrics.veryBigMargin)
            .bottom(by: -Metrics.veryBigMargin)
    }
    
    private func roundCorners() {
        contentView.layer.cornerRadius = 15
        button.layer.cornerRadius = button.frame.height / 2
    }
    
    @objc func didPressedButton() {
        buttonBlock?()
    }
}
