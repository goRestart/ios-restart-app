import Foundation
import UIKit
import LGCoreKit
import LGComponents

final class ListingDeckActionView: UIView {

    private struct Layout {
        struct Height {
            static let actionButton: CGFloat = 48.0
            static let blank: CGFloat = Metrics.shortMargin
        }
    }

    let actionButton: LetgoButton = {
        let button = LetgoButton(withStyle: .terciary)
        button.setTitle(R.Strings.productMarkAsSoldButton, for: .normal)
        return button
    }()

    private let separator: UIView = {
        let separator = UIView()
        separator.applyDefaultShadow()
        separator.layer.shadowOffset = CGSize(width: 0, height: -1)
        return separator
    }()

    convenience init() { self.init(frame: .zero) }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    private func setup() {
        addSubviewsForAutoLayout([actionButton, separator])
        [
            actionButton.heightAnchor.constraint(equalToConstant: Layout.Height.actionButton),
            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.margin),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.margin),
            actionButton.topAnchor.constraint(equalTo: topAnchor, constant: Metrics.shortMargin),

            separator.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: Metrics.shortMargin),
            separator.heightAnchor.constraint(equalToConstant: 1),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor)
        ].activate()
        setupUI()
    }

    func updatePrivateActionsWith(actionsAlpha: CGFloat) {
        actionButton.alpha = actionsAlpha
        separator.alpha = actionsAlpha
    }

    private func setupUI() {
        backgroundColor = .clear
        separator.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        separator.isHidden = true
        bringSubview(toFront: actionButton)
    }
    
}
