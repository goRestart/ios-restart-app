import UIKit
import LGComponents

final class P2PPaymentsNumberView: UIView {
    enum State {
        case number(Int)
        case success
        case fail
    }

    private let numberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemHeavyFont(size: 12)
        label.textColor = UIColor.primaryColor
        label.textAlignment = .center
        return label
    }()

    private let iconImageView: UIImageView = {
        let iconImageView = UIImageView()
        iconImageView.tintColor = UIColor.white
        return iconImageView
    }()

    private let backgrounView: UIView = UIView()
    private let state: State

    init(state: State) {
        self.state = state
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        addSubviewsForAutoLayout([numberLabel, iconImageView])
        layer.borderColor = UIColor.grayRegular.cgColor
        clipsToBounds = true
        setupConstraints()
        configureForCurrentState()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            numberLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            numberLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 18),
            iconImageView.heightAnchor.constraint(equalToConstant: 18),
        ])
    }

    private func configureForCurrentState() {
        switch state {
        case .number(let number):
            numberLabel.text = "\(number)"
            layer.borderWidth = 4
            layer.cornerRadius = 16
            backgroundColor = UIColor.white
            numberLabel.isHidden = false
            iconImageView.isHidden = true
        case .success:
            iconImageView.image = R.Asset.P2PPayments.icCheck.image
            layer.borderWidth = 0
            layer.cornerRadius = 14
            backgroundColor = UIColor.p2pPaymentsPositive
            numberLabel.isHidden = true
            iconImageView.isHidden = false
        case .fail:
            iconImageView.image = R.Asset.P2PPayments.close.image.withRenderingMode(.alwaysTemplate)
            layer.borderWidth = 0
            layer.cornerRadius = 14
            backgroundColor = UIColor.primaryColor
            numberLabel.isHidden = true
            iconImageView.isHidden = false
        }
    }

    override var intrinsicContentSize: CGSize {
        switch state {
        case .number:
            return CGSize(width: 32, height: 32)
        case .success, .fail:
            return CGSize(width: 28, height: 28)
        }
    }
}
